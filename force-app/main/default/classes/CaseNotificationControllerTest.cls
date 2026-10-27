@isTest
private class CaseNotificationControllerTest {
    
    // ------------------------------------------------------------------
    // HTTP Mock
    // ------------------------------------------------------------------
    public class MockHttpResponse implements HttpCalloutMock {
        Integer statusCode;
        String body;
        Boolean throwException;
        
        public MockHttpResponse(Integer statusCode, String body) {
            this.statusCode = statusCode;
            this.body = body;
            this.throwException = false;
        }
        
        public MockHttpResponse(Boolean throwException) {
            this.throwException = throwException;
        }
        
        public HTTPResponse respond(HTTPRequest req) {
            if (throwException) {
                throw new CalloutException('Mock callout exception');
            }
            HttpResponse res = new HttpResponse();
            res.setStatusCode(statusCode);
            res.setBody(body);
            return res;
        }
    }
    
    // ------------------------------------------------------------------
    // @testSetup — creates queues, an ILA account, and an ALBURAQ account
    // ------------------------------------------------------------------
    @testSetup
    static void setup() {
        
        createQueuesIfMissing();
        
        // 2. ILA customer
        Account ilaAcc = (Account) TestDataFactory.createSObject(
            new Account(CIF__pc = '1293779', PersonMobilePhone = '1234567890'),
            'TestFactoryDefaults.AccountDefaults',
            true
        );
        
        // 3. ALBURAQ customer — must satisfy your custom validation rule
        Account alburaqAcc = (Account) TestDataFactory.createSObject(
            new Account(CIF__pc = '1293780', PersonMobilePhone = '9876543210', Subscription_Model__pc = 'alburaq'),
            'TestFactoryDefaults.AccountDefaults',
            true
        );
        
        // TODO: set whichever field your validation rule needs for alburaq customers.
        // Example (change field + value to match your org):
        // alburaqAcc.Customer_Type__c = 'AlBuraq';
        // update alburaqAcc;
        
        // 4. One seed Case (ILA)
        Id caseRtId = Schema.SObjectType.Case
            .getRecordTypeInfosByDeveloperName()
            .get('Issue').getRecordTypeId();
        
        TestDataFactory.createSObject(
            new Case(
                RecordTypeId   = caseRtId,
                ContactId      = ilaAcc.PersonContactId,
                AccountId      = ilaAcc.Id,
                Case_Model__c  = 'ila',
                OwnerId        = [SELECT Id FROM Group WHERE Name = 'Loan Pre-Screener Queue' LIMIT 1].Id,
                Region_Flag__c = 'Bahrain'
            ),
            'TestFactoryDefaults.CaseDefaults',
            true
        );
    }
    
    // ------------------------------------------------------------------
    // Helpers
    // ------------------------------------------------------------------
    private static Id getQueueId(String name) {
        return [SELECT Id FROM Group WHERE Name = :name AND Type = 'Queue' LIMIT 1].Id;
    }
    
    /** Fetches the ILA account (CIF 1293779). */
    private static Account getIlaAccount() {
        return [SELECT Id, PersonContactId FROM Account WHERE CIF__pc = '1293779' LIMIT 1];
    }
    
    /** Fetches the ALBURAQ account (CIF 1293780). */
    private static Account getAlburaqAccount() {
        return [SELECT Id, PersonContactId FROM Account WHERE CIF__pc = '1293780' LIMIT 1];
    }
    
    /** Common case factory — pass which Account the case belongs to. */
    private static Case createCase(
        String caseModel,
        String subType,
        Id ownerId,
        String region,
        Account acc
    ) {
        Id caseRtId = Schema.SObjectType.Case
            .getRecordTypeInfosByDeveloperName()
            .get('Loan_Application').getRecordTypeId();
        
        Case c = new Case(
            RecordTypeId   = caseRtId,
            ContactId      = acc.PersonContactId,
            AccountId      = acc.Id,
            Case_Model__c  = caseModel,
            Sub_Type__c    = subType,
            OwnerId        = ownerId,
            Region_Flag__c = region
        );
        insert c;
        return c;
    }
    
    private static void createQueuesIfMissing() {
        List<String> names = new List<String>{
            'Loan Pre-Screener Queue',
                'Loan Document Verifier OBL',
                'Loan Document Verifier NDL',
                'Loan Document Verifier STL',
                'Generic Owner'
                };
                    
                    Set<String> existing = new Set<String>();
        for (Group g : [SELECT Id, Name FROM Group WHERE Type = 'Queue' AND Name IN :names]) {
            existing.add(g.Name);
        }
        
        List<Group> toCreate = new List<Group>();
        for (String n : names) {
            if (!existing.contains(n)) {
                toCreate.add(new Group(Name = n, Type = 'Queue'));
            }
        }
        if (toCreate.isEmpty()) return;
        
        // Use a real admin user, not new User(Id = ...)
        User admin = [
            SELECT Id FROM User
            WHERE Profile.Name = 'System Administrator'
            AND IsActive = true
            AND UserType = 'Standard'
            LIMIT 1
        ];
        
        System.runAs(admin) {
            Database.insert(toCreate, false); // don't fail the class on partial failure
            
            List<QueueSobject> qs = new List<QueueSobject>();
            for (Group g : toCreate) {
                if (g.Id != null) {
                    qs.add(new QueueSobject(QueueId = g.Id, SobjectType = 'Case'));
                }
            }
            if (!qs.isEmpty()) Database.insert(qs, false);
        }
        
        // Re-query and assert — better to fail with a clear message than a null OwnerId
        Set<String> created = new Set<String>();
        for (Group g : [SELECT Name FROM Group WHERE Type = 'Queue' AND Name IN :names]) {
            created.add(g.Name);
        }
        for (String n : names) {
            System.assert(created.contains(n),
                          'Could not create or find queue: ' + n);
        }
    }
    
