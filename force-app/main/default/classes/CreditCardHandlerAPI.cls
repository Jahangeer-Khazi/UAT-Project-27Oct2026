/*      Organization : ABC Bank
*      Description  : Helper methods for the Credit Card Request API calls made by
*                     initiateManualOnboarding.CCCaseCreation and CCCaseUpdate (request creation, card catalogue lookup,
*                     request body building, sending, failure logging and success handling).
*      Created Date : 21-11-2026
*      Change History:
*             #CH01# #Jahangeer Mohammed# 21-11-2026# Moved the duplicated code of initiateManualOnboarding.CCCaseCreation
*                    into helper methods (logic and API request bodies unchanged).
*             #CH02# #Jahangeer Mohammed# 22-11-2026# Added helper methods for the duplicated code of initiateManualOnboarding.CCCaseUpdate
*                    (send and log, card catalogue, status / campaign / approved bodies, signing details, stages, cross-selling).
*/
public inherited sharing class CreditCardHandlerAPI {
    private static ApiConnection con = new ApiConnection();

    private static final String TYPE_CREDIT_CARD = 'Credit Card Application';
    private static final String SUB_TYPE_NEW_CREDIT_CARD = 'New Credit Card';
    private static final String TYPE_LIMIT_INCREASE = 'Credit Limit Increase Application';
    private static final String SUB_TYPE_LIMIT_INCREASE = 'Credit Limit Increase';
    private static final String TYPE_SUPPLEMENTARY = 'Credit Card Supplementary Application';
    private static final String SUB_TYPE_SUPPLEMENTARY = 'New Supplementary Card';
    private static final String GULF_AIR_COBRAND_CARD = 'ILA_GULF_AIR_COBRAND_01';

    public static final String STATUS_IN_PROGRESS = 'IN_PROGRESS';
    public static final String STATUS_PENDING = 'PENDING';

    public static final String LOG_ENDPOINT_GET_CREDIT_CARDS = 'callout:NeoBank_Endpoint/api/v1/credit-cards?language=en&unit=neo';
    public static final String LOG_ENDPOINT_CREDIT_CARD_REQUEST = 'callout:NeoBank_Endpoint/api/v1/credit-cards/request?language=en&unit=neo';

    public static final String ACTION_CREDIT_CARD_APPLICATION = 'Credit Card Application';
    public static final String ACTION_SUPPLEMENTARY_APPLICATION = 'Credit Card Supplementary Application';

    /********************************************* CASE TYPE CHECKS *********************************************/
    public static Boolean isNewCreditCard(Case objCase){
        return objCase.Type == TYPE_CREDIT_CARD && objCase.Sub_Type__c == SUB_TYPE_NEW_CREDIT_CARD;
    }

    public static Boolean isLimitIncrease(Case objCase){
        return objCase.Type == TYPE_LIMIT_INCREASE && objCase.Sub_Type__c == SUB_TYPE_LIMIT_INCREASE;
    }

    public static Boolean isSupplementaryCard(Case objCase){
        return objCase.Type == TYPE_SUPPLEMENTARY && objCase.Sub_Type__c == SUB_TYPE_SUPPLEMENTARY;
    }

    /********************************************* REQUEST CREATION *********************************************/
    //CH19 / CH22: request on the Credit Card API with the x-canary header when the customer has one
    public static HttpRequest createCardApiRequest(String method, String path, String regionName, Case objCase){
        HttpRequest request = con.createRequest(method, path, regionName);
        if(objCase.Account.x_canary__pc != null){
            request.setHeader('x-canary', objCase.Account.x_canary__pc);//CH22
        }
        return request;
    }

    /********************************************* CARD CATALOGUE (GET) *********************************************/
    /**
    * @description Calls GET credit-cards and returns the cardProductConfigurationId of the requested card type.
    *              Returns currentConfigurationId when the call fails or the card type is not found (existing behaviour).
    */
    public static Integer getCardProductConfigurationId(Case objCase, String regionName, Integer currentConfigurationId, List<System_Action__c> lstSA){
        Integer cardProductConfigurationId = currentConfigurationId;
        HttpRequest request = createCardApiRequest('GET', System.Label.CC_EndPointGetCreditCards, regionName, objCase);
        System.debug('Person Email :'+objCase.Account.PersonEmail);
        System.debug('Customer ID :'+objCase.Account.CIF__pc);

        request.setHeader('userId', objCase.Account.PersonEmail);
        request.setHeader('customerId', objCase.Account.CIF__pc);
        request.setTimeOut(120000);
        system.debug('---> Request --> '+request.getBody());
        HttpResponse response = new Http().send(request);
        system.debug('---> Responce New --> '+response.getBody());

        if (response.getStatusCode() != 200)
        {
            //CH29: Added isAPIFailed parameter in the method
            replaceWithFailureLog(lstSA, request, response, objCase, LOG_ENDPOINT_GET_CREDIT_CARDS, 'GET');
        }
        else
        {
            System.debug(response.getBody());
            Map<String, Object> m = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
            System.debug('---> MAP m --> '+m);  // meta, data
            System.debug('---> MAP m VALUES --> '+m.Values());
            Map<String, Object> m1 = (Map<String, Object>)m.get('data');
            System.debug('---> MAP m1 --> '+m1);  // currentCards,pendingCards,cardOptions
            List<Object> m2 = (List<Object>)m1.get('cardOptions');
            System.debug('---> LIST m2 --> '+m2);

            for(Object obj : m2)
            {
                Map<String, Object> map1 = (Map<String, Object>)obj;
                system.debug('---->> OBJ Iterations --> '+obj);
                if(map1.get('productMappingCode')== objCase.cc_Requested_Card_Type__c)
                {
                    cardProductConfigurationId = (Integer)map1.get('cardProductConfigurationId');
                    system.debug('---> FINALL cardProductConfigurationId --> '+cardProductConfigurationId);
                }
            }
        }
        return cardProductConfigurationId;
    }

    /**
    * @description CCCaseUpdate: calls GET credit-cards (including other products) and logs the call when it fails.
    */
    public static HttpResponse sendApprovedCardCatalogueRequest(Case objCase, String regionName, List<System_Action__c> lstSA){
        //CH14 / CH19
        HttpRequest request1 = con.createRequest('GET',System.Label.CC_EndPointGetCreditCardsIncludingOtherProducts, regionName);
        request1.setHeader('userId', objCase.Account.PersonEmail);
        request1.setHeader('customerId', objCase.Account.CIF__pc);

        system.debug('---> request1 --> '+request1.getBody());
        HttpResponse response1 = new Http().send(request1);
        system.debug('---> Response New 111 --> '+response1.getBody());

        if (response1.getStatusCode() != 200)
        {
            //CH29: Added isAPIFailed parameter in the method
            replaceWithFailureLog(lstSA, request1, response1, objCase, LOG_ENDPOINT_GET_CREDIT_CARDS, 'GET');
        }
        return response1;
    }

    /**
    * @description CCCaseUpdate: returns the cardProductConfigurationId of the approved card type from a successful
    *              GET credit-cards response. Returns currentConfigurationId when it is not found, or in tests (existing behaviour).
    */
    public static Integer findApprovedCardProductConfigurationId(Case objCase, HttpResponse response1, Integer currentConfigurationId){
        Integer approvedCardProductConfigurationId = currentConfigurationId;
        if(!test.isRunningTest()){
            System.debug(response1.getBody());
            Map<String, Object> m = (Map<String, Object>)JSON.deserializeUntyped(response1.getBody());
            System.debug('---> MAP m 222 --> '+m);  // meta, data
            System.debug('---> MAP m VALUES 222 --> '+m.Values());
            Map<String, Object> m1 = (Map<String, Object>)m.get('data');
            System.debug('---> MAP m1 222--> '+m1);  // currentCards,pendingCards,cardOptions
            List<Object> m2 = new List<Object>();
            if(m1.containsKey('cardOptions') != null)
                m2=(List<Object>)m1.get('cardOptions');
            else if(m1.containsKey('pendingCards') != null)
                m2=(List<Object>)m1.get('pendingCards');
            System.debug('---> LIST m2 222--> '+m2);

            for(Object obj : m2)
            {
                Map<String, Object> map1 = (Map<String, Object>)obj;
                system.debug('---->> OBJ Iterations 222--> '+obj);
                if(map1.get('productMappingCode')== objCase.cc_Approved_Requested_Card_Type__c)
                {
                    approvedCardProductConfigurationId = (Integer)map1.get('cardProductConfigurationId');
                    system.debug('---> FINALL cardProductConfigurationId 222--> '+approvedCardProductConfigurationId);
                }
            }
        }
        return approvedCardProductConfigurationId;
    }

    /********************************************* REQUEST BODIES (PUT) *********************************************/
    /**
    * @description Builds the PUT credit-cards/request body for IN_PROGRESS or PENDING. Returns '' when no case type matches.
    */
    public static String buildCardRequestBody(Case objCase, Integer cardProductConfigurationId, String status){
        String body = '';
        //CH28 / CH30
        if(isNewCreditCard(objCase)){
            if(objCase.cc_Requested_Card_Type__c != GULF_AIR_COBRAND_CARD){
                body = buildNewCreditCardBody(objCase, cardProductConfigurationId, status);
            }
            else{
                body = buildCoBrandCardBody(objCase, cardProductConfigurationId, status);
            }
        }
        //CH21
        else if(isLimitIncrease(objCase)){
            body = buildLimitIncreaseBody(objCase, status);
        }
        else if(isSupplementaryCard(objCase)){
            if(status == STATUS_PENDING){
                body = buildSupplementaryPendingBody(objCase);
            }
            else{
                body = buildSupplementaryCardBody(objCase, cardProductConfigurationId, status);
            }
        }
        return body;
    }

    //CH28: New Credit Card (not Gulf Air co-brand)
    private static String buildNewCreditCardBody(Case objCase, Integer cardProductConfigurationId, String status){
        String body = '{"cardProductConfigurationId": "'+cardProductConfigurationId +
            '","crmCaseId": "'+objCase.Id;
        if(objCase.cc_Name_on_the_Card__c !=null){
            body += '","embossName": "'+objCase.cc_Name_on_the_Card__c +
                '","status":"'+status+'"}';
        }
        else{
            body += '","embossName": "'+null +
                ',"status":"'+status+'"}';
        }
        return body;
    }

    //CH30 / CH35: Gulf Air co-brand card with membership and spouse details
    private static String buildCoBrandCardBody(Case objCase, Integer cardProductConfigurationId, String status){
        String body = '{"cardProductConfigurationId": "'+cardProductConfigurationId +
            '","crmCaseId": "'+objCase.Id +
            '","embossName": "'+objCase.cc_Name_on_the_Card__c +
            '","hasMembership": "'+objCase.Has_Co_Brand_Membership_Number__c;
        if(objCase.cc_Approved_Embossing_line_4__c != null){
            body += '","membershipNumber": "'+objCase.cc_Approved_Embossing_line_4__c +
                '","issuedForSpouse": "'+objCase.Issuing_card_for_a_spouse__c +
                '","spouseCIF": "'+objCase.Spouse_CIF__c +
                '","status":"'+status+'"}';
        }
        else{
            body += '","issuedForSpouse": "'+objCase.Issuing_card_for_a_spouse__c +
                '","spouseCIF": "'+objCase.Spouse_CIF__c +
                '","membershipNumber": null,"status":"'+status+'"}';
        }
        return body;
    }

    //CH21: Credit Limit Increase - Manual (with PCI number) or API, permanent or temporary
    private static String buildLimitIncreaseBody(Case objCase, String status){
        Boolean isManual = objCase.cc_CC_Application_Source__c == 'Manual';
        Boolean isApi = objCase.cc_CC_Application_Source__c == 'API';
        Boolean isPermanent = objCase.cc_Request_Type__c == 'permanent';
        Boolean isTemporary = objCase.cc_Request_Type__c == 'temporary';
        if(!(isManual || isApi) || !(isPermanent || isTemporary)){
            return '';
        }
        String body = isManual ? '{"pciNumber": "'+objCase.cc_Credit_Card_PCI_Number__c + '","crmCaseId": "'+objCase.Id
                               : '{"crmCaseId": "'+objCase.Id;
        body += '","embossName": "'+objCase.cc_Name_on_the_Card__c +
            '","targetType": "LIMIT_INCREASE","status":"'+status+'"';
        if(isTemporary){
            body += ',"requestType":"temporary","duration":"'+objCase.cc_Temporary_Limit_Increase_Duration__c+'"';
        }
        return body + '}';
    }

    //Supplementary Card - IN_PROGRESS
    private static String buildSupplementaryCardBody(Case objCase, Integer cardProductConfigurationId, String status){
        return '{"cardProductConfigurationId": "'+cardProductConfigurationId +
            '","crmCaseId": "'+objCase.Id +
            '","embossName": "'+objCase.cc_Name_on_the_Card__c +
            '","targetType": "SUPPLEMENTARY_CARD","status":"'+status+'"}';
    }

    //CH06: Supplementary Card - PENDING (supplementary card holder details, Bahrain notification fields)
    private static String buildSupplementaryPendingBody(Case objCase){
        String body = '{"crmCaseId":"' + objCase.Id +
            '","cardProductConfigurationId":' + SM001_ApiCalls.stringApiFormat(objCase.PrimaryCardProductConfigurationId__c) +
            ',"pciNumber":' + SM001_ApiCalls.stringApiFormat(objCase.PrimaryCard__c) +
            ',"embossName":' + SM001_ApiCalls.stringApiFormat(objCase.cc_Name_on_the_Card__c) +
            ',"supplementaryCard":{' +
            '"mobile":"' + objCase.sc_Card_Holder_Mobile_No__c +
            '","email":"' + objCase.sc_Card_Holder_Email_Address__c +
            '","relationship":"' + objCase.sc_Relationship__c +
            '","enableSpendingLimit":false';
        // Add ONLY for Bahrain
        if (objCase.Region_Flag__c == 'Bahrain') {
            body +=
                ',"sendOTPNotificationsTo":' + SM001_ApiCalls.stringApiFormat(objCase.Send_OTP_Notifications_To__c) +
                ',"sendTransactionsNotificationsTo":' + SM001_ApiCalls.stringApiFormat(objCase.Send_Transaction_Notifications_To__c) +
                ',"cardHolderMobileNumber":' + SM001_ApiCalls.stringApiFormat(objCase.sc_Card_Holder_Mobile_No__c) +
                ',"cardHolderEmail":' + SM001_ApiCalls.stringApiFormat(objCase.sc_Card_Holder_Email_Address__c);
        }
        body += '},' +
            '"creditLimit": 0' +
            ',"targetType": "SUPPLEMENTARY_CARD","status":"PENDING"}';
        return body;
    }

    /**
    * @description CCCaseUpdate: status-only request body.
    *              {"crmCaseId": "<Id>"[,"cardProductConfigurationId": "<config>"][,"targetType": "<targetType>"],"status":"<status>"[,"requestType":"temporary","duration":"<duration>"]}
    */
    public static String buildStatusBody(Case objCase, String targetType, String status, Boolean includeCardConfig, Boolean isTemporary){
        String body = '{"crmCaseId": "'+objCase.Id;
        if(includeCardConfig){
            body += '","cardProductConfigurationId": "'+objCase.PrimaryCardProductConfigurationId__c;
        }
        if(targetType != null){
            body += '","targetType": "'+targetType;
        }
        body += '","status":"'+status+'"';
        if(isTemporary){
            body += ',"requestType":"temporary","duration":"'+objCase.cc_Temporary_Limit_Increase_Duration__c+'"';
        }
        return body + '}';
    }

    /**
    * @description CH21: CCCaseUpdate - status body for a permanent or temporary Credit Limit Increase.
    *              Returns currentBody unchanged for any other case (same as the two separate permanent / temporary if blocks).
    */
    public static String buildLimitIncreaseStatusBody(Case objCase, String status, Boolean includeCardConfig, String currentBody){
        if(isLimitIncrease(objCase) && objCase.cc_Request_Type__c=='permanent'){
            return buildStatusBody(objCase, 'LIMIT_INCREASE', status, includeCardConfig, false);
        }
        if(isLimitIncrease(objCase) && objCase.cc_Request_Type__c=='temporary'){
            return buildStatusBody(objCase, 'LIMIT_INCREASE', status, includeCardConfig, true);
        }
        return currentBody;
    }

    /**
    * @description CH15 / CH26: CCCaseUpdate - body with campaignId (quoted when set, null when blank).
    */
    public static String buildCampaignBody(Case objCase, String campaignId, String status, Boolean includeCardConfig){
        String body = '{"crmCaseId": "'+objCase.Id;
        if(includeCardConfig){
            body += '","cardProductConfigurationId": "'+objCase.PrimaryCardProductConfigurationId__c;
        }
        if(campaignId != null){
            body += '","campaignId": "'+campaignId +
                '","status":"'+status+'"}';
        }
        else{
            body += '","campaignId": null,"status":"'+status+'"}';
        }
        return body;
    }

    /**
    * @description CH15 / CH26: CCCaseUpdate - APPROVED body sent when the Signature Verifier accepts (with or without campaign).
    */
    public static String buildApprovedCardBody(Case objCase, Integer approvedCardProductConfigurationId){
        String body = '{"cardProductConfigurationId": "'+approvedCardProductConfigurationId +
            '","crmCaseId": "'+objCase.Id +
            '","creditLimit": "'+objCase.cc_Approved_Credit_Limit__c +
            '","balanceTransferAmount": "'+objCase.cc_Approved_Balance_Transfer_Amount__c +
            '","embossName": "'+objCase.cc_Approved_Name_on_the_card__c;
        if(objCase.Approved_Campaign_Name__c != null){
            body += '","campaignId": "'+objCase.Approved_Campaign_Name__c +
                '","status":"APPROVED"}';
        }
        else{
            body += '","campaignId": null,"status":"APPROVED"}';
        }
        return body;
    }

    /**
    * @description CH28 / CH35: CCCaseUpdate - APPROVED body for co-brand / balance transfer cards with membership and spouse details.
    *              Returns currentBody when the membership number does not match either condition (existing behaviour).
    */
    public static String buildApprovedCoBrandBody(Case objCase, Integer approvedCardProductConfigurationId, String currentBody){
        if(objCase.cc_Approved_Embossing_line_4__c == '' || objCase.cc_Approved_Embossing_line_4__c == null){
            return '{"cardProductConfigurationId": "'+approvedCardProductConfigurationId +
                '","crmCaseId": "'+objCase.Id +
                '","creditLimit": "'+objCase.cc_Approved_Credit_Limit__c +
                '","balanceTransferAmount": "'+objCase.cc_Approved_Balance_Transfer_Amount__c +
                '","embossName": "'+objCase.cc_Approved_Name_on_the_card__c +
                '","hasMembership": "'+objCase.Has_Co_Brand_Membership_Number__c +
                '","issuedForSpouse": "'+objCase.Issuing_card_for_a_spouse__c +
                '","spouseCIF": "'+objCase.Spouse_CIF__c +
                '","campaignId": null,"membershipNumber": null,"status":"APPROVED"}';
        }
        else if(objCase.cc_Approved_Embossing_line_4__c != null){
            return '{"cardProductConfigurationId": "'+approvedCardProductConfigurationId +
                '","crmCaseId": "'+objCase.Id +
                '","creditLimit": "'+objCase.cc_Approved_Credit_Limit__c +
                '","hasMembership": "'+objCase.Has_Co_Brand_Membership_Number__c +
                '","membershipNumber": "'+objCase.cc_Approved_Embossing_line_4__c +
                '","balanceTransferAmount": "'+objCase.cc_Approved_Balance_Transfer_Amount__c +
                '","embossName": "'+objCase.cc_Approved_Name_on_the_card__c +
                '","issuedForSpouse": "'+objCase.Issuing_card_for_a_spouse__c +
                '","spouseCIF": "'+objCase.Spouse_CIF__c +
                '","campaignId": null,"status":"APPROVED"}';
        }
        return currentBody;
    }

    //CCCaseUpdate: API status for the 'Referred by ...' sub-statuses (null for any other sub-status)
    private static final Map<String, String> REFERRED_STATUS_BY_SUB_STATUS = new Map<String, String>{
        'Referred by Evaluator' => 'REFERRED_BY_EVALUATOR',
        'Referred by Approver' => 'REFERRED_BY_APPROVER',
        'Referred  by Pre-Screener' => 'REFERRED_BY_PRESCREENER',
        'Referred by Verifier' => 'REFERRED_BY_VERIFIER'
    };
    public static String getReferredStatus(String subStatus){
        return REFERRED_STATUS_BY_SUB_STATUS.get(subStatus);
    }

    //CH39: CCCaseUpdate - DocuSign signing details: In-App (envelope and contact) or Email
    public static void addSigningInfo(Map<String, String> bodyObject, Case objCase, Boolean isInApp){
        if(isInApp){
            bodyObject.put('signingType','IN_APP');
            bodyObject.put('envelopeId',objCase.bs_Instrument_ID__c);
            bodyObject.put('crmContactId',objCase.ContactId);
        }
        else{
            bodyObject.put('signingType','EMAIL');
            bodyObject.put('envelopeId',null);
            bodyObject.put('crmContactId',null);
        }
    }

    /********************************************* SEND, LOG, RESPONSE *********************************************/
    public static HttpResponse sendCardRequest(HttpRequest request, Case objCase, String body){
        system.debug('---> BODY --> '+body);
        request.setBody(body);
        request.setHeader('userId', objCase.Account.PersonEmail);
        request.setHeader('customerId', objCase.Account.CIF__pc);

        system.debug('---> Request --> '+request.getBody());
        HttpResponse response = new Http().send(request);
        system.debug('---> Responce New --> '+response.getBody());
        return response;
    }

    /**
    * @description Logs a failed call. Keeps the existing behaviour of CCCaseCreation: lstSA is replaced,
    *              so only the last failed call of the transaction is kept.
    */
    public static void replaceWithFailureLog(List<System_Action__c> lstSA, HttpRequest request, HttpResponse response, Case objCase, String logEndpoint, String method){
        replaceWithFailureLog(lstSA, request, response, objCase, logEndpoint, method, ACTION_CREDIT_CARD_APPLICATION);
    }

    public static void replaceWithFailureLog(List<System_Action__c> lstSA, HttpRequest request, HttpResponse response, Case objCase, String logEndpoint, String method, String action){
        System.debug('The status code returned was not expected: ' + response.getStatusCode() + ' ' + response.getStatus());
        //CH29: Added isAPIFailed parameter in the method
        lstSA.clear();
        lstSA.addAll(initiateManualOnboarding.createSystemAction(request.getBody(),response.getBody(),logEndpoint,method,objCase.id,objCase.Customer_CIF__c,objCase.accountId,response.getStatusCode(), action, 'Credit Card',true));
    }

    /**
    * @description Sends the PUT credit-cards/request call and logs it when it fails (status != 200).
    *              Used by CCCaseUpdate. Keeps the existing behaviour: only the last failed call is kept in lstSA.
    */
    public static HttpResponse sendAndLogCardRequest(HttpRequest request, Case objCase, String body, List<System_Action__c> lstSA, String action){
        HttpResponse response = sendCardRequest(request, objCase, body);
        if (response.getStatusCode() != 200)
        {
            replaceWithFailureLog(lstSA, request, response, objCase, LOG_ENDPOINT_CREDIT_CARD_REQUEST, 'PUT', action);
        }
        return response;
    }

    public static void processCardRequestSuccess(Case objCase, HttpResponse response, List<World_Elite_Entitlement__c> lstWorldEntitCase){
        System.debug(response.getBody());
        //Start : NBA-8386
        if(isLimitIncrease(objCase) && objCase.cc_CC_Application_Source__c == 'Manual'){
            Decimal currentCreditLimit;
            Map<String, Object> parsedResponse = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
            Map<String, Object> data11 = (Map<String, Object>)parsedResponse.get('data');
            currentCreditLimit = (Decimal) data11.get('currentCreditLimit');
            if(currentCreditLimit != null){objCase.cc_Current_Credit_Limit__c = currentCreditLimit;}
        }
        //End : NBA-8386
        //CH36: Start
        if(System.Label.ILA_WORLD_ENTITLEMENT_ENABLE.equalsIgnoreCase('true') && isNewCreditCard(objCase) && (objCase.cc_Requested_Card_Type__c == 'WORLD_ELITE_CASHBACK_AND_REWARDS_01' || objCase.cc_Requested_Card_Type__c == 'WORLD_ELITE_CASHBACK_AND_REWARDS_02')){
            World_Elite_Entitlement__c wtlToInsert = CreateWorldEliteEntitCase.createWorldEntitlementCase(objCase.Account, objCase);
            lstWorldEntitCase.add(wtlToInsert);
        }
        //CH36: END
    }

    //CH28: CCCaseUpdate - store the co-brand membership number returned by the API
    public static void applyMembershipNumber(Case objCase, HttpResponse response){
        Map<String, Object> deserializeResponse = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());// meta, data
        Map<String, Object> dataMap = (Map<String, Object>)deserializeResponse.get('data');
        System.debug('Success Response with Membership Number:'+dataMap);
        String membershipNumber = String.valueOf(dataMap.get('membershipNumber'));
        objCase.cc_Embossing_Line_4__c = membershipNumber;
        objCase.cc_Approved_Embossing_line_4__c = membershipNumber;
    }

    //CH33 / CH34: CCCaseUpdate - Gulf Air co-brand cross-selling: Premium Invitation (Regular) or Premium Retention (Premium) case
    public static void addGulfCrossSellCase(Case objCase, List<Case> lstPremiumInvitationCaseToInsert){
        if(System.Label.ENABLE_CROSS_SELLING_GULF.equalsIgnoreCase('true') && objCase.Customer_Segment__c == 'Regular'){
            Case cseToInsert = CreatePremiumInvitationCase.createPremiumCase(objCase.Account,objCase.cc_Approved_Requested_Card_Type__c,objCase.cc_Approved_Name_on_the_card__c);
            lstPremiumInvitationCaseToInsert.add(cseToInsert);
        }
        else if(System.Label.ENABLE_CROSS_SELLING_GULF.equalsIgnoreCase('true') && objCase.Customer_Segment__c == 'Premium'){
            Case cseToInsert = CreatePremiumRetentionCase.createPremiumCase(objCase.Account,objCase.cc_Approved_Requested_Card_Type__c,objCase.cc_Approved_Name_on_the_card__c);
            lstPremiumInvitationCaseToInsert.add(cseToInsert);
        }
    }

    /********************************************* CASE FIELD UPDATES *********************************************/
    //CCCaseUpdate: stamps the result date/time field and sets the application stage
    public static void applyResultStage(Case objCase, Schema.SObjectField resultDateTimeField, String applicationStage){
        objCase.put(resultDateTimeField, system.now());
        objCase.cc_Application_Stages__c = applicationStage;
    }

    //CH31 / CH38: CCCaseUpdate - declined Credit Card / Limit Increase: restrict the customer from re-applying, then stamp date/time and stage
    public static void applyDeclineStage(Case objCase, Schema.SObjectField resultDateTimeField, String applicationStage, List<Account> accListToUpdateRestrictCreditCard){
        if((objCase.Type == 'Credit Card Application' || objCase.Type == 'Credit Limit Increase Application')){
            Account acc = initiateManualOnboarding.restrictAccountToApplyCard(objCase,objCase.AccountId);
            accListToUpdateRestrictCreditCard.add(acc);
        }
        applyResultStage(objCase, resultDateTimeField, applicationStage);
    }

    //CCCaseUpdate: case closed as Approved
    public static void markApproved(Case objCase){
        objCase.Status = 'Closed';
        objCase.Sub_Status__c = 'Approved';
        objCase.cc_Application_Stages__c = 'Completed';
        objCase.cc_CRM_Stage__c = 'APPROVED';
    }

    //CH11 / CH12 / CH32: CPR details (Bahraini ID only), card product configuration and passport number
    public static void applyCustomerIdDetails(Case objCase, Integer cardProductConfigurationId){
        System.debug('Account Id Type:'+objCase.Account.ID_Type__pc);
        if(objCase.Account.ID_Type__pc == 'Bahraini ID'){
            objCase.cc_CPR_Number__c = objCase.Account.ID_Number__pc;
            objCase.cc_CPR_Expiry_Date__c = objCase.Account.ID_Expiry_Date__pc;
        }
        //CH12
        objCase.PrimaryCardProductConfigurationId__c = String.valueOf(cardProductConfigurationId);
        //CH32
        objCase.cc_Passport_Number__c = objCase.Account.iGA_Passport_Number__pc;
    }
}
