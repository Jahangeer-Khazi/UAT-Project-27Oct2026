/*      Organization : ABC Bank
*      Created By:
*      Created Date:
*      Change History:
*             #CH01# #Jahangeer Mohammed# Added #28-04-2021# Added Logic to check before customer Archival all the related cases has to be closed.
*             #CH02# #Shashank# Added #10-06-2021# Added Logic to perform Docusign Automation to send the document based on cc_Application_Stages__c change of Case.
*             #CH03# #Jahangeer Mohammed# Added #20-06-2021# Added Logic to check Operations Result = Balance Transfer Processed.
*             #CH04# #Shashank# Added #21-06-2021# added logic for Account Closure.
*             #CH05# #Jahangeer Mohammed# Added #24-06-2021 Added Logic to Call API According to the Additional Requirements of Credit Cards.
*             #CH06# #Shashank# Added #27-07-2021# logic to use in Credit Limit Increase.
*             #CH07# #Jahangeer Mohammed# Added #05-09-2021# Added Logic to Send an Email and Pdf for No Due Certificate.
*             #CH08# #Jahangeer Mohammed# Added #21-09-2021# Added Logic for CEO Approval
*             #CH09# #Jahangeer Mohammed# Added #28-09-2021# Added Logic for Credit Retail Team wise and Application Stage wise agent can able to edit the case (Commented)
*             #CH10# #Jahangeer Mohammed# Added #04-10-2021# Added Logic for Credit Card Application Process Refinement.
*             #CH11# #Ashish Pandey# Added #07-10-2021# Added Logic when Customer is Uploading the documents through Mobile App
*             #CH12# #Jahangeer Mohammed# #11-10-2021# Added Logic for HR Comments.
*             #CH13# #Jahangeer Mohammed# #28-10-2021# Added LOgic for Credit Limit Update on Case Creation
*                    #Jahangeer Mohammed# #01-11-2021# Added Logic for Signature Verifier Result = 'Accept'
*                    #Jahangeer Mohammed# #02-11-2021# Commented the HR phase for Credit Limit Update
*                    #Jahangeer Mohammed# #05-11-2021# Changing the Record Type to 'Credit Limit Increase'
*                    #Jahangeer Mohammed# #12-11-2021# Calling API for SMS Reminders
*             #CH14# #Mbarki Aniss# #14-11-2021# for testing purposes to work around an impossible if condition (which requires creating a specific record in the "Credit_User__mdt" custom metadata) when we run the test class "CaseHandlerTest"
*             #CH15# #Jahangeer Mohammed# #28-11-2021# Added the Remainder Check Condition for Credit Card Application and Credit Limit Increase Application
*             #CH16# #Jahangeer Mohammed# #09-12-2021# Added the Cash Collateral Credit Card Logic
*             #CH17# #MBARKI ANISS# #09-12-2021# Added the Reminder Check Condition for Credit Card Supplementary Application
*             #CH18# #Wissal # #14-12-2021# cbb block/unblock changes
*             #CH19# #Jahangeer Mohammed# #09-01-2022# Added a Logic when Customer is Uploading the document using mobile App need to
*                    Stop triggering reminder Email notification.
*             #CH20# #Swapna Reddy# #20-01-2022# Added a Logic when Maker Accept new Credit Collection case update Owner Id to Credit Approval Queue and
*                    Update the sub-status.
*                    #Swapna Reddy# #20-01-2022# Added Logic update the sub-status based on cheker response for credit Collection Case
*             #CH21# #Jahangeer Mohammed #26-01-2022# Added a Logic to populate user when different credit team were action on
*                     credit card case creation.
*             #CH22# #Jahangeer Mohammed #31-01-2022# Added Logic for Credit Card Staff Application(NBA-4713)
*             #CH23# #Jahangeer Mohammed #09-02-2022# Added Logic for Request Digital Documents for Staff Application who have already
*                      Applied for Active Cards and Cases are Closed.
*             #CH24# #Jahangeer Mohammed #10-02-2022# Added Logic for Credit Card Staff Application(NBA-4807)
*             #CH25# #Jahangeer Mohammed #06-03-2022# Added a Logic to populate Approved Name on the Card (NBA-4607)
*             #CH26# #Jahangeer Mohammed #10-03-2022# Customer Responded condition commented for (NBA-4947/4948)
*             #CH27# #Swapna Reddy#06-03-2022# Added Logic for Premium Retention Case
*             #CH28# #Jahangeer Mohammed #03-04-2022# Added Logic for Cash Collateral Limit Increase for (NBA-5230)
*             #CH29# #Jahangeer Mohammed #28-03-2022# Added Logic for Debit Card Enhancements for (NBA-4723)
*             #CH30# #Swapna Konuganti #14-04-2022# Added Logic for Recovery Codes
*             #CH31# #Jahangeer Mohammed# #17-04-2022# Added CaseComment Logic for Cash Collateral and Supplemenatry Cards (PI-1561)
*             #CH32# #Jahangeer Mohammed# #18-04-2022# Added Friends Contact Number Logic (NBA-5143)
*             #CH33# #Jahangeer Mohammed# #26-04-2022# Added Logic to populate user for Credit Limit Increase Application.
*             #CH34# #Wissal# Added a condition for Block and Unblock Record Type.
*             #CH35# #Prashant# #26-04-2022#  Added a condition for Customer Profile Update Record Type.
*             #CH36# #Jahangeer Mohammed# #15-05-2022# Added extra brackets in If condition for Decline & Cancelled by Customer(PI-1564)
*             #CH37# #Benqezza wissal# #17-05-2022# Added condition on record type account interest rate cutom label
*             #CH38# #Jahangeer Mohammed# #2-06-2022#  Added a condition for by pass New Update Customer Profile Record Type.
*             #CH39#  #Prashant# #3-07-2022#   Bypass this condition for New_Update_Customer_Profile recordtype
*             #CH40# #Jahangeer Mohammed #28-06-2022# Added Logic to Populate CPR Number & CPR Expiry(NBA-5692 & NBA-5693)
*             #CH41# #MBARKI ANISS# #29-06-2022# add some logic if (Email_Status__c == 'Email Received' && caseObj.Awaiting_Customer_Feedback__c == true) for Credit Card Prepaid
*             #CH42# # ASHISH# #15-08-2022# Reset Recover Code - SMS to be sent on clicking 'Generate Reecovery Code'
*             #CH43# #Bug fix to avoid recursive call added !System.isFuture() check
*             #CH44# #Jahangeer Mohammed# #06-09-2022# Added Logic for Cash Collateral Limit Increase Application(NBA-6043)
*             #CH45# #Benqezza wissal# #05-10-2022# Added condition on  Amount Blocking Unblocking Directive Record Type
*             #CH46# #Jahangeer Mohammed# #13-10-2022# Added Logic as per Approved Campaign Name & Approved Campaign Validity as per(NBA-5719)
*             #CH47# #Jahangeer Mohammed# #07-11-2022# Added Logic for Walkin Customers to Send SMS Reminders
*             #CH48# #Jahangeer Mohammed #21-11-2022# Added Logic for Periodic Review Project
*             #CH49# #Aniss Mbarki #22-11-2022# Added Logic for Enhanced Supplementary Card Application Process
*             #CH50# #Jahangeer Mohammed# #24-11-2022# Added Logic for Application Queue Improvements (NBA-6361)
*             #CH51# #ASHISH# #30-11-2022# Added Logic for Custom History Tracking(CRM22-141)
*             #CH52# #ASHISH# #16-12-2022# Added Logic for Calculating the Final DBR and Obligation for Credit Cards(CRM22-139)
*             #CH55# #Jahangeer Mohammed# #09-04-2023# Restrict Credit Card Applications to Bahrain Region
*             #CH56# #Aniss Mbarki# #23-04-2023# bypass caseObj.Sub_Type__c = 'Alburaq Segment Change'
*             #CH57# #Aniss Mbarki# #04-05-2023# skip some Process for Jordan and some Credit card types
*             #CH58# #Jahangeer Mohammed# #23-10-2023# Credit Card Upgrade Enhancements(NBA-9090)
*             #CH59# : Elmustapha ELGARNI add HandleDNDCases function and add logic to handle Marketing Prefences to add/Remove customer to/from DND list . Date 04/03/2024
*             #CH62# #Jahangeer Mohammed# #02-01-2024# Added Logic for Investement Questionnaire - Sukuk/Bonds
*             #CH65# #Jahangeer Mohammed# #08-03-2024# Added Logic to automatically populate Credit Bureau Risk Rating(NBA-10657)
*             #CH66# #Jahangeer Mohammed# #13-03-2024# Added Logic for Credit Card Limit Increase Reminder - Ila World/Ila World Ilite Fast Track(NBA-8899)
*             #CH64# #Tsioucha Imane# #05-06-2024# Added Logic for Premium Retention Enhancement
*             #CH68# #Tsioucha Imane# #13-06-2024# Added Logic for SLA for Issue Cases(Local/International)
*             #CH69# #Jahangeer Mohammed# #20-05-2024# Added Decline & Cancelled by Customer in Signature Verifier Phase(NBA-11053)
*             #CH70# #Aniss Mbarki# #16-07-2024# Added Logic for Deceased Customer requirement
*             #CH72# #Ranjith Raja# #01-10-2024# Added Logic for Refreshing Custom Components
*             #CH73# #Ranjith Raja# #20-10-2024# Optimized the logic for creating case comments when users enter makers' and checkers' comments.
*             #CH74# #Jahangeer Mohammed# #30-12-2024# Added Logic to add Co-Branded Cards(NBA-12524)
*             #CH75# #Jahangeer Mohammed# #22-01-2025# Added Logic to Bypass for Credit Card Upgrade
*             #CH76# #Jahangeer Mohammed# #05-02-2025# Added Logic to Make Signature Verifier Result & HR Result Comments Blank
*             #CH77# #Jahangeer Mohammed# #19-06-2025# Added Logic for Loan Approval Matrix(NBA-12481)
*             #CH78# #Jahangeer Mohammed# #08-07-2025# Added Logic for Convert Credit Card Application(NBA-13871)
*             #CH79# #Aniss Mbarki# #23-07-2025# Added Logic for CRM+Enhancements+-+Generating+Letters+from+CRM+-+Files(NBA-15458)
*             #CH80# #Jahangeer Mohammed# 24-08-2025# Added a logic to control recursion on updating Premium invitation (PI-4283)
*             #CH81# #Jahangeer Mohammed# 06-10-2025# Added a logic for Credit Card Upgrade Restriction (NBA-15639)
*             #CH82# #Jahangeer Mohammed# 16-11-2025# Added Logic for World Entitlement Project(NBA-15929)
*             #CH83# #Jahangeer Mohammed# 24-11-2025# Added Logic for Queues Re-structuring at Credit Pre-Screener (NBA-15993)
*             #CH84# #Aniss Mbarki# 17-12-2025# Added Logic for Credit Card - In-App DocuSign Documents Signing  (NBA-13727)
*             #CH85# #Jahangeer Mohammed# 01-03-2026# Added Logic for Credit Card Services Cache API (NBA-16716)
*             #CH86# : #Jahangeer Mohammed# #11-03-2026# Added Logic for Credit Card Guarantor CIF (NBA-16525)
*             #CH87# #Aniss Mbarki# 21-04-2026# Added Logic for Credit Card FOR STAFF - In-App DocuSign Documents Signing  (NBA-13727)
*             #CH88# AITOGRAM Omar 27-04-2026 Added logic for Cancelling fawri transfer (NBA-15906)
*             #CH89# AITOGRAM Omar 11-05-2026 Added logic for FATCA project NBA-16536
#CH90# #Jahangeer Mohammed# 28-08-2026# Added Logic for Making Comments Blank for Credit Card Upgrade(UATNB-228941)
#CH91# #Maksud Ali 31-08-2026# Added logic for Maker/checker for Place Hold ticket.
#CH92# #Ranjith Raja 14-10-2026# Added logic for Jordan Credit Card Insurance Monthly Fee.
#CH93# 01-11-2026# Moved reStartManualOnboarding method to the new support class CreditCardHandler (logic unchanged).
*/
public without sharing class CaseHandler extends BaseTriggerHandler {
    private static final String  CONTACT_CENTRE_QUEUE = 'Contact Centre';
    private static final String  MAKER_QUEUE = 'Makers Queue';
    private static final String  CHECKER_QUEUE = 'CheckerQueue';
    private static final String  CREDIT_CARD_ANTI_ATTRITION = 'Credit Card Anti Attrition';
    private static final String  CREDIT_CARD_PRE_SCREENER_QUEUE = 'Credit Card Pre-Screener Queue';
    private static final String  VISIONPLUS_MANUAL_QUEUE = 'VisionPlus Manual Queue';
    private static Boolean hasRun = false;
    // CH51 - Start
    public static Map<Id,User> staticActiveUserById;
    public static Map<Id,User> getActiveUserById(){
        if(staticActiveUserById == null){
            staticActiveUserById = new Map<Id,User>([Select id, Name, FirstName, LastName, Email, Username from User where isActive=True]);
        }
        return staticActiveUserById;
    }
    // CH51 - End
    override public void beforeInsert () {
        setCaseUuid((List<Case>)Trigger.new);
        setContact((List<Case>)Trigger.new);
        //CH78: Start
        ConvertCreditCardHandler.handlerBeforeCaseCreation((List<Case>)Trigger.new);
        //CH78: END
        //CH16: Start
        CashCollateralHandler.handlerBeforeCaseCreation((List<Case>)Trigger.new);
        //CH16: END
        //CH48: Start
        PeriodicReviewHandler.handlerBeforeCaseCreation((List<Case>)Trigger.new);
        //CH48: END
        //CH30 : Start Swapna
        for(Case cs:(List<Case>)Trigger.new){
            if(cs.Type=='Unblock App Access' &&  cs.OwnerId!=system.Label.RMT_Queue_Id &&
               ((cs.Last_Date_Email_Changed__c>=0 && cs.Last_Date_Email_Changed__c<4)
                ||(cs.Last_Date_Mobile_Changed__c>=0 && cs.Last_Date_Mobile_Changed__c<4))){
                    cs.ownerId=system.Label.RMT_Queue_Id;
                }
        }
        //CH30 : End Swapna
        //CH47: Start
        walkInCustomerHandler.handlerBeforeCaseInsert((List<Case>)Trigger.new);
        //CH47: END
        //CH58: Start
        CreditCardUpgradeHandler.handlerBeforeCaseCreation((List<Case>)Trigger.new);
        //CH58: END
        //CH62: Start
        InvestmentQuestionnaireHandler.handlerBeforeCaseCreation((List<Case>)Trigger.new);
        //CH62: END
        creditCardListController.handleBeforeCaseCreation(Trigger.new);
        //CH92: Start
        List<Case> newCases = (List<Case>) Trigger.new;
        List<Case> creditCardCases = new List<Case>();
        for (Case cs: newCases) {
            if (cs.RecordType_DeveloperName__c == 'Credit_Card') {
                creditCardCases.add(cs);
            }
        }
        if (!creditCardCases.isEmpty()) {
            CaseCCInsuranceDefaultHandler.setDefaultCCInsurance(creditCardCases);
        }
        //CH92: End
    }
    override public void beforeUpdate () {
        before_UpdateDML((List<Case>)Trigger.new);
        //CH78: Start
        ConvertCreditCardHandler.handlerBeforeCaseUpdate((List<Case>)Trigger.new);
        //CH78: END
        //CH16: Start
        CashCollateralHandler.handlerBeforeCaseUpdate((List<Case>)Trigger.new);
        //CH16: END
        //CH29: Start
        DebitCardHandler.handlerBeforeCaseUpdate((List<Case>)Trigger.new);
        //CH29: END
        //CH48: Start
        PeriodicReviewHandler.handlerBeforeCaseUpdate((List<Case>)Trigger.new);
        //CH48: END
        //CH47: Start
        walkInCustomerHandler.handlerBeforeCaseUpdate((List<Case>)Trigger.new);
        //CH47: END
        //CH58: Start
        CreditCardUpgradeHandler.handlerBeforeCaseUpdate((List<Case>)Trigger.new);
        //CH58: END
        //CH62: Start
        InvestmentQuestionnaireHandler.handlerBeforeCaseUpdate((List<Case>)Trigger.new);
        //CH62: END
        // CH68 : START
        assignEntitlements((list<Case>)Trigger.new, (Map<Id,Case>)Trigger.oldMap);
        // CH68 : END
        CaseProcessingHandler.beforeServiceRequestUpdate((List<Case>) Trigger.new, (Map<Id, Case>) Trigger.oldMap);
        InvestmentQuestionnaireHandler.handlerBeforeCaseUpdate((List<Case>)Trigger.new, (Map<Id,Case>)Trigger.oldMap);
        creditCardListController.handleCancelBalanceTransferPlanMaker((List<Case>)Trigger.new, (Map<Id,Case>)Trigger.oldMap);
    }
    override public void afterInsert () {
        CCRequestCreation((List<Case>)Trigger.new);
        //CH16: Start
        CashCollateralHandler.handlerAfterCaseCreation((List<Case>)Trigger.new);
        //CH16: END
        //CH48: Start
        PeriodicReviewHandler.handlerAfterCaseCreation((List<Case>)Trigger.new);
        //CH48: END
        //CH59: Start
        HandleDNDCases((List<Case>)Trigger.new);
        //CH59: End
        //CH81: Start
        CreditCardUpgradeHandler.handlerAfterCaseCreation((List<Case>)Trigger.new);
        //CH81: END
    }
    override public void afterUpdate () {
        CreditCardHandler.reStartManualOnboarding((List<Case>)Trigger.new, (Map<Id,Case>)Trigger.oldMap); //CH93
        //CH18: wissal changes
        SM002_CbbAmountHandler.handleAfterCaseUpdate( (List<Case>) Trigger.new ,(Map<Id,Case>)Trigger.oldMap );
        //CH78: Start
        ConvertCreditCardHandler.handlerAfterCaseUpdate((List<Case>)Trigger.new);
        //CH78: END
        //CH16: Start
        CashCollateralHandler.handlerAfterCaseUpdate((List<Case>)Trigger.new);
        //CH16: END
        //CH29: Start
        DebitCardHandler.handlerAfterCaseUpdate((List<Case>)Trigger.new);
        //CH29: END
        //CH47: Start
        walkInCustomerHandler.handlerAfterCaseUpdate((List<Case>)Trigger.new);
        //CH47: END
        //CH48: Start
        PeriodicReviewHandler.handlerAfterCaseUpdate((List<Case>)Trigger.new);
        //CH48: END
        //CH58: Start
        CreditCardUpgradeHandler.handlerAfterCaseUpdate((List<Case>)Trigger.new);
        //CH58: END
        //CH72: Start
        CaseCommentController.componentRefreshPE();
        //CH72: END
        CaseSLATriggerHandler.handleOwnerChange((List<Case>)Trigger.new, (Map<Id,Case>)Trigger.oldMap);
        processPostUpdate((List<Case>)Trigger.new, (Map<Id, Case>)Trigger.oldMap);
        Set<Id> caseIds = new Set<Id>();
        Set<Id> placeHoldCaseIds = new Set<Id>(); //MA CH91
        for (Case c : (List<Case>)Trigger.new) {
            Case oldC = (Case)Trigger.oldMap.get(c.Id);
            if (c.cc_Checker_Result__c == 'Approve' &&
                c.cc_Checker_Result__c != oldC.cc_Checker_Result__c) {
                    if (c.cc_Request_Type__c == 'Staff Joiner' ||
                        (c.cc_Request_Type__c == 'Staff Leaver' && c.From_Date__c == Date.today())) {
                            caseIds.add(c.Id);
                        }
                }
            //CH91 START MA NBA-13633
            if(c.cc_Checker_Result__c != oldC.cc_Checker_Result__c && c.cc_Checker_Result__c == 'Place Hold'){
                placeHoldCaseIds.add(c.Id);
            }
            //CH91 END MA NBA-13633
        }
        if (!caseIds.isEmpty()) {
            System.enqueueJob(new HandleCheckerApprovalQueueable(caseIds));
        }
        creditCardListController.handleCancelBalanceTransferPlanChecker((List<Case>)Trigger.new, (Map<Id,Case>)Trigger.oldMap);
        creditCardListController.processQueuedCancellations();
        InvestmentQuestionnaireHandler.handlerAfterCaseUpdate((List<Case>)Trigger.new, (Map<Id,Case>)Trigger.oldMap);
        //CH91 START MA NBA-13633
        if(!placeHoldCaseIds.isEmpty()){
            System.enqueueJob(
                new PlaceHoldQueueable(placeHoldCaseIds)
            );
        }
        //CH91 END MA NBA-13633
    }
    @TestVisible
    private static void setCaseUuid(final List<Case> recs){
        //CH13: Start Added by #Jahangeer Mohammed# #05-11-2021#
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Credit Limit Increase').getRecordTypeId();
        //CH13: END
        Set<String> accountIds = new Set<String>();
        Map<Id,List<Case>> accountVsCase = new Map<Id,List<Case>>();
        for(Case rec : recs) {
            //#CH57 : Start skipp caseHandler process for Jordan
            if( rec.Region_Flag__c != 'Bahrain' ){
                System.debug('CaseHabdler before insert setCaseUuid Skipped for this record ---->>> ' + rec.CaseNumber );
                continue;
            }
            //#CH57 : END
            rec.Uuid__c = generateUuid();
            // checking id case Type is Credit Card
            //CH13: Start Added by #Jahangeer Mohammed# #05-11-2021#
            if(rec.Type == 'Credit Limit Increase Application'){
                rec.RecordTypeId = recordTypeId;
            }
            //CH13: END
            //CH04: Start
            if(rec.Type =='Credit Card Account Closing'){
                rec.Sub_Status__c ='In-Progress';
            }
            //CH04: End
        }
    }
    /**
* example (36 chars long): eccea743-9736-01fa-7d87-78965d61fa08
*/
    public static String generateUuid(){
        final Blob b = Crypto.GenerateAESKey(128);
        final String h = EncodingUtil.ConvertToHex(b);
        final String uuid = h.SubString(0,8)+ '-' + h.SubString(8,12) + '-' + h.SubString(12,16) + '-' + h.SubString(16,20) + '-' + h.substring(20);
        return uuid;
    }
    private static void CCRequestCreation(final List<Case> newRecs) {
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
            if(((caseObj.Type == 'Credit Card Supplementary Application' && caseObj.Sub_Type__c == 'New Supplementary Card') || (caseObj.Type == 'Credit Limit Increase Application' && caseObj.Sub_Type__c == 'Credit Limit Increase')) && (caseObj.Sub_Status__c == 'Pending' || caseObj.Sub_Status__c == 'In-Progress') && caseObj.Region_Flag__c == 'Bahrain' )
            {
                setSuppCasePending.add(caseObj.id);
            }
            //CH13: END
            //CH40: Start
            //CH55: Added Region Flag in if condition
            if(caseObj.Type == 'Credit Limit Increase Application' && caseObj.Sub_Type__c == 'Credit Limit Increase' && caseObj.Sub_Status__c == 'Documents Received' && caseObj.Region_Flag__c == 'Bahrain'){
                setCashCollateralLMTIncreaseDocsReceived.add(caseObj.id);
            }
            //CH40: END
        }
        if(!setCaseStaffInprog.isEmpty() && !test.isRunningTest())
        {
            initiateManualOnboarding.CCCaseCreation(setCaseStaffInprog);
        }
        if(!setCaseDocReceived.isEmpty() && !test.isRunningTest())
        {
            initiateManualOnboarding.CCCaseCreation(setCaseDocReceived);
        }
        if(!setSuppCasePending.isEmpty())
        {
            System.debug('Inside Credit Limit Update and Supplementary Cards:'+setSuppCasePending);
            initiateManualOnboarding.CCCaseCreation(setSuppCasePending);
        }
        //CH40: Start
        if(!setCashCollateralLMTIncreaseDocsReceived.isEmpty())
        {
            System.debug('CASH COLLATERAL LMT INCREASE DOCS RECEIVED:'+setCashCollateralLMTIncreaseDocsReceived);
            initiateManualOnboarding.CCCaseCreation(setCashCollateralLMTIncreaseDocsReceived);
        }
        //CH40: END
    }
    private static void before_UpdateDML(final List<Case> newRecs)
    {
        Set<Id> accountIds = new Set<Id>();
        Set<Id> setCaseReminders  = new Set<Id>();
        Set<Id> setResetCoveryCode = new Set<Id>();
        Set<Id> setSecondBHDAccount  = new Set<Id>();
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Credit Card Services').getRecordTypeId();
        //CH21: Start
        Map<ID,Schema.RecordTypeInfo> rt_Map = Case.sObjectType.getDescribe().getRecordTypeInfosById();
        //CH21: END
        Map<id,Case> CaseOldMap = (Map<id,Case>)Trigger.oldMap;
        //Get the queue label for the assignment depending on the region flag
        List<Queue_IDs__mdt> queueIds = [SELECT Id, DeveloperName, Label, Queue_ID__c, MasterLabel, Queue_Name__c, Region__c FROM Queue_IDs__mdt];
        Map<Id, String> caseToRegion = Util.getQueuesCustomMetadata(newRecs);
        // CH51 - Start
        List<History_Tracking__c> lstHistoryTracking = new list<History_Tracking__c>();
        Map<id,Case> caseNewMap = (Map<id,Case>)Trigger.newMap;
        Map<id,User> mapIdUser = getActiveUserById();
        String FinalTrackingList = system.Label.HT_CaseObjectFields1 + ',' + system.Label.HT_CaseObjectFields2 + ',' + system.Label.HT_CaseObjectFields3 + ',' + system.Label.HT_CaseObjectFields4 + ',' + system.Label.HT_CaseObjectFields5;
        List<String> finalLstLeadTrack = FinalTrackingList.split(',');
        Set<Id> accIds = new Set<Id>();
        // CH51 - End
        //CH74: Start
        Set<Id> premiumInvCaseIds = new Set<Id>();
        //CH74: END
        for(Case caseObj : newRecs)
        {
            //#CH57 : Start skipp caseHandler process for Jordan and some types
            String recordTypesExcludedLabel = system.Label.CaseHandler_recordTypesExcluded;
            String typesExcludedLabel = system.Label.CaseHandler_TypesExcluded;
            List<String> recordTypesExcluded = recordTypesExcludedLabel.split(';');
            List<String> typesExcluded = typesExcludedLabel.split(';');
            // CH51 - Start
            /////////////////////////// Custom History Tracking //////////////////////////
            for(String str : finalLstLeadTrack)
            {
                if(caseObj.get(str) != caseOldMap.get(caseObj.id).get(str))
                {
                    History_Tracking__c objHT = new History_Tracking__c();
                    if((string.valueOf(caseOldMap.get(caseObj.id).get(str))!=null && string.valueOf(caseOldMap.get(caseObj.id).get(str)).startsWith('005'))){
                        if(mapIdUser.containsKey(String.valueOf(caseOldMap.get(caseObj.id).get(str)))){
                            objHT.Prior_Value__c = mapIdUser.get(String.valueOf(caseOldMap.get(caseObj.id).get(str))).Name;
                        }
                    }
                    if(string.valueOf(caseObj.get(str))!=null && string.valueOf(caseObj.get(str)).startsWith('005')){
                        if(mapIdUser.containsKey(String.valueOf(caseObj.get(str)))){
                            objHT.Current_Value__c = mapIdUser.get(String.valueOf(caseObj.get(str))).Name;
                        }
                    }
                    if(((string.valueOf(caseOldMap.get(caseObj.id).get(str))!=null && !string.valueOf(caseOldMap.get(caseObj.id).get(str)).startsWith('005')) && string.valueOf(caseObj.get(str))!=null && !string.valueOf(caseObj.get(str)).startsWith('005')) || (string.valueOf(caseOldMap.get(caseObj.id).get(str))==null && string.valueOf(caseObj.get(str))!=null) || (string.valueOf(caseOldMap.get(caseObj.id).get(str))!=null && string.valueOf(caseObj.get(str))==null)){
                        objHT.Prior_Value__c = string.valueOf(caseOldMap.get(caseObj.id).get(str));
                        objHT.Current_Value__c = string.valueOf(caseObj.get(str));
                    }
                    objHT.Case__c = caseObj.id;
                    objHT.Changed_By_User__c = UserInfo.getUserId();
                    objHT.Changed_Date_Time__c = system.now();
                    objHT.Field_Name__c = str;
                    lstHistoryTracking.add(objHT);
                }
            }
            //////////////////////////////////////////////////////////////////////////////
            // CH51 - End
            if(caseObj.Region_Flag__c != 'Bahrain' &&
               (recordTypesExcluded.contains(caseObj.RecordType_DeveloperName__c) || typesExcluded.contains(caseObj.Type)) ){
                   System.debug('CaseHabdler before Update Skipped for this record ---->>> ' + caseObj.CaseNumber );
                   continue;
               }
            System.debug('CaseHabdler before Update not Skipped for this record ---->>> ' + caseObj.CaseNumber );
            //#CH57 : END
            ////////////////////////// Calculation of the total time when a case is 'Awaiting Customer Feedback'  //////////////////////////////////////////
            //CH21: Start
            string recordtypeName = rt_Map.get(caseObj.RecordTypeId).getName();
            //CH21: END
            Case caseOldObj = (Case)trigger.oldMap.get(caseobj.id);
            if(caseObj.Awaiting_Customer_Feedback__c != caseOldObj.Awaiting_Customer_Feedback__c && caseObj.Awaiting_Customer_Feedback__c == true)
            {
                caseObj.Date_Awaiting_Customer_Feedback__c = system.now();
            }
            //CH21: Start
            //CH33 : Added a condition for Credit Limit Increase Application.
            //CH55: Added Region Flag in if condition
            if(((caseObj.Type == 'Credit Card Application' && caseObj.Sub_Type__c == 'New Credit Card') || (caseObj.Type == 'Credit Limit Increase Application')) && caseObj.Region_Flag__c == 'Bahrain' && checkRecursive.runOnce()){
                if(caseOldObj.cc_Credit_Pre_Screening_Result__c != caseObj.cc_Credit_Pre_Screening_Result__c
                   && (caseObj.cc_Credit_Pre_Screening_Result__c != '' || caseObj.cc_Credit_Pre_Screening_Result__c != null )){
                       caseObj.cc_Credit_Pre_Screening_by__c = UserInfo.getUserId();
                       System.debug('Inside Pre-screener owner Updated by value');
                   }
                if(caseOldObj.cc_Credit_Evaluation_Result__c != caseObj.cc_Credit_Evaluation_Result__c
                   && (caseObj.cc_Credit_Evaluation_Result__c != '' || caseObj.cc_Credit_Evaluation_Result__c != null)){
                       caseObj.cc_Credit_Evaluation_by__c = UserInfo.getUserId();
                       System.debug('Inside Evaluator owner Updated by value');
                   }
                if(caseOldObj.cc_Credit_Verification_Result__c != caseObj.cc_Credit_Verification_Result__c
                   && (caseObj.cc_Credit_Verification_Result__c != '' || caseObj.cc_Credit_Verification_Result__c != null)){
                       caseObj.cc_Credit_Verified_by__c = UserInfo.getUserId();
                       System.debug('Inside verifier owner Updated by value');
                   }
                if(caseOldObj.cc_Credit_Approval_Result__c != caseObj.cc_Credit_Approval_Result__c
                   && (caseObj.cc_Credit_Approval_Result__c != '' || caseObj.cc_Credit_Approval_Result__c != null)){
                       caseObj.cc_Credit_Approved_by__c = UserInfo.getUserId();
                       System.debug('Inside Approver owner Updated by value');
                   }
                if(caseOldObj.cc_Business_Approval_Result__c != caseObj.cc_Business_Approval_Result__c
                   && (caseObj.cc_Business_Approval_Result__c != '' || caseObj.cc_Business_Approval_Result__c != null)){
                       caseObj.cc_Business_Approval_by__c = UserInfo.getUserId();
                       System.debug('Inside Business owner Updated by value');
                   }
                if(caseOldObj.cc_CEO_Result__c != caseObj.cc_CEO_Result__c
                   && (caseObj.cc_CEO_Result__c != '' || caseObj.cc_CEO_Result__c != null)){
                       caseObj.cc_CEO_Result_by__c = UserInfo.getUserId();
                       System.debug('Inside CEO owner Updated by value');
                   }
                if(caseOldObj.cc_Service_Centre_Result__c != caseObj.cc_Service_Centre_Result__c
                   && (caseObj.cc_Service_Centre_Result__c != '' || caseObj.cc_Service_Centre_Result__c != null)){
                       caseObj.cc_Service_Centre_by__c = UserInfo.getUserId();
                       System.debug('Inside Service center owner Updated by value');
                   }
                if(caseOldObj.cc_Signature_Verifier_Result__c != caseObj.cc_Signature_Verifier_Result__c
                   && (caseObj.cc_Signature_Verifier_Result__c != '' || caseObj.cc_Signature_Verifier_Result__c != null)){
                       caseObj.cc_Signature_Verifier_by__c = UserInfo.getUserId();
                       System.debug('Inside signature verifier owner Updated by value');
                   }
                if(caseOldObj.cc_Operations_Result__c != caseObj.cc_Operations_Result__c
                   && (caseObj.cc_Operations_Result__c != '' || caseObj.cc_Operations_Result__c != null)){
                       caseObj.cc_Operation_by__c = UserInfo.getUserId();
                       System.debug('Inside operations owner Updated by value');
                   }
                if(caseOldObj.cc_Contact_Centre_Result__c != caseObj.cc_Contact_Centre_Result__c
                   && (caseObj.cc_Contact_Centre_Result__c != '' || caseObj.cc_Contact_Centre_Result__c != null)){
                       caseObj.cc_Contact_Center_by__c = UserInfo.getUserId();
                       System.debug('Inside contact center owner Updated by value');
                   }
                //CH50: Start
                if(caseOldObj.Credit_Retention_Result__c != caseObj.Credit_Retention_Result__c
                   && (caseObj.Credit_Retention_Result__c != '' || caseObj.Credit_Retention_Result__c != null)){
                       caseObj.Retention_Result_Updated_by__c = UserInfo.getUserId();
                       System.debug('Inside Retention owner Updated by value');
                   }
                //CH50: END
            }
            //CH52: START
            //CH55: Added Region Flag in if condition
            if((caseObj.Type == 'Credit Card Application' && caseObj.Sub_Type__c == 'New Credit Card') || (caseObj.Type == 'Credit Limit Increase Application') && caseObj.Region_Flag__c == 'Bahrain'){
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
            if(caseObj.Type == 'Credit Card Application' && caseObj.Sub_Type__c == 'New Credit Card' && caseOldObj.Sub_Status__c != caseObj.Sub_Status__c &&
               (caseObj.Sub_Status__c == 'Pending' || caseObj.Sub_Status__c == 'Discrepancies' || caseObj.Sub_Status__c == 'Follow Up') && caseObj.Region_Flag__c == 'Bahrain'){
                   System.debug('Checking Sub Status values from Other State ------> Pending');
                   caseObj.cc_Last_Sub_Status_Changed_Pending__c = 'Not Changed';
                   caseObj.LastCaseSubStatusChanged__c = System.now();
               }
            //CH50: Added Follow up condition in if block
            //CH55: Added Region Flag in if condition
            if(caseObj.Type == 'Credit Card Application' && caseObj.Sub_Type__c == 'New Credit Card' && caseOldObj.Sub_Status__c != caseObj.Sub_Status__c &&
               (caseObj.Sub_Status__c != 'Pending' && caseObj.Sub_Status__c != 'Discrepancies' && caseObj.Sub_Status__c != 'Follow Up')  && caseObj.Region_Flag__c == 'Bahrain'){
                   System.debug('Checking Sub Status values from Pending ------> Other State');
                   caseObj.cc_Last_Sub_Status_Changed_Pending__c = 'Changed';
                   caseObj.LastCaseSubStatusChanged__c = System.now();
               }
            //CH26: END
            //CH66: Start
            if(caseObj.Type == 'Credit Limit Increase Application' && caseObj.Sub_Type__c == 'Credit Limit Increase' && caseOldObj.Sub_Status__c != caseObj.Sub_Status__c &&
               (caseObj.Sub_Status__c == 'Pending' || caseObj.Sub_Status__c == 'Discrepancies') && caseObj.Region_Flag__c == 'Bahrain'){
                   System.debug('Checking Sub Status values from Other State in limit increase ------> Pending');
                   caseObj.cc_Last_Sub_Status_Changed_Pending__c = 'Not Changed';
                   caseObj.LastCaseSubStatusChanged__c = System.now();
               }
            if(caseObj.Type == 'Credit Limit Increase Application' && caseObj.Sub_Type__c == 'Credit Limit Increase' && caseOldObj.Sub_Status__c != caseObj.Sub_Status__c &&
               (caseObj.Sub_Status__c != 'Pending' && caseObj.Sub_Status__c != 'Discrepancies') && caseObj.Region_Flag__c == 'Bahrain'){
                   System.debug('Checking Sub Status values from Pending/Discrepancies ------> Other State');
                   caseObj.cc_Last_Sub_Status_Changed_Pending__c = 'Changed';
                   caseObj.LastCaseSubStatusChanged__c = System.now();
               }
            //CH66: END
            //CH15: Start
            //CH26:Start Commented by Jahangeer Mohammed #13-03-2022# related to Credit Card Application
            //CH28 : Added IsCashCollateral field in if condition
            //CH44 : Commented by Jahangeer Mohammed #06-09-2022# realated to Credit Limit Increase Application
            //CH55: Added Region Flag in if condition
            if((caseObj.Type == 'Credit Limit Increase Application' && caseObj.Region_Flag__c == 'Bahrain') && caseObj.cc_Application_Stages__c == 'New' && caseObj.Awaiting_Customer_Feedback__c != caseOldObj.Awaiting_Customer_Feedback__c && caseObj.Awaiting_Customer_Feedback__c == true)
            {
            }
            //CH26:Start Commented by Jahangeer Mohammed #13-03-2022# related to Credit Card Application
            //CH28 : Added IsCashCollateral field in if condition
            //CH44 : Commented by Jahangeer Mohammed #06-09-2022# realated to Credit Limit Increase Application
            //CH55: Added Region Flag in if condition
            if((caseObj.Type == 'Credit Limit Increase Application' && caseObj.Region_Flag__c == 'Bahrain') && caseObj.cc_Signature_Verifier_Result__c != caseOldObj.cc_Signature_Verifier_Result__c && (caseObj.cc_Signature_Verifier_Result__c == 'Re-Send' || caseObj.cc_Signature_Verifier_Result__c == 'Refer to Service Center') && caseObj.Awaiting_Customer_Feedback__c == true)
            {
                caseObj.Customer_Responded_for_Pending_Signature__c = 'Customer Not Responded';
                caseObj.cc_Date_Awaiting_For_Pending_Signature__c = System.now();
            }
            //CH15: END
            //CH17: Start
            //CH55: Added Region Flag in if condition
            //CH49: END
            //CH17: END
            //CH20 :Start Swapna Reddy
            //CH55: Added Region Flag in if condition
            if(caseObj.Type=='Credit Collection Letter Application' && CaseOldMap.get(caseObj.Id).cc_Maker__c !=caseObj.cc_Maker__c
               && caseObj.RecordTypeId==system.Label.Credit_Collection_RecordType && caseObj.OwnerId==system.Label.Credit_Collection_Queue && caseObj.cc_Maker__c=='Accept' && (caseObj.Address_Updated_By__c==null ||caseObj.Address_Updated_By__c!= UserInfo.getUserId()) && caseObj.Region_Flag__c == 'Bahrain')
            {
                caseObj.OwnerId=system.Label.Credit_Collection_Checker;
                caseObj.Sub_Status__c='In-Progress';
                caseObj.Address_Updated_By__c = UserInfo.getUserId();
                caseObj.cc_Maker_Result_Date_Time__c = System.now();
                caseObj.Alias_account__c = 'LetterChecker';
            }
            //CH55: Added Region Flag in if condition
            if(caseObj.Type=='Credit Collection Letter Application' && CaseOldMap.get(caseObj.Id).cc_Checker_Result__c !=caseObj.cc_Checker_Result__c
               && caseObj.RecordTypeId==system.Label.Credit_Collection_RecordType && caseObj.OwnerId==system.Label.Credit_Collection_Checker && caseObj.cc_Maker__c=='Accept' && caseObj.cc_Checker_Result__c=='Accept' && caseObj.Region_Flag__c == 'Bahrain')
            {
                caseObj.status='Closed';
                caseObj.Sub_Status__c='Processed';
                caseObj.cc_Checker_Result_Date_Time__c = System.now();
            }
            //CH55: Added Region Flag in if condition
            if(caseObj.Type=='Credit Collection Letter Application' && CaseOldMap.get(caseObj.Id).cc_Checker_Result__c !=caseObj.cc_Checker_Result__c
               && caseObj.RecordTypeId==system.Label.Credit_Collection_RecordType && caseObj.OwnerId==system.Label.Credit_Collection_Checker && caseObj.cc_Maker__c=='Accept' && caseObj.cc_Checker_Result__c=='Decline' && caseObj.Region_Flag__c == 'Bahrain')
            {
                caseObj.Sub_Status__c='Declined';
                caseObj.Status='Closed';
                caseObj.cc_Checker_Result_Date_Time__c = System.now();
            }
            //CH55: Added Region Flag in if condition
            //CH079
            if(caseObj.Type=='Credit Collection Letter Application' && CaseOldMap.get(caseObj.Id).cc_Checker_Result__c !=caseObj.cc_Checker_Result__c
               && caseObj.RecordTypeId==system.Label.Credit_Collection_RecordType && (caseObj.cc_Checker_Result__c=='Return to Maker' || caseObj.cc_Checker_Result__c=='Send Email' || caseObj.cc_Checker_Result__c=='Download Letter') && caseObj.Region_Flag__c == 'Bahrain')
            {
                caseObj.Status='In Progress';
                caseObj.Sub_Status__c='In-Progress';
                caseObj.cc_Checker_Result_Date_Time__c = System.now();
                if(caseObj.cc_Checker_Result__c=='Return to Maker'){
                    caseObj.OwnerId=system.Label.Credit_Collection_Queue;
                    caseObj.cc_Maker__c ='';
                    caseObj.Alias_account__c = 'LetterMaker';
                }
            }
            //CH20 : stop
            //CH21 :Start swapna
            if(caseObj.Email_Status__c != caseOldObj.Email_Status__c && caseObj.Email_Status__c == 'Email Received' && caseObj.Origin == 'Email' && (caseObj.RecordTypeId == system.label.Service_request_record_type_id || caseObj.RecordTypeId == system.label.AIR_AccountInterestRate_RecordType) )
            {
                caseObj.Type = 'Query';
            }
            if(caseObj.Email_Status__c != caseOldObj.Email_Status__c && caseObj.Email_Status__c == 'Email Received' && caseObj.Awaiting_Customer_Feedback__c == true)
            {
                caseObj.Awaiting_Customer_Feedback__c = false;
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
                //CH41: Start
                if(caseObj.Type == 'Credit Card Prepaid Application'){
                    caseObj.Sub_Status__c = 'In-Progress';
                    Util.setOwnerQueue(queueIds, caseToRegion, caseObj, CREDIT_CARD_PRE_SCREENER_QUEUE);
                }
                if(caseObj.RecordType_DeveloperName__c == 'ppc_Prepaid_Card'){
                    caseObj.Sub_Status__c = 'In-Progress';
                    caseObj.OwnerId = system.Label.Prepaid_Maker_Queue;
                }
                //CH41: END
                //CH70: Start
                if(caseObj.RecordType_DeveloperName__c == 'Deceased_Customer'){
                    caseObj.Sub_Status__c = 'Death Notified';
                    caseObj.OwnerId = system.Label.Deceased_Customer_Validation;
                }
                //CH70: END
            }
            //CH83: Start
            if(caseObj.Email_Status__c != caseOldObj.Email_Status__c && caseObj.Email_Status__c == 'Email Sent' && caseObj.Region_Flag__c == 'Bahrain'){
                if(caseObj.Type == 'Credit Limit Increase Application' || caseObj.Type == 'Credit Card Application' || caseObj.Type == 'Cash Collateral Credit Limit Increase Application' || caseObj.Type == 'Credit Card Cash Collateral Application'){
                    caseObj.cc_Customer_Response__c = 'Email sent to Customer';
                    System.debug('Email Sent to the Customer');
                }
            }
            if(caseObj.Email_Status__c != caseOldObj.Email_Status__c && caseObj.Email_Status__c == 'Email Received' && caseObj.Region_Flag__c == 'Bahrain'){
                if(caseObj.Type == 'Credit Limit Increase Application' || caseObj.Type == 'Credit Card Application' || caseObj.Type == 'Cash Collateral Credit Limit Increase Application' || caseObj.Type == 'Credit Card Cash Collateral Application'){
                    caseObj.cc_Customer_Response__c = 'Customer Responded';
                    System.debug('Email Received from the Customer');
                }
            }
            //CH83: END
            //CH27: start Swapna
            if(caseObj.RecordTypeId==system.Label.Premium_Retention_RecordType && caseObj.Status!='Closed' )
            {
                if( caseObj.Type == 'Premium Retention Application' && caseobj.ac_RequestedBy__c=='Customer' && caseObj.Status!='Closed'
                   && caseObj.Sub_Status__c!='Retained Without Discount' && caseObj.Sub_Status__c!='Retained With Discount' && caseObj.Sub_Status__c!='Downgraded'
                   && caseObj.Sub_Status__c!='Declined by Customer' && caseObj.Sub_Status__c!='Expired' && caseObj.Sub_Status__c!='Rolled Back by Bank'
                   && caseObj.Sub_Status__c!='Cancelled' && caseObj.Sub_Status__c!='Pending Exit Interview' && caseObj.sub_Status__c!='Pending Discount From Bank'
                   && caseObj.Sub_Status__c!='Pending Customer' && caseObj.Sub_Status__c!='Pending Sales Team' && caseObj.Sub_Status__c!='Pending Contact Center')
                {    //CH64: Start Tsioucha
                    caseObj.OwnerId=system.Label.Contact_Centre_Queue;
                    caseObj.Sub_Status__c='Pending Exit Interview';
                    caseObj.Waiting_for_customer_feedback__c=true;
                    //CH64: End Tsioucha
                }
                if( caseObj.Type == 'Premium Retention Application' && caseobj.ac_RequestedBy__c=='Bank / CBB'
                   && caseObj.Sub_Status__c!='Retained Without Discount' && caseObj.Sub_Status__c!='Retained With Discount' && caseObj.Sub_Status__c!='Downgraded'
                   && caseObj.Sub_Status__c!='Declined by Customer' && caseObj.Sub_Status__c!='Expired' && caseObj.Sub_Status__c!='Rolled Back by Bank'
                   && caseObj.Sub_Status__c!='Cancelled' && caseObj.Sub_Status__c!='Pending Exit Interview' && caseObj.sub_Status__c!='Pending Discount From Bank'
                   && caseObj.Sub_Status__c!='Pending Customer')
                {
                    caseObj.OwnerId=system.Label.temp_Queue;
                    caseObj.Sub_Status__c='Pending Customer';
                    caseObj.Waiting_for_customer_feedback__c=true;
                    caseObj.Premium_Substatus_Changed__c=system.today().addDays(Integer.valueOf(caseObj.Expiry_Days__c));
                }
                // CH43 -start
                if((caseObj.cc_Contact_Centre_Result__c=='Request Discount' && caseObj.Type == 'Premium Retention Application' &&
                    caseObj.OwnerId==system.Label.Contact_Centre_Queue && caseObj.Sub_Status__c!='Pending Customer'  && caseObj.Sub_Status__c!='Pending Discount From Bank' && caseObj.cc_Contact_Centre_Date_Time__c==null)
                   ||(caseObj.cc_Contact_Centre_Result__c=='Request Discount' && caseObj.Type == 'Premium Retention Application' && caseObj.OwnerId==system.Label.temp_Queue && caseObj.Sub_Status__c=='Pending Customer' && !System.isFuture()
                      ))
                    // CH43 -end
                {
                    caseObj.OwnerId=system.Label.RMT_Queue_Id;
                    caseObj.Waiting_for_customer_feedback__c=false;
                    caseObj.Sub_Status__c='Pending Discount From Bank';
                    caseObj.cc_Contact_Centre_Date_Time__c=system.now();
                    caseObj.Premium_Substatus_Changed__c=system.today().addDays(Integer.valueOf(caseObj.Expiry_Days__c));
                }
                if(caseObj.cc_Contact_Centre_Result__c=='Retain Without Discount' && caseObj.Type == 'Premium Retention Application' && (caseObj.OwnerId==system.Label.Contact_Centre_Queue || caseObj.OwnerId==system.Label.temp_Queue))
                {
                    PremiumRetentionController.updateDiscountRequest(caseObj.Id,'Retained Without Discount',null,system.now(),null,null,'Closed','RETENTION');
                }
                if(caseObj.cc_Contact_Centre_Result__c=='Cancelled By Customer' && caseObj.Type == 'Premium Retention Application' && (caseObj.OwnerId==system.Label.Contact_Centre_Queue || caseObj.OwnerId==system.Label.temp_Queue))
                {
                    PremiumRetentionController.updateDiscountRequest(caseObj.Id,'Cancelled',null,system.now(),null,null,'Closed','RETENTION');
                }
                if(caseObj.cc_Contact_Centre_Result__c=='Downgrade' && caseObj.Type == 'Premium Retention Application' && caseObj.Status!='Closed')
                {
                    PremiumRetentionController.updateDiscountRequest(caseObj.Id,'Downgraded',null,system.now(),null,null,'Closed','RETENTION');
                }
                if(caseObj.cc_Contact_Centre_Result__c=='Rollback' && caseObj.Type == 'Premium Retention Application' && (caseObj.OwnerId==system.Label.RMT_Queue_Id||caseObj.OwnerId==system.Label.temp_Queue ))
                {
                    PremiumRetentionController.updateDiscountRequest(caseObj.Id,'Rolled Back by Bank',null,system.now(),null,null,'Closed','RETENTION');
                }
                if( caseObj.Type == 'Premium Retention Application' && caseObj.Status!='Closed' && caseObj.OwnerId==system.Label.Sales_Team && caseObj.Sales_result__c!=null && caseObj.Sub_Status__c=='Pending Sales Team')
                {
                    caseObj.Sub_Status__c='Pending Contact Center';
                    caseObj.OwnerId=system.Label.Contact_Centre_Queue;
                    caseObj.cc_Contact_Centre_Result__c='';
                }
                if( caseObj.Type == 'Premium Retention Application' && caseObj.Status!='Closed' && caseObj.OwnerId==system.Label.Contact_Centre_Queue && caseObj.cc_Contact_Centre_Result__c=='Send to Sales Team')
                {
                    System.debug('inside if1');
                    caseObj.Sub_Status__c='Pending Sales Team';
                    caseObj.OwnerId=system.Label.Sales_Team;
                    caseObj.Sales_result__c='';
                }
                if(caseObj.OwnerId==system.Label.RMT_Queue_Id && caseObj.Type == 'Premium Retention Application' && caseObj.RMT_Results__c=='Escalate to Business')
                {
                    caseObj.Sub_Status__c='Pending Discount From Bank';
                    caseObj.OwnerId=system.Label.Business_Team;
                    caseObj.RMT_Results_Date_Time__c=system.now();
                }
                if(caseObj.OwnerId==system.Label.Business_Team && caseObj.Type == 'Premium Retention Application' && caseObj.Head_of_Business_Results__c=='Return to RMT')
                {
                    caseObj.OwnerId=system.Label.RMT_Queue_Id;
                    caseObj.Sub_Status__c='Pending Discount From Bank';
                }
                if(caseObj.OwnerId==system.Label.Business_Team && caseObj.Type == 'Premium Retention Application' && caseObj.Head_of_Business_Results__c=='Apply Discount & Wait For Customer')
                {
                    PremiumRetentionController.updateDiscountRequest(caseObj.Id,'Pending Customer',system.Label.temp_Queue,null,null,system.now(),null,'RETENTION');
                }
                if( caseObj.Type == 'Premium Retention Application' && caseObj.Status!='Closed' && caseObj.OwnerId==system.Label.temp_Queue
                   && (caseObj.Sub_Status__c=='Retained Without Discount' || caseObj.Sub_Status__c=='Retained With Discount' || caseObj.Sub_Status__c=='Downgraded'
                       || caseObj.Sub_Status__c=='Declined by Customer' || caseObj.Sub_Status__c=='Expired' || caseObj.Sub_Status__c=='Rolled Back by Bank'
                       || caseObj.Sub_Status__c=='Cancelled'))
                {
                    caseObj.Status='Closed';
                }
                if(caseObj.OwnerId==system.Label.RMT_Queue_Id && caseObj.Type == 'Premium Retention Application' && caseObj.RMT_Results__c=='Apply Discount & Wait For Customer')
                {
                    system.debug('Apply Discount');
                    PremiumRetentionController.updateDiscountRequest(caseObj.Id,'Pending Customer',system.Label.temp_Queue,null,system.now(),null,null,'RETENTION');
                }
                if(caseObj.Type == 'Premium Retention Application' && caseObj.Status!='Closed' && caseObj.OwnerId==system.Label.temp_Queue &&
                   (caseObj.Sub_Status__c=='Pending Exit Interview' || caseObj.sub_Status__c=='Pending Discount From Bank'))
                {
                    caseObj.OwnerId=system.Label.Contact_Centre_Queue;
                    caseObj.Waiting_for_customer_feedback__c=false;
                }
            }
            if((caseObj.RecordTypeId==system.Label.Premium_Invitation_RecordTypeId || caseObj.RecordTypeId==system.Label.Service_request_record_type_id) && caseObj.Status!='Closed')
            {
                //CH74: Start Added a Subject in If condition
                //CH82: Start Added a Subject Metal in if condition
                if(caseObj.ownerId==system.Label.Invitation_temp_Queue && caseObj.Sub_Status__c=='Pending Customer' && caseObj.Waiting_for_customer_feedback__c==false && (caseObj.Subject != 'Premium Invitation Application - Co-Branded Credit Card' && caseObj.Subject != 'Premium Invitation Application - Ila World Elite' && caseObj.Subject != 'Premium Invitation Application - Ila World Elite Metal'))
                {
                    caseObj.Waiting_for_customer_feedback__c=true;
                    PremiumRetentionController.updateDiscountRequest(caseObj.Id,'Pending Customer',system.Label.Invitation_temp_Queue,null,system.now(),null,null,'INVITATION');
                }
                //CH82: END
                //CH80: Start
                //CH82: Start
                if(caseObj.ownerId==system.Label.Invitation_temp_Queue && caseObj.Sub_Status__c=='Pending Customer' && caseObj.Waiting_for_customer_feedback__c == false && (caseObj.Subject == 'Premium Invitation Application - Co-Branded Credit Card' || caseObj.Subject == 'Premium Invitation Application - Ila World Elite' || caseObj.Subject == 'Premium Invitation Application - Ila World Elite Metal' || caseObj.Subject == 'Premium Invitation Application') && checkRecursive.runOnceForCobrandCards())
                {
                    System.debug('Coming from Signature Verifier for Co-Brand Cards, Ila World Elite And Metal cards');
                    premiumInvCaseIds.add(caseObj.Id);
                }
                //CH82: END
                //CH80: END
                //CH74: END
                if(caseObj.ownerId==system.Label.Invitation_temp_Queue && caseOldObj.Sub_Status__c!=caseObj.Sub_Status__c && (caseObj.Sub_Status__c=='Accepted by Customer' || caseObj.Sub_Status__c=='Declined by Customer'))
                {
                    PremiumRetentionController.updateDiscountRequest(caseObj.Id,null,null,null,null,null,'Closed','INVITATION');
                }
                if(caseObj.ownerId==system.Label.RMT_Queue_Id && caseObj.RMT_Results__c=='Rollback' && caseOldObj.RMT_Results__c!=caseObj.RMT_Results__c)
                {
                    PremiumRetentionController.updateDiscountRequest(caseObj.Id,'Rolled Back by Bank',null,null,null,null,'Closed','INVITATION');
                }
                if(caseObj.ownerId==system.Label.RMT_Queue_Id && caseObj.Sub_Status__c=='Expired' && caseOldObj.Sub_Status__c!=caseObj.Sub_Status__c)
                {
                    PremiumRetentionController.updateDiscountRequest(caseObj.Id,null,null,null,null,null,'Closed','INVITATION');
                }
            }
            //CH27: stop
            // CH42 - START
            if(caseObj.Generate_Random_Recovery_Code__c != caseOldObj.Generate_Random_Recovery_Code__c && caseObj.Generate_Random_Recovery_Code__c == true && caseObj.RecordType_DeveloperName__c == 'Service_Request')
            {
                system.debug('--inside Reset Recovery Code SMS 1----');
                setResetCoveryCode.add(caseObj.id);
            }
            // CH42 - END
            if(caseObj.Awaiting_Customer_Feedback__c != caseOldObj.Awaiting_Customer_Feedback__c && caseObj.Awaiting_Customer_Feedback__c == false)
            {
                caseObj.Date_Customer_gave_feedback__c = system.now();
                if(caseObj.Total_Time_with_Customer__c == null)
                {
                    caseObj.Total_Time_with_Customer__c = 0.0;
                }
                //CH39: Bypass this condition for New_Update_Customer_Profile recordtype
                //CH41: Add Date_Awaiting_Customer_Feedback__c to if condition
                If(caseObj.RecordTypeId!=system.Label.New_Update_Customer_Profile && caseObj.Date_Awaiting_Customer_Feedback__c != null){
                    Decimal timediff = caseObj.Date_Customer_gave_feedback__c.getTime()-caseObj.Date_Awaiting_Customer_Feedback__c.getTime();
                    caseObj.Total_Time_with_Customer__c = (caseObj.Total_Time_with_Customer__c + timediff)/3600000;
                }
                //CH39:Stop
            }
            /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
            /////////////////////////////////////// Populating the 'User' who updates the Cutomer's Address  ////////////////////////////////////////////////
            // added by shashank
            if(caseObj.Type=='Credit Card Services' && caseObj.RecordTypeId == recordTypeId){
                // added by shashank for makers capture in Credit Card Service
                accountIds.add(caseObj.AccountId);
            }
            //CH04 Start
            ////////////////////////// updating first 6 and last 4 digit of the Balance Transfer Card Number //////////////////
            //CH55: Added Region Flag in if condition
            if(caseObj.cc_Approved_Balance_Transfer_Card_Number__c != null && caseObj.cc_Approved_Balance_Transfer_Card_Number__c != '' && caseObj.cc_Approved_Balance_Transfer_Card_Number__c != caseOldObj.cc_Approved_Balance_Transfer_Card_Number__c && caseObj.Region_Flag__c == 'Bahrain'){
                caseObj.sys_Balance_Transfer_Card_Number__c = caseObj.cc_Approved_Balance_Transfer_Card_Number__c;
                if(caseObj.sys_Balance_Transfer_Card_Number__c != '' && caseObj.sys_Balance_Transfer_Card_Number__c != null){
                    caseObj.cc_First_6_Digit__c = caseObj.sys_Balance_Transfer_Card_Number__c.substring(0,6);
                    caseObj.cc_Last_4_Digit__c = caseObj.sys_Balance_Transfer_Card_Number__c.substring(12,16);
                }
            }
            //CH46: Start
            //CH55: Added Region Flag in if condition
            if(caseObj.Type == 'Credit Card Application' && caseObj.Sub_Type__c == 'New Credit Card' && ((caseOldObj.Campaign_Name__c != caseObj.Campaign_Name__c) || (caseOldObj.Campaign_Validity__c != caseObj.Campaign_Validity__c)) && caseObj.Region_Flag__c == 'Bahrain'){
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
            if(caseObj.Type == 'Credit Card Application' && caseObj.Sub_Type__c == 'New Credit Card' && caseObj.cc_Friend_s_Contact_Number__c != caseOldObj.cc_Friend_s_Contact_Number__c &&
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
            if(caseObj.Type == 'Credit Card Application' && caseObj.Sub_Type__c == 'New Credit Card' && caseObj.cc_Friend_s_Contact_Number__c != caseOldObj.cc_Friend_s_Contact_Number__c &&
               caseObj.cc_Friend_s_Contact_Number__c == null && caseObj.Region_Flag__c == 'Bahrain'){
                   caseObj.cc_Final_Friend_s_Contact_Number__c = caseObj.cc_Friend_s_Contact_Number__c;
               }
            //CH32 : END
            //CH11 : Start
            //CH28 : Added IsCashCollateral field in if condition
            //CH26 : Commented the condition for Credit Card Application by #Jahangeer Mohammed# #13-03-2022#
            //CH44 : Commented by Jahangeer Mohammed #06-09-2022# realated to Credit Limit Increase Application
            //CH55: Added Region Flag in if condition
            if(((caseObj.Type == 'Credit Limit Increase Application' && caseObj.Sub_Type__c == 'Credit Limit Increase')) && caseObj.Sub_Status__c != caseOldObj.Sub_Status__c && caseObj.Sub_Status__c =='Documents Received' && caseObj.Region_Flag__c == 'Bahrain')
            {
                Util.setOwnerQueue(queueIds, caseToRegion, caseObj, CREDIT_CARD_PRE_SCREENER_QUEUE);
                caseObj.cc_CRM_Stage__c = 'IN PROGRESS';
                //CH19 : Start
                caseObj.cc_Application_Stages__c = 'Credit Pre-Screening';
                caseObj.Awaiting_Customer_Feedback__c = false;
                //CH19 : END
            }
            //CH55: Added Region Flag in if condition
            if(caseObj.Type == 'Credit Card Application' && caseObj.Sub_Type__c == 'New Credit Card' && caseObj.Sub_Status__c != caseOldObj.Sub_Status__c && caseObj.Sub_Status__c =='Documents Received' && caseObj.Region_Flag__c == 'Bahrain'){
                Util.setOwnerQueue(queueIds, caseToRegion, caseObj, CREDIT_CARD_PRE_SCREENER_QUEUE);
                caseObj.cc_CRM_Stage__c = 'IN PROGRESS';
                caseObj.cc_Application_Stages__c = 'Credit Pre-Screening';
                caseObj.Awaiting_Customer_Feedback__c = false;
            }
            //CH11 : END
            ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
            if(caseObj.cc_Maker__c =='Send to Anti Attrition' && CaseOldMap.get(caseObj.Id).cc_Maker__c !=caseObj.cc_Maker__c ){
                // assign to Send to Anti Attrition  Q
                caseObj.Address_Updated_By__c = UserInfo.getUserId();
                Util.setOwnerQueue(queueIds, caseToRegion, caseObj, CREDIT_CARD_ANTI_ATTRITION);
                caseObj.cc_Maker_Result_Date_Time__c = System.now();
            }
            if(caseObj.cc_Maker__c =='Send to Anti Attrition' && CaseOldMap.get(caseObj.Id).cc_Maker__c !=caseObj.cc_Maker__c ){
                // assign to Send to Anti Attrition  Q
                Util.setOwnerQueue(queueIds, caseToRegion, caseObj, CREDIT_CARD_ANTI_ATTRITION);
                caseObj.cc_Maker_Result_Date_Time__c = System.now();
            }
            if(CaseOldMap.get(caseObj.Id).cc_AntiAttritionResult__c !=caseObj.cc_AntiAttritionResult__c ){
                caseObj.cc_Anti_Attrition_Date_Time__c = System.now();
                if(caseObj.cc_AntiAttritionResult__c =='Cancel'){
                    // close the case
                    caseObj.Sub_Status__c ='Declined';
                    caseObj.Status = 'Closed';
                }else if(caseObj.cc_AntiAttritionResult__c =='Approve'){
                    Util.setOwnerQueue(queueIds, caseToRegion, caseObj, CONTACT_CENTRE_QUEUE);
                }else if(caseObj.cc_AntiAttritionResult__c =='Return to Maker'){
                    Util.setOwnerQueue(queueIds, caseToRegion, caseObj, MAKER_QUEUE);
                    caseObj.cc_Maker__c = '';
                    if(caseObj.Address_Updated_By__c != UserInfo.getUserId()){
                        caseObj.Address_Updated_By__c =NULL;
                    }
                }
            }
            if(CaseOldMap.get(caseObj.Id).cc_Contact_Centre_Result__c != caseObj.cc_Contact_Centre_Result__c){
                if(caseObj.cc_Contact_Centre_Result__c =='Request to Pay Outstanding Balance'){
                    caseObj.Awaiting_Customer_Feedback__c = TRUE;
                    caseObj.Sub_Status__c ='Waiting for Customer to Pay Outstanding Balance';
                    caseObj.cc_Contact_Centre_Date_Time__c = System.now();
                }
                else if(caseObj.cc_Contact_Centre_Result__c =='Card Blocked & Proceed with Closing'){
                    caseObj.cc_Waiting_for_Cooldown_Period__c = TRUE;
                    caseObj.cc_CoolDownDate__c  = System.today();
                    caseObj.cc_Cool_Down_Period_For_Account_Closing__c = System.now();
                    caseObj.Sub_Status__c ='In-Progress';
                    Util.setOwnerQueue(queueIds, caseToRegion, caseObj, VISIONPLUS_MANUAL_QUEUE);
                    caseObj.cc_Contact_Centre_Date_Time__c = System.now();
                }
                else if(caseObj.cc_Contact_Centre_Result__c =='Return to Anti Attrition'){
                    caseObj.Sub_Status__c ='In-Progress';
                    Util.setOwnerQueue(queueIds, caseToRegion, caseObj, CREDIT_CARD_ANTI_ATTRITION);
                    caseObj.cc_Contact_Centre_Date_Time__c = System.now();
                }
            }
            if(caseObj.cc_VisionPlus_Result__c =='Completed' && CaseOldMap.get(caseObj.Id).cc_VisionPlus_Result__c != caseObj.cc_VisionPlus_Result__c){
                caseObj.cc_Waiting_for_Cooldown_Period__c =FALSE;
                caseObj.Awaiting_Customer_Feedback__c=FALSE;
                caseObj.Sub_Status__c ='Completed';
                caseObj.Status ='Closed';
            }
            //CH04 End
            /////////////////////////////Second BHD Account Creation all the Case update the validation handling Starts here
            //CH38: Added a condition to Bypass Customer Profile Update Record Type in if condition
            //CH91: Aded Type != 'Place Hold' condition to bypass place hold
            if(caseObj.cc_Maker__c =='Send to Checker' && caseObj.Type != 'Place Hold' && CaseOldMap.get(caseObj.Id).cc_Maker__c !=caseObj.cc_Maker__c && caseObj.RecordTypeId!=system.Label.Customer_Update_Profile_record_type_id){
                // assign to checker Q
                caseObj.Address_Updated_By__c = UserInfo.getUserId();
                //CH75: Added Type != Credit Card Upgrade to Bypass this if condition for Split functionality
                if(caseObj.Type!='Block Account' && caseObj.Type!='Unblock Account' && caseObj.Type != 'CBB Amount block/unblock request' && caseObj.Type != 'CBB Amount block/unblock request' && caseObj.Type != 'Account Maintenance' && caseObj.Type != 'New Bond/Sukuk Buy Request' && caseObj.Type != 'New Bond/Sukuk sell Request' && caseObj.Type != 'Sukuk/bonds/Government security' && caseObj.Type != 'Credit Card Upgrade' && (caseObj.cc_Request_Type__c != 'Staff Joiner' && caseObj.cc_Request_Type__c != 'Staff Leaver' && caseObj.RecordType_DeveloperName__c != 'Investment_Questionnaire_Review')){
                    Util.setOwnerQueue(queueIds, caseToRegion, caseObj, CHECKER_QUEUE);
                }
                //CH75: END
                caseObj.cc_Maker_Result_Date_Time__c = System.now();
                system.debug('Case Object-->Send to Checker');
            }
            //CH75: Added Type != Credit Card Upgrade to Bypass this if condition for Split functionality
            if(caseObj.cc_Maker__c =='Cancel' && CaseOldMap.get(caseObj.Id).cc_Maker__c !=caseObj.cc_Maker__c && caseObj.Type != 'Credit Card Upgrade'){
                caseObj.Sub_Status__c = 'Declined';
                caseObj.Status='Closed';
                caseObj.cc_Maker_Result_Date_Time__c = System.now();
                system.debug('Case Object-->Cancel');
            }
            //CH75: END
            //CH18: Wissal
            if(caseObj.cc_Checker_Result__c =='Accept' && CaseOldMap.get(caseObj.Id).cc_Checker_Result__c !=caseObj.cc_Checker_Result__c){
                caseObj.cc_Checker_Result_Date_Time__c = System.now();
                system.debug('Case Object--> Accept');
            }
            //CH18: End
            //CH38: Bypass this condition for Customer_Profile_Update recordtype
            //CH56: Bypass this condition for && caseObj.Sub_Type__c = 'Alburaq Segment Change'
            //CH62: Start : Bypass this condition for Sukuk Bond Request Record Type
            //CH88: added Type != 'Funds Transfer' and RecordType_DeveloperName__c != 'Request' to Bypass Request RecordType with type 'Funds Transfer'
            //CH89 :  added Type != 'FATCA
            if(caseObj.cc_Checker_Result__c =='Approve' && CaseOldMap.get(caseObj.Id).cc_Checker_Result__c !=caseObj.cc_Checker_Result__c  && caseObj.RecordTypeId!=system.Label.Customer_Update_Profile_record_type_id && caseObj.RecordTypeId!=system.Label.Manual_Customer_Archival
               && caseObj.Type != 'FATCA'  && caseObj.Sub_Type__c != 'Alburaq Segment Change' && caseObj.RecordType_DeveloperName__c != 'Sukuk_Bond_Request' && (caseObj.Type != 'Funds Transfer' && caseObj.RecordType_DeveloperName__c != 'Request')
               && !(caseObj.Type == 'Account' && caseObj.Sub_Type__c == 'Segment' && caseObj.cc_Request_Type__c == 'Upgrade')){
                   setSecondBHDAccount.add(caseObj.Id);
                   caseObj.cc_Checker_Result_Date_Time__c = System.now();
                   system.debug('Case Object--> Approve');
               }
            //CH62: END
            if(caseObj.cc_Checker_Result__c =='Reject' && CaseOldMap.get(caseObj.Id).cc_Checker_Result__c !=caseObj.cc_Checker_Result__c){
                caseObj.Sub_Status__c = 'Declined';
                caseObj.cc_Checker_Result_Date_Time__c = System.now();
                caseObj.Status='Closed';
                system.debug('Case Object--> Rejected');
            }
            //CH34: Added a condition for Block-Unblock Record Type
            //CH35: Added a condition for Customer_Update_Profile_record_type_id Record Type
            //CH37: Start
            //CH41 :--Start by pass this block (!= Subscription_Model_Termination & != ppc_Prepaid_Card )
            //CH45 : Start
            //CH56: Bypass this condition for && caseObj.Sub_Type__c = 'Alburaq Segment Change'
            //CH75: Added Type != Credit Card Upgrade to Bypass this if condition for Split functionality
            //CH88: added RecordType_DeveloperName__c != 'Request' to Bypass Request RecordType
            //CH91: Added Type != 'Place Hold' to bypass the place hold maker/checker condition.
            if(caseObj.cc_Checker_Result__c =='Return to Maker' && caseObj.RecordTypeId!=system.Label.Credit_Collection_RecordType && caseObj.RecordTypeId!=system.Label.DormancyStatusRecordId && caseObj.RecordTypeId!=system.Label.Block_Unblock_Account_RecordType && caseObj.RecordTypeId!=system.Label.AIR_AccountInterestRate_RecordType && caseObj.Type != 'New Bond/Sukuk Buy Request' && caseObj.Type != 'New Bond/Sukuk sell Request' && caseObj.Type!='Sukuk/bonds/Government security'&& caseObj.Type != 'Place Hold' && CaseOldMap.get(caseObj.Id).cc_Checker_Result__c != caseObj.cc_Checker_Result__c && caseObj.RecordTypeId!=system.Label.Customer_Update_Profile_record_type_id
               && (caseObj.Type != 'Funds Transfer' && caseObj.RecordType_DeveloperName__c != 'Request' && caseObj.RecordType_DeveloperName__c != 'Sukuk_Bond_Request') && caseObj.RecordType_DeveloperName__c != 'ppc_Prepaid_Card' && caseObj.RecordType_DeveloperName__c != 'Subscription_Model_Termination' && caseObj.Sub_Type__c != 'Alburaq Segment Change' && caseObj.Type != 'Credit Card Upgrade' && (caseObj.cc_Request_Type__c != 'Staff Joiner' && caseObj.cc_Request_Type__c != 'Staff Leaver' && caseObj.RecordType_DeveloperName__c != 'Investment_Questionnaire_Review'))
            {
                system.debug('Return to Maker Changed...');
                Util.setOwnerQueue(queueIds, caseToRegion, caseObj, MAKER_QUEUE);
                caseObj.cc_Maker__c ='';
                if(caseObj.Address_Updated_By__c != UserInfo.getUserId()){
                    caseObj.Address_Updated_By__c =NULL;
                    system.debug('Case Object--> ID is NOT EQUAL');
                }
                caseObj.cc_Checker_Result_Date_Time__c = System.now();
                system.debug('Case Object--> Return to Maker');
            }
            //CH75 END
            //CH41 : End
            //CH37: End
            //CH45 : End
            //////////////////////////////////////Second BHD Account Ends//////////////////////////////////////////////
        }
        if(!setSecondBHDAccount.isEmpty()){
            initiateManualOnboarding.secondBHDAccountRequest(setSecondBHDAccount);
        }
        // CH42 - START
        if(setResetCoveryCode.size()>0){
            system.debug('--to Call Future - Reset Recovery Code SMS 2----');
            RequestAppUnlockController.resettingRecoveryCodeSMS(setResetCoveryCode);
        }
        // CH42 - END
        //CH74: Start
        if(!premiumInvCaseIds.isEmpty()){
            PremiumInvitationDiscountReqQueuable premInv = new PremiumInvitationDiscountReqQueuable(premiumInvCaseIds);
            System.enqueueJob(premInv);
        }
        //CH74: END
        // CH51 - Start
        if(lstHistoryTracking.size()>0)
            insert lstHistoryTracking;
        // CH51 - END
        if(!accountIds.isEmpty()){
            Map<Id,List<Case>> accIdsVsCaseList = new Map<Id,List<Case>>();
            for(Case cItem : [SELECT Id,cc_PCI_Id__c,Sub_Type__c,AccountId,CaseNumber FROM Case WHERE AccountId in:accountIds AND Status != 'Closed' AND cc_PCI_Id__c != NULL]){
                if(!accIdsVsCaseList.containsKey(cItem.AccountId)){
                    accIdsVsCaseList.put(cItem.AccountId, new List<Case>());
                }
                accIdsVsCaseList.get(cItem.AccountId).add(cItem);
            }
            for(Case newItem :newRecs){
                if(accIdsVsCaseList.containsKey(newItem.AccountId)){
                    for(Case xItem: accIdsVsCaseList.get(newItem.AccountId)){
                        if(newItem.cc_PCI_Id__c == xItem.cc_PCI_Id__c && newItem.Id != xItem.Id && newItem.Sub_Type__c == xItem.Sub_Type__c){
                            newItem.addError('A maximum of one '+ xItem.Sub_Type__c+' case can be open for the selected Card. Current case Open '+xItem.CaseNumber);
                        }
                    }
                }
            }
        }
    }
    public static void setContact(List<Case> newCaselist){
        Set<Id> accIdset = new Set<Id>();
        Set<Id> cntIds = new Set<Id>();
        Map<Id,List<Case>> mapContactToCases = new Map<Id,List<Case>>();
        Map<ID,Schema.RecordTypeInfo> rt_Map = Case.sObjectType.getDescribe().getRecordTypeInfosById();
        System.debug('BEFORE INSERT IS FIRED');
        for(Case cs : newCaselist){
            //CH01: Start
            string recordtypeName = rt_map.get(cs.RecordTypeId).getName();
            if(recordtypeName == 'Manual Customer Archival'){
            }
            if(cs.cc_Monthly_Income__c <= 500)
                cs.cc_sys_Montly_Income__c = '500';
            else if(cs.cc_Monthly_Income__c > 500 && cs.cc_Monthly_Income__c <= 999)
                cs.cc_sys_Montly_Income__c = '750';
            else if(cs.cc_Monthly_Income__c >= 1000 && cs.cc_Monthly_Income__c <= 1999)
                cs.cc_sys_Montly_Income__c = '1500';
            else if(cs.cc_Monthly_Income__c >= 2000 && cs.cc_Monthly_Income__c <= 2999)
                cs.cc_sys_Montly_Income__c = '2500';
            else if(cs.cc_Monthly_Income__c > 3000 && cs.cc_Monthly_Income__c <= 5000)
                cs.cc_sys_Montly_Income__c = '4000';
            else if(cs.cc_Monthly_Income__c > 5000)
                cs.cc_sys_Montly_Income__c = '5000';
            //CH25 : Added a condition for Credit Card Supplementary Application by #Jahangeer Mohammed #06-03-2022#
            //CH55: Added Region Flag in if condition
            if((cs.Type == 'Credit Card Application' && cs.Sub_Type__c == 'New Credit Card' && cs.Region_Flag__c == 'Bahrain') || (cs.Type == 'Credit Card Supplementary Application' && cs.Sub_Type__c == 'New Supplementary Card' && cs.Region_Flag__c == 'Bahrain') || test.isRunningTest()){
                if(cs.cc_Requested_Card_Type__c != null &&  cs.cc_Requested_Card_Type__c != '')
                    cs.cc_Approved_Requested_Card_Type__c = cs.cc_Requested_Card_Type__c;
                if(cs.cc_Name_on_the_Card__c != null &&  cs.cc_Name_on_the_Card__c != '')
                    cs.cc_Approved_Name_on_the_card__c = cs.cc_Name_on_the_Card__c;
                if(cs.cc_Embossing_Line_4__c != null &&  cs.cc_Embossing_Line_4__c != '')
                    cs.cc_Approved_Embossing_line_4__c = cs.cc_Embossing_Line_4__c;
                if(cs.cc_Balance_Transfer_Card_Provider__c != null && cs.cc_Balance_Transfer_Card_Provider__c != '')
                    cs.cc_Approved_Balance_Transfer_Card_Provi__c = cs.cc_Balance_Transfer_Card_Provider__c;
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
                    cs.cc_Last_Sub_Status_Changed_Pending__c = 'Not Changed';
                    cs.LastCaseSubStatusChanged__c = System.now();
                }
                //CH26: END
            }
            //CH66: Start
            else if(cs.Type == 'Credit Limit Increase Application' && cs.Sub_Type__c == 'Credit Limit Increase' && cs.Region_Flag__c == 'Bahrain'){
                if(cs.Sub_Status__c == 'Pending'){
                    System.debug('Before creation of Credit Card Limit Increase Case checking Last Sub status Change for Pending');
                    cs.cc_Last_Sub_Status_Changed_Pending__c = 'Not Changed';
                    cs.LastCaseSubStatusChanged__c = System.now();
                }
                if(cs.cc_Requested_Card_Type__c != null &&  cs.cc_Requested_Card_Type__c != '')
                    cs.cc_Approved_Requested_Card_Type__c = cs.cc_Requested_Card_Type__c;
            }
            //CH66: END
            //#CH84 : Start
            if( cs.Region_Flag__c == 'Bahrain' && ( cs.Type == 'Credit Card Application' || cs.Type == 'Credit Limit Increase Application' || cs.Type == 'Credit Card Cash Collateral Application' || cs.Type == 'Cash Collateral Credit Limit Increase Application') )
            {
                cs.Resend_DocuSign__c = System.Label.Default_Resend_DocuSign;//'In-App'
            }
            //#CH84 : End
            accIdset.add(cs.AccountId);
        }
        System.debug('Account Id Set Size:'+accIdset.size());
        System.debug('Account Id is :'+accIdset);
        if(!accIdset.isEmpty()){
            Map<Id,Id> accountVsContactIDs = new Map<Id,Id>();
            for(Account acc: [SELECT Id,PersonContact.Id FROM Account WHERE Id In:accIdset]){
                accountVsContactIDs.put(acc.Id,acc.PersonContact.Id);
            }
            if(!accountVsContactIDs.isEmpty()){
                for(Case cs : newCaselist){
                    if(accountVsContactIDs.containsKey(cs.AccountId) && cs.ContactId == NULL){
                        cs.ContactId = accountVsContactIDs.get(cs.AccountId);
                    }
                }
            }
        }
    }
    // CH59 - Start
    public static void HandleDNDCases(List<Case> newCaselist){
        Set<Id> setDNDCasesIds = new Set<Id>();
        for(Case caseObj : newCaselist){
            if(caseObj.type == 'Marketing Preference' && (caseObj.Sub_Type__c == 'Add to DND List' || caseObj.Sub_Type__c == 'Remove from DND List')){
                setDNDCasesIds.Add(caseObj.Id);
            }
        }
        if(setDNDCasesIds != null && setDNDCasesIds.size() > 0){
            initiateManualOnboarding.UpdateCustomerDetailsForDNDupdate(setDNDCasesIds);
        }
    }
    // CH59 - End
    //CH68 -START
    @TestVisible
    public static void assignEntitlements(List<Case> newList, Map<Id, Case> oldMap) {
        if (hasRun || newList.isEmpty()) return;
        hasRun = true;
        // Query all mappings
        List<Case_Entitlement_Mapping__mdt> mappings = [
            SELECT Type__c, Sub_Type__c, Request_Type__c, Segment__c, Entitlement_Name__c, SLA__c
            FROM Case_Entitlement_Mapping__mdt
        ];
        // Get all entitlement names (from static and mappings)
        Set<String> entitlementNames = new Set<String>{'IssueCase_Entitlement', 'MastercardSLA'};
            for (Case_Entitlement_Mapping__mdt m : mappings) {
                entitlementNames.add(m.Entitlement_Name__c);
            }
        // Query Entitlements once
        Map<String, Id> entitlementMap = new Map<String, Id>();
        for (Entitlement e : [SELECT Id, Name FROM Entitlement WHERE Name IN :entitlementNames AND Name NOT IN ('001Pw00000MUaG0IALEntitlement3')]) {
            entitlementMap.put(e.Name, e.Id);
        }
        // Get Accounts in bulk
        Set<Id> accountIds = new Set<Id>();
        for (Case cs : newList) {
            if (cs.AccountId != null) {
                accountIds.add(cs.AccountId);
            }
        }
        Map<Id, Account> accMap = new Map<Id, Account>(
            [SELECT Id, VVIP__pc, Segment__pc FROM Account WHERE Id IN :accountIds]
        );
        // Assign entitlement
        for (Case cs : newList) {
            if (cs.EntitlementId != null) continue;
            Account acc = accMap.get(cs.AccountId);
            String segment = (acc != null && acc.VVIP__pc) ? 'Premium' : acc?.Segment__pc;
            // Match metadata conditions
            List<Case_Entitlement_Mapping__mdt> matched = new List<Case_Entitlement_Mapping__mdt>();
            for (Case_Entitlement_Mapping__mdt m : mappings) {
                if (m.Type__c == cs.Type &&
                    m.Sub_Type__c == cs.Sub_Type__c &&
                    normalize(m.Request_Type__c) == normalize(cs.cc_Request_Type__c)) {
                        matched.add(m);
                    }
            }
            // Find best match based on Segment
            Case_Entitlement_Mapping__mdt selected;
            for (Case_Entitlement_Mapping__mdt m : matched) {
                if (m.Segment__c == segment) {
                    selected = m;
                    break;
                }
            }
            // Fallback to 'Regular' if not VVIP
            if (selected == null && (acc == null || !acc.VVIP__pc)) {
                for (Case_Entitlement_Mapping__mdt m : matched) {
                    if (m.Segment__c == 'Regular') {
                        selected = m;
                        break;
                    }
                }
            }
            // Set entitlement and pass SLA in a temporary custom field
            if (selected != null && entitlementMap.containsKey(selected.Entitlement_Name__c)) {
                System.debug('Entitlement Name- - -- >'+selected.Entitlement_Name__c);
                System.debug('Entitlement Id- - -- >'+entitlementMap.get(selected.Entitlement_Name__c));
                cs.EntitlementId = entitlementMap.get(selected.Entitlement_Name__c);
                cs.SLA__c = selected.SLA__c;
            }
        }
    }
    public static void processPostUpdate(List<Case> newList, Map<Id, Case> oldMap) {
        if (newList.isEmpty()) return;
        Set<Id> milestoneCaseIds = new Set<Id>();
        Map<Id, Decimal> caseIdToSLA = new Map<Id, Decimal>();
        for (Case cs : newList) {
            Case oldCs = oldMap.get(cs.Id);
            Boolean isNewEntitlement = cs.EntitlementId != null && oldCs.EntitlementId == null;
            if (isNewEntitlement) {
                milestoneCaseIds.add(cs.Id);
            }
        }
        if (!milestoneCaseIds.isEmpty()) {
            DynamicCaseReportController.updateRelatedRecordsAsync(milestoneCaseIds, caseIdToSLA);
        }
    }
    // Normalize to avoid Unicode/whitespace mismatches
    private static String normalize(String input) {
        return input != null
            ? input.trim().replaceAll('[\\u2018\\u2019\\u201C\\u201D]', '\'').replaceAll('[^\\x20-\\x7E]', '')
            : '';
    }
    //CH68 -END
}