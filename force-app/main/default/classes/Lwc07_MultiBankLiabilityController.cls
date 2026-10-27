public without sharing class Lwc07_MultiBankLiabilityController {

    private static final String DOCUMENT_VERIFIER_OBL_QUEUE = 'Loan_Document_Verifier_OBL';
    private static final String OPERATIONS_QUEUE = 'Loan_Operations_Team';

    @AuraEnabled(cacheable=true)
    public static InitializationResponse getInitializationData(Id recordId) {
        if (recordId == null) {
            throw new AuraHandledException('Case Id cannot be null.');
        }

        try {
            Case caseRecord = [ SELECT Id, OwnerId FROM Case WHERE Id = :recordId LIMIT 1];
            List<CaseAnnex__c> annexes = [ SELECT Id,cx_ln_Requested_MultiBankLiabilities__c,cx_ln_Approved_Buyout_Amount__c FROM CaseAnnex__c WHERE Case__c = :recordId LIMIT 1];

            if (annexes.isEmpty()) {
                throw new AuraHandledException('No Case Annex record was found for this Case.');
            }

            InitializationResponse response = new InitializationResponse();
            response.caseAnnexId = annexes[0].Id;
            response.multiBankLiabilitiesJson = annexes[0].cx_ln_Requested_MultiBankLiabilities__c;
            response.approvedBuyoutAmount = annexes[0].cx_ln_Approved_Buyout_Amount__c;
            response.entityOptions = getActiveEntityOptions();
            response.permissions = resolvePermissions(caseRecord.OwnerId);

            return response;
        } catch (AuraHandledException e) {
            throw e;
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR,'Lwc07_MultiBankLiabilityController.getInitializationData: ' +e.getMessage() + '\n' + e.getStackTraceString());
            throw new AuraHandledException('An error occurred while loading Multi-Bank Liabilities.');
        }
    }

    @AuraEnabled
    public static SaveResponse saveMultiBankLiabilities(Id recordId, String liabilitiesJson) {
        if (recordId == null) {
            throw new AuraHandledException('Case Id cannot be null.');
        }
        if (String.isBlank(liabilitiesJson)) {
            throw new AuraHandledException('Multi-Bank Liability JSON cannot be empty.');
        }

        try {
            Case caseRecord = [SELECT Id, OwnerId FROM Case WHERE Id = :recordId LIMIT 1 ];

            PermissionsResponse permissions = resolvePermissions(caseRecord.OwnerId);
            if (!permissions.canModifyTable) {
                throw new AuraHandledException('You are not authorized to modify Multi-Bank Liabilities for this Case.');
            }

            List<CaseAnnex__c> annexes = [SELECT Id, cx_ln_Requested_MultiBankLiabilities__c FROM CaseAnnex__c WHERE Case__c = :recordId LIMIT 1 FOR UPDATE];

            if (annexes.isEmpty()) {
                throw new AuraHandledException('No Case Annex record was found for this Case.');
            }

            CaseAnnex__c annex = annexes[0];
            Set<String> activeEntities = getActiveEntityNames();

            List<Map<String, Object>> normalizedRows = validateAndNormalizeRows( liabilitiesJson, annex.cx_ln_Requested_MultiBankLiabilities__c, permissions, activeEntities);

            Decimal approvedBuyoutAmount = calculateApprovedBuyoutAmount(normalizedRows);
            String normalizedJson = JSON.serialize(normalizedRows);

            CaseAnnex__c updateAnnex = new CaseAnnex__c(Id = annex.Id,cx_ln_Requested_MultiBankLiabilities__c = normalizedJson,cx_ln_Approved_Buyout_Amount__c = approvedBuyoutAmount);
            update updateAnnex;

            SaveResponse response = new SaveResponse();
            response.multiBankLiabilitiesJson = normalizedJson;
            response.approvedBuyoutAmount = approvedBuyoutAmount;
            return response;
        } catch (AuraHandledException e) {
            throw e;
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR,'Lwc07_MultiBankLiabilityController.saveMultiBankLiabilities: ' +e.getMessage() + '\n' + e.getStackTraceString());
            //throw new AuraHandledException('An error occurred while saving Multi-Bank Liabilities.');
            throw new AuraHandledException(e.getMessage());
        }
    }

    private static List<EntityOption> getActiveEntityOptions() {
        List<EntityOption> options = new List<EntityOption>();

        for (Loan_MultiBankLiability__mdt config : [SELECT EntityBankName__c, PaymentType__c FROM Loan_MultiBankLiability__mdt WHERE IsActive__c = true ORDER BY EntityBankName__c]) {
            if (String.isBlank(config.EntityBankName__c)) {
                continue;
            }

            EntityOption option = new EntityOption();
            option.label = config.EntityBankName__c.trim();
            option.value = config.EntityBankName__c.trim();
            option.paymentType = config.PaymentType__c;
            options.add(option);
        }

        return options;
    }

    private static Set<String> getActiveEntityNames() {
        Set<String> names = new Set<String>();
        for (Loan_MultiBankLiability__mdt config : [SELECT EntityBankName__c FROM Loan_MultiBankLiability__mdt WHERE IsActive__c = true]) {
            if (!String.isBlank(config.EntityBankName__c)) {
                names.add(normalizeEntityKey(config.EntityBankName__c));
            }
        }
        return names;
    }

    private static PermissionsResponse resolvePermissions(Id caseOwnerId) {
        Set<String> targetQueueDeveloperNames = new Set<String>{DOCUMENT_VERIFIER_OBL_QUEUE,OPERATIONS_QUEUE};

        Map<String, Group> queuesByDeveloperName = new Map<String, Group>();
        for (Group queueGroup : [SELECT Id, DeveloperName FROM Group WHERE Type = 'Queue' AND DeveloperName IN :targetQueueDeveloperNames]) {
            queuesByDeveloperName.put(queueGroup.DeveloperName, queueGroup);
        }

        Id documentVerifierOblQueueId = queuesByDeveloperName.containsKey(DOCUMENT_VERIFIER_OBL_QUEUE) ? queuesByDeveloperName.get(DOCUMENT_VERIFIER_OBL_QUEUE).Id : null;
        Id operationsQueueId = queuesByDeveloperName.containsKey(OPERATIONS_QUEUE) ? queuesByDeveloperName.get(OPERATIONS_QUEUE).Id : null;

        Boolean isDocumentVerifierOblContext = isOwnerInQueueContext(caseOwnerId,documentVerifierOblQueueId);
        Boolean isOperationsContext = isOwnerInQueueContext(caseOwnerId,operationsQueueId);

        Profile currentProfile = [SELECT PermissionsModifyAllData FROM Profile WHERE Id = :UserInfo.getProfileId() LIMIT 1];
        Boolean isAdmin = currentProfile.PermissionsModifyAllData;

        PermissionsResponse result = new PermissionsResponse();
        result.isAdmin = isAdmin;
        result.isDocumentVerifierOblContext = isDocumentVerifierOblContext;
        result.isOperationsContext = isOperationsContext;

        result.canEditEntityOutstanding = /*isAdmin ||*/ isDocumentVerifierOblContext;//toCheck : uncomment
        result.showLiabilityId = /*isAdmin ||*/ !isDocumentVerifierOblContext;
        result.canEditLiabilityId = /*isAdmin ||*/ isOperationsContext;//toCheck : uncomment
        result.canAddRow = /*isAdmin ||*/ isDocumentVerifierOblContext;//toCheck : uncomment
        result.canDeleteRow = isDocumentVerifierOblContext;
        result.canModifyTable = isAdmin || isDocumentVerifierOblContext || isOperationsContext;

        return result;
    }

    private static Boolean isOwnerInQueueContext(Id ownerId,Id queueId) {
        if (ownerId == null || queueId == null) { return false;}
        if (ownerId == queueId) { return true;}
        if (!String.valueOf(ownerId).startsWith('005')) { return false;}
        return isUserMemberOfQueue(ownerId,queueId);
    }

    public static Boolean isUserMemberOfQueue(Id userId,Id queueId) {
        List<GroupMember> memberships = [SELECT Id FROM GroupMember WHERE GroupId = :queueId AND UserOrGroupId = :userId LIMIT 1];
        return !memberships.isEmpty();
    }

    private static List<Map<String, Object>> validateAndNormalizeRows(String submittedJson,String persistedJson,PermissionsResponse permissions,Set<String> activeEntities) {
        Map<String, String> paymentTypeByEntity = new Map<String, String>();
        for (Loan_MultiBankLiability__mdt config : [SELECT EntityBankName__c, PaymentType__c FROM Loan_MultiBankLiability__mdt WHERE IsActive__c = true]) {
            if (!String.isBlank(config.EntityBankName__c)) {
                paymentTypeByEntity.put(
                    normalizeEntityKey(config.EntityBankName__c),
                    config.PaymentType__c
                );
            }
        }

        List<Object> submittedRows = deserializeRows(submittedJson);
        List<Object> persistedRows = deserializeRows(persistedJson);

        Map<String, Map<String, Object>> persistedById = new Map<String, Map<String, Object>>();
        for (Object persistedObject : persistedRows) {
            Map<String, Object> row = castRow(persistedObject);
            String rowId = getStringValue(row, 'Id');
            if (!String.isBlank(rowId)) {
                persistedById.put(rowId, row);
            }
        }

        if (submittedRows.size() < persistedRows.size() && !permissions.canDeleteRow) {
            throw new AuraHandledException('You are not authorized to delete Multi-Bank Liability rows.');
        }

        Set<String> submittedIds = new Set<String>();
        List<Map<String, Object>> normalizedRows = new List<Map<String, Object>>();

        for (Integer index = 0; index < submittedRows.size(); index++) {
            Map<String, Object> submitted = castRow(submittedRows[index]);
            String rowId = getStringValue(submitted, 'Id');

            if (String.isBlank(rowId)) {
                throw new AuraHandledException('Every Multi-Bank Liability row must have an Id.');
            }
            if (submittedIds.contains(rowId)) {
                throw new AuraHandledException('Duplicate Multi-Bank Liability row Id detected: ' + rowId + '.');
            }
            submittedIds.add(rowId);

            Boolean isNewRow = !persistedById.containsKey(rowId);
            if (isNewRow && !permissions.canAddRow) {
                throw new AuraHandledException('You are not authorized to add Multi-Bank Liability rows.');
            }

            Map<String, Object> persisted = isNewRow ? null : persistedById.get(rowId);

            String entity = getStringValue(submitted, 'entity');
            Decimal outstanding = getDecimalValue(submitted, 'outstanding');
            String liabilityId = getStringValue(submitted, 'liabilityID');
            String chequeNumber = getStringValue(submitted, 'chequeNumber');
            String entityKey = normalizeEntityKey(entity);
            Boolean isChequePayment = paymentTypeByEntity.containsKey(entityKey) && 'cheque'.equalsIgnoreCase(paymentTypeByEntity.get(entityKey));
            if (outstanding != null && outstanding < 0) {
                throw new AuraHandledException('Outstanding Amount cannot be negative on row ' + rowId + '.');
            }

            if (permissions.canEditEntityOutstanding) {
                if (String.isBlank(entity)) {
                    throw new AuraHandledException('Entity/Bank is required on row ' + rowId + '.');
                }
                if (outstanding == null) {
                    throw new AuraHandledException('Outstanding Amount is required on row ' + rowId + '.');
                }

                Boolean entityChanged = isNewRow || !stringsEqual(entity, getStringValue(persisted, 'entity'));
                if (entityChanged && !activeEntities.contains(entityKey)) {
                    throw new AuraHandledException( 'Entity/Bank "' + entity + '" is not an active Loan Multi-Bank Liability configuration value.');
                }
            } else {
                if (isNewRow) {
                    throw new AuraHandledException('You are not authorized to add Multi-Bank Liability rows.');
                }

                if (!stringsEqual(entity, getStringValue(persisted, 'entity')) || !decimalsEqual(outstanding, getDecimalValue(persisted, 'outstanding'))) {
                    throw new AuraHandledException('Entity/Bank and Outstanding Amount are read-only in your current Case ownership context.');
                }
            }

            if (permissions.canEditLiabilityId) {
                if (String.isBlank(liabilityId) && permissions.isOperationsContext) {
                    throw new AuraHandledException('Liability ID is required on row ' + rowId + '.');
                }
            } else {
                if (isNewRow) {
                    if (!String.isBlank(liabilityId)) {
                        throw new AuraHandledException('Liability ID cannot be set in the OBL queue context.');
                    }
                } else if (!stringsEqual(liabilityId, getStringValue(persisted, 'liabilityID'))) {
                    throw new AuraHandledException('Liability ID is read-only in your current Case ownership context.');
                }
            }

            if (isChequePayment) {
                if (permissions.canEditLiabilityId) {
                    if (String.isBlank(chequeNumber)) {
                        throw new AuraHandledException('Cheque Number is required on row ' + rowId + '.');
                    }
                } else {
                    if (isNewRow && !String.isBlank(chequeNumber)) {
                        throw new AuraHandledException('Cheque Number is read-only in your current Case ownership context.');
                    }

                    if (!isNewRow &&
                        !stringsEqual(chequeNumber, getStringValue(persisted, 'chequeNumber'))) {
                        throw new AuraHandledException('Cheque Number is read-only in your current Case ownership context.');
                    }
                }
            } else {
                // Cheque Number is not applicable for non-Cheque payment types.
                // Clear any previous value automatically when Entity/Bank changes.
                chequeNumber = '';
            }

            Map<String, Object> normalized = new Map<String, Object>();
            normalized.put('Id', rowId);
            normalized.put('entity', entity);
            normalized.put('outstanding', outstanding);
            normalized.put('liabilityID', liabilityId);
            normalized.put('chequeNumber', chequeNumber);
            normalizedRows.add(normalized);
        }

        for (String persistedId : persistedById.keySet()) {
            if (!submittedIds.contains(persistedId) && !permissions.canDeleteRow) {
                throw new AuraHandledException('You are not authorized to delete Multi-Bank Liability rows.');
            }
        }

        return normalizedRows;
    }

    private static Decimal calculateApprovedBuyoutAmount(List<Map<String, Object>> rows) {
        Decimal total = 0;

        for (Map<String, Object> row : rows) {
            Decimal outstanding = getDecimalValue(row, 'outstanding');
            if (outstanding != null) {
                total += outstanding;
            }
        }

        return total;
    }

    private static List<Object> deserializeRows(String jsonValue) {
        if (String.isBlank(jsonValue)) {
            return new List<Object>();
        }

        Object parsed;
        try {
            parsed = JSON.deserializeUntyped(jsonValue);
        } catch (Exception e) {
            throw new AuraHandledException('Multi-Bank Liability data contains invalid JSON.');
        }

        if (!(parsed instanceof List<Object>)) {
            throw new AuraHandledException('Multi-Bank Liability data must be a JSON array.');
        }

        return (List<Object>)parsed;
    }

    private static Map<String, Object> castRow(Object rowObject) {
        if (!(rowObject instanceof Map<String, Object>)) {
            throw new AuraHandledException('Each Multi-Bank Liability entry must be a JSON object.');
        }
        return (Map<String, Object>)rowObject;
    }

    private static String getStringValue(Map<String, Object> row, String fieldName) {
        if (row == null || !row.containsKey(fieldName) || row.get(fieldName) == null) {
            return '';
        }
        return String.valueOf(row.get(fieldName)).trim();
    }

    private static Decimal getDecimalValue(Map<String, Object> row, String fieldName) {
        if (row == null || !row.containsKey(fieldName) || row.get(fieldName) == null) {
            return null;
        }

        String value = String.valueOf(row.get(fieldName));
        if (String.isBlank(value)) {
            return null;
        }

        try {
            return Decimal.valueOf(value);
        } catch (Exception e) {
            throw new AuraHandledException(fieldName + ' must contain a valid number.');
        }
    }


    private static Boolean stringsEqual(String leftValue, String rightValue) {
        String leftNormalized = leftValue == null ? '' : leftValue.trim();
        String rightNormalized = rightValue == null ? '' : rightValue.trim();
        return leftNormalized == rightNormalized;
    }

    private static Boolean decimalsEqual(Decimal leftValue, Decimal rightValue) {
        if (leftValue == null && rightValue == null) {
            return true;
        }
        if (leftValue == null || rightValue == null) {
            return false;
        }
        return leftValue == rightValue;
    }

    private static String normalizeEntityKey(String value) {
        return String.isBlank(value) ? '' : value.trim().toLowerCase();
    }

    public class InitializationResponse {
        @AuraEnabled public Id caseAnnexId { get; set; }
        @AuraEnabled public String multiBankLiabilitiesJson { get; set; }
        @AuraEnabled public Decimal approvedBuyoutAmount { get; set; }
        @AuraEnabled public List<EntityOption> entityOptions { get; set; }
        @AuraEnabled public PermissionsResponse permissions { get; set; }
    }

    public class SaveResponse {
        @AuraEnabled public String multiBankLiabilitiesJson { get; set; }
        @AuraEnabled public Decimal approvedBuyoutAmount { get; set; }
    }

    public class EntityOption {
        @AuraEnabled public String label { get; set; }
        @AuraEnabled public String value { get; set; }
        @AuraEnabled public String paymentType { get; set; }
    }

    public class PermissionsResponse {
        @AuraEnabled public Boolean isAdmin { get; set; }
        @AuraEnabled public Boolean isDocumentVerifierOblContext { get; set; }
        @AuraEnabled public Boolean isOperationsContext { get; set; }
        @AuraEnabled public Boolean canEditEntityOutstanding { get; set; }
        @AuraEnabled public Boolean canEditLiabilityId { get; set; }
        @AuraEnabled public Boolean canAddRow { get; set; }
        @AuraEnabled public Boolean canDeleteRow { get; set; }
        @AuraEnabled public Boolean canModifyTable { get; set; }
        @AuraEnabled public Boolean showLiabilityId { get; set; }
    }
}