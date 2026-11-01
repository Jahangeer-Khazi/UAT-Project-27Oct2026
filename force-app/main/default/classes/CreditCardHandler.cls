/*      Organization : ABC Bank
*      Description  : Support class for CaseHandler. Contains the Credit Card / Manual Onboarding
*                     after-update logic that was previously in CaseHandler.reStartManualOnboarding.
*                     Invoked from CaseHandler.afterUpdate().
*      Created Date : 01-11-2026
*      Change History:
*             #CH01# 01-11-2026# Moved reStartManualOnboarding from CaseHandler and renamed it to creditCardApplicationUpdate (CaseHandler #CH93#).
*                    All change markers (CH01-CH92) inside the method refer to the CaseHandler change history.
*/
public without sharing class CreditCardHandler {
    /**
    * @description After-update processing for Case records (moved from CaseHandler).
    * @param newRecs  Trigger.new  - updated Case records
    * @param oldMap   Trigger.oldMap - previous versions of the Case records
    */
    public static void creditCardApplicationUpdate(final List<Case> newRecs, final Map<Id, Case> oldMap) {
        //CH01: Start
        Set<Id> cntIds = new Set<Id>();
        Map<ID,Schema.RecordTypeInfo> rt_Map = Case.sObjectType.getDescribe().getRecordTypeInfosById();
        Map<Id,List<Case>> mapContactToCases = new Map<Id,List<Case>>();
        //CH01: END
        //CH02: Start
        Set<Id> reSendDocSet = new Set<Id>();
        //CH02: END
        Set<Id> setCase  = new Set<Id>();
        Set<Id> reSendDocSetInApp = new Set<Id>();//#CH84
        Set<Id> setCasePending = new Set<Id>();
        Set<Id> setCaseDocReceived  = new Set<Id>();
        Set<Id> setCaseReferred  = new Set<Id>();
        Set<Id> setCaseDocDiscrepancies  = new Set<Id>();
        Set<Id> setCaseDeclined  = new Set<Id>();
        Set<Id> setCaseExpired = new Set<Id>();
        Set<Id> setCaseEKYC  = new Set<Id>();
        Set<Id> setCaseEKYCManualRetry  = new Set<Id>();
        Set<Id> setCaseEKYCIdentificationCase  = new Set<Id>();
        Set<Id> setCaseStopJamiyah  = new Set<Id>();
        Set<ID> setSuppCaseMakerReferToSC = new Set<ID>();
        Set<ID> setSuppCaseMakerRelationshipEstablishment = new Set<ID>();
        Set<ID> setSuppCaseMakerSendPreScreener = new Set<ID>();
        Set<ID> setSuppCaseDecline = new Set<ID>();
        Set<ID> setSuppCaseCancelledByCustomer = new Set<ID>();
        Set<ID> setSuppCasePreScreenerApproved = new Set<ID>();
        Set<ID> setSuppCasePrescreenerRelationshipEstablishment = new Set<ID>();
        Set<ID> setSuppCasePrescreenerToSC = new Set<ID>();
        Set<ID> setSuppCaseSCRoutedToMaker = new Set<ID>();
        //CH05: Start
        Set<Id> setCaseRoutedFromPreScreenerToEvaluator = new Set<Id>();
        Set<Id> setCaseRoutedFromPrescreenerToServiceCenter = new Set<Id>();
        //CH50: Start
        Set<Id> setCaseRoutedFromPrescreenertoCreditRetention = new Set<Id>();
        //CH50: END
        Set<Id> setCaseRoutedFromEvaluatorToServiceCenter = new Set<Id>();
        Set<Id> setCaseRoutedFromEvaluatorToVerifier = new Set<Id>();
        Set<Id> setCaseRoutedFromVerifierToApprover = new Set<Id>();
        Set<Id> setCaseRoutedFromVerifierToServiceCenter = new Set<Id>();
        Set<Id> setCasesRoutedToCreditSignatureVerificationQueueFromApprover = new Set<Id>();
        Set<Id> setCasesRoutedToCreditSignatureVerificationQueueFromApproverInApp = new Set<Id>();//#CH84
        Set<Id> setCasesRoutedToCreditServiceCenterQueueFromApprover = new Set<Id>();
        Set<Id> setCaseClosedBySignatureVerifier = new Set<Id>();
        Set<Id> setCasesRemainInSignatureVerifier = new Set<Id>();
        Set<Id> setCasesRoutedToCreditServiceCenterQueueFromSignatureVerifier = new Set<Id>();
        Set<Id> setCaseRoutedToPreScreenerQueueFromServiceCenter = new Set<Id>();
        Set<Id> setCaseRoutedToEvaluationQueueFromServiceCenter = new Set<Id>();
        Set<Id> setCaseRoutedToVerificationQueueFromServiceCenter = new Set<Id>();
        Set<Id> setCaseRoutedToApproverQueueFromServiceCenter = new Set<Id>();
        Set<Id> setCaseRoutedToSignatureVerifierFromServiceCenter = new Set<Id>();
        Set<Id> setCaseRoutedToEvaluationFromServiceCenterIfLetterRec = new Set<Id>();
        Set<Id> setCasesRouteToBuyoutQueue = new Set<Id>();
        Set<Id> setCaseClosedByOperationsForCardBlockRelease = new Set<Id>();
        Set<Id> setCaseRouteToServiceCenterFromBuyoutOperationsQueue = new Set<Id>();
        //CH22: Start
        Set<Id> setCaseRoutedToSignatureVerifierFromHR  = new Set<Id>();
        //CH22: END
        Set<Id> setCaseRoutedToSignatureVerifierFromHRInApp  = new Set<Id>(); //#CH87
        //CH23: Start
        set<Id> setExistingCasesProvideDigitalDocs = new Set<Id>();
        //CH23: END
        //CH10: Start
        Set<Id> setCasesCancelledByCustomer = new Set<Id>();
        Set<Id> setCaseHRApprovedForBuyout  = new Set<Id>();
        Set<Id> setCasesRouteToBuyoutQueueForBuyoutType = new Set<Id>();
        //CH10: END
        Set<Id> setCaseHRApprovedForReleaseLetter  = new Set<Id>();
        Set<Id> setCaseAcceptedByEvaluator = new Set<Id>();
        //CH38  Start
        Set<Id> setCaseProfileUpdate = new Set<Id>();
        //CH38  End
        //CH13: Start
        Set<Id> setCaseApprovedBySigVerifierForLimitIncrease = new Set<Id>();
        //CH24: Start
        Set<Id> setCaseRoutedToSignatureVerifierFromHRForLimitIncrease = new Set<Id>();
        //CH24 : END
        Set<Id> setCaseRoutedToSignatureVerifierFromHRForLimitIncreaseInApp = new Set<Id>();//#CH87
        Set<Id> setCasePendingForSMSReminders = new Set<Id>();
        Set<Id> setCasePendingForSignatureReminders = new Set<Id>();
        //CH13: END
        List<Case> caseLst = new List<Case>();
        //CH05: END
        //CH06: Start
        Set<Id> setCaseLimitIncrease  = new Set<Id>();
        //CH06: End
        Map<Id, Id> mapCasetoAccount = new Map<Id, Id>();
        //CH40: Start
        Map<Id, Id> mapCaseToAccountHR = new Map<Id, Id>();
        //CH40: END
        List<CaseComment> lstComment = new List<CaseComment>();
        Map<id,Case> CaseOldMap = oldMap;
        //CH07: Start
        Set<Id> setCaseIdsForNoDueCertificatePdf = new Set<id>();
        //CH07: END
        //CH73: Start
        Set<Id> caseIdstoUpdate = new Set<Id>();
        //CH73: End
        //CH85: Start
        Set<Id> ccservicecseIds = new Set<Id>();
        //CH85: END
        for(Case caseObj : newRecs) {
            Case caseOldObj = oldMap.get(caseobj.id);
            //CH01: Start
            string recordtypeName = rt_Map.get(caseObj.RecordTypeId).getName();
            if(recordtypeName == 'Manual Customer Archival' && caseObj.Status != caseOldObj.Status && caseObj.Status == 'Closed' && (((caseObj.cc_Checker_Result__c!='Decline' && caseObj.cc_Maker__c!='Cancel Prospect Archive') && caseObj.Region_Flag__c=='Bahrain') ||(caseObj.Closure_Type__c!='Closed Rejected' && caseObj.Region_Flag__c=='Jordan'))){
                cntIds.add(caseObj.ContactId);
            }
            //CH01: END
            //CH07: Start
            //CH09: END
            //CH85: Start
            if(recordtypeName == 'Credit Card Services' && caseObj.Status != caseOldObj.Status && caseObj.Status == 'Closed'){
                ccservicecseIds.add(caseObj.id);
            }
            //CH85: END
            if(caseObj.Lead_Created_Account__c == true && caseObj.Status != caseOldObj.Status && caseObj.Status == 'Closed' && caseObj.Type == 'Technical' && caseObj.archive__c==false)
            {
                setCase.add(caseObj.id);
            }
            if(caseObj.Status != caseOldObj.Status && caseObj.Status == 'Closed' && caseObj.Type == 'eKYC' && caseObj.archive__c==false)
            {
                setCaseEKYC.add(caseObj.id);
            }
            if(caseObj.eKYC_decision__c != caseOldObj.eKYC_decision__c && caseObj.Type == 'eKYC' && caseObj.eKYC_decision__c == 'Manual Retry')
            {
                setCaseEKYCManualRetry.add(caseObj.id);
            }
            if(caseObj.eKYC_decision__c != caseOldObj.eKYC_decision__c && caseObj.Type == 'eKYC' && caseObj.eKYC_decision__c == 'Convert to Identification Case')
            {
                setCaseEKYCIdentificationCase.add(caseObj.id);
            }
            if(caseObj.Type == 'Stop Jamiyah' && caseObj.Requested_by_Admin_new__c != true && caseObj.Closure_Type__c != caseOldObj.Closure_Type__c && caseObj.Closure_Type__c == 'Closed Approved')
            {
                setCaseStopJamiyah.add(caseObj.id);
            }
            //CH55: Added Region Flag in if condition
            if(caseOldObj.Sub_Status__c != caseObj.Sub_Status__c  && caseObj.Sub_Status__c =='Pending' && caseObj.Region_Flag__c == 'Bahrain' && ((caseObj.Type == 'Credit Card Application' && caseObj.Sub_Type__c == 'New Credit Card')  || (caseObj.Type == 'Credit Card Supplementary Application' && caseObj.Sub_Type__c == 'New Supplementary Card') || (caseObj.Type == 'Credit Limit Increase Application' && caseObj.Sub_Type__c == 'Credit Limit Increase')))
            {
                system.debug('----> check in 1 --> '+caseObj);
                setCasePending.add(caseObj.id);
            }
            //CH55: Added Region Flag in if condition
            if(caseObj.Sub_Status__c != caseOldObj.Sub_Status__c && caseObj.Sub_Status__c =='Documents Received' && caseObj.Region_Flag__c == 'Bahrain'  && ((caseObj.Type == 'Credit Card Application' && caseObj.Sub_Type__c == 'New Credit Card')  || (caseObj.Type == 'Credit Card Supplementary Application' && caseObj.Sub_Type__c == 'New Supplementary Card') || (caseObj.Type == 'Credit Limit Increase Application' && caseObj.Sub_Type__c == 'Credit Limit Increase')))
            {
                setCaseDocReceived.add(caseObj.id);
            }
            if( caseObj.Sub_Status__c != caseOldObj.Sub_Status__c && (caseObj.Sub_Status__c =='Referred by Evaluator' || caseObj.Sub_Status__c =='Referred by Verifier' || caseObj.Sub_Status__c =='Referred by Approver' ) && ((caseObj.Type == 'Credit Card Application' && caseObj.Sub_Type__c == 'New Credit Card') || (caseObj.Type == 'Credit Limit Increase Application' && caseObj.Sub_Type__c == 'Credit Limit Increase')))
            {
            }
            System.debug('New Substatus:'+caseObj.Sub_Status__c);
            System.debug('Old Substatus:'+caseOldObj.Sub_Status__c);
            //CH55: Added Region Flag in if condition
            if(caseObj.Sub_Status__c != caseOldObj.Sub_Status__c && caseObj.Sub_Status__c =='Discrepancies' && caseObj.Region_Flag__c == 'Bahrain' && ((caseObj.Type == 'Credit Card Application' && caseObj.Sub_Type__c == 'New Credit Card')  || (caseObj.Type == 'Credit Card Supplementary Application' && caseObj.Sub_Type__c == 'New Supplementary Card') || (caseObj.Type == 'Credit Limit Increase Application' && caseObj.Sub_Type__c == 'Credit Limit Increase')))
            {
                System.debug('Dicrepancy in Documents');
                setCaseDocDiscrepancies.add(caseObj.id);
            }
            //CH05: Start
            /******************************************* CREDIT MAKER RESULT START ************************************************/
            //CH55: Added Region Flag in if condition
            if((caseObj.Type == 'Credit Card Supplementary Application' && caseObj.Sub_Type__c == 'New Supplementary Card')  &&
               caseObj.cc_Maker__c == 'Refer to Service Center' && caseObj.cc_Maker__c != caseOldObj.cc_Maker__c &&
               caseObj.cc_Application_Stages__c == 'Credit Maker' && caseObj.Region_Flag__c == 'Bahrain'){
                   System.debug('Set Supplementary Cases from Maker Queue to Service Center');
                   setSuppCaseMakerReferToSC.add(caseObj.id);
               }
            //CH55: Added Region Flag in if condition
            if((caseObj.Type == 'Credit Card Supplementary Application' && caseObj.Sub_Type__c == 'New Supplementary Card')  &&
               caseObj.cc_Maker__c == 'Pending Relationship Establishment' && caseObj.cc_Maker__c != caseOldObj.cc_Maker__c &&
               caseObj.cc_Application_Stages__c == 'Credit Maker' && caseObj.Region_Flag__c == 'Bahrain'){
                   System.debug('Set Supplementary Cases from Maker Queue to Temp Queue');
                   setSuppCaseMakerRelationshipEstablishment.add(caseObj.id);
               }
            //CH55: Added Region Flag in if condition
            if((caseObj.Type == 'Credit Card Supplementary Application' && caseObj.Sub_Type__c == 'New Supplementary Card')  &&
               caseObj.cc_Maker__c == 'Send to Pre-Screener' && caseObj.cc_Maker__c != caseOldObj.cc_Maker__c &&
               caseObj.cc_Application_Stages__c == 'Credit Maker' && caseObj.Region_Flag__c == 'Bahrain'){
                   System.debug('Set Supplementary Cases from Maker Queue to PreScreener');
                   setSuppCaseMakerSendPreScreener.add(caseObj.id);
               }
            /******************************************************************************************************************************/
            //CH05: Start
            /******************************************* CREDIT PRE SCREENING RESULT START ************************************************/
            System.debug('Pre screening App Stage:'+caseObj.cc_Application_Stages__c);
            //CH55: Added Region Flag in if condition
            if(((caseObj.Type == 'Credit Card Application' && caseObj.Sub_Type__c == 'New Credit Card')  || (caseObj.Type == 'Credit Limit Increase Application' && caseObj.Sub_Type__c == 'Credit Limit Increase')) &&
               caseObj.cc_Credit_Pre_Screening_Result__c == 'Accept' && caseObj.cc_Credit_Pre_Screening_Result__c != caseOldObj.cc_Credit_Pre_Screening_Result__c &&
               caseObj.cc_Application_Stages__c == 'Credit Pre-Screening' && caseObj.Region_Flag__c == 'Bahrain'){
                   System.debug('Set Cases from Temp Queue to Pre screener');
                   setCaseRoutedFromPreScreenerToEvaluator.add(caseObj.id);
               }
            System.debug('Pre screening Result:'+caseObj.cc_Credit_Pre_Screening_Result__c);
            System.debug('Old Pre screening Result:'+caseOldObj.cc_Credit_Pre_Screening_Result__c);
            System.debug('Application Stage:'+caseObj.cc_Application_Stages__c);
            //CH55: Added Region Flag in if condition
            if(((caseObj.Type == 'Credit Card Application' && caseObj.Sub_Type__c == 'New Credit Card')|| (caseObj.Type == 'Credit Limit Increase Application' && caseObj.Sub_Type__c == 'Credit Limit Increase')) &&
               caseObj.cc_Credit_Pre_Screening_Result__c == 'Refer to Service Center' && caseObj.cc_Credit_Pre_Screening_Result__c != caseOldObj.cc_Credit_Pre_Screening_Result__c &&
               caseObj.cc_Application_Stages__c == 'Credit Pre-Screening' && caseObj.Region_Flag__c == 'Bahrain'){
                   System.debug('Set Cases from Pre screener Queue to Service Center');
                   setCaseRoutedFromPrescreenerToServiceCenter.add(caseObj.id);
               }
            //CH55: Added Region Flag in if condition
            //CH50: Start
            if(caseObj.Type == 'Credit Card Application' && caseObj.Sub_Type__c == 'New Credit Card' &&
               ((caseObj.cc_Credit_Pre_Screening_Result__c == 'Offer Cash Collateral') || (caseObj.cc_Credit_Pre_Screening_Result__c == 'Request Missing / Incomplete Documents') || (caseObj.cc_Credit_Pre_Screening_Result__c == 'Retain Customer')) &&
               caseObj.cc_Credit_Pre_Screening_Result__c != caseOldObj.cc_Credit_Pre_Screening_Result__c && caseObj.cc_Application_Stages__c == 'Credit Pre-Screening' && caseObj.Region_Flag__c == 'Bahrain'){
                   System.debug('Set Cases From Pre-screener to Retention Queue');
                   setCaseRoutedFromPrescreenertoCreditRetention.add(caseObj.id);
               }
            //CH50: END
            //CH55: Added Region Flag in if condition
            if((caseObj.Type == 'Credit Card Supplementary Application' && caseObj.Sub_Type__c == 'New Supplementary Card')  &&
               caseObj.cc_Credit_Pre_Screening_Result__c == 'Pending Relationship Establishment' && caseObj.cc_Credit_Pre_Screening_Result__c != caseOldObj.cc_Credit_Pre_Screening_Result__c &&
               caseObj.cc_Application_Stages__c == 'Credit Pre-Screening' && caseObj.Region_Flag__c == 'Bahrain'){
                   System.debug('Set Cases from Pre screener Queue to Service Center');
                   setSuppCasePrescreenerRelationshipEstablishment.add(caseObj.id);
               }
            //CH55: Added Region Flag in if condition
            if((caseObj.Type == 'Credit Card Supplementary Application' && caseObj.Sub_Type__c == 'New Supplementary Card') &&
               caseObj.cc_Credit_Pre_Screening_Result__c == 'Refer to Service Center' && caseObj.cc_Credit_Pre_Screening_Result__c != caseOldObj.cc_Credit_Pre_Screening_Result__c &&
               caseObj.cc_Application_Stages__c == 'Credit Pre-Screening' && caseObj.Region_Flag__c == 'Bahrain'){
                   System.debug('Set Cases from Pre screener Queue to Service Center');
                   setSuppCasePrescreenerToSC.add(caseObj.id);
               }
            System.debug('----> 823 ---> OLD Substatus Value---> '+caseOldObj.sub_status__c);
            System.debug('----> 823 ---> NEW Substatus Value---> '+caseObj.sub_status__c);
            //CH55: Added Region Flag in if condition
            if((caseObj.Type == 'Credit Card Supplementary Application' && caseObj.Sub_Type__c == 'New Supplementary Card') &&
               caseObj.cc_Credit_Pre_Screening_Result__c == 'Accept' && caseObj.cc_Credit_Pre_Screening_Result__c != caseOldObj.cc_Credit_Pre_Screening_Result__c &&
               caseObj.cc_Application_Stages__c == 'Credit Pre-Screening' && caseObj.Region_Flag__c == 'Bahrain'){
                   System.debug('Set Cases from Pre screener Queue to Service Center');
                   setSuppCasePreScreenerApproved.add(caseObj.id);
               }
            //#CH49 : Start
            //CH55: Added Region Flag in if condition
            if((caseObj.Type == 'Credit Card Supplementary Application' && caseObj.Sub_Type__c == 'New Supplementary Card') &&
               caseObj.cc_Maker__c == 'Accept' && caseObj.cc_Maker__c != caseOldObj.cc_Maker__c && caseObj.Region_Flag__c == 'Bahrain'){
                   System.debug('Same process as Prescrener to Accept');
                   setSuppCasePreScreenerApproved.add(caseObj.id);
               }
            //#CH49 : End
            /******************************************* CREDIT PRE SCREENING RESULT END **************************************************/
            /******************************************* CREDIT EVALUATOR RESULT START ****************************************************/
            //CH55: Added Region Flag in if condition
            if(((caseObj.Type == 'Credit Card Application' && caseObj.Sub_Type__c == 'New Credit Card') || (caseObj.Type == 'Credit Limit Increase Application' && caseObj.Sub_Type__c == 'Credit Limit Increase')) &&
               caseObj.cc_Credit_Evaluation_Result__c == 'Refer to Service Center' &&
               caseObj.cc_Credit_Evaluation_Result__c != caseOldObj.cc_Credit_Evaluation_Result__c  &&
               caseObj.cc_Application_Stages__c == 'Credit Evaluation' && caseObj.Region_Flag__c == 'Bahrain'){
                   System.debug('Set Cases from Evaluator to Service Center');
                   setCaseRoutedFromEvaluatorToServiceCenter.add(caseObj.id);
               }
            //CH55: Added Region Flag in if condition
            if(((caseObj.Type == 'Credit Card Application' && caseObj.Sub_Type__c == 'New Credit Card') || (caseObj.Type == 'Credit Limit Increase Application' && caseObj.Sub_Type__c == 'Credit Limit Increase')) &&
               caseObj.cc_Credit_Evaluation_Result__c == 'Accept' &&
               caseObj.cc_Credit_Evaluation_Result__c != caseOldObj.cc_Credit_Evaluation_Result__c  &&
               caseObj.cc_Application_Stages__c == 'Credit Evaluation' && caseObj.Region_Flag__c == 'Bahrain'){
                   System.debug('Set Cases from Evaluator to Verifier');
                   setCaseRoutedFromEvaluatorToVerifier.add(caseObj.id);
               }
            //CH55: Added Region Flag in if condition
            //CH10: Start
            if(((caseObj.Type == 'Credit Card Application' && caseObj.Sub_Type__c == 'New Credit Card') || (caseObj.Type == 'Credit Limit Increase Application' && caseObj.Sub_Type__c == 'Credit Limit Increase')) &&
               caseObj.cc_Credit_Evaluation_Result__c == 'Accept Release Letter' &&
               caseObj.cc_Credit_Evaluation_Result__c != caseOldObj.cc_Credit_Evaluation_Result__c  &&
               caseObj.cc_Application_Stages__c == 'Credit Evaluation' && caseObj.Region_Flag__c == 'Bahrain'){
                   System.debug('Set Cases from Evaluator Accept Release Letter');
                   setCaseAcceptedByEvaluator.add(caseObj.id);
               }
            //CH10: END
            /******************************************* CREDIT EVALUATOR RESULT END ****************************************************/
            /******************************************* CREDIT VERIFIER START **********************************************************/
            //CH55: Added Region Flag in if condition
            if(((caseObj.Type == 'Credit Card Application' && caseObj.Sub_Type__c == 'New Credit Card') || (caseObj.Type == 'Credit Limit Increase Application' && caseObj.Sub_Type__c == 'Credit Limit Increase')) &&
               caseObj.cc_Credit_Verification_Result__c == 'Approve' &&
               caseObj.cc_Credit_Verification_Result__c != caseOldObj.cc_Credit_Verification_Result__c  &&
               caseObj.cc_Application_Stages__c == 'Credit Verification' && caseObj.Region_Flag__c == 'Bahrain'){
                   System.debug('Set Cases from Verifier to Approver');
                   setCaseRoutedFromVerifierToApprover.add(caseObj.id);
               }
            //CH55: Added Region Flag in if condition
            if(((caseObj.Type == 'Credit Card Application' && caseObj.Sub_Type__c == 'New Credit Card') || (caseObj.Type == 'Credit Limit Increase Application' && caseObj.Sub_Type__c == 'Credit Limit Increase')) &&
               caseObj.cc_Credit_Verification_Result__c == 'Refer to Service Center' &&
               caseObj.cc_Credit_Verification_Result__c != caseOldObj.cc_Credit_Verification_Result__c  &&
               caseObj.cc_Application_Stages__c == 'Credit Verification' && caseObj.Region_Flag__c == 'Bahrain'){
                   System.debug('Set Cases from Verifier to Service Center');
                   setCaseRoutedFromVerifierToServiceCenter.add(caseObj.id);
               }
            /******************************************* CREDIT VERIFIER END **********************************************************/
            /******************************************* CREDIT APPROVER RESULT START ***************************************************/
            //CH55: Added Region Flag in if condition
            if(((caseObj.Type == 'Credit Card Application' && caseObj.Sub_Type__c == 'New Credit Card') || (caseObj.Type == 'Credit Limit Increase Application' && caseObj.Sub_Type__c == 'Credit Limit Increase')) &&
               caseObj.cc_Credit_Approval_Result__c == 'Approve' &&
               caseObj.cc_Credit_Approval_Result__c != caseOldObj.cc_Credit_Approval_Result__c &&
               caseObj.cc_Application_Stages__c == 'Credit Approval' && caseObj.Region_Flag__c == 'Bahrain'){
                   System.debug('Set Cases for Signature Verification Queue From Credit Approver');
                   //#CH84 : Start
                   if(caseObj.Resend_DocuSign__c == 'Email' ){
                       setCasesRoutedToCreditSignatureVerificationQueueFromApprover.add(caseObj.id);
                   }
                   else{
                       setCasesRoutedToCreditSignatureVerificationQueueFromApproverInApp.add(caseObj.id);
                   }
                   //#CH84 : End
               }
            /******************************************************************************************************************************/
            // to Limit Increase
            ////////////////////////// Start : Cases Routing to Credit Service Center when Credit Approval Result = 'Refer to Service Center' in CRM and Sending Status 'REFERRED' in API ///////////////////////////////////////
            //CH55: Added Region Flag in if condition
            if(((caseObj.Type == 'Credit Card Application' && caseObj.Sub_Type__c == 'New Credit Card') || (caseObj.Type == 'Credit Limit Increase Application' && caseObj.Sub_Type__c == 'Credit Limit Increase')) &&
               caseObj.cc_Credit_Approval_Result__c == 'Refer to Service Center' &&
               caseObj.cc_Credit_Approval_Result__c != caseOldObj.cc_Credit_Approval_Result__c &&
               caseObj.cc_Application_Stages__c == 'Credit Approval' && caseObj.Region_Flag__c == 'Bahrain'){
                   System.debug('Set Cases for Credit Card Service Center Queue From Credit Approver');
                   setCasesRoutedToCreditServiceCenterQueueFromApprover.add(caseObj.id);
               }
            ////////////////////////// END : Cases Routing to Credit Service Center when Credit Approval Result = 'Refer to Service Center' in CRM and Sending Status 'REFERRED' in API ///////////////////////////////////////
            /******************************************* CREDIT APPROVER RESULT END ***************************************************/
            /******************************************** CEO APPROVER RESULT START *****************************************************/
            /******************************************** CEO APPROVER RESULT END *******************************************************/
            /******************************************* SIGNATURE VERIFIER RESULT START ***************************************************/
            //////// Start : When Signature Verifier Result = 'Accept' then cases are closed in CRM, If Approved Requested Card Type = ila Blue or ila Black and Sending Status as 'Approved' in API ////////////////////
            //CH55: Added Region Flag in if condition
            //CH13: Commented the Credit Limit Update condition by Jahangeer Mohammed #01-11-2021#
            //CH74: Added Is_Balance_Transfer__c in if condition for Cobranded Cards
            if(((caseObj.Type == 'Credit Card Application' && caseObj.Sub_Type__c == 'New Credit Card')) &&
               caseObj.cc_Signature_Verifier_Result__c == 'Accept' &&  caseObj.cc_Signature_Verifier_Result__c != caseOldObj.cc_Signature_Verifier_Result__c &&
               caseObj.cc_Application_Stages__c == 'Credit Signature Verification' && (caseObj.cc_Approved_Requested_Card_Type__c != 'PLATINUM_BALANCE_TRANSFER_01' && caseObj.Is_Balance_Transfer__c == false) && caseObj.Region_Flag__c == 'Bahrain'){
                   System.debug('Set Cases for Credit Signature for ila blue/black');
                   setCaseClosedBySignatureVerifier.add(caseObj.id);
               }
            //////// END : When Signature Verifier Result = 'Accept' then cases are closed in CRM, If Approved Requested Card Type = ila Blue or ila Black and Sending Status as 'Approved' in API ////////////////////
            //////// Start : When Signature Verifier Result = 'Accept' then cases are open in CRM, If Approved Requested Card Type = ila Switch, Approved Transfer Type = Balance Transfer and Sending Status as 'APPROVED_BT' in API ////////////////////
            //CH55: Added Region Flag in if condition
            //CH74: Added Is_Balance_Transfer__c in if condition for Cobranded Cards
            if(((caseObj.Type == 'Credit Card Application' && caseObj.Sub_Type__c == 'New Credit Card') || (caseObj.Type == 'Credit Limit Increase Application' && caseObj.Sub_Type__c == 'Credit Limit Increase')) &&
               caseObj.cc_Signature_Verifier_Result__c == 'Accept' &&  caseObj.cc_Signature_Verifier_Result__c != caseOldObj.cc_Signature_Verifier_Result__c &&
               caseObj.cc_Application_Stages__c == 'Credit Signature Verification' && (caseObj.cc_Approved_Requested_Card_Type__c == 'PLATINUM_BALANCE_TRANSFER_01' || caseObj.Is_Balance_Transfer__c == true) && caseObj.cc_Approved_Transfer_Type__c == 'Balance Transfer' && caseObj.Region_Flag__c == 'Bahrain'){
                   System.debug('Set Cases for Credit Signature for ila switch Balance Transfer');
                   setCasesRouteToBuyoutQueue.add(caseObj.id);
               }
            //////// END : When Signature Verifier Result = 'Accept' then cases are open in CRM, If Approved Requested Card Type = ila Switch and Sending Status as 'APPROVED_PENDING_RELEASE' in API ////////////////////
            //////// Start : When Signature Verifier Result = 'Accept' then cases are open in CRM, If Approved Requested Card Type = ila Switch, Approved Transfer Type = Buy Out and Sending Status as 'APPROVED_BT' in API ////////////////////
            //CH10: Start
            System.debug('Type:'+caseObj.Type);
            System.debug('Sub Type:'+caseObj.Sub_Type__c);
            System.debug('New Signature verifier Result:'+caseObj.cc_Signature_Verifier_Result__c);
            System.debug('Old Signature verifier Result:'+caseOldObj.cc_Signature_Verifier_Result__c);
            System.debug('Application Stage:'+caseObj.cc_Application_Stages__c);
            System.debug('Application Stage:'+caseOldObj.cc_Application_Stages__c);
            System.debug('Approved Requested Card Type:'+caseObj.cc_Approved_Requested_Card_Type__c);
            System.debug('Approved Transfer Type:'+caseObj.cc_Approved_Transfer_Type__c);
            //CH55: Added Region Flag in if condition
            //CH74: Added Is_Balance_Transfer__c in if condition for Cobranded Cards
            if(((caseObj.Type == 'Credit Card Application' && caseObj.Sub_Type__c == 'New Credit Card')) &&
               caseObj.cc_Signature_Verifier_Result__c == 'Accept' &&  caseObj.cc_Signature_Verifier_Result__c != caseOldObj.cc_Signature_Verifier_Result__c &&
               (caseObj.cc_Approved_Requested_Card_Type__c == 'PLATINUM_BALANCE_TRANSFER_01' || caseObj.Is_Balance_Transfer__c == true) && caseObj.cc_Approved_Transfer_Type__c == 'Buy Out' && caseObj.Region_Flag__c == 'Bahrain'){
                   System.debug('Set Cases for Credit Signature for ila switch Buy-Out');
                   setCasesRouteToBuyoutQueueForBuyoutType.add(caseObj.id);
               }
            //CH10: END
            //////// END : When Signature Verifier Result = 'Accept' then cases are open in CRM, If Approved Requested Card Type = ila Switch and Sending Status as 'APPROVED_PENDING_RELEASE' in API ////////////////////
            /////// Start : When Signature Verifier Result = Re-send it remains in the same Queue(Credit Signature Verification) and Sending Status as 'APPROVED_PENDING_SIGNATURE' in API ////////////////////////////////////
            //CH55: Added Region Flag in if condition
            if(((caseObj.Type == 'Credit Card Application' && caseObj.Sub_Type__c == 'New Credit Card') || (caseObj.Type == 'Credit Limit Increase Application' && caseObj.Sub_Type__c == 'Credit Limit Increase')) &&
               caseObj.cc_Signature_Verifier_Result__c == 'Re-Send' && caseObj.cc_Signature_Verifier_Result__c != caseOldObj.cc_Signature_Verifier_Result__c &&
               caseObj.cc_Application_Stages__c == 'Credit Signature Verification' && caseObj.Region_Flag__c == 'Bahrain'){
                   System.debug('Set Cases Remains in for Credit Signature verifier');
                   setCasesRemainInSignatureVerifier.add(caseObj.id);
               }
            /////// END : When Signature Verifier Result = Re-send it remains in the same Queue(Credit Signature Verification) and Sending Status as 'APPROVED_PENDING_SIGNATURE' in API ////////////////////////////////////
            ////// Start : When Signature Verifier Result = Refer to Service Center then Re-routing to Credit Card Service Center Queue ////////////////////////
            //CH55: Added Region Flag in if condition
            if(((caseObj.Type == 'Credit Card Application' && caseObj.Sub_Type__c == 'New Credit Card') || (caseObj.Type == 'Credit Limit Increase Application' && caseObj.Sub_Type__c == 'Credit Limit Increase')) &&
               caseObj.cc_Signature_Verifier_Result__c == 'Refer to Service Center' &&
               caseObj.cc_Signature_Verifier_Result__c != caseOldObj.cc_Signature_Verifier_Result__c &&
               caseObj.cc_Application_Stages__c == 'Credit Signature Verification' && caseObj.Region_Flag__c == 'Bahrain'){
                   System.debug('Set Cases for Credit Card Service Center Queue From Signature Verifier');
                   setCasesRoutedToCreditServiceCenterQueueFromSignatureVerifier.add(caseObj.id);
               }
            ////// END : When Signature Verifier Result = Refer to Service Center then Re-routing to Credit Card Service Center Queue ////////////////////////
            /******************************************* SIGNATURE VERIFIER RESULT END ***************************************************/
            /******************************************* CREDIT SERVICE CENTER RESULT START ********************************************/
            ////// Start : When Service Center Result = 'Return to Pre-screener' then Re-routing to Credit Card Pre-screener Queue ////////////////////////
            //CH55: Added Region Flag in if condition
            if(((caseObj.Type == 'Credit Card Application' && caseObj.Sub_Type__c == 'New Credit Card') || (caseObj.Type == 'Credit Limit Increase Application' && caseObj.Sub_Type__c == 'Credit Limit Increase') || (caseObj.Type == 'Credit Card Supplementary Application' && caseObj.Sub_Type__c == 'New Supplementary Card')) &&
               caseObj.cc_Service_Centre_Result__c == 'Return to Pre-Screener' && caseObj.cc_Service_Centre_Result__c != caseOldObj.cc_Service_Centre_Result__c &&
               caseObj.cc_Application_Stages__c == 'Credit Service Centre' && caseObj.Region_Flag__c == 'Bahrain'){
                   System.debug('Set Cases Routed from Service Center to Pre-screener queue');
                   setCaseRoutedToPreScreenerQueueFromServiceCenter.add(caseObj.id);
               }
            ////// END : When Service Center Result = 'Return to Pre-screener' then Re-routing to Credit Card Pre-screener Queue ////////////////////////
            ////// Start : When Service Center Result = 'Return to Evaluator' then Re-routing to Credit Card Evaluation Queue ////////////////////////
            //CH55: Added Region Flag in if condition
            if(((caseObj.Type == 'Credit Card Application' && caseObj.Sub_Type__c == 'New Credit Card') || (caseObj.Type == 'Credit Limit Increase Application' && caseObj.Sub_Type__c == 'Credit Limit Increase')) &&
               caseObj.cc_Service_Centre_Result__c == 'Return to Evaluator' &&
               caseObj.cc_Service_Centre_Result__c != caseOldObj.cc_Service_Centre_Result__c &&
               caseObj.cc_Application_Stages__c == 'Credit Service Centre' && caseObj.Region_Flag__c == 'Bahrain'){
                   System.debug('Set Cases Routed from Service Center to Evaluation queue');
                   setCaseRoutedToEvaluationQueueFromServiceCenter.add(caseObj.id);
               }
            ////// END : When Service Center Result = 'Return to Evaluator' then Re-routing to Credit Card Evaluation Queue ////////////////////////
            ////// Start : When Service Center Result = 'Return to Verifier' then Re-routing to Credit Verification Queue ////////////////////////
            //CH55: Added Region Flag in if condition
            if(((caseObj.Type == 'Credit Card Application' && caseObj.Sub_Type__c == 'New Credit Card') || (caseObj.Type == 'Credit Limit Increase Application' && caseObj.Sub_Type__c == 'Credit Limit Increase')) &&
               caseObj.cc_Service_Centre_Result__c == 'Return to Verifier' &&
               caseObj.cc_Service_Centre_Result__c != caseOldObj.cc_Service_Centre_Result__c &&
               caseObj.cc_Application_Stages__c == 'Credit Service Centre' && caseObj.Region_Flag__c == 'Bahrain'){
                   System.debug('Set Cases Routed from Service Center to Verification queue');
                   setCaseRoutedToVerificationQueueFromServiceCenter.add(caseObj.id);
               }
            ////// END : When Service Center Result = 'Return to Evaluator' then Re-routing to Credit Verification Queue ////////////////////////
            ////// Start : When Service Center Result = 'Return to Approver' then Re-routing to Credit Approver Queue ////////////////////////
            //CH55: Added Region Flag in if condition
            if(((caseObj.Type == 'Credit Card Application' && caseObj.Sub_Type__c == 'New Credit Card') || (caseObj.Type == 'Credit Limit Increase Application' && caseObj.Sub_Type__c == 'Credit Limit Increase')) &&
               caseObj.cc_Service_Centre_Result__c == 'Return to Approver' &&
               caseObj.cc_Service_Centre_Result__c != caseOldObj.cc_Service_Centre_Result__c &&
               caseObj.cc_Application_Stages__c == 'Credit Service Centre' && caseObj.Region_Flag__c == 'Bahrain'){
                   System.debug('Set Cases Routed from Service Center to Approval queue');
                   setCaseRoutedToApproverQueueFromServiceCenter.add(caseObj.id);
               }
            ////// END : When Service Center Result = 'Return to Approver' then Re-routing to Credit Approver Queue ////////////////////////
            ////// Start : When Service Center Result = 'Return to Signature Verifier' then Re-routing to Credit Signature Verification Queue ////////////////////////
            //CH55: Added Region Flag in if condition
            if(((caseObj.Type == 'Credit Card Application' && caseObj.Sub_Type__c == 'New Credit Card') || (caseObj.Type == 'Credit Limit Increase Application' && caseObj.Sub_Type__c == 'Credit Limit Increase')) &&
               caseObj.cc_Service_Centre_Result__c == 'Return to Signature Verifier' && caseObj.cc_Service_Centre_Result__c != caseOldObj.cc_Service_Centre_Result__c &&
               caseObj.cc_Application_Stages__c == 'Credit Service Centre' && caseObj.Region_Flag__c == 'Bahrain'){
                   System.debug('Set Cases Routed from Service Center to Signature Verification queue');
                   setCaseRoutedToSignatureVerifierFromServiceCenter.add(caseObj.id);
               }
            ////// END : When Service Center Result = 'Return to Signature Verifier' then Re-routing to Credit Signature Verification Queue ////////////////////////
            ////// Start : When Service Center Result = 'Release Letter Received' then Re-routing to Credit Evaluation Queue ////////////////////////
            //CH55: Added Region Flag in if condition
            if(((caseObj.Type == 'Credit Card Application' && caseObj.Sub_Type__c == 'New Credit Card') || (caseObj.Type == 'Credit Limit Increase Application' && caseObj.Sub_Type__c == 'Credit Limit Increase')) &&
               caseObj.cc_Service_Centre_Result__c == 'Release Letter Received' && caseObj.cc_Service_Centre_Result__c != caseOldObj.cc_Service_Centre_Result__c &&
               caseObj.cc_Application_Stages__c == 'Credit Service Centre' && caseObj.Region_Flag__c == 'Bahrain'){
                   System.debug('Set Cases Routed from Service Center to Evaluation queue if Release Letter Received');
                   setCaseRoutedToEvaluationFromServiceCenterIfLetterRec.add(caseObj.id);
               }
            ////// END : When Service Center Result = 'Release Letter Received' then Re-routing to Credit Evaluation Queue ////////////////////////
            //CH55: Added Region Flag in if condition
            if( (caseObj.Type == 'Credit Card Supplementary Application' && caseObj.Sub_Type__c == 'New Supplementary Card') &&
               caseObj.cc_Service_Centre_Result__c == 'Return to Maker' && caseObj.cc_Service_Centre_Result__c != caseOldObj.cc_Service_Centre_Result__c &&
               caseObj.cc_Application_Stages__c == 'Credit Service Centre' && caseObj.Region_Flag__c == 'Bahrain'){
                   System.debug('Set Cases Routed from Service Center to Evaluation queue if Release Letter Received');
                   setSuppCaseSCRoutedToMaker.add(caseObj.id);
               }
            /******************************************* CREDIT SERVICE CENTER RESULT END ********************************************/
            /******************************************* CREDIT BUYOUT OPERATIONS START ****************************************************/
            //CH55: Added Region Flag in if condition
            //CH74: Added Is_Balance_Transfer__c in if condition for Cobranded Cards
            if(((caseObj.Type == 'Credit Card Application' && caseObj.Sub_Type__c == 'New Credit Card')) &&
               caseObj.cc_Operations_Result__c == 'Balance Transfer Processed' && caseObj.cc_Operations_Result__c != caseOldObj.cc_Operations_Result__c &&
               caseObj.cc_Application_Stages__c == 'Credit Buyout' && (caseObj.cc_Approved_Requested_Card_Type__c == 'PLATINUM_BALANCE_TRANSFER_01' || caseObj.Is_Balance_Transfer__c == true) &&
               caseObj.cc_Approved_Transfer_Type__c == 'Buy Out' && caseObj.Region_Flag__c == 'Bahrain'){
                   System.debug('Set Cases Routing to Service Center if Approve Transfer type is Buyout');
                   setCaseRouteToServiceCenterFromBuyoutOperationsQueue.add(caseObj.id);
               }
            //CH55: Added Region Flag in if condition
            //CH74: Added Is_Balance_Transfer__c in if condition for Cobranded Cards
            if(((caseObj.Type == 'Credit Card Application' && caseObj.Sub_Type__c == 'New Credit Card')) &&
               caseObj.cc_Operations_Result__c == 'Card Block Released' && caseObj.cc_Operations_Result__c != caseOldObj.cc_Operations_Result__c &&
               caseObj.cc_Application_Stages__c == 'Credit Buyout' && (caseObj.cc_Approved_Requested_Card_Type__c == 'PLATINUM_BALANCE_TRANSFER_01' || caseObj.Is_Balance_Transfer__c == true) && caseObj.Region_Flag__c == 'Bahrain'){
                   System.debug('Set Cases Closed By Operations Team If Result is CARD BLOCK RELEASED');
                   setCaseClosedByOperationsForCardBlockRelease.add(caseObj.id);
               }
            /******************************************* CREDIT BUYOUT OPERATIONS END ****************************************************/
            /******************************************* HR APPROVAL RESULT START FOR ILA SWITCH-BALANCE TRANSFER **************************************************************/
            System.debug('Record Type Name:'+recordtypeName);
            System.debug('Old HR Result:'+caseOldObj.cc_HR_Result__c);
            System.debug('New HR Result:'+caseObj.cc_HR_Result__c);
            System.debug('Case Type:'+caseObj.Type);
            System.debug('Case Sub Type:'+caseObj.Sub_Type__c);
            //CH22: Start
            //CH55: Added Region Flag in if condition
            if(((caseObj.Type == 'Credit Card Application' && caseObj.Sub_Type__c == 'New Credit Card')) &&
               recordtypeName == 'Credit Card - Staff  Application' && (caseObj.cc_HR_Result__c != caseOldObj.cc_HR_Result__c && caseObj.cc_HR_Result__c =='Approved') && caseObj.Region_Flag__c == 'Bahrain')
            {
                //#CH87 : Start
                if(caseObj.Resend_DocuSign__c == 'Email' ){
                    System.debug('Set Cases for HR Approval Email------------> HR Signature Verifier');
                    setCaseRoutedToSignatureVerifierFromHR.add(caseObj.id);
                }
                else{
                    System.debug('Set Cases for HR Approval In-App------------> HR Signature Verifier');
                    setCaseRoutedToSignatureVerifierFromHRInApp.add(caseObj.id);
                }
                //#CH87 : End
            }
            //CH22: END
            /******************************************* HR APPROVAL RESULT END FOR ILA SWITCH-BALANCE TRANSFER **************************************************************/
            /******************************************* HR APPROVAL RESULT START FOR ILA SWITCH-BUYOUT ***********************************************************************/
            //CH10: Start
            //CH10: END
            /******************************************* HR APPROVAL RESULT END FOR ILA SWITCH-BUYOUT ***********************************************************************/
            /******************************************* HR APPROVAL RESULT START ACCEPT RELEASE LETTER **************************************************************/
            //CH55: Added Region Flag in if condition
            //CH13: Commented by #Jahangeer Mohammed# #02-11-2021# Credit Limit Update Condition.
            //CH74: Added Is_Balance_Transfer__c in if condition for Cobranded Cards
            if(((caseObj.Type == 'Credit Card Application' && caseObj.Sub_Type__c == 'New Credit Card')) &&
               recordtypeName == 'Credit Card - Staff  Application' &&
               (caseObj.cc_HR_Result__c != caseOldObj.cc_HR_Result__c && caseObj.cc_HR_Result__c =='Accept Release Letter') && (caseObj.cc_Approved_Requested_Card_Type__c == 'PLATINUM_BALANCE_TRANSFER_01' || caseObj.Is_Balance_Transfer__c == true) && caseObj.cc_Approved_Transfer_Type__c == 'Buy Out' && caseObj.Region_Flag__c == 'Bahrain')
            {
                System.debug('Set Cases for HR Result is Accept Release Letter');
                setCaseHRApprovedForReleaseLetter.add(caseObj.id);
            }
            /******************************************* HR APPROVAL RESULT END ACCEPT RELEASE LETTER **************************************************************/
            /******************************************* HR APPROVAL RESULT START FOR ILA BLUE/BLACK **************************************************************/
            /******************************************* HR APPROVAL RESULT END FOR ILA BLUE/BLACK **************************************************************/
            /******************************************* HR APPROVAL START FOR LIMIT UPDATE *******************************************************/
            //CH13: Start
            //CH24: Start
            //CH55: Added Region Flag in if condition
            if(((caseObj.Type == 'Credit Limit Increase Application' && caseObj.Sub_Type__c == 'Credit Limit Increase')) && recordtypeName == 'Credit Limit Increase Staff' &&
               (caseObj.cc_HR_Result__c != caseOldObj.cc_HR_Result__c && caseObj.cc_HR_Result__c =='Approved') && caseObj.Region_Flag__c == 'Bahrain')
            {
                //#CH87 : Start
                if(caseObj.Resend_DocuSign__c == 'Email' ){
                    System.debug('Set Cases for HR Approval in Credit Limit Update');
                    setCaseRoutedToSignatureVerifierFromHRForLimitIncrease.add(caseObj.id);
                }
                else{
                    System.debug('Set Cases for HR Approval in Credit Limit Update -- In-App');
                    setCaseRoutedToSignatureVerifierFromHRForLimitIncreaseInApp.add(caseObj.id);
                }
                //#CH87 : End
            }
            //CH24: END
            //CH13: END
            /******************************************* HR APPROVAL END FOR LIMIT UPDATE **********************************************************/
            //CH05: END
            /****************************************** HR REQUESTING FOR DIGITAL DOCUMENTS START ***********************************************************/
            //CH23: Start
            // //CH55: Added Region Flag in if condition
            if(((caseObj.Type == 'Credit Card Application' && caseObj.Sub_Type__c == 'New Credit Card' && recordtypeName == 'Credit Card - Staff  Application') || (caseObj.Type == 'Credit Limit Increase Application' && caseObj.Sub_Type__c == 'Credit Limit Increase'  && recordtypeName == 'Credit Limit Increase Staff')) &&
               caseObj.cc_Request_Digital_Documents__c != caseOldObj.cc_Request_Digital_Documents__c && caseObj.cc_Request_Digital_Documents__c == true &&
               caseObj.Status == 'Closed' && (caseObj.Sub_Status__c == 'Approved' || caseObj.Sub_Status__c == 'Balance Transfer Processed') && caseObj.Region_Flag__c == 'Bahrain'){
                   System.debug('Set Cases for HR Requesting for digital documents for Closed Cases');
                   setExistingCasesProvideDigitalDocs.add(caseObj.id);
               }
            //CH23: END
            /****************************************** HR REQUESTING FOR DIGITAL DOCUMENTS END **************************************************************/
            //CH55: Added Region Flag in if condition
            //CH02: Start
            if(((caseObj.Type == 'Credit Card Application' && caseObj.Sub_Type__c == 'New Credit Card') || (caseObj.Type == 'Credit Limit Increase Application' && caseObj.Sub_Type__c == 'Credit Limit Increase')) &&
               caseObj.cc_Signature_Verifier_Result__c != caseOldObj.cc_Signature_Verifier_Result__c && caseObj.cc_Signature_Verifier_Result__c =='Re-Send' && caseObj.Region_Flag__c == 'Bahrain'){
                   System.debug('Set Cases for Re-Send DocuSign');
                   reSendDocSet.add(caseObj.id);
               }
            //CH02: End
            //#CH84: Start
            if(((caseObj.Type == 'Credit Card Application' && caseObj.Sub_Type__c == 'New Credit Card') || (caseObj.Type == 'Credit Limit Increase Application' && caseObj.Sub_Type__c == 'Credit Limit Increase')) &&
               caseObj.cc_Signature_Verifier_Result__c != caseOldObj.cc_Signature_Verifier_Result__c && caseObj.cc_Signature_Verifier_Result__c =='Re-Send In-App' && caseObj.Region_Flag__c == 'Bahrain'){
                   System.debug('Set Cases for Re-Send In-App DocuSign');
                   reSendDocSetInApp.add(caseObj.id);//#CH84
               }
            //#CH84: End
            //CH55: Added Region Flag in if condition
            //CH36: Added extra brackets in if condition to avoid multiple future calls.
            //CH69: Start: Added a condition Signature Verifier Result = Decline in if Condition
            if(((caseObj.Type == 'Credit Card Application' && caseObj.Sub_Type__c == 'New Credit Card') || (caseObj.Type == 'Credit Limit Increase Application' && caseObj.Sub_Type__c == 'Credit Limit Increase')) &&
               ((caseObj.cc_CEO_Result__c != caseOldObj.cc_CEO_Result__c && caseObj.cc_CEO_Result__c == 'Decline') ||
                (caseObj.cc_Credit_Approval_Result__c != caseOldObj.cc_Credit_Approval_Result__c && caseObj.cc_Credit_Approval_Result__c =='Decline') ||
                (caseObj.cc_HR_Result__c != caseOldObj.cc_HR_Result__c && caseObj.cc_HR_Result__c =='Decline') ||
                (caseObj.cc_Business_Approval_Result__c != caseOldObj.cc_Business_Approval_Result__c && caseObj.cc_Business_Approval_Result__c =='Decline')||
                (caseObj.cc_Credit_Evaluation_Result__c != caseOldObj.cc_Credit_Evaluation_Result__c && (caseObj.cc_Credit_Evaluation_Result__c =='Rejected' || caseObj.cc_Credit_Evaluation_Result__c == 'Decline'))||
                (caseObj.cc_Credit_Verification_Result__c != caseOldObj.cc_Credit_Verification_Result__c && caseObj.cc_Credit_Verification_Result__c =='Decline')||
                (caseObj.cc_Credit_Pre_Screening_Result__c != caseOldObj.cc_Credit_Pre_Screening_Result__c && caseObj.cc_Credit_Pre_Screening_Result__c =='Decline')||
                (caseObj.cc_Signature_Verifier_Result__c != caseOldObj.cc_Signature_Verifier_Result__c && caseObj.cc_Signature_Verifier_Result__c =='Decline')) && caseObj.Region_Flag__c == 'Bahrain')
            {
                System.debug('Inside Decline Condition');
                setCaseDeclined.add(caseObj.id);
            }
            //CH55: Added Region Flag in if condition
            //CH69: END
            //CH10: Start
            //CH36: Added extra brackets in if condition to avoid multiple future calls.
            //CH69: Start: Added a condition Signature Verifier Result = Cancelled by Customer in if Condition
            if(((caseObj.Type == 'Credit Card Application' && caseObj.Sub_Type__c == 'New Credit Card') || (caseObj.Type == 'Credit Limit Increase Application' && caseObj.Sub_Type__c == 'Credit Limit Increase')) &&
               ((caseObj.cc_Credit_Approval_Result__c != caseOldObj.cc_Credit_Approval_Result__c && caseObj.cc_Credit_Approval_Result__c =='Cancelled by Customer') ||
                (caseObj.cc_HR_Result__c != caseOldObj.cc_HR_Result__c && caseObj.cc_HR_Result__c =='Cancelled by Customer') ||
                (caseObj.cc_Credit_Evaluation_Result__c != caseOldObj.cc_Credit_Evaluation_Result__c && caseObj.cc_Credit_Evaluation_Result__c =='Cancelled by Customer') ||
                (caseObj.cc_Credit_Verification_Result__c != caseOldObj.cc_Credit_Verification_Result__c && caseObj.cc_Credit_Verification_Result__c =='Cancelled by Customer')||
                (caseObj.cc_Credit_Pre_Screening_Result__c != caseOldObj.cc_Credit_Pre_Screening_Result__c && caseObj.cc_Credit_Pre_Screening_Result__c =='Cancelled by Customer')||
                (caseObj.cc_Signature_Verifier_Result__c != caseOldObj.cc_Signature_Verifier_Result__c && caseObj.cc_Signature_Verifier_Result__c =='Cancelled by Customer'))  && caseObj.Region_Flag__c == 'Bahrain')
            {
                System.debug('Inside CANCEL BY Customer Condition');
                setCasesCancelledByCustomer.add(caseObj.id);
            }
            //CH10: END
            //CH69: END
            //CH49: Start Added by #Jahangeer Mohammmed# #28-02-2023#
            //CH55: Added Region Flag in if condition
            if(!System.isFuture() && ((caseObj.Type == 'Credit Limit Increase Application' && caseObj.Sub_Type__c == 'Credit Limit Increase' && caseObj.cc_Credit_Pre_Screening_Result__c != caseOldObj.cc_Credit_Pre_Screening_Result__c && caseObj.cc_Credit_Pre_Screening_Result__c =='Expired') ||
                                      (caseObj.Type == 'Credit Card Supplementary Application' && caseObj.Sub_Type__c == 'New Supplementary Card' && caseObj.Sub_Status__c != caseOldObj.Sub_Status__c && caseObj.Sub_Status__c == 'Expired')) && caseObj.Region_Flag__c == 'Bahrain')
            {
                setCaseExpired.add(caseObj.id);
            }
            //CH49: END
            //CH13 : Start
            //CH26 : Commented by #Jahangeer Mohammed# #14-03-2022# related to Credit Card Application
            //CH55: Added Region Flag in if condition
            if((caseObj.Type == 'Credit Limit Increase Application') && caseOldObj.cc_SMS_Sent_Flag__c != caseObj.cc_SMS_Sent_Flag__c && caseObj.cc_SMS_Sent_Flag__c == true && caseObj.Region_Flag__c == 'Bahrain' ){
                setCasePendingForSMSReminders.add(caseObj.id);
            }
            //CH26 : Commented by #Jahangeer Mohammed# #14-03-2022# related to Credit Card Application
            //CH55: Added Region Flag in if condition
            //CH44 : Added by Jahangeer Mohammed #16-10-2022# related to 'Cash Collateral Credit Limit Increase Application' in if condition
            if((caseObj.Type == 'Credit Limit Increase Application' || caseObj.Type == 'Cash Collateral Credit Limit Increase Application') && caseOldObj.cc_signature_sms_sent_flag__c != caseObj.cc_signature_sms_sent_flag__c && caseObj.cc_signature_sms_sent_flag__c == true && caseObj.Region_Flag__c == 'Bahrain'){
                setCasePendingForSignatureReminders.add(caseObj.id);
            }
            //CH13 : END
            /////////////////////////////////////////////////////////////  Comments Clearing and Adding Section to the Case Feeds //////////////////////////////////////////////////////////////////////////////////
            //CH31 : Added condition for Cash Collateral and Supplementary Cards
            //CH55: Added Region Flag in if condition
            if(caseObj.cc_Credit_Pre_Screener_Comments__c !=caseOldObj.cc_Credit_Pre_Screener_Comments__c && caseObj.cc_Credit_Pre_Screener_Comments__c != null && caseObj.cc_Credit_Pre_Screener_Comments__c != '' && (caseObj.Type == 'Credit Card Application' || (caseObj.Type == 'Credit Limit Increase Application' && caseObj.Sub_Type__c == 'Credit Limit Increase') || caseObj.Type == 'Credit Card Cash Collateral Application' || caseObj.Type == 'Credit Card Supplementary Application' || caseObj.Type == 'New Loan / Finance Application') && caseObj.Region_Flag__c == 'Bahrain')
            {
                System.debug('Inside Prescreener Comments');
                CaseComment preScreenerComm = new CaseComment(ParentID=caseObj.id, CommentBody= 'Credit Pre-Screener Comments - '+ caseObj.cc_Credit_Pre_Screener_Comments__c);
                lstComment.add(preScreenerComm);
            }
            //CH55: Added Region Flag in if condition
            if(caseObj.cc_Credit_Evaluator_Comments__c !=caseOldObj.cc_Credit_Evaluator_Comments__c && caseObj.cc_Credit_Evaluator_Comments__c != null && caseObj.cc_Credit_Evaluator_Comments__c != '' && (caseObj.Type == 'Credit Card Application' || (caseObj.Type == 'Credit Limit Increase Application' && caseObj.Sub_Type__c == 'Credit Limit Increase') || caseObj.Type == 'New Loan / Finance Application') && caseObj.Region_Flag__c == 'Bahrain')
            {
                System.debug('Inside Evaluator Comments');
                CaseComment EvalComm = new CaseComment(ParentID=caseObj.id, CommentBody= 'Credit Evaluator Comments - '+ caseObj.cc_Credit_Evaluator_Comments__c);
                lstComment.add(EvalComm);
            }
            //CH55: Added Region Flag in if condition
            if(caseObj.cc_Credit_Verifier_Comments__c !=caseOldObj.cc_Credit_Verifier_Comments__c && caseObj.cc_Credit_Verifier_Comments__c != null && caseObj.cc_Credit_Verifier_Comments__c != '' && (caseObj.Type == 'Credit Card Application' || (caseObj.Type == 'Credit Limit Increase Application' && caseObj.Sub_Type__c == 'Credit Limit Increase') || caseObj.Type == 'New Loan / Finance Application') && caseObj.Region_Flag__c == 'Bahrain')
            {
                System.debug('Inside Verifier Comments');
                CaseComment VerifierComm = new CaseComment(ParentID=caseObj.id, CommentBody= 'Credit Verifier Comments - '+ caseObj.cc_Credit_Verifier_Comments__c);
                lstComment.add(VerifierComm);
            }
            //CH55: Added Region Flag in if conditionTeam
            //CH31 : Added Condition for Cash Collateral
            //CH90: Added  Type = Credit Card Upgrade
            if(caseObj.cc_Credit_Approver_Comments__c !=caseOldObj.cc_Credit_Approver_Comments__c && caseObj.cc_Credit_Approver_Comments__c != null && caseObj.cc_Credit_Approver_Comments__c != '' && (caseObj.Type == 'Credit Card Application' || caseObj.Type == 'Credit Limit Increase Application' || caseObj.Type == 'Credit Card Cash Collateral Application' || caseObj.Type == 'New Loan / Finance Application' || caseObj.Type == 'Credit Card Upgrade')  && caseObj.Region_Flag__c == 'Bahrain')
            {
                System.debug('Inside Approver Comments');
                CaseComment ApprovalComm = new CaseComment(ParentID=caseObj.id, CommentBody= 'Credit Approver Comments - '+ caseObj.cc_Credit_Approver_Comments__c);
                lstComment.add(ApprovalComm);
            }
            //CH90: END
            //CH55: Added Region Flag in if condition
            //CH31 : Added Condition for Cash Collateral
            if(caseObj.cc_Credit_Business_Team_Comments__c !=caseOldObj.cc_Credit_Business_Team_Comments__c && caseObj.cc_Credit_Business_Team_Comments__c != null && caseObj.cc_Credit_Business_Team_Comments__c != '' && (caseObj.Type == 'Credit Card Application' || (caseObj.Type == 'Credit Limit Increase Application' && caseObj.Sub_Type__c == 'Credit Limit Increase') || caseObj.Type == 'Credit Card Cash Collateral Application' || caseObj.Type == 'New Loan / Finance Application') && caseObj.Region_Flag__c == 'Bahrain')
            {
                System.debug('Inside Business Team Comments');
                CaseComment BusinessComm = new CaseComment(ParentID=caseObj.id, CommentBody= 'Credit Business Team Comments - '+ caseObj.cc_Credit_Business_Team_Comments__c);
                lstComment.add(BusinessComm);
            }
            //CH55: Added Region Flag in if condition
            //CH31 : Added Condition for Cash Collateral and Supplementary Cards
            if(caseObj.cc_Service_Centre_Comments__c !=caseOldObj.cc_Service_Centre_Comments__c && caseObj.cc_Service_Centre_Comments__c != null && caseObj.cc_Service_Centre_Comments__c != '' && (caseObj.Type == 'Credit Card Application' || (caseObj.Type == 'Credit Limit Increase Application' && caseObj.Sub_Type__c == 'Credit Limit Increase') || caseObj.Type == 'Credit Card Cash Collateral Application' || caseObj.Type == 'Credit Card Supplementary Application'  || caseObj.Type == 'New Loan / Finance Application') && caseObj.Region_Flag__c == 'Bahrain')
            {
                System.debug('Inside Service Center Comments');
                CaseComment SCComm = new CaseComment(ParentID=caseObj.id, CommentBody= 'Credit Service Centre Comments - '+ caseObj.cc_Service_Centre_Comments__c);
                lstComment.add(SCComm);
            }
            //CH55: Added Region Flag in if condition
            //CH31 : Added Condition for Cash Collateral
            //CH90: Added  Type = Credit Card Upgrade
            if(caseObj.cc_Contact_Centre_Comments__c !=caseOldObj.cc_Contact_Centre_Comments__c && caseObj.cc_Contact_Centre_Comments__c != null && caseObj.cc_Contact_Centre_Comments__c != '' && (caseObj.Type == 'Credit Card Application' || (caseObj.Type == 'Credit Limit Increase Application' && caseObj.Sub_Type__c == 'Credit Limit Increase') || caseObj.Type == 'Credit Card Cash Collateral Application' || caseObj.Type == 'New Loan / Finance Application' || caseObj.Type == 'Credit Card Upgrade') && caseObj.Region_Flag__c == 'Bahrain')
            {
                System.debug('Inside Contact Comments');
                CaseComment CCComm = new CaseComment(ParentID=caseObj.id, CommentBody= 'Credit Contact Centre Comments - '+ caseObj.cc_Contact_Centre_Comments__c);
                lstComment.add(CCComm);
            }
            //CH90: END
            //CH55: Added Region Flag in if condition
            //CH50: Start
            if(caseObj.Retention_Comments__c !=caseOldObj.Retention_Comments__c && caseObj.Retention_Comments__c != null && caseObj.Retention_Comments__c != '' && (caseObj.Type == 'Credit Card Application'  || caseObj.Type == 'New Loan / Finance Application') && caseObj.Region_Flag__c == 'Bahrain')
            {
                System.debug('Inside Retention Comments');
                CaseComment CCRetention = new CaseComment(ParentID=caseObj.id, CommentBody= 'Credit Retention Comments - '+ caseObj.Retention_Comments__c);
                lstComment.add(CCRetention);
            }
            //CH50: END
            // added by Shashank to update the HandOff Process Case Comments by Maker and Checker.
            // CH31 : Added Condition for Supplementary Cards
            //CH55: Added Region Flag in if condition
            //CH58: Start Added a Type = Credit Card Upgrade in If block
            //CH73: Removed Type from the if condition
            if(caseObj.cc_Maker_Comments__c !=caseOldObj.cc_Maker_Comments__c && caseObj.cc_Maker_Comments__c != null && caseObj.cc_Maker_Comments__c != '' && caseObj.Region_Flag__c == 'Bahrain')
            {
                System.debug('Inside Maker Comments');
                CaseComment makerComm = new CaseComment(ParentID=caseObj.id, CommentBody= 'Maker Comment - '+ caseObj.cc_Maker_Comments__c);
                lstComment.add(makerComm);
                caseIdstoUpdate.add(caseObj.Id);
            }
            //CH73: End
            //CH58: END
            //CH55: Added Region Flag in if condition
            //CH58: Start Added a Type = Credit Card Upgrade in If block
            //CH73: Removed Type from the if condition
            if(caseObj.cc_Checker_Comments__c !=caseOldObj.cc_Checker_Comments__c && caseObj.cc_Checker_Comments__c != null && caseObj.cc_Checker_Comments__c != '' && caseObj.Region_Flag__c == 'Bahrain')
            {
                System.debug('Inside Checker Comments');
                CaseComment checkerComm = new CaseComment(ParentID=caseObj.id, CommentBody= 'Checker Comment - '+ caseObj.cc_Checker_Comments__c);
                lstComment.add(checkerComm);
                caseIdstoUpdate.add(caseObj.Id);
            }
            //CH73: End
            //CH58: END
            //CH31 : Added Condition for Cash Collateral
            //CH05 : Start
            //CH55: Added Region Flag in if condition
            //CH76: Start
            if(caseObj.cc_Signature_Verification_Comments__c !=caseOldObj.cc_Signature_Verification_Comments__c && caseObj.cc_Signature_Verification_Comments__c != null && caseObj.cc_Signature_Verification_Comments__c != '' && (caseObj.Type == 'Credit Card Application' || (caseObj.Type == 'Credit Limit Increase Application' && caseObj.Sub_Type__c == 'Credit Limit Increase') || caseObj.Type == 'Credit Card Cash Collateral Application' || caseObj.Type == 'Credit Card Upgrade' || caseObj.Type == 'New Loan / Finance Application') && caseObj.Region_Flag__c == 'Bahrain')
            {
                System.debug('Inside Signature Verifier Comments');
                CaseComment signComments = new CaseComment(ParentID=caseObj.id, CommentBody= 'Credit Signature Verifier Comments - '+ caseObj.cc_Signature_Verification_Comments__c);
                lstComment.add(signComments);
            }
            //CH76: END
            //CH31 : Added Condition for Cash Collateral
            //CH55: Added Region Flag in if condition
            //CH90: Added  Type = Credit Card Upgrade
            if(caseObj.cc_Operations_Comments__c !=caseOldObj.cc_Operations_Comments__c && caseObj.cc_Operations_Comments__c != null && caseObj.cc_Operations_Comments__c != '' && (caseObj.Type == 'Credit Card Application' || (caseObj.Type == 'Credit Limit Increase Application' && caseObj.Sub_Type__c == 'Credit Limit Increase') || caseObj.Type == 'Credit Card Cash Collateral Application' || caseObj.Type == 'New Loan / Finance Application' || caseObj.Type == 'Credit Card Upgrade') && caseObj.Region_Flag__c == 'Bahrain')
            {
                System.debug('Inside Operations Comments');
                CaseComment operationComments = new CaseComment(ParentID=caseObj.id, CommentBody= 'Credit Operation Comments - '+ caseObj.cc_Operations_Comments__c);
                lstComment.add(operationComments);
            }
            //CH90: END
            //CH31 : Added Condition for Cash Collateral
            //CH08 : Start
            //CH55: Added Region Flag in if condition
            if(caseObj.cc_CEO_Comments__c !=caseOldObj.cc_CEO_Comments__c && caseObj.cc_CEO_Comments__c != null && caseObj.cc_CEO_Comments__c != '' && (caseObj.Type == 'Credit Card Application' || (caseObj.Type == 'Credit Limit Increase Application' && caseObj.Sub_Type__c == 'Credit Limit Increase') || caseObj.Type == 'Credit Card Cash Collateral Application' || caseObj.Type == 'New Loan / Finance Application') && caseObj.Region_Flag__c == 'Bahrain')
            {
                System.debug('Inside CEO Comments');
                CaseComment ceoComments = new CaseComment(ParentID=caseObj.id, CommentBody= 'Credit CEO Comments - '+ caseObj.cc_CEO_Comments__c);
                lstComment.add(ceoComments);
            }
            //CH08 : END
            //CH08 : END
            //CH12 : Start
            //CH31 : Added Condition for Cash Collateral
            //CH55: Added Region Flag in if condition
            //CH76: Start
            if(caseObj.cc_HR_Comments__c !=caseOldObj.cc_HR_Comments__c && caseObj.cc_HR_Comments__c != null && caseObj.cc_HR_Comments__c != '' && (caseObj.Type == 'Credit Card Application' || (caseObj.Type == 'Credit Limit Increase Application' && caseObj.Sub_Type__c == 'Credit Limit Increase') || caseObj.Type == 'Credit Card Cash Collateral Application' || caseObj.Type == 'Credit Card Upgrade') && caseObj.Region_Flag__c == 'Bahrain')
            {
                System.debug('Inside HR Comments');
                CaseComment hrComments = new CaseComment(ParentID=caseObj.id, CommentBody= 'Credit HR Comments - '+ caseObj.cc_HR_Comments__c);
                lstComment.add(hrComments);
            }
            //CH76: END
            //CH12 : END
            //CH55: Added Region Flag in if condition
            if(caseObj.cc_Anti_Attrition_Comment__c !=caseOldObj.cc_Anti_Attrition_Comment__c && caseObj.cc_Anti_Attrition_Comment__c != null && caseObj.cc_Anti_Attrition_Comment__c != '' && caseObj.Type == 'Credit Card Account Closing' && caseObj.Region_Flag__c == 'Bahrain')
            {
                System.debug('Inside Anti Attration Comments');
                CaseComment antiAttritionComments = new CaseComment(ParentID=caseObj.id, CommentBody= 'Credit Anti Attrition Comments - '+ caseObj.cc_Anti_Attrition_Comment__c);
                lstComment.add(antiAttritionComments);
            }
            //CH55: Added Region Flag in if condition
            if((caseObj.cc_Balance_Transfer_Amount__c != caseOldObj.cc_Balance_Transfer_Amount__c && caseObj.cc_Balance_Transfer_Amount__c != null)
               || (caseObj.cc_Balance_Transfer_Card_Provider__c != caseOldObj.cc_Balance_Transfer_Card_Provider__c && caseObj.cc_Balance_Transfer_Card_Provider__c != null)
               || (caseObj.cc_Balance_Transfer_Card_Number__c != caseOldObj.cc_Balance_Transfer_Card_Number__c && caseObj.cc_Balance_Transfer_Card_Number__c != null)
               || (caseObj.cc_Balance_Transfer_Type__c != caseOldObj.cc_Balance_Transfer_Type__c) && caseObj.cc_Balance_Transfer_Type__c != null && caseObj.Region_Flag__c == 'Bahrain'){
                   System.debug('Inside Balance Transfer Amount Update');
                   Case c = new Case();
                   c.Id = caseObj.Id;
                   c.cc_Approved_Balance_Transfer_Amount__c = caseObj.cc_Balance_Transfer_Amount__c;
                   c.cc_Approved_Balance_Transfer_Card_Number__c = caseObj.cc_Balance_Transfer_Card_Number__c;
                   c.cc_Approved_Balance_Transfer_Card_Provi__c = caseObj.cc_Balance_Transfer_Card_Provider__c;
                   c.cc_Approved_Transfer_Type__c = caseObj.cc_Balance_Transfer_Type__c;
                   caseLst.add(c);
               }
            //CH05 : END
            //CH06: Start
            //CH55: Added Region Flag in if condition
            //CH13: Start
            if(caseObj.cc_Signature_Verifier_Result__c =='Accept' && caseObj.Type =='Credit Limit Increase Application' && caseObj.cc_Signature_Verifier_Result__c != caseOldObj.cc_Signature_Verifier_Result__c && caseObj.Region_Flag__c == 'Bahrain'){
                System.debug('Signature Verifier Accepts for Credit Limit Increase');
                setCaseApprovedBySigVerifierForLimitIncrease.add(caseObj.Id);
            }
            //CH13: END
            //CH06: END
            ////////////////////////////////////// Updating Customer details on Contact Post Credit Evaluator Approval/ rejection on Case ///////////////////////////////////
            //CH55: Added Region Flag in if condition
            //CH40: Start
            if(((caseObj.Type == 'Credit Card Application' &&  caseObj.Sub_Type__c == 'New Credit Card') || (caseObj.Type =='Credit Limit Increase Application' && caseObj.Sub_Type__c == 'Credit Limit Increase')) && caseObj.cc_Credit_Approval_Result__c != caseOldObj.cc_Credit_Approval_Result__c && (caseObj.cc_Credit_Approval_Result__c == 'Approve' || caseObj.cc_Credit_Approval_Result__c == 'Decline') && caseObj.Region_Flag__c == 'Bahrain')
            {
                mapCasetoAccount.put(caseObj.Id, caseObj.AccountId);
            }
            //CH55: Added Region Flag in if condition
            if(((caseObj.Type == 'Credit Card Application' &&  caseObj.Sub_Type__c == 'New Credit Card') || (caseObj.Type =='Credit Limit Increase Application' && caseObj.Sub_Type__c == 'Credit Limit Increase')) && caseObj.cc_HR_Result__c != caseOldObj.cc_HR_Result__c && (caseObj.cc_HR_Result__c == 'Approved' || caseObj.cc_HR_Result__c == 'Decline')  && caseObj.Region_Flag__c == 'Bahrain')
            {
                mapCasetoAccountHR.put(caseObj.Id, caseObj.AccountId);
            }
            //CH40: END
            /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
            ///////////////////////////////////////////// Supplementary Card -- DECLINE/ CANCELLED BY CUSTOMER -- Maker/ Pre-Screener ///////////////////////////////////////
            //CH55: Added Region Flag in if condition
            if((caseObj.Type == 'Credit Card Supplementary Application' && caseObj.Sub_Type__c == 'New Supplementary Card')  &&
               ((caseObj.cc_Maker__c == 'Decline' && caseObj.cc_Maker__c != caseOldObj.cc_Maker__c) || (caseObj.cc_Credit_Pre_Screening_Result__c == 'Decline' && caseObj.cc_Credit_Pre_Screening_Result__c != caseOldObj.cc_Credit_Pre_Screening_Result__c)) && caseObj.Region_Flag__c == 'Bahrain'){
                   System.debug('Set Supplementary Cases from Maker Queue to Decline');
                   setSuppCaseDecline.add(caseObj.id);
               }
            //CH55: Added Region Flag in if condition
            if((caseObj.Type == 'Credit Card Supplementary Application' && caseObj.Sub_Type__c == 'New Supplementary Card')  &&
               ((caseObj.cc_Maker__c == 'Cancelled by Customer' && caseObj.cc_Maker__c != caseOldObj.cc_Maker__c) || (caseObj.cc_Credit_Pre_Screening_Result__c == 'Cancelled by Customer' && caseObj.cc_Credit_Pre_Screening_Result__c != caseOldObj.cc_Credit_Pre_Screening_Result__c)) && caseObj.Region_Flag__c == 'Bahrain'){
                   System.debug('Set Supplementary Cases from Maker Queue to Cancelled');
                   setSuppCaseCancelledByCustomer.add(caseObj.id);
               }
            /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
            //CH38: Start
            //CH86: Start
            if(recordtypeName == 'Customer Profile Update' && caseObj.cc_Checker_Result__c != caseOldObj.cc_Checker_Result__c && caseObj.cc_Checker_Result__c == 'Approve' && caseObj.Status != 'Closed'){
                if(caseObj.Type == 'Profile Update' || (caseObj.Type == 'Personal Info Update' && ((caseObj.Sub_Type__c == 'Mobile update') || (caseObj.Sub_Type__c == 'Email update') || (caseObj.Sub_Type__c == 'Expired ID Update') || (caseObj.Sub_Type__c == 'Name Fix / Update') || (caseObj.Sub_Type__c == 'Address update') || (caseObj.Sub_Type__c == 'Additional Information') || (caseObj.Sub_Type__c == 'Guardian Info') ||(caseObj.Sub_Type__c == 'Geo-Location Check') || (caseObj.Sub_Type__c == 'Credit Card Guarantor CIF')))){
                    System.debug('Customer Mobile Update for Automation of Production support');
                    setCaseProfileUpdate.add(caseObj.Id);
                }
            }
            //CH86: END
            //CH38: END
        }
        //CH38: Start
        if(!setCaseProfileUpdate.isEmpty()){
            profileUpdateHandler.profileUpdate(setCaseProfileUpdate);
        }
        //CH38: END
        //CH01: Start
        if(!cntIds.isEmpty()){
            System.debug('Contact Ids:'+cntIds);
            for(Case c : [Select id,ContactId,Status,cc_request_type__c,Sub_Type__c,Type from Case where (Type !='Manual Customer Archival' AND Sub_Type__c!='Archival' AND cc_request_type__c NOT IN ('Archival Duplicate','Archival Underage','Archival Stuck in OB stage','Archival Others')) and Status NOT IN('Closed','Approved','Rejected') AND (Region_Flag__c='Jordan' OR (Region_Flag__c='Bahrain' AND Archive__c=False))  AND  ContactId IN : (cntIds)]){
                system.debug('Type'+c.Type);
                system.debug('Sub_Type__c'+C.Sub_Type__c);
                system.debug('cc_request_type__c'+C.cc_request_type__c);
                if(mapContactToCases.containsKey(c.ContactId)){
                    mapContactToCases.get(c.ContactId).add(c);
                }
                else{
                    mapContactToCases.put(c.ContactId,new List<Case>{c});
                }
            }
            for(Case cs : newRecs){
                if(mapContactToCases.containsKey(cs.ContactId)){
                    cs.addError(System.Label.ARCHIVE_ERROR_MSG);
                }
            }
        }
        //CH01: END
        //CH85: Start
        if(ccservicecseIds.size()>0){
            CreditCardCacheQueuableAPI cacheCards =  new CreditCardCacheQueuableAPI(ccservicecseIds);
            System.enqueueJob(cacheCards);
        }
        //CH85: END
        if(!setCase.isEmpty())
        {
            initiateManualOnboarding.reTriggerManualOnboarding(setCase);
        }
        ////////////////////// Triggering the Continue Onboarding on Manual CLosure of eKYC cases /////////////////////
        if(!setCaseEKYC.isEmpty())
        {
            initiateManualOnboarding.EKYCManualClosure(setCaseEKYC);
        }
        if(!setCaseEKYCManualRetry.isEmpty())
        {
            initiateManualOnboarding.EKYCManualRetry_IDCase(setCaseEKYCManualRetry);
        }
        if(!setCaseEKYCIdentificationCase.isEmpty())
        {
            initiateManualOnboarding.EKYCManualRetry_IDCase(setCaseEKYCIdentificationCase);
        }
        ///////////////////////////////////////////////////////////////////////////////////////////////////////////////
        ////////////////////// Triggering the request for the Jamiyah Stop cases /////////////////////
        if(!setCaseStopJamiyah.isEmpty())
        {
            initiateManualOnboarding.stopJamiyahCase(setCaseStopJamiyah);
        }
        ///////////////////////////////////////////////////////////////////////////////////////////////////////////////
        ////////////////////// Credit Card update requests API calls /////////////////////
        if(!setCasePending.isEmpty())
        {
            initiateManualOnboarding.CCCaseUpdate(setCasePending);
        }
        if(!setCaseDocReceived.isEmpty())
        {
            initiateManualOnboarding.CCCaseUpdate(setCaseDocReceived);
        }
        if(!setCaseReferred.isEmpty())
        {
            initiateManualOnboarding.CCCaseUpdate(setCaseReferred);
        }
        if(!setCaseDocDiscrepancies.isEmpty())
        {
            System.debug('Discrepancy in Documents:'+setCaseDocDiscrepancies);
            initiateManualOnboarding.CCCaseUpdate(setCaseDocDiscrepancies);
        }
        //CH05: Start
        //CH22: Start
        if(!setCaseRoutedToSignatureVerifierFromHR.isEmpty())
        {
            if(!test.isRunningTest()){
                DocuSignApexToolKit autoSendDocSign =  new DocuSignApexToolKit(setCaseRoutedToSignatureVerifierFromHR);
                System.enqueueJob(autoSendDocSign);
            }
            initiateManualOnboarding.CCCaseUpdate(setCaseRoutedToSignatureVerifierFromHR);
        }
        //CH22: END
        //#CH87 : Start
        if(!setCaseRoutedToSignatureVerifierFromHRInApp.isEmpty() && !test.isRunningTest()){
            System.debug('HR Approval for InApp Scenario-----> '+setCaseRoutedToSignatureVerifierFromHRInApp);
            cc_DocuSignGetEnvelopeId.cc_DocuSignGetEnvelopeIdProcess(setCaseRoutedToSignatureVerifierFromHRInApp);
        }
        //#CH87 : End
        //CH23: Start
        if(!setExistingCasesProvideDigitalDocs.isEmpty()){
            if(!test.isRunningTest()){
                DocuSignApexToolKit autoSendDocSign =  new DocuSignApexToolKit(setExistingCasesProvideDigitalDocs);
                System.enqueueJob(autoSendDocSign);
            }
        }
        //CH23: END
        //CH10: Start
        if(!setCasesCancelledByCustomer.isEmpty()){
            System.debug('CUSTOMER CANCELLED CARD:'+setCasesCancelledByCustomer);
            initiateManualOnboarding.CCCaseUpdate(setCasesCancelledByCustomer);
        }
        if(!setCaseHRApprovedForBuyout.isEmpty()){
            System.debug('HR APPROVER FOR BUYOUT CARD --------> BUYOUT QUEUE:'+setCaseHRApprovedForBuyout);
            initiateManualOnboarding.CCCaseUpdate(setCaseHRApprovedForBuyout);
        }
        if(!setCasesRouteToBuyoutQueueForBuyoutType.isEmpty()){
            System.debug('SIGNATURE VERIFIER ACCEPT ILA SWITCH - BUY OUT --------> BUYOUT QUEUE:'+setCasesRouteToBuyoutQueueForBuyoutType);
            initiateManualOnboarding.CCCaseUpdate(setCasesRouteToBuyoutQueueForBuyoutType);
        }
        //CH10: END
        if(!setCaseHRApprovedForReleaseLetter.isEmpty()){
            System.debug('HR APPROVER --------> BUYOUT QUEUE:'+setCaseHRApprovedForReleaseLetter);
            initiateManualOnboarding.CCCaseUpdate(setCaseHRApprovedForReleaseLetter);
        }
        //CH05: END
        //CH02: Start
        if(!reSendDocSet.isEmpty() && !test.isRunningTest()){
            DocuSignApexToolKit autoSendDocSign =  new DocuSignApexToolKit(reSendDocSet);
            System.enqueueJob(autoSendDocSign);
        }
        //CH02: END
        //#CH84: Start
        if(!reSendDocSetInApp.isEmpty() && !test.isRunningTest()){
            System.debug('Credit Card reSendDocSetInApp for InApp -----> '+reSendDocSetInApp);
            cc_DocuSignGetEnvelopeId.cc_DocuSignGetEnvelopeIdProcess(reSendDocSetInApp);
        }
        //#CH84: END
        System.debug('Decline Case Id:'+setCaseDeclined);
        if(!setCaseDeclined.isEmpty())
        {
            initiateManualOnboarding.CCCaseUpdate(setCaseDeclined);
        }
        if(!setCaseExpired.isEmpty())
        {
            initiateManualOnboarding.CCCaseUpdate(setCaseExpired);
        }
        //CH13: Start
        if(!setCasePendingForSMSReminders.isEmpty()){
            System.debug('Reminder Activation for Pending/Discrepancy SMS:'+setCasePendingForSMSReminders);
            initiateManualOnboarding.sendSMSReminder(setCasePendingForSMSReminders);
        }
        if(!setCasePendingForSignatureReminders.isEmpty()){
            System.debug('Reminder Activation for Pending Signature SMS:'+setCasePendingForSignatureReminders);
            initiateManualOnboarding.sendSMSReminder(setCasePendingForSignatureReminders);
        }
        //CH13: END
        //CH05: Start
        if(!setCaseRoutedFromPreScreenerToEvaluator.isEmpty()){
            System.debug('Credit Card Evaluator Queue:'+setCaseRoutedFromPreScreenerToEvaluator);
            initiateManualOnboarding.CCCaseUpdate(setCaseRoutedFromPreScreenerToEvaluator);
        }
        //CH50: Start
        if(!setCaseRoutedFromPrescreenertoCreditRetention.isEmpty()){
            System.debug('Credit Card Retention Queue:'+setCaseRoutedFromPrescreenertoCreditRetention);
            initiateManualOnboarding.CCCaseUpdate(setCaseRoutedFromPrescreenertoCreditRetention);
        }
        //CH50: END
        if(!setCaseRoutedFromPrescreenerToServiceCenter.isEmpty()){
            System.debug('Credit Card Pre screener----->Service Center Queue:'+setCaseRoutedFromPrescreenerToServiceCenter);
            initiateManualOnboarding.CCCaseUpdate(setCaseRoutedFromPrescreenerToServiceCenter);
        }
        if(!setCaseRoutedFromEvaluatorToServiceCenter.isEmpty()){
            System.debug('Credit Card Evaluator----->Service Center Queue:'+setCaseRoutedFromEvaluatorToServiceCenter);
            initiateManualOnboarding.CCCaseUpdate(setCaseRoutedFromEvaluatorToServiceCenter);
        }
        if(!setCaseRoutedFromEvaluatorToVerifier.isEmpty()){
            System.debug('Credit Card Evaluator----->Verifier:'+setCaseRoutedFromEvaluatorToVerifier);
            initiateManualOnboarding.CCCaseUpdate(setCaseRoutedFromEvaluatorToVerifier);
        }
        //CH10: Start
        if(!setCaseAcceptedByEvaluator.isEmpty()){
            System.debug('Credit Card Evaluator----->Accept Release Letter:'+setCaseAcceptedByEvaluator);
            initiateManualOnboarding.CCCaseUpdate(setCaseAcceptedByEvaluator);
        }
        //CH10: END
        if(!setCaseRoutedFromVerifierToApprover.isEmpty()){
            System.debug('Credit Card Verifier----->Approver:'+setCaseRoutedFromVerifierToApprover);
            initiateManualOnboarding.CCCaseUpdate(setCaseRoutedFromVerifierToApprover);
        }
        if(!setCaseRoutedFromVerifierToServiceCenter.isEmpty()){
            System.debug('Credit Card Verifier----->Service Center:'+setCaseRoutedFromVerifierToServiceCenter);
            initiateManualOnboarding.CCCaseUpdate(setCaseRoutedFromVerifierToServiceCenter);
        }
        if(!setCasesRoutedToCreditSignatureVerificationQueueFromApprover.isEmpty() && !test.isRunningTest()){
            System.debug('Credit Card Approver----->Signature Verification:'+setCasesRoutedToCreditSignatureVerificationQueueFromApprover);
            //CH02:Start
            DocuSignApexToolKit autoSendDocSign =  new DocuSignApexToolKit(setCasesRoutedToCreditSignatureVerificationQueueFromApprover);
            System.enqueueJob(autoSendDocSign);
            //CH02: End
            initiateManualOnboarding.CCCaseUpdate(setCasesRoutedToCreditSignatureVerificationQueueFromApprover);
        }
        //#CH84 : Start
        if(!setCasesRoutedToCreditSignatureVerificationQueueFromApproverInApp.isEmpty() && !test.isRunningTest()){
            System.debug('Credit Card Approver for InApp Scenario-----> '+setCasesRoutedToCreditSignatureVerificationQueueFromApproverInApp);
            cc_DocuSignGetEnvelopeId.cc_DocuSignGetEnvelopeIdProcess(setCasesRoutedToCreditSignatureVerificationQueueFromApproverInApp);
        }
        //#CH84 : End
        if(!setCaseRouteToServiceCenterFromBuyoutOperationsQueue.isEmpty()){
            System.debug('Credit Card Buyout Operations----->Service Center:'+setCaseRouteToServiceCenterFromBuyoutOperationsQueue);
            initiateManualOnboarding.CCCaseUpdate(setCaseRouteToServiceCenterFromBuyoutOperationsQueue);
        }
        if(!setCaseClosedByOperationsForCardBlockRelease.isEmpty()){
            System.debug('Credit Card Operations Card block release:'+setCaseClosedByOperationsForCardBlockRelease);
            initiateManualOnboarding.CCCaseUpdate(setCaseClosedByOperationsForCardBlockRelease);
        }
        //////////////////////////// Start : Cases Routing to Credit Service Center when Credit Approval Result = 'Refer to Service Center' in CRM and Sending Status 'REFERRED' in API ///////////////////////////////////////
        if(!setCasesRoutedToCreditServiceCenterQueueFromApprover.isEmpty()){
            System.debug('Credit Card Service Center Queue:'+setCasesRoutedToCreditServiceCenterQueueFromApprover);
            initiateManualOnboarding.CCCaseUpdate(setCasesRoutedToCreditServiceCenterQueueFromApprover);
        }
        ////////////////////////// END : Cases Routing to Credit Service Center when Credit Approval Result = 'Refer to Service Center' in CRM and Sending Status 'REFERRED' in API ///////////////////////////////////////
        //////// Start : When Signature Verifier Result = 'Accept' then cases are closed in CRM, If Approved Requested Card Type = ila Blue or ila Black and Sending Status as 'Approved' in API ////////////////////
        if(!setCaseClosedBySignatureVerifier.isEmpty()){
            System.debug('Credit Signature Verifier Queue:'+setCaseClosedBySignatureVerifier);
            initiateManualOnboarding.CCCaseUpdate(setCaseClosedBySignatureVerifier);
        }
        //////// END : When Signature Verifier Result = 'Accept' then cases are closed in CRM, If Approved Requested Card Type = ila Blue or ila Black and Sending Status as 'Approved' in API ////////////////////
        //////// Start : When Signature Verifier Result = 'Accept' then cases are open in CRM, If Approved Requested Card Type = ila Switch and Sending Status as 'APPROVED_BT' in API ////////////////////
        if(!setCasesRouteToBuyoutQueue.isEmpty()){
            System.debug('Credit Card Buyout Queue for Balance Transfer:'+setCasesRouteToBuyoutQueue);
            initiateManualOnboarding.CCCaseUpdate(setCasesRouteToBuyoutQueue);
        }
        //////// END : When Signature Verifier Result = 'Accept' then cases are open in CRM, If Approved Requested Card Type = ila Switch and Sending Status as 'APPROVED_PENDING_RELEASE' in API ////////////////////
        //CH13: Start
        if(!setCaseApprovedBySigVerifierForLimitIncrease.isEmpty()){
            System.debug('Signature Verifier is Accept for Limit Update:'+setCaseApprovedBySigVerifierForLimitIncrease);
            initiateManualOnboarding.CCCaseUpdate(setCaseApprovedBySigVerifierForLimitIncrease);
        }
        //CH24: Start
        if(!setCaseRoutedToSignatureVerifierFromHRForLimitIncrease.isEmpty())
        {
            if(!test.isRunningTest()){
                DocuSignApexToolKit autoSendDocSign =  new DocuSignApexToolKit(setCaseRoutedToSignatureVerifierFromHRForLimitIncrease);
                System.enqueueJob(autoSendDocSign);
            }
            initiateManualOnboarding.CCCaseUpdate(setCaseRoutedToSignatureVerifierFromHRForLimitIncrease);
        }
        //CH24: END
        //#CH87 : Start
        if(!setCaseRoutedToSignatureVerifierFromHRForLimitIncreaseInApp.isEmpty() && !test.isRunningTest()){
            System.debug('HR Approval for InApp Scenario-----> '+setCaseRoutedToSignatureVerifierFromHRForLimitIncreaseInApp);
            cc_DocuSignGetEnvelopeId.cc_DocuSignGetEnvelopeIdProcess(setCaseRoutedToSignatureVerifierFromHRForLimitIncreaseInApp);
        }
        //#CH87 : End
        //CH13: END
        /////// Start : When Signature Verifier Result = Re-send it remains in the same Queue(Credit Signature Verification) and Sending Status as 'APPROVED_PENDING_SIGNATURE' in API ////////////////////////////////////
        if(!setCasesRemainInSignatureVerifier.isEmpty()){
            System.debug('Case Remain in Credit Signature Verifier Queue:'+setCasesRemainInSignatureVerifier);
            initiateManualOnboarding.CCCaseUpdate(setCasesRemainInSignatureVerifier);
        }
        /////// END : When Signature Verifier Result = Re-send it remains in the same Queue(Credit Signature Verification) and Sending Status as 'APPROVED_PENDING_SIGNATURE' in API ////////////////////////////////////
        ////// Start : When Signature Verifier Result = Refer to Service Center then Re-routing to Credit Card Service Center Queue ////////////////////////
        if(!setCasesRoutedToCreditServiceCenterQueueFromSignatureVerifier.isEmpty()){
            System.debug('Case Routed to Service Center from Verifier Signature:'+setCasesRoutedToCreditServiceCenterQueueFromSignatureVerifier);
            initiateManualOnboarding.CCCaseUpdate(setCasesRoutedToCreditServiceCenterQueueFromSignatureVerifier);
        }
        ////// END : When Signature Verifier Result = Refer to Service Center then Re-routing to Credit Card Service Center Queue ////////////////////////
        ////// Start : When Service Center Result = 'Return to Pre-screener' then Re-routing to Credit Card Pre-screener Queue ////////////////////////
        if(!setCaseRoutedToPreScreenerQueueFromServiceCenter.isEmpty()){
            System.debug('Case Routed to Pre-screener from Service Center:'+setCaseRoutedToPreScreenerQueueFromServiceCenter);
            initiateManualOnboarding.CCCaseUpdate(setCaseRoutedToPreScreenerQueueFromServiceCenter);
        }
        ////// END : When Service Center Result = 'Return to Pre-screener' then Re-routing to Credit Card Pre-screener Queue ////////////////////////
        ////// Start : When Service Center Result = 'Return to Evaluator' then Re-routing to Credit Card Evaluation Queue ////////////////////////
        if(!setCaseRoutedToEvaluationQueueFromServiceCenter.isEmpty()){
            System.debug('Case Routed to Evaluation from Service Center:'+setCaseRoutedToEvaluationQueueFromServiceCenter);
            initiateManualOnboarding.CCCaseUpdate(setCaseRoutedToEvaluationQueueFromServiceCenter);
        }
        ////// END : When Service Center Result = 'Return to Evaluator' then Re-routing to Credit Card Evaluation Queue ////////////////////////
        ////// Start : When Service Center Result = 'Return to Verifier' then Re-routing to Credit Verification Queue ////////////////////////
        if(!setCaseRoutedToVerificationQueueFromServiceCenter.isEmpty()){
            System.debug('Case Routed to Verification from Service Center:'+setCaseRoutedToVerificationQueueFromServiceCenter);
            initiateManualOnboarding.CCCaseUpdate(setCaseRoutedToVerificationQueueFromServiceCenter);
        }
        ////// END : When Service Center Result = 'Return to Verifier' then Re-routing to Credit Verification Queue ////////////////////////
        ////// Start : When Service Center Result = 'Return to Approver' then Re-routing to Credit Approver Queue ////////////////////////
        if(!setCaseRoutedToApproverQueueFromServiceCenter.isEmpty()){
            System.debug('Case Routed to Approval from Service Center:'+setCaseRoutedToApproverQueueFromServiceCenter);
            initiateManualOnboarding.CCCaseUpdate(setCaseRoutedToApproverQueueFromServiceCenter);
        }
        ////// END : When Service Center Result = 'Return to Approver' then Re-routing to Credit Approver Queue ////////////////////////
        ////// Start : When Service Center Result = 'Return to Signature Verifier' then Re-routing to Credit Signature Verification Queue ////////////////////////
        if(!setCaseRoutedToSignatureVerifierFromServiceCenter.isEmpty()){
            System.debug('Case Routed to Signature Verifier from Service Center:'+setCaseRoutedToSignatureVerifierFromServiceCenter);
            initiateManualOnboarding.CCCaseUpdate(setCaseRoutedToSignatureVerifierFromServiceCenter);
        }
        ////// END : When Service Center Result = 'Return to Signature Verifier' then Re-routing to Credit Signature Verification Queue ////////////////////////
        ////// Start : When Service Center Result = 'Release Letter Received' then Re-routing to Credit Evaluation Queue ////////////////////////
        if(!setCaseRoutedToEvaluationFromServiceCenterIfLetterRec.isEmpty()){
            System.debug('Case Routed to Evaluation Queue from Service Center:'+setCaseRoutedToEvaluationFromServiceCenterIfLetterRec);
            initiateManualOnboarding.CCCaseUpdate(setCaseRoutedToEvaluationFromServiceCenterIfLetterRec);
        }
        ////// END : When Service Center Result = 'Release Letter Received' then Re-routing to Credit Evaluation Queue ////////////////////////
        /////////////////////////////////////////////// Supplementary Card APIs calling based on the results ///////////////////////////////////////////////////////////////
        if(!setSuppCaseMakerReferToSC.isEmpty()){
            initiateManualOnboarding.CCCaseUpdate(setSuppCaseMakerReferToSC);
        }
        if(!setSuppCaseMakerRelationshipEstablishment.isEmpty()){
            initiateManualOnboarding.CCCaseUpdate(setSuppCaseMakerRelationshipEstablishment);
        }
        if(!setSuppCaseMakerSendPreScreener.isEmpty()){
            initiateManualOnboarding.CCCaseUpdate(setSuppCaseMakerSendPreScreener);
        }
        if(!setSuppCasePrescreenerRelationshipEstablishment.isEmpty()){
            initiateManualOnboarding.CCCaseUpdate(setSuppCasePrescreenerRelationshipEstablishment);
        }
        if(!setSuppCasePreScreenerApproved.isEmpty()){
            initiateManualOnboarding.CCCaseUpdate(setSuppCasePreScreenerApproved);
        }
        if(!setSuppCasePrescreenerToSC.isEmpty()){
            initiateManualOnboarding.CCCaseUpdate(setSuppCasePrescreenerToSC);
        }
        if(!setSuppCaseSCRoutedToMaker.isEmpty()){
            initiateManualOnboarding.CCCaseUpdate(setSuppCaseSCRoutedToMaker);
        }
        if(!setSuppCaseDecline.isEmpty()){
            initiateManualOnboarding.CCCaseUpdate(setSuppCaseDecline);
        }
        if(!setSuppCaseCancelledByCustomer.isEmpty()){
            initiateManualOnboarding.CCCaseUpdate(setSuppCaseCancelledByCustomer);
        }
        ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
        if(!caseLst.isEmpty()){
            update caseLst;
        }
        //CH05: END
        if(!mapCasetoAccount.isEmpty())
        {
            creditCardCustomerProfileUpdate.updateCustomerdetails(mapCasetoAccount);
        }
        //CH40: Start
        if(!mapCasetoAccountHR.isEmpty())
        {
            creditCardCustomerProfileUpdate.updateCustomerdetailsVIAHR(mapCasetoAccountHR);
        }
        //CH40: END
        System.debug('List Of Comments Outside Check recursive:'+lstComment.size());
        System.debug('Detail Of Comments Outside Check recursive:'+lstComment);
        if(lstComment.size()>0){
            System.debug('List Of Comments inside Check recursive:'+lstComment.size());
            System.debug('Detail Of Comments inside Check recursive:'+lstComment);
            insert lstComment;
        }
        //CH73: Start
        if(!caseIdstoUpdate.isEmpty()) {
            CaseProcessingHandler.clearMakerCheckerComments(caseIdstoUpdate);
        }
        //CH73: End
    }
}
