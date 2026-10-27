public class DocuSignLoanCmpController {

    public Case caseRecord { get; set; }
    public CaseAnnex__c caseAnnexObj { get; set; }
    
    public void setCaseObject(Object obj){
        caseRecord = (Case)obj;
    }
    
    public Case getCaseObject(){
        return caseRecord;
    }
    
    public void setCaseAnnexObject(Object obj){
        caseAnnexObj = (CaseAnnex__c)obj;
    }
    
    public CaseAnnex__c getCaseAnnexObject(){
        return caseAnnexObj;
    }
    
    
    public Decimal getCurrentDBR(){
        try {
            return ((caseAnnexObj.cx_ln_TotalCurrentObligations__c / caseAnnexObj.cx_ln_Total_Approved_Income__c) * 100).setScale(3);
        }
        catch(Exception ex){
            return 0;
		}
    }
    
    public Decimal getNoOfMultiples(){
        
        try {
            return (caseAnnexObj.cx_ln_Approved_Loan_Amount__c / caseAnnexObj.cx_ln_Total_Approved_Income__c).setScale(3);
        }
        catch(Exception ex){
            return 0;
		}
    }

    public Decimal getProposedCreditCardDeduction(){
        try {
            return ((caseAnnexObj.cx_ln_Approved_Credit_Limit__c) * 0.05).setScale(3);
        }
        catch(Exception ex){
            return 0;
		}
    }
    
    public Decimal getCoverageRatio(){
        
        try {
            return (caseRecord.ccol_Hold_Amount__c / caseAnnexObj.cx_ln_Approved_Loan_Amount__c).setScale(3);
        }
        catch(Exception ex){
            return 0;
		}
    }

    public Boolean getIsFinanceServiceRequest() {
        if (caseRecord == null || String.isBlank(caseRecord.Sub_Type__c)) {
            return false;
        }

        if (caseRecord == null || String.isBlank(caseRecord.RecordType_DeveloperName__c)) {
            return false;
        }

        String subType = caseRecord.Sub_Type__c.trim();
        String recordTypeName = caseRecord.RecordType_DeveloperName__c.trim();

        return (subType == 'Partial Settlement'
            || subType == 'Restructuring'
            || subType == 'Top-up'
            || recordTypeName == 'Loan_Application');
    }

    
public Boolean getIsOperationQueueAvailable() {
    if (caseRecord == null || String.isBlank(caseRecord.RecordType_DeveloperName__c)) {
        return false;
    }

    String recordTypeName = caseRecord.RecordType_DeveloperName__c.trim();

    if (recordTypeName == 'LoanFinanceServiceRequest') {
        return true;
    }

    if (recordTypeName == 'Loan_Application') {
        return caseAnnexObj != null &&
            caseAnnexObj.cx_ln_Business_Nature_Type__c != null &&
            caseAnnexObj.cx_ln_Business_Nature_Type__c.trim() == 'Buyout Loan/Finance';
    }

    return false;
}

}