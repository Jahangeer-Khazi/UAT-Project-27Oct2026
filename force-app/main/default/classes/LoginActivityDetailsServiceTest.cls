@isTest
public class LoginActivityDetailsServiceTest {

    private static final String SUCCESS_BODY =
        '{"items":[' +
        '{"timestamp":"2026-09-07T12:00:00Z","outcome":"SUCCESS","deviceId":"08b","ipAddress":"203.192.227.60","city":"Manama"},' +
        '{"timestamp":"2026-09-07T11:00:00Z","outcome":"FAILED","deviceId":"09c","ipAddress":"10.0.0.1","city":"Riffa"}' +
        '],"hasMore":false}';

    @isTest
    static void testGetRecentActivityDetails_Success() {
        Account customer = createCustomer('6205808');
        Test.setMock(HttpCalloutMock.class, new LoginHistoryMock(200, SUCCESS_BODY));

        Test.startTest();
        List<LoginActivityDetailWrapper> results = LoginActivityDetailsService.getRecentActivityDetails(customer.Id, 0, 8);
        Test.stopTest();

        System.assertEquals(2, results.size(), 'Should return API login items');
        System.assertEquals('Successful Login', results[0].description);
        System.assertEquals('Success', results[0].result);
        System.assertEquals('203.192.227.60', results[0].category);
        System.assertEquals('Manama', results[0].unit);
        System.assertEquals('08b', results[0].channel);
    }

    @isTest
    static void testGetLatestActivityDetails_OmitsDates() {
        Account customer = createCustomer('6205808');
        LatestQueryMock mock = new LatestQueryMock(200, SUCCESS_BODY);
        Test.setMock(HttpCalloutMock.class, mock);

        Test.startTest();
        List<LoginActivityDetailWrapper> results = LoginActivityDetailsService.getLatestActivityDetails(customer.Id);
        Test.stopTest();

        System.assertEquals(2, results.size());
        System.assert(mock.endpoint.contains('limit=5'), 'Latest details should request limit=5');
        System.assert(!mock.endpoint.contains('startDate='), 'Latest details should omit startDate');
        System.assert(!mock.endpoint.contains('endDate='), 'Latest details should omit endDate');
    }

    @isTest
    static void testGetLoginActivities_PaginationAndStatus() {
        Account customer = createCustomer('6205808');
        Test.setMock(HttpCalloutMock.class, new LoginHistoryMock(200, SUCCESS_BODY));

        Test.startTest();
        LoginActivityDetailsResponse pageOne = LoginActivityDetailsService.getLoginActivities(
            customer.Id,
            1,
            1,
            Date.newInstance(2026, 9, 7),
            Date.newInstance(2026, 9, 7),
            'All'
        );
        LoginActivityDetailsResponse failedOnly = LoginActivityDetailsService.getLoginActivities(
            customer.Id,
            50,
            1,
            Date.newInstance(2026, 9, 7),
            Date.newInstance(2026, 9, 7),
            'Failed'
        );
        Test.stopTest();

        System.assertEquals(2, pageOne.totalRecords);
        System.assertEquals(2, pageOne.totalPages);
        System.assertEquals(1, pageOne.records.size());
        System.assertEquals(1, failedOnly.totalRecords);
        System.assertEquals('Failed', failedOnly.records[0].result);
        System.assertEquals('Failed Login', failedOnly.records[0].description);
    }

    @isTest
    static void testGetCustomerExportInfo() {
        Account customer = createCustomer('6205808');

        Test.startTest();
        Map<String, String> info = LoginActivityDetailsService.getCustomerExportInfo(customer.Id);
        Test.stopTest();

        System.assertEquals('6205808', info.get('cif'));
        System.assert(String.isNotBlank(info.get('name')), 'Customer name should be populated');
    }

    @isTest
    static void testGetRecentActivityDetails_ApiError() {
        Account customer = createCustomer('6205808');
        Test.setMock(HttpCalloutMock.class, new LoginHistoryMock(500, '{"meta":{"message":"backend error"}}'));

        Test.startTest();
        try {
            LoginActivityDetailsService.getRecentActivityDetails(customer.Id, 0, 8);
            System.assert(false, 'Should have thrown API error');
        } catch (AuraHandledException e) {
            System.assert(String.isNotBlank(e.getMessage()), 'Error message should be populated');
        }
        Test.stopTest();
    }

    private static Account createCustomer(String cif) {
        Account acc = new Account(
            LastName = 'Login Activity Details Customer',
            CIF__pc = cif,
            Region_Flag__c = 'Bahrain',
            Subscription_Model__pc = 'ila'
        );
        insert acc;
        return acc;
    }

    private class LoginHistoryMock implements HttpCalloutMock {
        private Integer statusCode;
        private String body;

        LoginHistoryMock(Integer statusCode, String body) {
            this.statusCode = statusCode;
            this.body = body;
        }

        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(statusCode);
            res.setBody(body);
            return res;
        }
    }

    private class LatestQueryMock implements HttpCalloutMock {
        private Integer statusCode;
        private String body;
        public String endpoint;

        LatestQueryMock(Integer statusCode, String body) {
            this.statusCode = statusCode;
            this.body = body;
        }

        public HTTPResponse respond(HTTPRequest req) {
            endpoint = req.getEndpoint() == null ? '' : req.getEndpoint();
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(statusCode);
            res.setBody(body);
            return res;
        }
    }
}