public class LoanDocuSignDocumentListController {
    
    public String caseId { get; set; }
    public String caseNumber { get; set; }
    public List<DocuSignWrapper> documentList { get; set; }
    
    // ---------------------------------------------------------
    // HEAP GUARD (Moved to top-level class to allow 'static')
    // ---------------------------------------------------------
    private static final Decimal HEAP_THRESHOLD = 0.98; // stop at 90% of limit
    
    private static Boolean canFit(Integer extraBytes) {
        Integer usedHeap  = Limits.getHeapSize();
        Integer heapLimit = Limits.getLimitHeapSize();
        // Renamed 'limit' to 'heapLimit' because 'limit' is a reserved Apex keyword
        return (usedHeap + extraBytes) < (heapLimit * HEAP_THRESHOLD);
    }
    // ---------------------------------------------------------
    
    @AuraEnabled(cacheable=false)
    public static List<DocuSignWrapper> getDocumentList(Id caseId, Boolean fetchAllDocument){
        // ----- UNCHANGED FROM YOUR PRODUCTION CODE -----
        System.debug('===== getDocumentList START =====');
        System.debug('caseId: ' + caseId);
        System.debug('fetchAllDocument: ' + fetchAllDocument);

        List<DocuSignWrapper> documentList = new List<DocuSignWrapper>();
        
        Map<Id, Content__c> docMap = new Map<Id, Content__c>();
        System.debug('Initialized documentList and docMap');

        List<ContentDocumentLink> links = new List<ContentDocumentLink>();

        Case caseObj = [
            SELECT Id, CaseNumber, Account.CIF__pc
            FROM Case
            WHERE Id = :caseId
        ];

        System.debug('Case retrieved: ' + caseObj);
        System.debug('Case Id: ' + caseObj.Id);
        System.debug('Case Number: ' + caseObj.CaseNumber);
        System.debug('Account CIF: ' + caseObj.Account.CIF__pc);

        if(fetchAllDocument){
            System.debug('fetchAllDocument = TRUE. Fetching Content__c records for Case.');

            for(Content__c cnt : [
                SELECT Id, Name, Case__c, Document_Model__c, CreatedBy.Name,
                       CreatedDate, Person__r.Name, LastModifiedDate,
                       Document_Type__c, Case__r.CaseNumber, Region_Flag__c
                FROM Content__c
                WHERE Case__c = :caseId
            ]){
                System.debug('Content__c record found: ' + cnt);
                System.debug('Content__c Id: ' + cnt.Id);
                System.debug('Content__c Name: ' + cnt.Name);
                System.debug('Content__c Case Id: ' + cnt.Case__c);
                System.debug('Content__c Document Model: ' + cnt.Document_Model__c);
                System.debug('Content__c Document Type: ' + cnt.Document_Type__c);
                System.debug('Content__c Region Flag: ' + cnt.Region_Flag__c);

                docMap.put(cnt.Id, cnt);
            }

            System.debug('Total Content__c records found: ' + docMap.size());

            if(!docMap.isEmpty()){
                System.debug('Fetching ContentDocumentLink records for Content__c Ids: ' + docMap.keySet());

                links = [
                    SELECT Id, LinkedEntityId, ContentDocumentId,ContentDocument.CreatedDate,
                           ContentDocument.Title, ContentDocument.FileExtension,ContentDocument.LastModifiedDate,
                           ContentDocument.ContentSize, ContentDocument.CreatedBy.Name
                    FROM ContentDocumentLink
                    WHERE LinkedEntityId IN :docMap.keySet() 
                ];

                System.debug('Total ContentDocumentLink records found: ' + links.size());
            }
            else {
                System.debug('No Content__c records found. ContentDocumentLink query will not be executed.');
            }
        }
        else {
            System.debug('fetchAllDocument = FALSE. Fetching ContentDocumentLink records directly for Case.');

            links = [
                SELECT Id, LinkedEntityId, ContentDocumentId,
                       ContentDocument.Title, ContentDocument.FileExtension,
                       ContentDocument.ContentSize,
                       ContentDocument.LastModifiedDate, ContentDocument.CreatedDate,
                       ContentDocument.CreatedBy.Name
                FROM ContentDocumentLink
                WHERE LinkedEntityId = :caseId
            ];

            System.debug('Total ContentDocumentLink records found: ' + links.size());
        }

        if(links.isEmpty()){
            System.debug('No ContentDocumentLink records found. Returning empty documentList.');
            System.debug('===== getDocumentList END =====');
            return documentList;
        }

        System.debug('Processing ' + links.size() + ' ContentDocumentLink records.');

        Integer sno = 1;

        for(ContentDocumentLink cdl : links){
            System.debug('--- Processing ContentDocumentLink ---');
            System.debug('Sequence No: ' + sno);
            System.debug('ContentDocumentLink Id: ' + cdl.Id);
            System.debug('LinkedEntityId: ' + cdl.LinkedEntityId);
            System.debug('ContentDocumentId: ' + cdl.ContentDocumentId);
            System.debug('Document Title: ' + cdl.ContentDocument.Title);
            System.debug('File Extension: ' + cdl.ContentDocument.FileExtension);
            System.debug('Content Size: ' + cdl.ContentDocument.ContentSize);

            Content__c contentRecord = docMap.get(cdl.LinkedEntityId);

            System.debug('Mapped Content__c record: ' + contentRecord);

            documentList.add(
                new DocuSignWrapper(
                    sno,
                    contentRecord,
                    cdl,
                    caseObj
                )
            );

            System.debug('DocuSignWrapper added. Current documentList size: ' + documentList.size());

            sno++;
        }

        System.debug('Final documentList size: ' + documentList.size());
        System.debug('Final documentList: ' + documentList);
        System.debug('===== getDocumentList END =====');

        return documentList;
    }

