public class LoanCalculationSummaryController {

    public CaseAnnex__c caseAnnexObj { get; set; }
    public List<LoanDocuSignDocumentListController.DocuSignWrapper> docList {get;set;}
    public List<LoanDocuSignDocumentListController.DocuSignWrapper> docuSignList {get;set;}

    public Case caseRecord { get; set; }
    public Boolean hasCreditCard { get; set; }
    public Boolean isFinanceServiceRequest { get; set; }
    public Boolean isFinanceSerReq { get; set; }
    public Boolean isUnsecured { get; set; }
    public Boolean isSecured { get; set; }

    static Id caseId = ApexPages.currentPage().getParameters().get('id');

    public LoanCalculationSummaryController(ApexPages.StandardController controller){

        caseRecord = [
            SELECT Id, AIR_HaveCreditCard__c, Type, Sub_Type__c, Existing_ila_Credit_Card_Deduction__c,
                   RecordType.DeveloperName, cc_Approved_Credit_Limit__c, RecordType_DeveloperName__c,
                   ccol_Hold_Amount__c, ccol_Hold_Account_IBAN__c, Approved_Hold_Amount_in_words__c,
                   ccol_Hold_Account__c, ccol_Hold_Reference_Number__c,
                   cc_Deviation_1_type__c, cc_Other_Deviation_1_type__c,
                   cc_Deviation_2_type__c, cc_Other_Deviation_2_type__c,
                   cc_Credit_Pre_Screening_Result__c, cc_Credit_Pre_Screening_by__c,
                   cc_Credit_Pre_Screening_Result_Date_Time__c,
                   cc_Credit_Evaluation_Result__c, cc_Credit_Evaluation_by__c,
                   cc_Credit_Evaluation_Result_Date_Time__c,
                   cc_Credit_Approval_Result__c, cc_Credit_Approved_by__c,
                   cc_Credit_Approval_Result_Date_Time__c,
                   cc_Signature_Verifier_Result__c, cc_Signature_Verifier_by__c, cc_Signature_Verification_Date_Time__c,
                   cc_Employment_Status__c,
                   cc_Employer_Sector__c,
                   cc_Length_Of_Service__c,
                   cc_Employer_Name__c,
                   cc_Employer_Grade__c,
                   cc_Occupation__c,
                   Operation_Result__c,
                   cc_Operation_by__c,
                   cc_Operations_Date_Time__c,
                   cc_Requested_Credit_Limit__c,
                   cc_Requested_Card_Type__c,
                   Total_Internal_Loans__c
            FROM Case
            WHERE Id = :caseId
            LIMIT 1
        ];

        caseAnnexObj = [SELECT Id, cx_ln_Approved_Loan_Amount__c, cx_ln_Product__c, cx_ln_Document_Verifier_OBL_Result__c,
                        cx_ln_Document_Verifier_OBL_Result_By__c, cx_ln_DocumentVerifierOBLResult_DateTime__c,
                        cx_ln_Document_Verifier_Result__c, cx_ln_Document_Verifier_Result_By__c,
                        cx_ln_Document_Verifier_Result_Date_Time__c, cx_ln_DocumentVerifierNDLResult__c,
                        cx_ln_Document_Verifier_NDL_Result_By__c, cx_ln_DocumentVerifierNDLResult_DateTime__c,
                        cx_ln_Loan_Finance_Type__c, cx_ln_Requested_Loan_Finance_Amount__c, cx_ln_Business_Nature_Type__c,
                        cx_ln_Basic_Salary__c, cx_ln_Fixed_Allowances__c, cx_ln_Variable_Allowances__c, cx_ln_Business_Income__c,
                        cx_ln_Total_Approved_Income__c, cx_ln_Final_DBR__c, cx_ln_Total_Deductions__c, EarlyRepaymentPrincipalAmount__c,
                        cx_ln_TotalConsumerLoansInstallments__c, cx_ln_TotalMortgageLoansInstallments__c, cx_ln_TotalCreditCardsInstallments__c,
                        cx_ln_TotalGovernmentLoansInstallments__c, cx_ln_Other_Deductions__c, cx_ln_Approved_Installment_Amount__c,
                        cx_ln_TotalCurrentObligations__c, cx_ln_Approved_Credit_Limit__c, cx_ln_InternalDeductions__c,
                        cx_ln_Total_IlaCreditCardsInstallments__c
                        FROM CaseAnnex__c WHERE Case__c = :caseId LIMIT 1];

        hasCreditCard = caseRecord.AIR_HaveCreditCard__c == true;

        isFinanceServiceRequest =
            caseRecord.RecordType.DeveloperName == 'LoanFinanceServiceRequest' &&
            caseRecord.Type == 'New Loan / Finance Service Request' &&
            (
                caseRecord.Sub_Type__c == 'Partial Settlement' ||
                caseRecord.Sub_Type__c == 'Restructuring' ||
                caseRecord.Sub_Type__c == 'Top-up'
            );

        isFinanceSerReq = (caseRecord.RecordType.DeveloperName == 'LoanFinanceServiceRequest' && caseRecord.Type == 'New Loan / Finance Service Request');

        Boolean productIsUnsecured = caseAnnexObj != null && caseAnnexObj.cx_ln_Product__c == 'Unsecured';
        Boolean productIsSecured   = caseAnnexObj != null && caseAnnexObj.cx_ln_Product__c == 'Secured';

        // Existing Loan Application behavior preserved exactly
        isUnsecured = productIsUnsecured;
        isSecured   = productIsSecured;

        docList = LoanDocuSignDocumentListController.getDocumentList(caseId, true);
        docuSignList = LoanDocuSignDocumentListController.getDocumentList(caseId, false);
        System.debug('docList ' + docList.size());
        System.debug('docuSignList ' + docuSignList.size());
    }
}