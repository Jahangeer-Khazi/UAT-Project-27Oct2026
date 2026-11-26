/*     Organization : ABC Bank
*      Description  : Support class for CaseHandler. Contains the Credit Card after-update logic that was previously in CaseHandler.reStartManualOnboarding.
*                     Moved reStartManualOnboarding from CaseHandler and renamed it to creditCardApplicationUpdate
*                     Moved the Credit Card logic of CaseHandler.setContact into creditCardApplicationInsert 
*                     Moved the Credit Card logic of CaseHandler.before_UpdateDML into creditCardBeforeUpdate and creditCardBeforeUpdateRouting
*                     Removed duplicate code with private helper methods (HELPER METHODS section) and removed dead code (unused variables, empty if blocks, never-filled sets)               
*      Created Date : 01-11-2026
*      Change History:
*                  
*/
public without sharing class CreditCardHandler {
    private static final String  CREDIT_CARD_PRE_SCREENER_QUEUE = 'Credit Card Pre-Screener Queue';
    /**
    * @description After-update processing for Case records (moved from CaseHandler).
    * @param newRecs  Trigger.new  - updated Case records
    * @param oldMap   Trigger.oldMap - previous versions of the Case records
    */
    public static void creditCardApplicationUpdate(final List<Case> newRecs, final Map<Id, Case> oldMap) {
        Map<ID,Schema.RecordTypeInfo> rt_Map = Case.sObjectType.getDescribe().getRecordTypeInfosById();
        //CH02: Start
        Set<Id> reSendDocSet = new Set<Id>();
        //CH02: END
        Set<Id> reSendDocSetInApp = new Set<Id>();//#CH84
        Set<Id> setCasePending = new Set<Id>();
        Set<Id> setCaseDocReceived  = new Set<Id>();
        Set<Id> setCaseDocDiscrepancies  = new Set<Id>();
        Set<Id> setCaseDeclined  = new Set<Id>();
        Set<Id> setCaseExpired = new Set<Id>();
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
        Set<Id> setCasesRouteToBuyoutQueueForBuyoutType = new Set<Id>();
        //CH10: END
        Set<Id> setCaseHRApprovedForReleaseLetter  = new Set<Id>();
        Set<Id> setCaseAcceptedByEvaluator = new Set<Id>();
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
        Map<Id, Id> mapCasetoAccount = new Map<Id, Id>();
        //CH40: Start
        Map<Id, Id> mapCaseToAccountHR = new Map<Id, Id>();
        //CH40: END
        List<CaseComment> lstComment = new List<CaseComment>();
        //CH73: Start
        Set<Id> caseIdstoUpdate = new Set<Id>();
        //CH73: End
        //CH85: Start
        Set<Id> ccservicecseIds = new Set<Id>();
        //CH85: END
        for(Case caseObj : newRecs) {
            Case caseOldObj = oldMap.get(caseobj.id);
            string recordtypeName = rt_Map.get(caseObj.RecordTypeId).getName();
            //CH07: Start
            //CH09: END
            //CH85: Start
            if(recordtypeName == 'Credit Card Services' && changedTo(caseObj, caseOldObj, Case.Status, 'Closed')){
                ccservicecseIds.add(caseObj.id);
            }
            //CH85: END
            //CH55: Added Region Flag in if condition
            if(changedTo(caseObj, caseOldObj, Case.Sub_Status__c, 'Pending') && caseObj.Region_Flag__c == 'Bahrain' && (isNewCreditCard(caseObj)  || isSupplementaryCard(caseObj) || isLimitIncrease(caseObj)))
            {
                system.debug('----> check in 1 --> '+caseObj);
                setCasePending.add(caseObj.id);
            }
            //CH55: Added Region Flag in if condition
            if(changedTo(caseObj, caseOldObj, Case.Sub_Status__c, 'Documents Received') && caseObj.Region_Flag__c == 'Bahrain'  && (isNewCreditCard(caseObj)  || isSupplementaryCard(caseObj) || isLimitIncrease(caseObj)))
            {
                setCaseDocReceived.add(caseObj.id);
            }
            System.debug('New Substatus:'+caseObj.Sub_Status__c);
            System.debug('Old Substatus:'+caseOldObj.Sub_Status__c);
            //CH55: Added Region Flag in if condition
            if(changedTo(caseObj, caseOldObj, Case.Sub_Status__c, 'Discrepancies') && caseObj.Region_Flag__c == 'Bahrain' && (isNewCreditCard(caseObj)  || isSupplementaryCard(caseObj) || isLimitIncrease(caseObj)))
            {
                System.debug('Dicrepancy in Documents');
                setCaseDocDiscrepancies.add(caseObj.id);
            }
            //CH05: Start
            /******************************************* CREDIT MAKER RESULT START ************************************************/
            //CH55: Added Region Flag in if condition
            if(isSupplementaryCard(caseObj)  &&
               changedTo(caseObj, caseOldObj, Case.cc_Maker__c, 'Refer to Service Center') &&
               caseObj.cc_Application_Stages__c == 'Credit Maker' && caseObj.Region_Flag__c == 'Bahrain'){
                   System.debug('Set Supplementary Cases from Maker Queue to Service Center');
                   setSuppCaseMakerReferToSC.add(caseObj.id);
               }
            //CH55: Added Region Flag in if condition
            if(isSupplementaryCard(caseObj)  &&
               changedTo(caseObj, caseOldObj, Case.cc_Maker__c, 'Pending Relationship Establishment') &&
               caseObj.cc_Application_Stages__c == 'Credit Maker' && caseObj.Region_Flag__c == 'Bahrain'){
                   System.debug('Set Supplementary Cases from Maker Queue to Temp Queue');
                   setSuppCaseMakerRelationshipEstablishment.add(caseObj.id);
               }
            //CH55: Added Region Flag in if condition
            if(isSupplementaryCard(caseObj)  &&
               changedTo(caseObj, caseOldObj, Case.cc_Maker__c, 'Send to Pre-Screener') &&
               caseObj.cc_Application_Stages__c == 'Credit Maker' && caseObj.Region_Flag__c == 'Bahrain'){
                   System.debug('Set Supplementary Cases from Maker Queue to PreScreener');
                   setSuppCaseMakerSendPreScreener.add(caseObj.id);
               }
            /******************************************************************************************************************************/
            //CH05: Start
            /******************************************* CREDIT PRE SCREENING RESULT START ************************************************/
            System.debug('Pre screening App Stage:'+caseObj.cc_Application_Stages__c);
            //CH55: Added Region Flag in if condition
            if((isNewCreditCard(caseObj)  || isLimitIncrease(caseObj)) &&
               changedTo(caseObj, caseOldObj, Case.cc_Credit_Pre_Screening_Result__c, 'Accept') &&
               caseObj.cc_Application_Stages__c == 'Credit Pre-Screening' && caseObj.Region_Flag__c == 'Bahrain'){
                   System.debug('Set Cases from Temp Queue to Pre screener');
                   setCaseRoutedFromPreScreenerToEvaluator.add(caseObj.id);
               }
            System.debug('Pre screening Result:'+caseObj.cc_Credit_Pre_Screening_Result__c);
            System.debug('Old Pre screening Result:'+caseOldObj.cc_Credit_Pre_Screening_Result__c);
            System.debug('Application Stage:'+caseObj.cc_Application_Stages__c);
            //CH55: Added Region Flag in if condition
            if((isNewCreditCard(caseObj)|| isLimitIncrease(caseObj)) &&
               changedTo(caseObj, caseOldObj, Case.cc_Credit_Pre_Screening_Result__c, 'Refer to Service Center') &&
               caseObj.cc_Application_Stages__c == 'Credit Pre-Screening' && caseObj.Region_Flag__c == 'Bahrain'){
                   System.debug('Set Cases from Pre screener Queue to Service Center');
                   setCaseRoutedFromPrescreenerToServiceCenter.add(caseObj.id);
               }
            //CH55: Added Region Flag in if condition
            //CH50: Start
            if(isNewCreditCard(caseObj) &&
               changedToAny(caseObj, caseOldObj, Case.cc_Credit_Pre_Screening_Result__c, new List<String>{'Offer Cash Collateral', 'Request Missing / Incomplete Documents', 'Retain Customer'}) &&
               caseObj.cc_Application_Stages__c == 'Credit Pre-Screening' && caseObj.Region_Flag__c == 'Bahrain'){
                   System.debug('Set Cases From Pre-screener to Retention Queue');
                   setCaseRoutedFromPrescreenertoCreditRetention.add(caseObj.id);
               }
            //CH50: END
            //CH55: Added Region Flag in if condition
            if(isSupplementaryCard(caseObj)  &&
               changedTo(caseObj, caseOldObj, Case.cc_Credit_Pre_Screening_Result__c, 'Pending Relationship Establishment') &&
               caseObj.cc_Application_Stages__c == 'Credit Pre-Screening' && caseObj.Region_Flag__c == 'Bahrain'){
                   System.debug('Set Cases from Pre screener Queue to Service Center');
                   setSuppCasePrescreenerRelationshipEstablishment.add(caseObj.id);
               }
            //CH55: Added Region Flag in if condition
            if(isSupplementaryCard(caseObj) &&
               changedTo(caseObj, caseOldObj, Case.cc_Credit_Pre_Screening_Result__c, 'Refer to Service Center') &&
               caseObj.cc_Application_Stages__c == 'Credit Pre-Screening' && caseObj.Region_Flag__c == 'Bahrain'){
                   System.debug('Set Cases from Pre screener Queue to Service Center');
                   setSuppCasePrescreenerToSC.add(caseObj.id);
               }
            System.debug('----> 823 ---> OLD Substatus Value---> '+caseOldObj.sub_status__c);
            System.debug('----> 823 ---> NEW Substatus Value---> '+caseObj.sub_status__c);
            //CH55: Added Region Flag in if condition
            if(isSupplementaryCard(caseObj) &&
               changedTo(caseObj, caseOldObj, Case.cc_Credit_Pre_Screening_Result__c, 'Accept') &&
               caseObj.cc_Application_Stages__c == 'Credit Pre-Screening' && caseObj.Region_Flag__c == 'Bahrain'){
                   System.debug('Set Cases from Pre screener Queue to Service Center');
                   setSuppCasePreScreenerApproved.add(caseObj.id);
               }
            //#CH49 : Start
            //CH55: Added Region Flag in if condition
            if(isSupplementaryCard(caseObj) &&
               changedTo(caseObj, caseOldObj, Case.cc_Maker__c, 'Accept') && caseObj.Region_Flag__c == 'Bahrain'){
                   System.debug('Same process as Prescrener to Accept');
                   setSuppCasePreScreenerApproved.add(caseObj.id);
               }
            //#CH49 : End
            /******************************************* CREDIT PRE SCREENING RESULT END **************************************************/
            /******************************************* CREDIT EVALUATOR RESULT START ****************************************************/
            //CH55: Added Region Flag in if condition
            if((isNewCreditCard(caseObj) || isLimitIncrease(caseObj)) &&
               changedTo(caseObj, caseOldObj, Case.cc_Credit_Evaluation_Result__c, 'Refer to Service Center')  &&
               caseObj.cc_Application_Stages__c == 'Credit Evaluation' && caseObj.Region_Flag__c == 'Bahrain'){
                   System.debug('Set Cases from Evaluator to Service Center');
                   setCaseRoutedFromEvaluatorToServiceCenter.add(caseObj.id);
               }
            //CH55: Added Region Flag in if condition
            if((isNewCreditCard(caseObj) || isLimitIncrease(caseObj)) &&
               changedTo(caseObj, caseOldObj, Case.cc_Credit_Evaluation_Result__c, 'Accept')  &&
               caseObj.cc_Application_Stages__c == 'Credit Evaluation' && caseObj.Region_Flag__c == 'Bahrain'){
                   System.debug('Set Cases from Evaluator to Verifier');
                   setCaseRoutedFromEvaluatorToVerifier.add(caseObj.id);
               }
            //CH55: Added Region Flag in if condition
            //CH10: Start
            if((isNewCreditCard(caseObj) || isLimitIncrease(caseObj)) &&
               changedTo(caseObj, caseOldObj, Case.cc_Credit_Evaluation_Result__c, 'Accept Release Letter')  &&
               caseObj.cc_Application_Stages__c == 'Credit Evaluation' && caseObj.Region_Flag__c == 'Bahrain'){
                   System.debug('Set Cases from Evaluator Accept Release Letter');
                   setCaseAcceptedByEvaluator.add(caseObj.id);
               }
            //CH10: END
            /******************************************* CREDIT EVALUATOR RESULT END ****************************************************/
            /******************************************* CREDIT VERIFIER START **********************************************************/
            //CH55: Added Region Flag in if condition
            if((isNewCreditCard(caseObj) || isLimitIncrease(caseObj)) &&
               changedTo(caseObj, caseOldObj, Case.cc_Credit_Verification_Result__c, 'Approve')  &&
               caseObj.cc_Application_Stages__c == 'Credit Verification' && caseObj.Region_Flag__c == 'Bahrain'){
                   System.debug('Set Cases from Verifier to Approver');
                   setCaseRoutedFromVerifierToApprover.add(caseObj.id);
               }
            //CH55: Added Region Flag in if condition
            if((isNewCreditCard(caseObj) || isLimitIncrease(caseObj)) &&
               changedTo(caseObj, caseOldObj, Case.cc_Credit_Verification_Result__c, 'Refer to Service Center')  &&
               caseObj.cc_Application_Stages__c == 'Credit Verification' && caseObj.Region_Flag__c == 'Bahrain'){
                   System.debug('Set Cases from Verifier to Service Center');
                   setCaseRoutedFromVerifierToServiceCenter.add(caseObj.id);
               }
            /******************************************* CREDIT VERIFIER END **********************************************************/
            /******************************************* CREDIT APPROVER RESULT START ***************************************************/
            //CH55: Added Region Flag in if condition
            if((isNewCreditCard(caseObj) || isLimitIncrease(caseObj)) &&
               changedTo(caseObj, caseOldObj, Case.cc_Credit_Approval_Result__c, 'Approve') &&
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
            if((isNewCreditCard(caseObj) || isLimitIncrease(caseObj)) &&
               changedTo(caseObj, caseOldObj, Case.cc_Credit_Approval_Result__c, 'Refer to Service Center') &&
               caseObj.cc_Application_Stages__c == 'Credit Approval' && caseObj.Region_Flag__c == 'Bahrain'){
                   System.debug('Set Cases for Credit Card Service Center Queue From Credit Approver');
                   setCasesRoutedToCreditServiceCenterQueueFromApprover.add(caseObj.id);
               }
            ////////////////////////// END : Cases Routing to Credit Service Center when Credit Approval Result = 'Refer to Service Center' in CRM and Sending Status 'REFERRED' in API ///////////////////////////////////////
            /******************************************* CREDIT APPROVER RESULT END ***************************************************/
            /******************************************* SIGNATURE VERIFIER RESULT START ***************************************************/
            //////// Start : When Signature Verifier Result = 'Accept' then cases are closed in CRM, If Approved Requested Card Type = ila Blue or ila Black and Sending Status as 'Approved' in API ////////////////////
            //CH55: Added Region Flag in if condition
            //CH13: Commented the Credit Limit Update condition by Jahangeer Mohammed #01-11-2021#
            //CH74: Added Is_Balance_Transfer__c in if condition for Cobranded Cards
            if((isNewCreditCard(caseObj)) &&
               changedTo(caseObj, caseOldObj, Case.cc_Signature_Verifier_Result__c, 'Accept') &&
               caseObj.cc_Application_Stages__c == 'Credit Signature Verification' && (caseObj.cc_Approved_Requested_Card_Type__c != 'PLATINUM_BALANCE_TRANSFER_01' && caseObj.Is_Balance_Transfer__c == false) && caseObj.Region_Flag__c == 'Bahrain'){
                   System.debug('Set Cases for Credit Signature for ila blue/black');
                   setCaseClosedBySignatureVerifier.add(caseObj.id);
               }
            //////// END : When Signature Verifier Result = 'Accept' then cases are closed in CRM, If Approved Requested Card Type = ila Blue or ila Black and Sending Status as 'Approved' in API ////////////////////
            //////// Start : When Signature Verifier Result = 'Accept' then cases are open in CRM, If Approved Requested Card Type = ila Switch, Approved Transfer Type = Balance Transfer and Sending Status as 'APPROVED_BT' in API ////////////////////
            //CH55: Added Region Flag in if condition
            //CH74: Added Is_Balance_Transfer__c in if condition for Cobranded Cards
            if((isNewCreditCard(caseObj) || isLimitIncrease(caseObj)) &&
               changedTo(caseObj, caseOldObj, Case.cc_Signature_Verifier_Result__c, 'Accept') &&
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
            if((isNewCreditCard(caseObj)) &&
               changedTo(caseObj, caseOldObj, Case.cc_Signature_Verifier_Result__c, 'Accept') &&
               (caseObj.cc_Approved_Requested_Card_Type__c == 'PLATINUM_BALANCE_TRANSFER_01' || caseObj.Is_Balance_Transfer__c == true) && caseObj.cc_Approved_Transfer_Type__c == 'Buy Out' && caseObj.Region_Flag__c == 'Bahrain'){
                   System.debug('Set Cases for Credit Signature for ila switch Buy-Out');
                   setCasesRouteToBuyoutQueueForBuyoutType.add(caseObj.id);
               }
            //CH10: END
            //////// END : When Signature Verifier Result = 'Accept' then cases are open in CRM, If Approved Requested Card Type = ila Switch and Sending Status as 'APPROVED_PENDING_RELEASE' in API ////////////////////
            /////// Start : When Signature Verifier Result = Re-send it remains in the same Queue(Credit Signature Verification) and Sending Status as 'APPROVED_PENDING_SIGNATURE' in API ////////////////////////////////////
            //CH55: Added Region Flag in if condition
            if((isNewCreditCard(caseObj) || isLimitIncrease(caseObj)) &&
               changedTo(caseObj, caseOldObj, Case.cc_Signature_Verifier_Result__c, 'Re-Send') &&
               caseObj.cc_Application_Stages__c == 'Credit Signature Verification' && caseObj.Region_Flag__c == 'Bahrain'){
                   System.debug('Set Cases Remains in for Credit Signature verifier');
                   setCasesRemainInSignatureVerifier.add(caseObj.id);
               }
            /////// END : When Signature Verifier Result = Re-send it remains in the same Queue(Credit Signature Verification) and Sending Status as 'APPROVED_PENDING_SIGNATURE' in API ////////////////////////////////////
            ////// Start : When Signature Verifier Result = Refer to Service Center then Re-routing to Credit Card Service Center Queue ////////////////////////
            //CH55: Added Region Flag in if condition
            if((isNewCreditCard(caseObj) || isLimitIncrease(caseObj)) &&
               changedTo(caseObj, caseOldObj, Case.cc_Signature_Verifier_Result__c, 'Refer to Service Center') &&
               caseObj.cc_Application_Stages__c == 'Credit Signature Verification' && caseObj.Region_Flag__c == 'Bahrain'){
                   System.debug('Set Cases for Credit Card Service Center Queue From Signature Verifier');
                   setCasesRoutedToCreditServiceCenterQueueFromSignatureVerifier.add(caseObj.id);
               }
            ////// END : When Signature Verifier Result = Refer to Service Center then Re-routing to Credit Card Service Center Queue ////////////////////////
            /******************************************* SIGNATURE VERIFIER RESULT END ***************************************************/
            /******************************************* CREDIT SERVICE CENTER RESULT START ********************************************/
            ////// Start : When Service Center Result = 'Return to Pre-screener' then Re-routing to Credit Card Pre-screener Queue ////////////////////////
            //CH55: Added Region Flag in if condition
            if((isNewCreditCard(caseObj) || isLimitIncrease(caseObj) || isSupplementaryCard(caseObj)) &&
               changedTo(caseObj, caseOldObj, Case.cc_Service_Centre_Result__c, 'Return to Pre-Screener') &&
               caseObj.cc_Application_Stages__c == 'Credit Service Centre' && caseObj.Region_Flag__c == 'Bahrain'){
                   System.debug('Set Cases Routed from Service Center to Pre-screener queue');
                   setCaseRoutedToPreScreenerQueueFromServiceCenter.add(caseObj.id);
               }
            ////// END : When Service Center Result = 'Return to Pre-screener' then Re-routing to Credit Card Pre-screener Queue ////////////////////////
            ////// Start : When Service Center Result = 'Return to Evaluator' then Re-routing to Credit Card Evaluation Queue ////////////////////////
            //CH55: Added Region Flag in if condition
            if((isNewCreditCard(caseObj) || isLimitIncrease(caseObj)) &&
               changedTo(caseObj, caseOldObj, Case.cc_Service_Centre_Result__c, 'Return to Evaluator') &&
               caseObj.cc_Application_Stages__c == 'Credit Service Centre' && caseObj.Region_Flag__c == 'Bahrain'){
                   System.debug('Set Cases Routed from Service Center to Evaluation queue');
                   setCaseRoutedToEvaluationQueueFromServiceCenter.add(caseObj.id);
               }
            ////// END : When Service Center Result = 'Return to Evaluator' then Re-routing to Credit Card Evaluation Queue ////////////////////////
            ////// Start : When Service Center Result = 'Return to Verifier' then Re-routing to Credit Verification Queue ////////////////////////
            //CH55: Added Region Flag in if condition
            if((isNewCreditCard(caseObj) || isLimitIncrease(caseObj)) &&
               changedTo(caseObj, caseOldObj, Case.cc_Service_Centre_Result__c, 'Return to Verifier') &&
               caseObj.cc_Application_Stages__c == 'Credit Service Centre' && caseObj.Region_Flag__c == 'Bahrain'){
                   System.debug('Set Cases Routed from Service Center to Verification queue');
                   setCaseRoutedToVerificationQueueFromServiceCenter.add(caseObj.id);
               }
            ////// END : When Service Center Result = 'Return to Evaluator' then Re-routing to Credit Verification Queue ////////////////////////
            ////// Start : When Service Center Result = 'Return to Approver' then Re-routing to Credit Approver Queue ////////////////////////
            //CH55: Added Region Flag in if condition
            if((isNewCreditCard(caseObj) || isLimitIncrease(caseObj)) &&
               changedTo(caseObj, caseOldObj, Case.cc_Service_Centre_Result__c, 'Return to Approver') &&
               caseObj.cc_Application_Stages__c == 'Credit Service Centre' && caseObj.Region_Flag__c == 'Bahrain'){
                   System.debug('Set Cases Routed from Service Center to Approval queue');
                   setCaseRoutedToApproverQueueFromServiceCenter.add(caseObj.id);
               }
            ////// END : When Service Center Result = 'Return to Approver' then Re-routing to Credit Approver Queue ////////////////////////
            ////// Start : When Service Center Result = 'Return to Signature Verifier' then Re-routing to Credit Signature Verification Queue ////////////////////////
            //CH55: Added Region Flag in if condition
            if((isNewCreditCard(caseObj) || isLimitIncrease(caseObj)) &&
               changedTo(caseObj, caseOldObj, Case.cc_Service_Centre_Result__c, 'Return to Signature Verifier') &&
               caseObj.cc_Application_Stages__c == 'Credit Service Centre' && caseObj.Region_Flag__c == 'Bahrain'){
                   System.debug('Set Cases Routed from Service Center to Signature Verification queue');
                   setCaseRoutedToSignatureVerifierFromServiceCenter.add(caseObj.id);
               }
            ////// END : When Service Center Result = 'Return to Signature Verifier' then Re-routing to Credit Signature Verification Queue ////////////////////////
            ////// Start : When Service Center Result = 'Release Letter Received' then Re-routing to Credit Evaluation Queue ////////////////////////
            //CH55: Added Region Flag in if condition
            if((isNewCreditCard(caseObj) || isLimitIncrease(caseObj)) &&
               changedTo(caseObj, caseOldObj, Case.cc_Service_Centre_Result__c, 'Release Letter Received') &&
               caseObj.cc_Application_Stages__c == 'Credit Service Centre' && caseObj.Region_Flag__c == 'Bahrain'){
                   System.debug('Set Cases Routed from Service Center to Evaluation queue if Release Letter Received');
                   setCaseRoutedToEvaluationFromServiceCenterIfLetterRec.add(caseObj.id);
               }
            ////// END : When Service Center Result = 'Release Letter Received' then Re-routing to Credit Evaluation Queue ////////////////////////
            //CH55: Added Region Flag in if condition
            if( isSupplementaryCard(caseObj) &&
               changedTo(caseObj, caseOldObj, Case.cc_Service_Centre_Result__c, 'Return to Maker') &&
               caseObj.cc_Application_Stages__c == 'Credit Service Centre' && caseObj.Region_Flag__c == 'Bahrain'){
                   System.debug('Set Cases Routed from Service Center to Evaluation queue if Release Letter Received');
                   setSuppCaseSCRoutedToMaker.add(caseObj.id);
               }
            /******************************************* CREDIT SERVICE CENTER RESULT END ********************************************/
            /******************************************* CREDIT BUYOUT OPERATIONS START ****************************************************/
            //CH55: Added Region Flag in if condition
            //CH74: Added Is_Balance_Transfer__c in if condition for Cobranded Cards
            if((isNewCreditCard(caseObj)) &&
               changedTo(caseObj, caseOldObj, Case.cc_Operations_Result__c, 'Balance Transfer Processed') &&
               caseObj.cc_Application_Stages__c == 'Credit Buyout' && (caseObj.cc_Approved_Requested_Card_Type__c == 'PLATINUM_BALANCE_TRANSFER_01' || caseObj.Is_Balance_Transfer__c == true) &&
               caseObj.cc_Approved_Transfer_Type__c == 'Buy Out' && caseObj.Region_Flag__c == 'Bahrain'){
                   System.debug('Set Cases Routing to Service Center if Approve Transfer type is Buyout');
                   setCaseRouteToServiceCenterFromBuyoutOperationsQueue.add(caseObj.id);
               }
            //CH55: Added Region Flag in if condition
            //CH74: Added Is_Balance_Transfer__c in if condition for Cobranded Cards
            if((isNewCreditCard(caseObj)) &&
               changedTo(caseObj, caseOldObj, Case.cc_Operations_Result__c, 'Card Block Released') &&
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
            if((isNewCreditCard(caseObj)) &&
               recordtypeName == 'Credit Card - Staff  Application' && (changedTo(caseObj, caseOldObj, Case.cc_HR_Result__c, 'Approved')) && caseObj.Region_Flag__c == 'Bahrain')
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
            /******************************************* HR APPROVAL RESULT START ACCEPT RELEASE LETTER **************************************************************/
            //CH55: Added Region Flag in if condition
            //CH13: Commented by #Jahangeer Mohammed# #02-11-2021# Credit Limit Update Condition.
            //CH74: Added Is_Balance_Transfer__c in if condition for Cobranded Cards
            if((isNewCreditCard(caseObj)) &&
               recordtypeName == 'Credit Card - Staff  Application' &&
               (changedTo(caseObj, caseOldObj, Case.cc_HR_Result__c, 'Accept Release Letter')) && (caseObj.cc_Approved_Requested_Card_Type__c == 'PLATINUM_BALANCE_TRANSFER_01' || caseObj.Is_Balance_Transfer__c == true) && caseObj.cc_Approved_Transfer_Type__c == 'Buy Out' && caseObj.Region_Flag__c == 'Bahrain')
            {
                System.debug('Set Cases for HR Result is Accept Release Letter');
                setCaseHRApprovedForReleaseLetter.add(caseObj.id);
            }
            /******************************************* HR APPROVAL RESULT END ACCEPT RELEASE LETTER **************************************************************/
            /******************************************* HR APPROVAL START FOR LIMIT UPDATE *******************************************************/
            //CH13: Start
            //CH24: Start
            //CH55: Added Region Flag in if condition
            if((isLimitIncrease(caseObj)) && recordtypeName == 'Credit Limit Increase Staff' &&
               (changedTo(caseObj, caseOldObj, Case.cc_HR_Result__c, 'Approved')) && caseObj.Region_Flag__c == 'Bahrain')
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
            if(((isNewCreditCard(caseObj) && recordtypeName == 'Credit Card - Staff  Application') || (isLimitIncrease(caseObj)  && recordtypeName == 'Credit Limit Increase Staff')) &&
               changedToTrue(caseObj, caseOldObj, Case.cc_Request_Digital_Documents__c) &&
               caseObj.Status == 'Closed' && (caseObj.Sub_Status__c == 'Approved' || caseObj.Sub_Status__c == 'Balance Transfer Processed') && caseObj.Region_Flag__c == 'Bahrain'){
                   System.debug('Set Cases for HR Requesting for digital documents for Closed Cases');
                   setExistingCasesProvideDigitalDocs.add(caseObj.id);
               }
            //CH23: END
            /****************************************** HR REQUESTING FOR DIGITAL DOCUMENTS END **************************************************************/
            //CH55: Added Region Flag in if condition
            //CH02: Start
            if((isNewCreditCard(caseObj) || isLimitIncrease(caseObj)) &&
               changedTo(caseObj, caseOldObj, Case.cc_Signature_Verifier_Result__c, 'Re-Send') && caseObj.Region_Flag__c == 'Bahrain'){
                   System.debug('Set Cases for Re-Send DocuSign');
                   reSendDocSet.add(caseObj.id);
               }
            //CH02: End
            //#CH84: Start
            if((isNewCreditCard(caseObj) || isLimitIncrease(caseObj)) &&
               changedTo(caseObj, caseOldObj, Case.cc_Signature_Verifier_Result__c, 'Re-Send In-App') && caseObj.Region_Flag__c == 'Bahrain'){
                   System.debug('Set Cases for Re-Send In-App DocuSign');
                   reSendDocSetInApp.add(caseObj.id);//#CH84
               }
            //#CH84: End
            //CH55: Added Region Flag in if condition
            //CH36: Added extra brackets in if condition to avoid multiple future calls.
            //CH69: Start: Added a condition Signature Verifier Result = Decline in if Condition
            if((isNewCreditCard(caseObj) || isLimitIncrease(caseObj)) &&
               ((changedTo(caseObj, caseOldObj, Case.cc_CEO_Result__c, 'Decline')) ||
                (changedTo(caseObj, caseOldObj, Case.cc_Credit_Approval_Result__c, 'Decline')) ||
                (changedTo(caseObj, caseOldObj, Case.cc_HR_Result__c, 'Decline')) ||
                (changedTo(caseObj, caseOldObj, Case.cc_Business_Approval_Result__c, 'Decline'))||
                (changedToAny(caseObj, caseOldObj, Case.cc_Credit_Evaluation_Result__c, new List<String>{'Rejected', 'Decline'}))||
                (changedTo(caseObj, caseOldObj, Case.cc_Credit_Verification_Result__c, 'Decline'))||
                (changedTo(caseObj, caseOldObj, Case.cc_Credit_Pre_Screening_Result__c, 'Decline'))||
                (changedTo(caseObj, caseOldObj, Case.cc_Signature_Verifier_Result__c, 'Decline'))) && caseObj.Region_Flag__c == 'Bahrain')
            {
                System.debug('Inside Decline Condition');
                setCaseDeclined.add(caseObj.id);
            }
            //CH55: Added Region Flag in if condition
            //CH69: END
            //CH10: Start
            //CH36: Added extra brackets in if condition to avoid multiple future calls.
            //CH69: Start: Added a condition Signature Verifier Result = Cancelled by Customer in if Condition
            if((isNewCreditCard(caseObj) || isLimitIncrease(caseObj)) &&
               ((changedTo(caseObj, caseOldObj, Case.cc_Credit_Approval_Result__c, 'Cancelled by Customer')) ||
                (changedTo(caseObj, caseOldObj, Case.cc_HR_Result__c, 'Cancelled by Customer')) ||
                (changedTo(caseObj, caseOldObj, Case.cc_Credit_Evaluation_Result__c, 'Cancelled by Customer')) ||
                (changedTo(caseObj, caseOldObj, Case.cc_Credit_Verification_Result__c, 'Cancelled by Customer'))||
                (changedTo(caseObj, caseOldObj, Case.cc_Credit_Pre_Screening_Result__c, 'Cancelled by Customer'))||
                (changedTo(caseObj, caseOldObj, Case.cc_Signature_Verifier_Result__c, 'Cancelled by Customer')))  && caseObj.Region_Flag__c == 'Bahrain')
            {
                System.debug('Inside CANCEL BY Customer Condition');
                setCasesCancelledByCustomer.add(caseObj.id);
            }
            //CH10: END
            //CH69: END
            //CH49: Start Added by #Jahangeer Mohammmed# #28-02-2023#
            //CH55: Added Region Flag in if condition
            if(!System.isFuture() && ((isLimitIncrease(caseObj) && changedTo(caseObj, caseOldObj, Case.cc_Credit_Pre_Screening_Result__c, 'Expired')) ||
                                      (isSupplementaryCard(caseObj) && changedTo(caseObj, caseOldObj, Case.Sub_Status__c, 'Expired'))) && caseObj.Region_Flag__c == 'Bahrain')
            {
                setCaseExpired.add(caseObj.id);
            }
            //CH49: END
            //CH13 : Start
            //CH26 : Commented by #Jahangeer Mohammed# #14-03-2022# related to Credit Card Application
            //CH55: Added Region Flag in if condition
            if((caseObj.Type == 'Credit Limit Increase Application') && changedToTrue(caseObj, caseOldObj, Case.cc_SMS_Sent_Flag__c) && caseObj.Region_Flag__c == 'Bahrain' ){
                setCasePendingForSMSReminders.add(caseObj.id);
            }
            //CH26 : Commented by #Jahangeer Mohammed# #14-03-2022# related to Credit Card Application
            //CH55: Added Region Flag in if condition
            //CH44 : Added by Jahangeer Mohammed #16-10-2022# related to 'Cash Collateral Credit Limit Increase Application' in if condition
            if((caseObj.Type == 'Credit Limit Increase Application' || caseObj.Type == 'Cash Collateral Credit Limit Increase Application') && changedToTrue(caseObj, caseOldObj, Case.cc_signature_sms_sent_flag__c) && caseObj.Region_Flag__c == 'Bahrain'){
                setCasePendingForSignatureReminders.add(caseObj.id);
            }
            //CH13 : END
            /////////////////////////////////////////////////////////////  Comments Clearing and Adding Section to the Case Feeds //////////////////////////////////////////////////////////////////////////////////
            //CH31 : Added condition for Cash Collateral and Supplementary Cards
            //CH55: Added Region Flag in if condition
            addCaseComment(caseObj, caseOldObj, Case.cc_Credit_Pre_Screener_Comments__c, (caseObj.Type == 'Credit Card Application' || isLimitIncrease(caseObj) || caseObj.Type == 'Credit Card Cash Collateral Application' || caseObj.Type == 'Credit Card Supplementary Application' || caseObj.Type == 'New Loan / Finance Application'), 'Inside Prescreener Comments', 'Credit Pre-Screener Comments - ', lstComment);
            //CH55: Added Region Flag in if condition
            addCaseComment(caseObj, caseOldObj, Case.cc_Credit_Evaluator_Comments__c, (caseObj.Type == 'Credit Card Application' || isLimitIncrease(caseObj) || caseObj.Type == 'New Loan / Finance Application'), 'Inside Evaluator Comments', 'Credit Evaluator Comments - ', lstComment);
            //CH55: Added Region Flag in if condition
            addCaseComment(caseObj, caseOldObj, Case.cc_Credit_Verifier_Comments__c, (caseObj.Type == 'Credit Card Application' || isLimitIncrease(caseObj) || caseObj.Type == 'New Loan / Finance Application'), 'Inside Verifier Comments', 'Credit Verifier Comments - ', lstComment);
            //CH55: Added Region Flag in if conditionTeam
            //CH31 : Added Condition for Cash Collateral
            //CH90: Added  Type = Credit Card Upgrade
            addCaseComment(caseObj, caseOldObj, Case.cc_Credit_Approver_Comments__c, (caseObj.Type == 'Credit Card Application' || caseObj.Type == 'Credit Limit Increase Application' || caseObj.Type == 'Credit Card Cash Collateral Application' || caseObj.Type == 'New Loan / Finance Application' || caseObj.Type == 'Credit Card Upgrade'), 'Inside Approver Comments', 'Credit Approver Comments - ', lstComment);
            //CH90: END
            //CH55: Added Region Flag in if condition
            //CH31 : Added Condition for Cash Collateral
            addCaseComment(caseObj, caseOldObj, Case.cc_Credit_Business_Team_Comments__c, (caseObj.Type == 'Credit Card Application' || isLimitIncrease(caseObj) || caseObj.Type == 'Credit Card Cash Collateral Application' || caseObj.Type == 'New Loan / Finance Application'), 'Inside Business Team Comments', 'Credit Business Team Comments - ', lstComment);
            //CH55: Added Region Flag in if condition
            //CH31 : Added Condition for Cash Collateral and Supplementary Cards
            addCaseComment(caseObj, caseOldObj, Case.cc_Service_Centre_Comments__c, (caseObj.Type == 'Credit Card Application' || isLimitIncrease(caseObj) || caseObj.Type == 'Credit Card Cash Collateral Application' || caseObj.Type == 'Credit Card Supplementary Application'  || caseObj.Type == 'New Loan / Finance Application'), 'Inside Service Center Comments', 'Credit Service Centre Comments - ', lstComment);
            //CH55: Added Region Flag in if condition
            //CH31 : Added Condition for Cash Collateral
            //CH90: Added  Type = Credit Card Upgrade
            addCaseComment(caseObj, caseOldObj, Case.cc_Contact_Centre_Comments__c, (caseObj.Type == 'Credit Card Application' || isLimitIncrease(caseObj) || caseObj.Type == 'Credit Card Cash Collateral Application' || caseObj.Type == 'New Loan / Finance Application' || caseObj.Type == 'Credit Card Upgrade'), 'Inside Contact Comments', 'Credit Contact Centre Comments - ', lstComment);
            //CH90: END
            //CH55: Added Region Flag in if condition
            //CH50: Start
            addCaseComment(caseObj, caseOldObj, Case.Retention_Comments__c, (caseObj.Type == 'Credit Card Application'  || caseObj.Type == 'New Loan / Finance Application'), 'Inside Retention Comments', 'Credit Retention Comments - ', lstComment);
            //CH50: END
            // added by Shashank to update the HandOff Process Case Comments by Maker and Checker.
            // CH31 : Added Condition for Supplementary Cards
            //CH55: Added Region Flag in if condition
            //CH58: Start Added a Type = Credit Card Upgrade in If block
            //CH73: Removed Type from the if condition
            if(addCaseComment(caseObj, caseOldObj, Case.cc_Maker_Comments__c, true, 'Inside Maker Comments', 'Maker Comment - ', lstComment)){
                caseIdstoUpdate.add(caseObj.Id);
            }
            //CH73: End
            //CH58: END
            //CH55: Added Region Flag in if condition
            //CH58: Start Added a Type = Credit Card Upgrade in If block
            //CH73: Removed Type from the if condition
            if(addCaseComment(caseObj, caseOldObj, Case.cc_Checker_Comments__c, true, 'Inside Checker Comments', 'Checker Comment - ', lstComment)){
                caseIdstoUpdate.add(caseObj.Id);
            }
            //CH73: End
            //CH58: END
            //CH31 : Added Condition for Cash Collateral
            //CH05 : Start
            //CH55: Added Region Flag in if condition
            //CH76: Start
            addCaseComment(caseObj, caseOldObj, Case.cc_Signature_Verification_Comments__c, (caseObj.Type == 'Credit Card Application' || isLimitIncrease(caseObj) || caseObj.Type == 'Credit Card Cash Collateral Application' || caseObj.Type == 'Credit Card Upgrade' || caseObj.Type == 'New Loan / Finance Application'), 'Inside Signature Verifier Comments', 'Credit Signature Verifier Comments - ', lstComment);
            //CH76: END
            //CH31 : Added Condition for Cash Collateral
            //CH55: Added Region Flag in if condition
            //CH90: Added  Type = Credit Card Upgrade
            addCaseComment(caseObj, caseOldObj, Case.cc_Operations_Comments__c, (caseObj.Type == 'Credit Card Application' || isLimitIncrease(caseObj) || caseObj.Type == 'Credit Card Cash Collateral Application' || caseObj.Type == 'New Loan / Finance Application' || caseObj.Type == 'Credit Card Upgrade'), 'Inside Operations Comments', 'Credit Operation Comments - ', lstComment);
            //CH90: END
            //CH31 : Added Condition for Cash Collateral
            //CH08 : Start
            //CH55: Added Region Flag in if condition
            addCaseComment(caseObj, caseOldObj, Case.cc_CEO_Comments__c, (caseObj.Type == 'Credit Card Application' || isLimitIncrease(caseObj) || caseObj.Type == 'Credit Card Cash Collateral Application' || caseObj.Type == 'New Loan / Finance Application'), 'Inside CEO Comments', 'Credit CEO Comments - ', lstComment);
            //CH08 : END
            //CH08 : END
            //CH12 : Start
            //CH31 : Added Condition for Cash Collateral
            //CH55: Added Region Flag in if condition
            //CH76: Start
            addCaseComment(caseObj, caseOldObj, Case.cc_HR_Comments__c, (caseObj.Type == 'Credit Card Application' || isLimitIncrease(caseObj) || caseObj.Type == 'Credit Card Cash Collateral Application' || caseObj.Type == 'Credit Card Upgrade'), 'Inside HR Comments', 'Credit HR Comments - ', lstComment);
            //CH76: END
            //CH12 : END
            //CH55: Added Region Flag in if condition
            addCaseComment(caseObj, caseOldObj, Case.cc_Anti_Attrition_Comment__c, caseObj.Type == 'Credit Card Account Closing', 'Inside Anti Attration Comments', 'Credit Anti Attrition Comments - ', lstComment);
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
            if(changedTo(caseObj, caseOldObj, Case.cc_Signature_Verifier_Result__c, 'Accept') && caseObj.Type =='Credit Limit Increase Application' && caseObj.Region_Flag__c == 'Bahrain'){
                System.debug('Signature Verifier Accepts for Credit Limit Increase');
                setCaseApprovedBySigVerifierForLimitIncrease.add(caseObj.Id);
            }
            //CH13: END
            //CH06: END
            ////////////////////////////////////// Updating Customer details on Contact Post Credit Evaluator Approval/ rejection on Case ///////////////////////////////////
            //CH55: Added Region Flag in if condition
            //CH40: Start
            if((isNewCreditCard(caseObj) || isLimitIncrease(caseObj)) && changedToAny(caseObj, caseOldObj, Case.cc_Credit_Approval_Result__c, new List<String>{'Approve', 'Decline'}) && caseObj.Region_Flag__c == 'Bahrain')
            {
                mapCasetoAccount.put(caseObj.Id, caseObj.AccountId);
            }
            //CH55: Added Region Flag in if condition
            if((isNewCreditCard(caseObj) || isLimitIncrease(caseObj)) && changedToAny(caseObj, caseOldObj, Case.cc_HR_Result__c, new List<String>{'Approved', 'Decline'})  && caseObj.Region_Flag__c == 'Bahrain')
            {
                mapCasetoAccountHR.put(caseObj.Id, caseObj.AccountId);
            }
            //CH40: END
            /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
            ///////////////////////////////////////////// Supplementary Card -- DECLINE/ CANCELLED BY CUSTOMER -- Maker/ Pre-Screener ///////////////////////////////////////
            //CH55: Added Region Flag in if condition
            if(isSupplementaryCard(caseObj)  &&
               ((changedTo(caseObj, caseOldObj, Case.cc_Maker__c, 'Decline')) || (changedTo(caseObj, caseOldObj, Case.cc_Credit_Pre_Screening_Result__c, 'Decline'))) && caseObj.Region_Flag__c == 'Bahrain'){
                   System.debug('Set Supplementary Cases from Maker Queue to Decline');
                   setSuppCaseDecline.add(caseObj.id);
               }
            //CH55: Added Region Flag in if condition
            if(isSupplementaryCard(caseObj)  &&
               ((changedTo(caseObj, caseOldObj, Case.cc_Maker__c, 'Cancelled by Customer')) || (changedTo(caseObj, caseOldObj, Case.cc_Credit_Pre_Screening_Result__c, 'Cancelled by Customer'))) && caseObj.Region_Flag__c == 'Bahrain'){
                   System.debug('Set Supplementary Cases from Maker Queue to Cancelled');
                   setSuppCaseCancelledByCustomer.add(caseObj.id);
               }
            /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
        }
        //CH85: Start
        if(ccservicecseIds.size()>0){
            CreditCardCacheQueuableAPI cacheCards =  new CreditCardCacheQueuableAPI(ccservicecseIds);
            System.enqueueJob(cacheCards);
        }
        //CH85: END
        ////////////////////// Credit Card update requests API calls /////////////////////
        callCaseUpdate(setCasePending, null);
        callCaseUpdate(setCaseDocReceived, null);
        callCaseUpdate(setCaseDocDiscrepancies, 'Discrepancy in Documents:');
        //CH05: Start
        //CH22: Start
        if(!setCaseRoutedToSignatureVerifierFromHR.isEmpty()){
            enqueueDocuSign(setCaseRoutedToSignatureVerifierFromHR);
        }
        callCaseUpdate(setCaseRoutedToSignatureVerifierFromHR, null);
        //CH22: END
        //#CH87 : Start
        startInAppSigning(setCaseRoutedToSignatureVerifierFromHRInApp, 'HR Approval for InApp Scenario-----> ');
        //#CH87 : End
        //CH23: Start
        if(!setExistingCasesProvideDigitalDocs.isEmpty()){
            enqueueDocuSign(setExistingCasesProvideDigitalDocs);
        }
        //CH23: END
        //CH10: Start
        callCaseUpdate(setCasesCancelledByCustomer, 'CUSTOMER CANCELLED CARD:');
        callCaseUpdate(setCasesRouteToBuyoutQueueForBuyoutType, 'SIGNATURE VERIFIER ACCEPT ILA SWITCH - BUY OUT --------> BUYOUT QUEUE:');
        //CH10: END
        callCaseUpdate(setCaseHRApprovedForReleaseLetter, 'HR APPROVER --------> BUYOUT QUEUE:');
        //CH05: END
        //CH02: Start
        if(!reSendDocSet.isEmpty()){
            enqueueDocuSign(reSendDocSet);
        }
        //CH02: END
        //#CH84: Start
        startInAppSigning(reSendDocSetInApp, 'Credit Card reSendDocSetInApp for InApp -----> ');
        //#CH84: END
        System.debug('Decline Case Id:'+setCaseDeclined);
        callCaseUpdate(setCaseDeclined, null);
        callCaseUpdate(setCaseExpired, null);
        //CH13: Start
        sendSMSReminders(setCasePendingForSMSReminders, 'Reminder Activation for Pending/Discrepancy SMS:');
        sendSMSReminders(setCasePendingForSignatureReminders, 'Reminder Activation for Pending Signature SMS:');
        //CH13: END
        //CH05: Start
        callCaseUpdate(setCaseRoutedFromPreScreenerToEvaluator, 'Credit Card Evaluator Queue:');
        //CH50: Start
        callCaseUpdate(setCaseRoutedFromPrescreenertoCreditRetention, 'Credit Card Retention Queue:');
        //CH50: END
        callCaseUpdate(setCaseRoutedFromPrescreenerToServiceCenter, 'Credit Card Pre screener----->Service Center Queue:');
        callCaseUpdate(setCaseRoutedFromEvaluatorToServiceCenter, 'Credit Card Evaluator----->Service Center Queue:');
        callCaseUpdate(setCaseRoutedFromEvaluatorToVerifier, 'Credit Card Evaluator----->Verifier:');
        //CH10: Start
        callCaseUpdate(setCaseAcceptedByEvaluator, 'Credit Card Evaluator----->Accept Release Letter:');
        //CH10: END
        callCaseUpdate(setCaseRoutedFromVerifierToApprover, 'Credit Card Verifier----->Approver:');
        callCaseUpdate(setCaseRoutedFromVerifierToServiceCenter, 'Credit Card Verifier----->Service Center:');
        if(!setCasesRoutedToCreditSignatureVerificationQueueFromApprover.isEmpty() && !test.isRunningTest()){
            System.debug('Credit Card Approver----->Signature Verification:'+setCasesRoutedToCreditSignatureVerificationQueueFromApprover);
            //CH02:Start
            enqueueDocuSign(setCasesRoutedToCreditSignatureVerificationQueueFromApprover);
            //CH02: End
            initiateManualOnboarding.CCCaseUpdate(setCasesRoutedToCreditSignatureVerificationQueueFromApprover);
        }
        //#CH84 : Start
        startInAppSigning(setCasesRoutedToCreditSignatureVerificationQueueFromApproverInApp, 'Credit Card Approver for InApp Scenario-----> ');
        //#CH84 : End
        callCaseUpdate(setCaseRouteToServiceCenterFromBuyoutOperationsQueue, 'Credit Card Buyout Operations----->Service Center:');
        callCaseUpdate(setCaseClosedByOperationsForCardBlockRelease, 'Credit Card Operations Card block release:');
        //////////////////////////// Start : Cases Routing to Credit Service Center when Credit Approval Result = 'Refer to Service Center' in CRM and Sending Status 'REFERRED' in API ///////////////////////////////////////
        callCaseUpdate(setCasesRoutedToCreditServiceCenterQueueFromApprover, 'Credit Card Service Center Queue:');
        ////////////////////////// END : Cases Routing to Credit Service Center when Credit Approval Result = 'Refer to Service Center' in CRM and Sending Status 'REFERRED' in API ///////////////////////////////////////
        //////// Start : When Signature Verifier Result = 'Accept' then cases are closed in CRM, If Approved Requested Card Type = ila Blue or ila Black and Sending Status as 'Approved' in API ////////////////////
        callCaseUpdate(setCaseClosedBySignatureVerifier, 'Credit Signature Verifier Queue:');
        //////// END : When Signature Verifier Result = 'Accept' then cases are closed in CRM, If Approved Requested Card Type = ila Blue or ila Black and Sending Status as 'Approved' in API ////////////////////
        //////// Start : When Signature Verifier Result = 'Accept' then cases are open in CRM, If Approved Requested Card Type = ila Switch and Sending Status as 'APPROVED_BT' in API ////////////////////
        callCaseUpdate(setCasesRouteToBuyoutQueue, 'Credit Card Buyout Queue for Balance Transfer:');
        //////// END : When Signature Verifier Result = 'Accept' then cases are open in CRM, If Approved Requested Card Type = ila Switch and Sending Status as 'APPROVED_PENDING_RELEASE' in API ////////////////////
        //CH13: Start
        callCaseUpdate(setCaseApprovedBySigVerifierForLimitIncrease, 'Signature Verifier is Accept for Limit Update:');
        //CH24: Start
        if(!setCaseRoutedToSignatureVerifierFromHRForLimitIncrease.isEmpty()){
            enqueueDocuSign(setCaseRoutedToSignatureVerifierFromHRForLimitIncrease);
        }
        callCaseUpdate(setCaseRoutedToSignatureVerifierFromHRForLimitIncrease, null);
        //CH24: END
        //#CH87 : Start
        startInAppSigning(setCaseRoutedToSignatureVerifierFromHRForLimitIncreaseInApp, 'HR Approval for InApp Scenario-----> ');
        //#CH87 : End
        //CH13: END
        /////// Start : When Signature Verifier Result = Re-send it remains in the same Queue(Credit Signature Verification) and Sending Status as 'APPROVED_PENDING_SIGNATURE' in API ////////////////////////////////////
        callCaseUpdate(setCasesRemainInSignatureVerifier, 'Case Remain in Credit Signature Verifier Queue:');
        /////// END : When Signature Verifier Result = Re-send it remains in the same Queue(Credit Signature Verification) and Sending Status as 'APPROVED_PENDING_SIGNATURE' in API ////////////////////////////////////
        ////// Start : When Signature Verifier Result = Refer to Service Center then Re-routing to Credit Card Service Center Queue ////////////////////////
        callCaseUpdate(setCasesRoutedToCreditServiceCenterQueueFromSignatureVerifier, 'Case Routed to Service Center from Verifier Signature:');
        ////// END : When Signature Verifier Result = Refer to Service Center then Re-routing to Credit Card Service Center Queue ////////////////////////
        ////// Start : When Service Center Result = 'Return to Pre-screener' then Re-routing to Credit Card Pre-screener Queue ////////////////////////
        callCaseUpdate(setCaseRoutedToPreScreenerQueueFromServiceCenter, 'Case Routed to Pre-screener from Service Center:');
        ////// END : When Service Center Result = 'Return to Pre-screener' then Re-routing to Credit Card Pre-screener Queue ////////////////////////
        ////// Start : When Service Center Result = 'Return to Evaluator' then Re-routing to Credit Card Evaluation Queue ////////////////////////
        callCaseUpdate(setCaseRoutedToEvaluationQueueFromServiceCenter, 'Case Routed to Evaluation from Service Center:');
        ////// END : When Service Center Result = 'Return to Evaluator' then Re-routing to Credit Card Evaluation Queue ////////////////////////
        ////// Start : When Service Center Result = 'Return to Verifier' then Re-routing to Credit Verification Queue ////////////////////////
        callCaseUpdate(setCaseRoutedToVerificationQueueFromServiceCenter, 'Case Routed to Verification from Service Center:');
        ////// END : When Service Center Result = 'Return to Verifier' then Re-routing to Credit Verification Queue ////////////////////////
        ////// Start : When Service Center Result = 'Return to Approver' then Re-routing to Credit Approver Queue ////////////////////////
        callCaseUpdate(setCaseRoutedToApproverQueueFromServiceCenter, 'Case Routed to Approval from Service Center:');
        ////// END : When Service Center Result = 'Return to Approver' then Re-routing to Credit Approver Queue ////////////////////////
        ////// Start : When Service Center Result = 'Return to Signature Verifier' then Re-routing to Credit Signature Verification Queue ////////////////////////
        callCaseUpdate(setCaseRoutedToSignatureVerifierFromServiceCenter, 'Case Routed to Signature Verifier from Service Center:');
        ////// END : When Service Center Result = 'Return to Signature Verifier' then Re-routing to Credit Signature Verification Queue ////////////////////////
        ////// Start : When Service Center Result = 'Release Letter Received' then Re-routing to Credit Evaluation Queue ////////////////////////
        callCaseUpdate(setCaseRoutedToEvaluationFromServiceCenterIfLetterRec, 'Case Routed to Evaluation Queue from Service Center:');
        ////// END : When Service Center Result = 'Release Letter Received' then Re-routing to Credit Evaluation Queue ////////////////////////
        /////////////////////////////////////////////// Supplementary Card APIs calling based on the results ///////////////////////////////////////////////////////////////
        callCaseUpdate(setSuppCaseMakerReferToSC, null);
        callCaseUpdate(setSuppCaseMakerRelationshipEstablishment, null);
        callCaseUpdate(setSuppCaseMakerSendPreScreener, null);
        callCaseUpdate(setSuppCasePrescreenerRelationshipEstablishment, null);
        callCaseUpdate(setSuppCasePreScreenerApproved, null);
        callCaseUpdate(setSuppCasePrescreenerToSC, null);
        callCaseUpdate(setSuppCaseSCRoutedToMaker, null);
        callCaseUpdate(setSuppCaseDecline, null);
        callCaseUpdate(setSuppCaseCancelledByCustomer, null);
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
    public static void creditCardApplicationInsert(List<Case> newCaselist){
        for(Case cs : newCaselist){
            //CH25 : Added a condition for Credit Card Supplementary Application by #Jahangeer Mohammed #06-03-2022#
            //CH55: Added Region Flag in if condition
            if((isNewCreditCard(cs) && cs.Region_Flag__c == 'Bahrain') || (isSupplementaryCard(cs) && cs.Region_Flag__c == 'Bahrain') || test.isRunningTest()){
                copyIfNotBlank(cs, Case.cc_Requested_Card_Type__c, Case.cc_Approved_Requested_Card_Type__c);
                copyIfNotBlank(cs, Case.cc_Name_on_the_Card__c, Case.cc_Approved_Name_on_the_card__c);
                copyIfNotBlank(cs, Case.cc_Embossing_Line_4__c, Case.cc_Approved_Embossing_line_4__c);
                copyIfNotBlank(cs, Case.cc_Balance_Transfer_Card_Provider__c, Case.cc_Approved_Balance_Transfer_Card_Provi__c);
                if(cs.cc_Balance_Transfer_Card_Number__c != null && cs.cc_Balance_Transfer_Card_Number__c != ''){
                    cs.cc_Approved_Balance_Transfer_Card_Number__c = cs.cc_Balance_Transfer_Card_Number__c;
                    cs.sys_Balance_Transfer_Card_Number__c = cs.cc_Balance_Transfer_Card_Number__c;
                    if(cs.sys_Balance_Transfer_Card_Number__c != '' && cs.sys_Balance_Transfer_Card_Number__c != null){
                        cs.cc_First_6_Digit__c = cs.sys_Balance_Transfer_Card_Number__c.substring(0,6);
                        cs.cc_Last_4_Digit__c = cs.sys_Balance_Transfer_Card_Number__c.substring(12,16);
                    }
                }
                if(cs.cc_Balance_Transfer_Amount__c != null)
                    cs.cc_Approved_Balance_Transfer_Amount__c = cs.cc_Balance_Transfer_Amount__c;
                if(cs.cc_Balance_Transfer_Type__c != null)
                    cs.cc_Approved_Transfer_Type__c = cs.cc_Balance_Transfer_Type__c;
                //CH26: Start
                if(cs.Sub_Status__c == 'Pending'){
                    System.debug('Before creation of Credit Card Case checking Last Sub status Change for Pending');
                    stampSubStatusChange(cs, 'Not Changed');
                }
                //CH26: END
            }
            //CH66: Start
            else if(isLimitIncrease(cs) && cs.Region_Flag__c == 'Bahrain'){
                if(cs.Sub_Status__c == 'Pending'){
                    System.debug('Before creation of Credit Card Limit Increase Case checking Last Sub status Change for Pending');
                    stampSubStatusChange(cs, 'Not Changed');
                }
                copyIfNotBlank(cs, Case.cc_Requested_Card_Type__c, Case.cc_Approved_Requested_Card_Type__c);
            }
            //CH66: END
            //#CH84 : Start
            if( cs.Region_Flag__c == 'Bahrain' && ( cs.Type == 'Credit Card Application' || cs.Type == 'Credit Limit Increase Application' || cs.Type == 'Credit Card Cash Collateral Application' || cs.Type == 'Cash Collateral Credit Limit Increase Application') )
            {
                cs.Resend_DocuSign__c = System.Label.Default_Resend_DocuSign;//'In-App'
            }
            //#CH84 : End
        }
    }
    public static void creditCardBeforeUpdate(Case caseObj, Case caseOldObj){
            //CH21: Start
            //CH33 : Added a condition for Credit Limit Increase Application.
            //CH55: Added Region Flag in if condition
            if((isNewCreditCard(caseObj) || (caseObj.Type == 'Credit Limit Increase Application')) && caseObj.Region_Flag__c == 'Bahrain' && checkRecursive.runOnce()){
                stampUpdatedBy(caseObj, caseOldObj, Case.cc_Credit_Pre_Screening_Result__c, Case.cc_Credit_Pre_Screening_by__c, 'Inside Pre-screener owner Updated by value');
                stampUpdatedBy(caseObj, caseOldObj, Case.cc_Credit_Evaluation_Result__c, Case.cc_Credit_Evaluation_by__c, 'Inside Evaluator owner Updated by value');
                stampUpdatedBy(caseObj, caseOldObj, Case.cc_Credit_Verification_Result__c, Case.cc_Credit_Verified_by__c, 'Inside verifier owner Updated by value');
                stampUpdatedBy(caseObj, caseOldObj, Case.cc_Credit_Approval_Result__c, Case.cc_Credit_Approved_by__c, 'Inside Approver owner Updated by value');
                stampUpdatedBy(caseObj, caseOldObj, Case.cc_Business_Approval_Result__c, Case.cc_Business_Approval_by__c, 'Inside Business owner Updated by value');
                stampUpdatedBy(caseObj, caseOldObj, Case.cc_CEO_Result__c, Case.cc_CEO_Result_by__c, 'Inside CEO owner Updated by value');
                stampUpdatedBy(caseObj, caseOldObj, Case.cc_Service_Centre_Result__c, Case.cc_Service_Centre_by__c, 'Inside Service center owner Updated by value');
                stampUpdatedBy(caseObj, caseOldObj, Case.cc_Signature_Verifier_Result__c, Case.cc_Signature_Verifier_by__c, 'Inside signature verifier owner Updated by value');
                stampUpdatedBy(caseObj, caseOldObj, Case.cc_Operations_Result__c, Case.cc_Operation_by__c, 'Inside operations owner Updated by value');
                stampUpdatedBy(caseObj, caseOldObj, Case.cc_Contact_Centre_Result__c, Case.cc_Contact_Center_by__c, 'Inside contact center owner Updated by value');
                //CH50: Start
                stampUpdatedBy(caseObj, caseOldObj, Case.Credit_Retention_Result__c, Case.Retention_Result_Updated_by__c, 'Inside Retention owner Updated by value');
                //CH50: END
            }
            //CH52: START
            //CH55: Added Region Flag in if condition
            if(isNewCreditCard(caseObj) || (caseObj.Type == 'Credit Limit Increase Application') && caseObj.Region_Flag__c == 'Bahrain'){
                if(caseObj.Basic_Salary__c == null){
                    caseObj.Basic_Salary__c = 0;
                }
                if(caseObj.Fixed_Allowances__c == null){
                    caseObj.Fixed_Allowances__c = 0;
                }
                if(caseObj.Variable_Allowances__c == null){
                    caseObj.Variable_Allowances__c = 0;
                }
                if(caseObj.Business_Income__c == null){
                    caseObj.Business_Income__c = 0;
                }
                if(caseOldObj.Basic_Salary__c != caseObj.Basic_Salary__c || caseOldObj.Fixed_Allowances__c != caseObj.Fixed_Allowances__c || caseOldObj.Variable_Allowances__c != caseObj.Variable_Allowances__c || caseOldObj.Business_Income__c != caseObj.Business_Income__c){
                    caseObj.cc_Approved_Salary__c=caseObj.Basic_Salary__c + caseObj.Fixed_Allowances__c + caseObj.Variable_Allowances__c + caseObj.Business_Income__c;
                }
                if(caseObj.cc_Approved_Salary__c == 0){
                    caseObj.cc_Final_DBR__c = 0;
                }else{
                    caseObj.cc_Final_DBR__c = (caseObj.Final_Total_Obligations__c/ caseObj.cc_Approved_Salary__c)*100;
                }
                //CH52: END
                //CH65: Start
                if(caseOldObj.cc_Credit_Bureau_Score__c != caseObj.cc_Credit_Bureau_Score__c && caseObj.cc_Credit_Bureau_Score__c > 850){
                    caseObj.addError('cc_Credit_Bureau_Score__c','Credit Score should be greater than or equal to 300 and less than or equal to 850');
                }
                else if(caseOldObj.cc_Credit_Bureau_Score__c != caseObj.cc_Credit_Bureau_Score__c && caseObj.cc_Credit_Bureau_Score__c < 300 && caseObj.cc_Credit_Bureau_Score__c > 0){
                    caseObj.addError('cc_Credit_Bureau_Score__c','Credit Score should be greater than or equal to 300 and less than or equal to 850');
                }
                else if(caseOldObj.cc_Credit_Bureau_Score__c != caseObj.cc_Credit_Bureau_Score__c && caseObj.cc_Credit_Bureau_Score__c == 0){
                    caseObj.cc_Credit_Bureau_Risk_Rating__c = '';
                }
                if(caseObj.cc_Credit_Bureau_Score__c >= 300 && caseObj.cc_Credit_Bureau_Score__c <= 449 && caseOldObj.cc_Credit_Bureau_Score__c != caseObj.cc_Credit_Bureau_Score__c){
                    caseObj.cc_Credit_Bureau_Risk_Rating__c = 'High Risk 300-450';
                }
                else if(caseObj.cc_Credit_Bureau_Score__c >= 450 && caseObj.cc_Credit_Bureau_Score__c <= 549 && caseOldObj.cc_Credit_Bureau_Score__c != caseObj.cc_Credit_Bureau_Score__c){
                    caseObj.cc_Credit_Bureau_Risk_Rating__c = 'Medium to High Risk 450-550';
                }
                else if(caseObj.cc_Credit_Bureau_Score__c >= 550 && caseObj.cc_Credit_Bureau_Score__c <= 649 && caseOldObj.cc_Credit_Bureau_Score__c != caseObj.cc_Credit_Bureau_Score__c){
                    caseObj.cc_Credit_Bureau_Risk_Rating__c = 'Medium Risk 550-650';
                }
                else if(caseObj.cc_Credit_Bureau_Score__c >= 650 && caseObj.cc_Credit_Bureau_Score__c <= 749 && caseOldObj.cc_Credit_Bureau_Score__c != caseObj.cc_Credit_Bureau_Score__c){
                    caseObj.cc_Credit_Bureau_Risk_Rating__c = 'Medium to Low Risk 650-750';
                }
                else if(caseObj.cc_Credit_Bureau_Score__c >= 750 && caseObj.cc_Credit_Bureau_Score__c <= 850 && caseOldObj.cc_Credit_Bureau_Score__c != caseObj.cc_Credit_Bureau_Score__c){
                    caseObj.cc_Credit_Bureau_Risk_Rating__c = 'Low Risk 750-850';
                }
                else if(caseObj.cc_Credit_Bureau_Score__c == 0 && caseObj.cc_Credit_Bureau_Risk_Rating__c != 'Zero Score - 1st Facility' && caseObj.cc_Credit_Bureau_Risk_Rating__c != 'Zero Score - With Credit History' && caseObj.cc_Credit_Bureau_Risk_Rating__c != '' && caseObj.cc_Credit_Bureau_Risk_Rating__c != caseOldObj.cc_Credit_Bureau_Risk_Rating__c ){
                    caseObj.addError('cc_Credit_Bureau_Risk_Rating__c','Please select Zero Score option on Credit Bureau Risk Rating field');
                }
                //CH65: END
            }
            //CH21: END
            //CH26: Start
            //CH50: Added Follow up condition in if block
            //CH55: Added Region Flag in if condition
            if(isNewCreditCard(caseObj) && changedToAny(caseObj, caseOldObj, Case.Sub_Status__c, new List<String>{'Pending', 'Discrepancies', 'Follow Up'}) && caseObj.Region_Flag__c == 'Bahrain'){
                   System.debug('Checking Sub Status values from Other State ------> Pending');
                   stampSubStatusChange(caseObj, 'Not Changed');
               }
            //CH50: Added Follow up condition in if block
            //CH55: Added Region Flag in if condition
            if(isNewCreditCard(caseObj) && caseOldObj.Sub_Status__c != caseObj.Sub_Status__c &&
               (caseObj.Sub_Status__c != 'Pending' && caseObj.Sub_Status__c != 'Discrepancies' && caseObj.Sub_Status__c != 'Follow Up')  && caseObj.Region_Flag__c == 'Bahrain'){
                   System.debug('Checking Sub Status values from Pending ------> Other State');
                   stampSubStatusChange(caseObj, 'Changed');
               }
            //CH26: END
            //CH66: Start
            if(isLimitIncrease(caseObj) && changedToAny(caseObj, caseOldObj, Case.Sub_Status__c, new List<String>{'Pending', 'Discrepancies'}) && caseObj.Region_Flag__c == 'Bahrain'){
                   System.debug('Checking Sub Status values from Other State in limit increase ------> Pending');
                   stampSubStatusChange(caseObj, 'Not Changed');
               }
            if(isLimitIncrease(caseObj) && caseOldObj.Sub_Status__c != caseObj.Sub_Status__c &&
               (caseObj.Sub_Status__c != 'Pending' && caseObj.Sub_Status__c != 'Discrepancies') && caseObj.Region_Flag__c == 'Bahrain'){
                   System.debug('Checking Sub Status values from Pending/Discrepancies ------> Other State');
                   stampSubStatusChange(caseObj, 'Changed');
               }
            //CH66: END
            //CH15: Start
            //CH26:Start Commented by Jahangeer Mohammed #13-03-2022# related to Credit Card Application
            //CH28 : Added IsCashCollateral field in if condition
            //CH44 : Commented by Jahangeer Mohammed #06-09-2022# realated to Credit Limit Increase Application
            //CH55: Added Region Flag in if condition
            if((caseObj.Type == 'Credit Limit Increase Application' && caseObj.Region_Flag__c == 'Bahrain') && changedToAny(caseObj, caseOldObj, Case.cc_Signature_Verifier_Result__c, new List<String>{'Re-Send', 'Refer to Service Center'}) && caseObj.Awaiting_Customer_Feedback__c == true)
            {
                caseObj.Customer_Responded_for_Pending_Signature__c = 'Customer Not Responded';
                caseObj.cc_Date_Awaiting_For_Pending_Signature__c = System.now();
            }
            //CH15: END
    }
    public static void creditCardBeforeUpdateRouting(Case caseObj, Case caseOldObj, List<Queue_IDs__mdt> queueIds, Map<Id, String> caseToRegion){
            //CH46: Start
            //CH55: Added Region Flag in if condition
            if(isNewCreditCard(caseObj) && ((caseOldObj.Campaign_Name__c != caseObj.Campaign_Name__c) || (caseOldObj.Campaign_Validity__c != caseObj.Campaign_Validity__c)) && caseObj.Region_Flag__c == 'Bahrain'){
                if(caseOldObj.Campaign_Name__c != caseObj.Campaign_Name__c && caseObj.Campaign_Name__c != null){
                    caseObj.Approved_Campaign_Name__c = caseObj.Campaign_Name__c;
                }
                if(caseOldObj.Campaign_Validity__c != caseObj.Campaign_Validity__c && caseObj.Campaign_Validity__c != null){
                    caseObj.Approved_Campaign_Validity__c = caseObj.Campaign_Validity__c;
                }
            }
            //CH46: END
            //CH32 : Start
            //CH55: Added Region Flag in if condition
            if(isNewCreditCard(caseObj) && caseObj.cc_Friend_s_Contact_Number__c != caseOldObj.cc_Friend_s_Contact_Number__c &&
               caseObj.cc_Friend_s_Contact_Number__c != null && caseObj.Region_Flag__c == 'Bahrain'){
                   String appendCountryCodeWithFriendNumber = '';
                   String friendNumber = caseObj.cc_Friend_s_Contact_Number__c;
                   if(!friendNumber.startsWith('+') && !friendNumber.startsWith('00')){
                       appendCountryCodeWithFriendNumber = '+973';
                       System.debug('Final Friend Contact Number:'+appendCountryCodeWithFriendNumber + caseObj.cc_Friend_s_Contact_Number__c);
                       caseObj.cc_Final_Friend_s_Contact_Number__c = appendCountryCodeWithFriendNumber + caseObj.cc_Friend_s_Contact_Number__c;
                   }
                   if(friendNumber.startsWith('+973')){
                       caseObj.cc_Final_Friend_s_Contact_Number__c = friendNumber ;
                   }
                   if(friendNumber.startsWith('00')){
                       String extractStartingTwoIndexValues = friendNumber.substring(0,2);
                       String replaceString = '+';
                       String replace00WithPlus = extractStartingTwoIndexValues.replace(extractStartingTwoIndexValues,replaceString);
                       String extractAfterSecondIndex = friendNumber.substring(2,friendNumber.length());
                       caseObj.cc_Final_Friend_s_Contact_Number__c  = replace00WithPlus + extractAfterSecondIndex;
                   }
               }
            //CH55: Added Region Flag in if condition
            if(isNewCreditCard(caseObj) && caseObj.cc_Friend_s_Contact_Number__c != caseOldObj.cc_Friend_s_Contact_Number__c &&
               caseObj.cc_Friend_s_Contact_Number__c == null && caseObj.Region_Flag__c == 'Bahrain'){
                   caseObj.cc_Final_Friend_s_Contact_Number__c = caseObj.cc_Friend_s_Contact_Number__c;
               }
            //CH32 : END
            //CH11 : Start
            //CH28 : Added IsCashCollateral field in if condition
            //CH26 : Commented the condition for Credit Card Application by #Jahangeer Mohammed# #13-03-2022#
            //CH44 : Commented by Jahangeer Mohammed #06-09-2022# realated to Credit Limit Increase Application
            //CH55: Added Region Flag in if condition
            if((isLimitIncrease(caseObj)) && changedTo(caseObj, caseOldObj, Case.Sub_Status__c, 'Documents Received') && caseObj.Region_Flag__c == 'Bahrain')
            {
                routeToPreScreener(caseObj, queueIds, caseToRegion);
                //CH19 : END
            }
            //CH55: Added Region Flag in if condition
            if(isNewCreditCard(caseObj) && changedTo(caseObj, caseOldObj, Case.Sub_Status__c, 'Documents Received') && caseObj.Region_Flag__c == 'Bahrain'){
                routeToPreScreener(caseObj, queueIds, caseToRegion);
            }
            //CH11 : END
    }
    public static void creditCardEmailReceivedResponse(Case caseObj){
                //CH15: Start
                //CH26:Start Commented by Jahangeer Mohammed #10-03-2022# related to Credit Card Application
                //CH28 : Added IsCashCollateral field in if condition
                //CH44 : Commented by Jahangeer Mohammed #06-09-2022# realated to Credit Limit Increase Application
                //CH55: Added Region Flag in if condition
                //CH83: Start Added the condition Credit Card Application,Cash Collateral Credit Limit Increase Application,Credit Card Cash Collateral Application in the below condition
                if(caseObj.Sub_Status__c == 'Pending' && ((caseObj.Type == 'Credit Limit Increase Application' || caseObj.Type == 'Credit Card Application' || caseObj.Type == 'Cash Collateral Credit Limit Increase Application' || caseObj.Type == 'Credit Card Cash Collateral Application') && caseObj.Region_Flag__c == 'Bahrain' )){
                    caseObj.cc_Customer_Response__c = 'Customer Responded';
                }
                //CH83: END
                //CH28 : Added IsCashCollateral field in if condition
                //CH44 : Commented by Jahangeer Mohammed #06-09-2022# realated to Credit Limit Increase Application
                //CH55: Added Region Flag in if condition
                if(caseObj.Sub_Status__c == 'Discrepancies' && (caseObj.Type == 'Credit Limit Increase Application' && caseObj.Region_Flag__c == 'Bahrain' )){
                    caseObj.cc_Customer_Response_For_Discrepancy__c = 'Customer Responded';
                }
                //CH28 : Added IsCashCollateral field in if condition
                //CH44 : Commented by Jahangeer Mohammed #06-09-2022# realated to Credit Limit Increase Application and added Type = 'Cash Collateral Credit Limit Increase Application' in If condition
                //CH55: Added Region Flag in if condition
                if((caseObj.Type == 'Credit Limit Increase Application' || caseObj.Type == 'Cash Collateral Credit Limit Increase Application' && caseObj.Region_Flag__c == 'Bahrain' ) && caseObj.Sub_Status__c == 'Pending Signature Verification'){
                    caseObj.Customer_Responded_for_Pending_Signature__c = 'Customer Responded';
                }
                //CH26: END
                //CH15: END
                //CH17: Start
                //CH55: Added Region Flag in if condition
                if(caseObj.Sub_Status__c == 'Pending' && caseObj.Type == 'Credit Card Supplementary Application' && caseObj.Region_Flag__c == 'Bahrain'){
                    caseObj.cc_Customer_Response__c = 'Customer Responded';
                }
                //CH17: END
    }
    public static void creditCardEmailStatusResponse(Case caseObj, Case caseOldObj){
            //CH83: Start
            if(changedTo(caseObj, caseOldObj, Case.Email_Status__c, 'Email Sent') && caseObj.Region_Flag__c == 'Bahrain'){
                if(caseObj.Type == 'Credit Limit Increase Application' || caseObj.Type == 'Credit Card Application' || caseObj.Type == 'Cash Collateral Credit Limit Increase Application' || caseObj.Type == 'Credit Card Cash Collateral Application'){
                    caseObj.cc_Customer_Response__c = 'Email sent to Customer';
                    System.debug('Email Sent to the Customer');
                }
            }
            if(changedTo(caseObj, caseOldObj, Case.Email_Status__c, 'Email Received') && caseObj.Region_Flag__c == 'Bahrain'){
                if(caseObj.Type == 'Credit Limit Increase Application' || caseObj.Type == 'Credit Card Application' || caseObj.Type == 'Cash Collateral Credit Limit Increase Application' || caseObj.Type == 'Credit Card Cash Collateral Application'){
                    caseObj.cc_Customer_Response__c = 'Customer Responded';
                    System.debug('Email Received from the Customer');
                }
            }
            //CH83: END
    }
    public static void CCRequestCreation(final List<Case> newRecs) {
        Set<Id> setCaseStaffInprog  = new Set<Id>();
        Set<Id> setCaseDocReceived  = new Set<Id>();
        Set<Id> setSuppCasePending  = new Set<Id>();
        //CH40: Start
        Set<Id> setCashCollateralLMTIncreaseDocsReceived = new Set<Id>();
        //CH40: END
        for(Case caseObj : newRecs) {
            //CH55: Added Region Flag in if condition
            if(caseObj.Type == 'Credit Card Application' && caseObj.cc_Requested_Card_Type__c != '' && caseObj.Sub_Type__c == 'New Credit Card' && (caseObj.Sub_Status__c == 'In-Progress' || caseObj.Sub_Status__c == 'Pending') && caseObj.Region_Flag__c == 'Bahrain')
            {
                setCaseStaffInprog.add(caseObj.id);
            }
            //CH55: Added Region Flag in if condition
            if(caseObj.Type == 'Credit Card Application' && caseObj.cc_Requested_Card_Type__c != '' && caseObj.Sub_Type__c == 'New Credit Card' && caseObj.Sub_Status__c == 'Documents Received' && caseObj.Region_Flag__c == 'Bahrain')
            {
                setCaseDocReceived.add(caseObj.id);
            }
            //CH13: Start
            //CH55: Added Region Flag in if condition
            if((isSupplementaryCard(caseObj) || isLimitIncrease(caseObj)) && (caseObj.Sub_Status__c == 'Pending' || caseObj.Sub_Status__c == 'In-Progress') && caseObj.Region_Flag__c == 'Bahrain' )
            {
                setSuppCasePending.add(caseObj.id);
            }
            //CH13: END
            //CH40: Start
            //CH55: Added Region Flag in if condition
            if(isLimitIncrease(caseObj) && caseObj.Sub_Status__c == 'Documents Received' && caseObj.Region_Flag__c == 'Bahrain'){
                setCashCollateralLMTIncreaseDocsReceived.add(caseObj.id);
            }
            //CH40: END
        }
        callCaseCreation(setCaseStaffInprog, true, null);
        callCaseCreation(setCaseDocReceived, true, null);
        callCaseCreation(setSuppCasePending, false, 'Inside Credit Limit Update and Supplementary Cards:');
        //CH40: Start
        callCaseCreation(setCashCollateralLMTIncreaseDocsReceived, false, 'CASH COLLATERAL LMT INCREASE DOCS RECEIVED:');
        //CH40: END
    }

    /********************************************* HELPER METHODS *********************************************/
    //Calls the Credit Card case update API (future) for one bucket of cases; debugLabel is logged with the case Ids when given
    private static void callCaseUpdate(Set<Id> caseIds, String debugLabel){
        if(!caseIds.isEmpty()){
            if(debugLabel != null){
                System.debug(debugLabel+caseIds);
            }
            initiateManualOnboarding.CCCaseUpdate(caseIds);
        }
    }

    //CH02: Sends the DocuSign documents (not in tests)
    private static void enqueueDocuSign(Set<Id> caseIds){
        if(!test.isRunningTest()){
            DocuSignApexToolKit autoSendDocSign =  new DocuSignApexToolKit(caseIds);
            System.enqueueJob(autoSendDocSign);
        }
    }

    //CH84 / CH87: Starts the In-App DocuSign signing (not in tests)
    private static void startInAppSigning(Set<Id> caseIds, String debugLabel){
        if(!caseIds.isEmpty() && !test.isRunningTest()){
            System.debug(debugLabel+caseIds);
            cc_DocuSignGetEnvelopeId.cc_DocuSignGetEnvelopeIdProcess(caseIds);
        }
    }

    //CH13: Sends the SMS reminders
    private static void sendSMSReminders(Set<Id> caseIds, String debugLabel){
        if(!caseIds.isEmpty()){
            System.debug(debugLabel+caseIds);
            initiateManualOnboarding.sendSMSReminder(caseIds);
        }
    }

    //CH05 / CH31 / CH50 / CH58 / CH73 / CH76 / CH90: adds a Case Comment when the comment field changed and is not blank,
    //for an allowed case type in Bahrain. Returns true when a comment was added.
    private static Boolean addCaseComment(Case caseObj, Case caseOldObj, Schema.SObjectField commentField, Boolean isAllowedType, String debugMessage, String commentPrefix, List<CaseComment> lstComment){
        String newComment = (String)caseObj.get(commentField);
        String oldComment = (String)caseOldObj.get(commentField);
        if(newComment != oldComment && newComment != null && newComment != '' && isAllowedType && caseObj.Region_Flag__c == 'Bahrain'){
            System.debug(debugMessage);
            CaseComment comm = new CaseComment(ParentID=caseObj.id, CommentBody= commentPrefix+ newComment);
            lstComment.add(comm);
            return true;
        }
        return false;
    }

    //CH21 / CH50: stores the current user in byField when the result field changed (existing check kept as it is)
    private static void stampUpdatedBy(Case caseObj, Case caseOldObj, Schema.SObjectField resultField, Schema.SObjectField byField, String debugMessage){
        String newResult = (String)caseObj.get(resultField);
        String oldResult = (String)caseOldObj.get(resultField);
        if(oldResult != newResult
           && (newResult != '' || newResult != null)){
               caseObj.put(byField, UserInfo.getUserId());
               System.debug(debugMessage);
           }
    }

    //CH26 / CH66: stamps the Pending sub-status change ('Not Changed' / 'Changed') and its date/time
    private static void stampSubStatusChange(Case caseObj, String changeValue){
        caseObj.cc_Last_Sub_Status_Changed_Pending__c = changeValue;
        caseObj.LastCaseSubStatusChanged__c = System.now();
    }

    //CH11 / CH19: Documents Received - routes the case to the Credit Card Pre-Screener queue
    private static void routeToPreScreener(Case caseObj, List<Queue_IDs__mdt> queueIds, Map<Id, String> caseToRegion){
        Util.setOwnerQueue(queueIds, caseToRegion, caseObj, CREDIT_CARD_PRE_SCREENER_QUEUE);
        caseObj.cc_CRM_Stage__c = 'IN PROGRESS';
        caseObj.cc_Application_Stages__c = 'Credit Pre-Screening';
        caseObj.Awaiting_Customer_Feedback__c = false;
    }

    //CH25 / CH66: copies sourceField into targetField when it is not blank
    private static void copyIfNotBlank(Case cs, Schema.SObjectField sourceField, Schema.SObjectField targetField){
        String sourceValue = (String)cs.get(sourceField);
        if(sourceValue != null &&  sourceValue != ''){
            cs.put(targetField, sourceValue);
        }
    }

    //Calls the Credit Card case creation API (future) for one bucket of cases.
    //skipInTests keeps the existing test behaviour of each bucket; debugLabel is logged with the case Ids when given
    private static void callCaseCreation(Set<Id> caseIds, Boolean skipInTests, String debugLabel){
        if(!caseIds.isEmpty() && !(skipInTests && test.isRunningTest())){
            if(debugLabel != null){
                System.debug(debugLabel+caseIds);
            }
            initiateManualOnboarding.CCCaseCreation(caseIds);
        }
    }

    //Case type checks
    private static Boolean isNewCreditCard(Case caseObj){
        return caseObj.Type == 'Credit Card Application' && caseObj.Sub_Type__c == 'New Credit Card';
    }
    private static Boolean isLimitIncrease(Case caseObj){
        return caseObj.Type == 'Credit Limit Increase Application' && caseObj.Sub_Type__c == 'Credit Limit Increase';
    }
    private static Boolean isSupplementaryCard(Case caseObj){
        return caseObj.Type == 'Credit Card Supplementary Application' && caseObj.Sub_Type__c == 'New Supplementary Card';
    }

    //true when the field changed and its new value is newValue
    private static Boolean changedTo(Case caseObj, Case caseOldObj, Schema.SObjectField field, String newValue){
        String newFieldValue = (String)caseObj.get(field);
        String oldFieldValue = (String)caseOldObj.get(field);
        return newFieldValue != oldFieldValue && newFieldValue == newValue;
    }

    //true when the field changed and its new value is one of newValues (each value compared with ==, as before)
    private static Boolean changedToAny(Case caseObj, Case caseOldObj, Schema.SObjectField field, List<String> newValues){
        String newFieldValue = (String)caseObj.get(field);
        String oldFieldValue = (String)caseOldObj.get(field);
        if(newFieldValue == oldFieldValue){
            return false;
        }
        for(String newValue : newValues){
            if(newFieldValue == newValue){
                return true;
            }
        }
        return false;
    }

    //true when the checkbox field changed and is now checked
    private static Boolean changedToTrue(Case caseObj, Case caseOldObj, Schema.SObjectField field){
        Boolean newFieldValue = (Boolean)caseObj.get(field);
        Boolean oldFieldValue = (Boolean)caseOldObj.get(field);
        return newFieldValue != oldFieldValue && newFieldValue == true;
    }
}