    @AuraEnabled(cacheable=true)
    public static List<fileDataWrapper> getFileData(String caseId) {
        List<fileDataWrapper> fileData = new List<fileDataWrapper>();

        // 1) Calculation Summary (small, always first)
        String summary = getCalculationSummaryPDF(caseId);
        if (String.isNotBlank(summary) && canFit(summary.length())) {
            fileData.add(new fileDataWrapper('CalculationSummary', summary));
        } else {
            System.debug('CalculationSummary skipped – not enough heap.');
            return fileData;
        }
        
        // 2) DocuSign metadata (light)
        List<DocuSignWrapper> docList = new List<DocuSignWrapper>();
        for(DocuSignWrapper doc : getDocumentList(caseId, true)){
            if(doc.documentType != 'DocuSign Document'){
                docList.add(doc);
            }
        }
        docList.addAll(getDocumentList(caseId, false));
        
        // 3) Loan Summary (may be large)
        String loanSummary = getLoanPaymentSummary(caseId);
        if (String.isNotBlank(loanSummary) && canFit(loanSummary.length())) {
            fileData.add(new fileDataWrapper('LoanSummary', loanSummary));
        } else {
            System.debug('LoanSummary skipped – not enough heap.');
        }
        
        if(docList.isEmpty()){
            return fileData;
        }
        
        // 4) DocuSign PDFs – loaded incrementally
        Set<Id> contentDocumentIds = new Set<Id>();
        for(DocuSignWrapper contentDoc : docList){
            contentDocumentIds.add(contentDoc.contentDocumentId);
        }
        
        // 4a) Query IDs only (no VersionData) to avoid initial heap spike
        List<ContentVersion> metaVersions = [
            SELECT Id
            FROM ContentVersion
            WHERE ContentDocumentId IN :contentDocumentIds
              AND FileExtension = 'pdf'
            ORDER BY CreatedDate DESC
        ];
        
        List<Id> versionIds = new List<Id>();
        for(ContentVersion v : metaVersions){
            versionIds.add(v.Id);
        }
        
        // 4b) Load blobs in small batches, stopping at ~90% heap limit
        final Integer BATCH_SIZE = 5;
        Integer idx = 0;
        
        while (idx < versionIds.size()) {
            List<Id> batchIds = new List<Id>();
            Integer endIdx = Math.min(idx + BATCH_SIZE, versionIds.size());
            for (Integer k = idx; k < endIdx; k++) {
                batchIds.add(versionIds[k]);
            }
            idx = endIdx;
            
            Map<Id, ContentVersion> batchMap = new Map<Id, ContentVersion>([
                SELECT Id, VersionData
                FROM ContentVersion
                WHERE Id IN :batchIds
            ]);
            
            Boolean stop = false;
            
            for (Id vid : batchIds) {
                ContentVersion cv = batchMap.get(vid);
                if (cv == null) continue;
                
                // Base64 size is roughly 1.33x the blob size
                Integer estimatedBase64 = (cv.VersionData.size() * 4) / 3 + 4;
                
                if (!canFit(estimatedBase64)) {
                    System.debug('Heap guard triggered. Stopping at ' + fileData.size() + ' files.');
                    stop = true;
                    break; // Exits the inner loop
                }
                
                String base64Data = EncodingUtil.base64Encode(cv.VersionData);
                fileData.add(new fileDataWrapper('DocuSign', base64Data));
            }
            
            if (stop) break; // Exits the outer while loop
        }
        
        return fileData;
    }
    
    public static String getLoanPaymentSummary(String caseId){
        PageReference pdfPage = Page.loanPaymentScheduleVF;
        String encodedCaseId = EncodingUtil.base64Encode(Blob.valueOf(caseId));
        String encodedPageName = EncodingUtil.base64Encode(Blob.valueOf('case'));
        pdfPage.getParameters().put('caseId', encodedCaseId);
        pdfPage.getParameters().put('pageName',encodedPageName);
        Blob pdfBlob;
        
        try {
            pdfBlob = pdfPage.getContentAsPDF();
            String base64Pdf = EncodingUtil.base64Encode(pdfBlob);
            return base64Pdf;
        } catch (Exception e) {
            System.debug('Error -->'+e.getMessage());
            System.debug('Error Line -->'+e.getLineNumber());
            return '';
        }
    }
    