    // ------------------------------------------------------------------
    // Test methods
    // ------------------------------------------------------------------
    
    /** caseId == null → early return */
    @isTest
    static void testNullCaseId() {
        Test.startTest();
        CaseNotificationController.sendDiscrepancySMS(null);
        Test.stopTest();
    }
    
    /** ILA + PRE → success (200) → FeedItem created */
    @isTest
    static void testILA_PRE() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse(200, 'OK'));
        Case c = createCase('ILA', null, getQueueId('Loan Pre-Screener Queue'), 'Bahrain', getIlaAccount());
        Test.startTest();
        CaseNotificationController.sendDiscrepancySMS(c.Id);
        Test.stopTest();
    }
    
    /** ILA + OBL */
    @isTest
    static void testILA_OBL() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse(200, 'OK'));
        Case c = createCase('ILA', null, getQueueId('Loan Document Verifier OBL'), 'Bahrain', getIlaAccount());
        Test.startTest();
        CaseNotificationController.sendDiscrepancySMS(c.Id);
        Test.stopTest();
    }
    
    /** ILA + NDL */
    @isTest
    static void testILA_NDL() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse(200, 'OK'));
        Case c = createCase('ILA', null, getQueueId('Loan Document Verifier NDL'), 'Bahrain', getIlaAccount());
        Test.startTest();
        CaseNotificationController.sendDiscrepancySMS(c.Id);
        Test.stopTest();
    }
    
    /** ILA + STL */
    @isTest
    static void testILA_STL() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse(200, 'OK'));
        Case c = createCase('ILA', null, getQueueId('Loan Document Verifier STL'), 'Bahrain', getIlaAccount());
        Test.startTest();
        CaseNotificationController.sendDiscrepancySMS(c.Id);
        Test.stopTest();
    }
    
    /** ALBURAQ (exact lowercase) + PRE → covers regionName += '_alburaq' */
    @isTest
    static void testAlburaq_PRE_exact() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse(200, 'OK'));
        Case c = createCase('alburaq', null, getQueueId('Loan Pre-Screener Queue'), 'Bahrain', getAlburaqAccount());
        Test.startTest();
        CaseNotificationController.sendDiscrepancySMS(c.Id);
        Test.stopTest();
    }
    
    /** Mixed-case AlBuraq + OBL → productKey = ALBURAQ but regionName NOT appended */
    @isTest
    static void testAlburaq_OBL_mixedCase() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse(200, 'OK'));
        Case c = createCase('AlBuraq', null, getQueueId('Loan Document Verifier OBL'), 'Bahrain', getAlburaqAccount());
        Test.startTest();
        CaseNotificationController.sendDiscrepancySMS(c.Id);
        Test.stopTest();
    }
    
    /** ALBURAQ + NDL */
    @isTest
    static void testAlburaq_NDL() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse(200, 'OK'));
        Case c = createCase('alburaq', null, getQueueId('Loan Document Verifier NDL'), 'Bahrain', getAlburaqAccount());
        Test.startTest();
        CaseNotificationController.sendDiscrepancySMS(c.Id);
        Test.stopTest();
    }
    
    /** ALBURAQ + STL */
    @isTest
    static void testAlburaq_STL() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse(200, 'OK'));
        Case c = createCase('alburaq', null, getQueueId('Loan Document Verifier STL'), 'Bahrain', getAlburaqAccount());
        Test.startTest();
        CaseNotificationController.sendDiscrepancySMS(c.Id);
        Test.stopTest();
    }
    
    /** Owner doesn't match any stage → 'Unable to determine stage' */
    @isTest
    static void testNoStage() {
        Case c = createCase('ILA', null, getQueueId('Generic Owner'), 'Bahrain', getIlaAccount());
        Test.startTest();
        CaseNotificationController.sendDiscrepancySMS(c.Id);
        Test.stopTest();
    }
    
    /** HTTP 400 → 'FAILURE: Service returned status 400' */
    @isTest
    static void testNon200() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse(400, 'Bad Request'));
        Case c = createCase('ILA', null, getQueueId('Loan Pre-Screener Queue'), 'Bahrain', getIlaAccount());
        Test.startTest();
        CaseNotificationController.sendDiscrepancySMS(c.Id);
        Test.stopTest();
    }
    
    /** Callout throws → catch block + logSystemAction on exception path */
    @isTest
    static void testException() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse(true));
        Case c = createCase('ILA', null, getQueueId('Loan Pre-Screener Queue'), 'Bahrain', getIlaAccount());
        Test.startTest();
        CaseNotificationController.sendDiscrepancySMS(c.Id);
        Test.stopTest();
    }
}