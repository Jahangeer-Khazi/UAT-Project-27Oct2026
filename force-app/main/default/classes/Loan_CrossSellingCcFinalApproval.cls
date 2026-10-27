/**
* @author Aniss Mbarki
* @date Création 30/09/2024
* @date Modification
* @description : 
*/
public without sharing class Loan_CrossSellingCcFinalApproval {
    
    private static String CLASS_NAME = Loan_CrossSellingCcFinalApproval.class.getName();
    private static ApiConnection con = new ApiConnection();
    private static List<System_Action__c> lstSA = new List<System_Action__c>();
    

    @InvocableMethod(label='call Update Loan Cross Selling CC Request Status API' description='call Update Loan Cross Selling CC Request Status API' callout=true )
    public static List<String> updateCrossSellingCCReqApiFromFlow(List<RequestLoanCrossSelling> reqCrossSellingCase)
    {   
        system.debug('reqCrossSellingCase debug ==> '+reqCrossSellingCase);
        RequestLoanCrossSelling reqCrossSellingRecord = reqCrossSellingCase.get(0);
        Map<String,String> details = new Map<String,String>();
        details.put('changedField',reqCrossSellingRecord.changedField);
        
        try{
            
            updateCreditCardCrossReqApiFutureMeth(new Set<Id>{reqCrossSellingRecord.caseId},details);
            
        }catch(Exception e){
            Case caseObj = [SELECT Id,Customer_CIF__c,accountId,Type FROM Case WHERE Id =: reqCrossSellingRecord.caseId];
            caseObj.Last_Api_Call_Status__c = 'Failed';
            update caseObj;
            //store unexpected errors from system !!
            System.debug(e.getMessage());
            System.debug(e.getStackTraceString());
            insert SM001_ApiCalls.setSystemAction( e.getMessage(),String.valueOf(e.getStackTraceString()),
                                                  null,null,
                                                  caseObj.id,caseObj.Customer_CIF__c,caseObj.accountId,null, 
                                                  'please check : '+CLASS_NAME+'.updateCrossSellingCCReqApiFromFlow()', caseObj.Type
                                                 );
        }
        
        List<String> strLst = new List<String>();
        for(RequestLoanCrossSelling qst : reqCrossSellingCase){
            strLst.add(qst.caseId);
        }
        return strLst;
    }

    @future(callout=true)
    public static void updateCreditCardCrossReqApiFutureMeth(Set<Id> caseIds , Map<String,String> details){
        
        
        List<Case> cases = new List<Case>();
        if (caseIds != null && caseIds.size() > 0) {
            String fields = DM000_sObjectDescriber.constructFieldListForQueryFrom('Case');
            String soqlQuery = 'SELECT ' + fields + ',CaseAnnex__r.cx_ln_Approved_Credit_Limit__c,CaseAnnex__r.cx_ln_Cross_Selling_PreScreening_Result__c,CaseAnnex__r.cx_ln_Cross_Selling_Evaluator_Result__c,CaseAnnex__r.cx_ln_Cross_Selling_Verifier_Result__c,CaseAnnex__r.cx_ln_Cross_Selling_Approver_Result__c,Account.PersonEmail,Account.CIF__pc,Account.x_canary__pc,Account.Region_Flag__pc FROM Case WHERE Id IN :caseIds';
            cases = new List<Case>((List<Case>)Database.query(soqlQuery));
        }
        
        String changedField = details.get('changedField');
        List<CaseAnnex__c> cxList = new List<CaseAnnex__c>();
        Boolean isUpdateCase = false;
        for(Case caseObj : cases){
            try {
                
                String regionName = caseObj.Region_Flag__c;
                if (caseObj.Case_Model__c == 'alburaq') {
                    regionName += '_alburaq';
                }
                
                HttpRequest request = con.createRequest('POST', '/api/v1/credit-cards/cross?',regionName);
                request.setTimeout(60000);
                HttpResponse response;
                if ( test.isRunningTest() ) {
                    //fake response 
                    response = new HttpResponse();
                    String body = '{"meta":{"code":"CCRD-12345","message":"your card application is captured successfully"},"data":{"caseId":"AJ987df344","holdRefrence":"8778679"}}';
                    response.setStatus('OK');    
                    response.setStatusCode(200);
                    response.setBody(body);
                    response.setHeader('Content-Type', 'application/json');
                }

                if( changedField != null && changedField.equalsIgnoreCase('cx_ln_Cross_Selling_PreScreening_Result__c') ){
                    CaseAnnex__c cx = new CaseAnnex__c(
                                    Id=caseObj.CaseAnnex__c,
                                    cx_ln_CrossSelling_PreScreening_Datetime__c = System.now()
                                );
                    if( caseObj.CaseAnnex__r.cx_ln_Cross_Selling_PreScreening_Result__c == 'Decline' ){
                        response = updateCrossSellingCaseStatusApi(request,caseObj,'DECLINED');
                        caseObj.cc_Approved_Credit_Limit__c = 0;
                        cx.cx_ln_Approved_Credit_Limit__c = 0;
                        isUpdateCase = true;
                    }
                    else if( caseObj.CaseAnnex__r.cx_ln_Cross_Selling_PreScreening_Result__c == 'Cancelled' ){
                        response = updateCrossSellingCaseStatusApi(request,caseObj,'CANCELLED');
                        caseObj.cc_Approved_Credit_Limit__c = 0;
                        cx.cx_ln_Approved_Credit_Limit__c = 0;
                        isUpdateCase = true;
                    }
                    cxList.add(cx);
                }
                else if( changedField != null && changedField.equalsIgnoreCase('cx_ln_Cross_Selling_Evaluator_Result__c') ){
                    CaseAnnex__c cx = new CaseAnnex__c(
                                    Id=caseObj.CaseAnnex__c,
                                    cx_ln_Cross_Selling_Evaluator_Datetime__c = System.now()
                                );
                    
                    if( caseObj.CaseAnnex__r.cx_ln_Cross_Selling_Evaluator_Result__c == 'Decline' ){
                        response = updateCrossSellingCaseStatusApi(request,caseObj,'DECLINED');
                        caseObj.cc_Approved_Credit_Limit__c = 0;
                        cx.cx_ln_Approved_Credit_Limit__c = 0;
                        isUpdateCase = true;
                    }
                    else if( caseObj.CaseAnnex__r.cx_ln_Cross_Selling_Evaluator_Result__c == 'Cancelled' ){
                        response = updateCrossSellingCaseStatusApi(request,caseObj,'CANCELLED');
                        caseObj.cc_Approved_Credit_Limit__c = 0;
                        cx.cx_ln_Approved_Credit_Limit__c = 0;
                        isUpdateCase = true;
                    }
                    cxList.add(cx);
                }
                else if( changedField != null && changedField.equalsIgnoreCase('cx_ln_Cross_Selling_Verifier_Result__c') ){
                    CaseAnnex__c cx = new CaseAnnex__c(
                                    Id=caseObj.CaseAnnex__c,
                                    cx_ln_Cross_Selling_Verifier_Date_Time__c = System.now()
                                );
                    
                    if( caseObj.CaseAnnex__r.cx_ln_Cross_Selling_Verifier_Result__c == 'Decline' ){
                        response = updateCrossSellingCaseStatusApi(request,caseObj,'DECLINED');
                        caseObj.cc_Approved_Credit_Limit__c = 0;
                        cx.cx_ln_Approved_Credit_Limit__c = 0;
                        isUpdateCase = true;
                    }
                    else if( caseObj.CaseAnnex__r.cx_ln_Cross_Selling_Verifier_Result__c == 'Cancelled' ){
                        response = updateCrossSellingCaseStatusApi(request,caseObj,'CANCELLED');
                        caseObj.cc_Approved_Credit_Limit__c = 0;
                        cx.cx_ln_Approved_Credit_Limit__c = 0;
                        isUpdateCase = true;
                    }
                    cxList.add(cx);
                }
                else if( changedField != null && changedField.equalsIgnoreCase('cx_ln_Cross_Selling_Approver_Result__c') ){
                    CaseAnnex__c cx = new CaseAnnex__c(
                                    Id=caseObj.CaseAnnex__c,
                                    cx_ln_Cross_Selling_Approver_Date_Time__c = System.now()
                                );
                    
                    if( caseObj.CaseAnnex__r.cx_ln_Cross_Selling_Approver_Result__c == 'Decline' ){
                        response = updateCrossSellingCaseStatusApi(request,caseObj,'DECLINED');
                        caseObj.cc_Approved_Credit_Limit__c = 0;
                        cx.cx_ln_Approved_Credit_Limit__c = 0;
                        isUpdateCase = true;
                    }
                    else if( caseObj.CaseAnnex__r.cx_ln_Cross_Selling_Approver_Result__c == 'Cancelled' ){
                        response = updateCrossSellingCaseStatusApi(request,caseObj,'CANCELLED');
                        caseObj.cc_Approved_Credit_Limit__c = 0;
                        cx.cx_ln_Approved_Credit_Limit__c = 0;
                        isUpdateCase = true;
                    }
                    cxList.add(cx);
                }
                //cc_Signature_Verifier_Result__c ==> accept
                else if( changedField != null && changedField.equalsIgnoreCase('cc_Signature_Verifier_Result__c') ){
                    if( !test.isRunningTest() ){
                        if( caseObj.cc_Signature_Verifier_Result__c == 'Accept' ){
                            response = updateCrossSellingCaseStatusApi(request,caseObj,'APPROVED');
                        }
                    }
                }
                //Store Both Success/Error Response 
                if(response != null && response.getStatusCode() != null){
                    lstSA.add(SM001_ApiCalls.setSystemAction( request.getBody(),response.getBody(),
                                    request.getEndpoint(),request.getMethod(),
                                    caseObj.id,caseObj.Customer_CIF__c,caseObj.accountId,response.getStatusCode(), 
                                    caseObj.Type+' Request cross selling Status API', caseObj.Type
                                ));
                }
                
            } catch (Exception e) {
                System.debug(e.getMessage());
                System.debug(e.getStackTraceString());
                lstSA.add(SM001_ApiCalls.setSystemAction( null,'Error Message : ' +e.getMessage()+'; Trace : '+String.valueOf(e.getStackTraceString()),
                                                         null,null,
                                                         caseObj.id,caseObj.Customer_CIF__c,caseObj.accountId,null, 
                                                         caseObj.Type+' updateCreditCardCrossReqApiFutureMeth (unhandled error)', caseObj.Type
                                                        ));
            }
            
        }
        
        if(cxList != null && cxList.size()>0){
            update cxList;
        }
        if(lstSA != null && lstSA.size()>0){
            insert lstSA;
        }
        if(isUpdateCase == true && cases != null && cases.size()>0){
            update cases;
        }
    }

    public static HttpResponse updateCrossSellingCaseStatusApi(HttpRequest request,Case objCase,String updatedStatus){
        PAD.debugLogBegin(CLASS_NAME, 'updateCrossSellingCaseStatusApi','Parameters : [objCase] : '+ objCase);
        system.debug('debug API status : '+updatedStatus);
        if(objCase.Customer_CIF__c != null){
            request.setHeader('customerId', objCase.Customer_CIF__c);
        }
        
        Map<String, String> requestObject = new Map<String, String>{
            'cardProductConfigurationId' => objCase.PrimaryCardProductConfigurationId__c,
            'crmCaseId' => objCase.Id,
            'status' => updatedStatus,
            'nameOnTheCard' => objCase.cc_Name_on_the_Card__c, 
            'creditLimit' => String.valueOf(objCase.cc_Requested_Credit_Limit__c),
            'targetType' => 'CREDIT_CARD_ORDER_CROSS_SELL'
        };

        if( updatedStatus == 'APPROVED'){
            if(objCase.cc_Approved_Name_on_the_card__c != null){
                requestObject.put( 'nameOnTheCard' , String.valueOf(objCase.cc_Approved_Name_on_the_card__c) );
            }
            if(objCase.CaseAnnex__r.cx_ln_Approved_Credit_Limit__c != null){
                requestObject.put( 'creditLimit' , String.valueOf(objCase.CaseAnnex__r.cx_ln_Approved_Credit_Limit__c) );
            }

            Http http = new Http();
            HttpRequest request1 = new HttpRequest();
            String regionName = objCase.Region_Flag__c;    
            if(objCase.Case_Model__c == 'alburaq'){    
                regionName += '_alburaq';  
            }
            request1 = con.createRequest('GET', System.Label.CC_EndPointGetCreditCards, regionName ); 

            System.debug('Person Email :'+objCase.Account.PersonEmail);
            System.debug('Customer ID :'+objCase.Account.CIF__pc);
            
            request1.setHeader('userId', objCase.Account.PersonEmail);
            request1.setHeader('customerId', objCase.Account.CIF__pc);
            if(objCase.Account.x_canary__pc != null){
                request1.setHeader('x-canary', objCase.Account.x_canary__pc);
            }
            
            system.debug('---> request1 --> '+request1.getBody());
            request1.setTimeout(60000);
            HttpResponse response1 = http.send(request1);
            system.debug('---> Responce New --> '+response1.getBody());
            lstSA.add(SM001_ApiCalls.setSystemAction(request1.getBody(),response1.getBody(),
                                                    request1.getEndpoint(),request1.getMethod(),
                                                    objCase.id,objCase.Customer_CIF__c,objCase.accountId,response1.getStatusCode(),
                                                    objCase.Type+' -- call api to et api/v1/credit-cards list --', 'Credit Card'));
            if (response1.getStatusCode() != 200)
            {
                System.debug('The status code returned was not expected: ' + response1.getStatusCode() + ' ' + response1.getStatus());
            }
            else
            {
                System.debug(response1.getBody());
                Map<String, Object> m = (Map<String, Object>)JSON.deserializeUntyped(response1.getBody());
                System.debug('---> MAP m --> '+m);  // meta, data
                System.debug('---> MAP m VALUES --> '+m.Values());
                Map<String, Object> m1 = (Map<String, Object>)m.get('data');
                System.debug('---> MAP m1 --> '+m1);  // currentCards,pendingCards,cardOptions
                List<Object> m2 = (List<Object>)m1.get('cardOptions');
                System.debug('---> LIST m2 --> '+m2);
                
                List<Map<String, Object>> a = new List<Map<String, Object>> ();
                
                for(Object obj : m2)
                {
                    a.add((Map<String, Object>)obj);
                    {
                        system.debug('---->> OBJ Iterations --> '+obj);
                    }
                }
                system.debug('---->> FINALL aaaa --> '+a);
                
                for(Map<String, Object> map1 : a)
                {
                    if( map1.get('productMappingCode') == objCase.cc_Approved_Requested_Card_Type__c )
                    {
                        system.debug('---> FINALL 1111 --> '+(Integer)map1.get('cardProductConfigurationId'));
                        requestObject.put( 'cardProductConfigurationId' , String.valueOf((Integer)map1.get('cardProductConfigurationId')) );
                    }
                }
            }
        }

        request.setBody( JSON.serialize(requestObject) );

        System.debug('********************* updateCrossSellingCaseStatusApi request.getEndpoint() **********************');
        System.debug(request.getEndpoint());
        
        System.debug('********************* updateCrossSellingCaseStatusApi request.getBody() **********************');
        System.debug(request.getBody());
        
        HttpResponse response = EM001_ApiCalls.updateCreditCardRequestStatusApi(request,200);

        PAD.debugLogEnd(CLASS_NAME, 'updateCrossSellingCaseStatusApi', '[response] code : ' + response.getStatusCode() +' ,body : '+response.getBody());
        
        return response;
    }

    public class RequestLoanCrossSelling {
        @InvocableVariable(label='Case Id' description='the Id of the Case' required=true)
        public String caseId;
        
        @InvocableVariable(label='changedField' description='changedField apiName')
        public String changedField;
    }
    
}