    public static String getCalculationSummaryPDF(String caseId){
        PageReference pdfPage = Page.LoanCalculationSummary;
        pdfPage.getParameters().put('id', caseId);
        Blob pdfBlob;
        
        try {
            pdfBlob = pdfPage.getContentAsPDF();
        } catch (Exception e) {
            System.debug('Error -->'+e.getMessage());
            System.debug('Error Line -->'+e.getLineNumber());
        }
        
        String base64Pdf = EncodingUtil.base64Encode(pdfBlob);
        return base64Pdf;
    }
    
    public static String getDocuSignPDF(String caseId){
        PageReference pdfPage = Page.VF02_CalculationSummaryReportPdf;
        pdfPage.getParameters().put('id', caseId);
        Blob pdfBlob;
        
        try {
            pdfBlob = pdfPage.getContentAsPDF();
        } catch (Exception e) {
            System.debug('Error -->'+e.getMessage());
            System.debug('Error Line -->'+e.getLineNumber());
        }
        
        String base64Pdf = EncodingUtil.base64Encode(pdfBlob);
        return base64Pdf;
    }
    
    public class fileDataWrapper {
        @AuraEnabled
        public String fileTitle { get; set; }
        
        @AuraEnabled
        public String fileData { get; set; }
        
        public fileDataWrapper(String title, String fData){
            this.fileTitle = title;
            this.fileData = fData;
        }
    }
    
    public class DocuSignWrapper {
        @AuraEnabled
        public Integer sno { get; set; }
        
        @AuraEnabled
        public String fileTitle { get; set; }
        
        @AuraEnabled
        public String fileExt { get; set; }
        
        @AuraEnabled
        public String caseNumber { get; set; }
        
        @AuraEnabled
        public String contentName { get; set; }
        
        @AuraEnabled
        public String regionFlag { get; set; }
        
        @AuraEnabled
        public String documentModel { get; set; }
        
        @AuraEnabled
        public String contentDocumentId { get; set; }
        
        @AuraEnabled
        public String contentDocumentLinkId { get; set; }
        
        @AuraEnabled
        public String ownerName { get; set; }
        
        @AuraEnabled
        public String fileSize { get; set; }
        
        @AuraEnabled
        public String documentType { get; set; }
        
        @AuraEnabled
        public Date lastModifiedDate { get; set; }
        
        @AuraEnabled
        public Date createdDate { get; set; }
        
        @AuraEnabled
        public String signerName { get; set; }
        
        @AuraEnabled
        public String fileName {
            get {
                return fileTitle;
            }
            private set;
        }
        
        @AuraEnabled
        public String documentURL {
            get {
                return  URL.getOrgDomainUrl().toExternalForm() + '/lightning/r/ContentDocument/' + contentDocumentId + '/view#/';
            }
            private set;
        }

        public DocuSignWrapper(Integer sno,Content__c contentObj,ContentDocumentLink cdl,Case caseObj) {
            this.sno = sno;
            this.documentType = contentObj == null ? 'DocuSign Document' : contentObj.Document_Type__c;
            this.fileTitle = cdl.ContentDocument.Title;
            this.fileExt = cdl.ContentDocument.FileExtension;
            this.contentDocumentId = cdl.ContentDocumentId;
            this.contentDocumentLinkId = cdl.Id;
            this.caseNumber = caseObj.CaseNumber;
            this.contentName = contentObj == null ? 'Signed' : contentObj.Name;
            this.regionFlag = contentObj == null ? '' : contentObj.Region_Flag__c;
            this.documentModel = contentObj == null ? '' : contentObj.Document_Model__c;
            this.ownerName = contentObj == null ? cdl.ContentDocument.CreatedBy.Name : contentObj.CreatedBy.Name;
            this.fileSize = ((Decimal)cdl.ContentDocument.ContentSize / 1024 / 1024).setScale(2) + ' MB';
            this.lastModifiedDate = contentObj == null ? cdl.ContentDocument.LastModifiedDate.date() : contentObj.LastModifiedDate.date();
            this.createdDate = contentObj == null ? cdl.ContentDocument.CreatedDate.date() : contentObj.CreatedDate.date();
            this.signerName = caseObj.Account.CIF__pc;
            
            Map<String,String> partialFileNames = new Map<String,String>();
            partialFileNames.put('personalloanstermsandcondition','Personal Loans Terms and Condition');
            partialFileNames.put('taxinvoice','Tax Invoice');
            partialFileNames.put('ilamanagercheque','ila Manager Cheque');
            partialFileNames.put('certificateofcompletion','Certificate Of Completion');
            partialFileNames.put('promissorynote','Promissory Note - ila');
            partialFileNames.put('loandetailedrepaymentscheduleform','Loan Detailed Repayment Schedule Form');
            partialFileNames.put('personalloanagreemen','Personal Loan Agreemen');
            partialFileNames.put('loanapplicationform','Loan Application Form');
            
            for(String key :partialFileNames.keyset()){
                String fName = cdl.ContentDocument.Title.toLowerCase().trim();
                fName = fName.replaceAll('\\s','').replaceAll('\'s','').replace('_','');
                if(fName.contains(key)){
                    if(contentObj == null){
                        this.contentName = partialFileNames.get(key);
                    }
                    break;
                }
            }
        }
    }
}