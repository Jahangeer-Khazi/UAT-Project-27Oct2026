@isTest
public class LoginActivityServiceTest {

    private static final String SUCCESS_BODY =
        '{"items":[{"timestamp":"2026-09-07T12:00:00Z","outcome":"SUCCESS","deviceId":"08b","ipAddress":"203.192.227.60","city":"Manama"}],"hasMore":false}';

    @isTest
    static void testGetLastLoginAttempt_Success() {
        Account customer = createCustomer('6205808');
        Test.setMock(HttpCalloutMock.class, new LoginHistoryMock(200, SUCCESS_BODY));

        Test.startTest();
        LoginActivityWrapper result = LoginActivityService.getLastLoginAttempt(customer.Id, 0, 8);
        Test.stopTest();

        System.assertNotEquals(null, result, 'Last login should be returned');
        System.assertEquals('Success', result.status);
        System.assertEquals('203.192.227.60', result.deviceIp);
        System.assertEquals('08b', result.deviceModel);
        System.assertEquals('Manama', result.location);
    }

    @isTest
    static void testGetLastLoginAttempt_OmitsDates() {
        Account customer = createCustomer('6205808');
        QueryCapturingMock mock = new QueryCapturingMock(200, SUCCESS_BODY);
        Test.setMock(HttpCalloutMock.class, mock);

        Test.startTest();
        LoginActivityService.getLastLoginAttempt(customer.Id, 0, 8);
        Test.stopTest();

        System.assert(mock.endpoint.contains('limit=1'), 'Last login should request limit=1');
        System.assert(!mock.endpoint.contains('startDate='), 'Last login should omit startDate');
        System.assert(!mock.endpoint.contains('endDate='), 'Last login should omit endDate');
    }

    @isTest
    static void testGetLoginHistory_FiltersStatus() {
        Account customer = createCustomer('6205808');
        String body =
            '{"items":[' +
            '{"timestamp":"2026-09-07T12:00:00Z","outcome":"SUCCESS","deviceId":"08b","ipAddress":"203.192.227.60","city":"Manama"},' +
            '{"timestamp":"2026-09-07T10:00:00Z","outcome":"FAILED","deviceId":"09c","ipAddress":"10.0.0.1","city":"Riffa"}' +
            '],"hasMore":false}';
        Test.setMock(HttpCalloutMock.class, new LoginHistoryMock(200, body));

        Test.startTest();
        List<LoginActivityWrapper> allRows = LoginActivityService.getLoginHistory(
            customer.Id,
            Date.newInstance(2026, 9, 7),
            Date.newInstance(2026, 9, 7),
            'All'
        );
        List<LoginActivityWrapper> failedRows = LoginActivityService.getLoginHistory(
            customer.Id,
            Date.newInstance(2026, 9, 7),
            Date.newInstance(2026, 9, 7),
            'Failed'
        );
        Test.stopTest();

        System.assertEquals(2, allRows.size(), 'All statuses should be returned');
        System.assertEquals(1, failedRows.size(), 'Only failed logins should be returned');
        System.assertEquals('Failed', failedRows[0].status);
    }

    @isTest
    static void testGetLoginHistory_FollowsNextToken() {
        Account customer = createCustomer('6205808');
        Test.setMock(HttpCalloutMock.class, new PagedLoginHistoryMock());

        Test.startTest();
        List<LoginActivityWrapper> rows = LoginActivityService.getLoginHistory(
            customer.Id,
            Date.newInstance(2026, 9, 7),
            Date.newInstance(2026, 9, 7),
            'All'
        );
        Test.stopTest();

        System.assertEquals(2, rows.size(), 'Both pages should be merged');
    }

    @isTest
    static void testGetLastLoginAttempt_MissingCif() {
        Test.setMock(HttpCalloutMock.class, new LoginHistoryMock(200, SUCCESS_BODY));
        Account customer = createCustomer('6205808');
        customer.CIF__pc = null;
        update customer;

        Test.startTest();
        try {
            LoginActivityService.getLastLoginAttempt(customer.Id, null, null);
            System.assert(false, 'Should have thrown for missing CIF');
        } catch (AuraHandledException e) {
            System.assert(
                e.getMessage().contains('CIF') || e.getMessage().contains('Script-thrown exception'),
                'Error should mention CIF'
            );
        }
        Test.stopTest();
    }

    @isTest
    static void testGetLoginHistory_ApiError() {
        Account customer = createCustomer('6205808');
        Test.setMock(HttpCalloutMock.class, new LoginHistoryMock(500, '{"meta":{"message":"backend error"}}'));

        Test.startTest();
        try {
            LoginActivityService.getLoginHistory(customer.Id, Date.today(), Date.today(), 'All');
            System.assert(false, 'Should have thrown API error');
        } catch (AuraHandledException e) {
            System.assert(String.isNotBlank(e.getMessage()), 'Error message should be populated');
        }
        Test.stopTest();
    }

    @isTest
    static void testGenerateExportUrl() {
        String url = LoginActivityService.generateExportUrl(UserInfo.getUserId(), Date.today(), Date.today(), 'All');
        System.assert(url.contains('login-activity'), 'Should return export URL');
    }

    @isTest
    static void testRequestLoginHistoryReport_Success() {
        Account customer = createCustomer('10020634');
        ReportRequestMock mock = new ReportRequestMock(
            200,
            '{"data":{"taskId":"358","status":"PENDING"}}',
            null
        );
        Test.setMock(HttpCalloutMock.class, mock);

        Test.startTest();
        Map<String, String> result = LoginActivityService.requestLoginHistoryReport(
            customer.Id,
            Date.newInstance(2026, 10, 1),
            Date.newInstance(2026, 10, 31)
        );
        Test.stopTest();

        System.assertEquals('358', result.get('taskId'));
        List<System_Action__c> actions = [
            SELECT Id FROM System_Action__c WHERE Account__c = :customer.Id
        ];
        System.assertEquals(0, actions.size(), 'Successful POST should not create a System Action');
        System.assert(mock.postEndpoint.contains('/api/v1/background-tasks'), mock.postEndpoint);
        System.assertEquals('POST', mock.postMethod);
        System.assertEquals(null, mock.getEndpoint, 'POST should not call GET');
        System.assert(mock.requestBody.contains('LOGIN_HISTORY_REPORT'), mock.requestBody);
        System.assert(mock.requestBody.contains('"cif":"10020634"'), mock.requestBody);
        System.assert(mock.requestBody.contains('"startDate":"2026-10-01"'), mock.requestBody);
        System.assert(mock.requestBody.contains('"endDate":"2026-10-31"'), mock.requestBody);
        System.assert(mock.requestBody.contains('"format":"EXCEL"'), mock.requestBody);
        System.assertEquals('10020634', mock.customerIdHeader);
    }

    @isTest
    static void testGetLoginHistoryReportStatus_RootPayload() {
        Account customer = createCustomer('10020634');
        ReportRequestMock mock = new ReportRequestMock(
            200,
            '{"data":{"taskId":"359","status":"PENDING"}}',
            '{"taskId":"359","type":"LOGIN_HISTORY_REPORT","status":"COMPLETED","result":{"downloadUrl":"https://example.com/report.xlsx","expiresAt":"2026-10-07T10:51:46"}}'
        );
        Test.setMock(HttpCalloutMock.class, mock);

        Test.startTest();
        Map<String, String> status = LoginActivityService.getLoginHistoryReportStatus(customer.Id, '359');
        Test.stopTest();

        System.assertEquals('359', status.get('taskId'));
        System.assertEquals('COMPLETED', status.get('status'));
        System.assertEquals('LOGIN_HISTORY_REPORT', status.get('type'));
        System.assertEquals('https://example.com/report.xlsx', status.get('downloadUrl'));
        System.assertEquals('2026-10-07T10:51:46', status.get('expiresAt'));
        System.assert(mock.getEndpoint.contains('/api/v1/background-tasks/359'), mock.getEndpoint);
        System.assertEquals('GET', mock.getMethod);
        List<System_Action__c> actions = [
            SELECT Id FROM System_Action__c WHERE Account__c = :customer.Id
        ];
        System.assertEquals(0, actions.size(), 'Successful GET should not create a System Action');
    }

    @isTest
    static void testRequestLoginHistoryReport_ApiError() {
        Account customer = createCustomer('10020634');
        Test.setMock(HttpCalloutMock.class, new ReportRequestMock(500, '{"meta":{"message":"backend error"}}', null));

        Test.startTest();
        Map<String, String> result = LoginActivityService.requestLoginHistoryReport(
            customer.Id,
            Date.today(),
            Date.today()
        );
        Test.stopTest();

        System.assert(String.isNotBlank(result.get('error')), 'Failed POST should return an error');
        List<System_Action__c> failedActions = [
            SELECT Action__c, Method__c, HTTP_Response_Code__c, Response_Body__c
            FROM System_Action__c
            WHERE Account__c = :customer.Id
        ];
        System.assertEquals(1, failedActions.size(), 'Failed POST should create a System Action');
        System.assertEquals('Login History Report Request', failedActions[0].Action__c);
        System.assertEquals('POST', failedActions[0].Method__c);
        System.assertEquals(500, failedActions[0].HTTP_Response_Code__c);
    }

    @isTest
    static void testGetLoginHistoryReportStatus_Http404() {
        Account customer = createCustomer('10020634');
        ReportRequestMock mock = new ReportRequestMock(
            200,
            '{"data":{"taskId":"359","status":"PENDING"}}',
            404,
            '{"meta":{"message":"Task not found"}}'
        );
        Test.setMock(HttpCalloutMock.class, mock);

        Test.startTest();
        Map<String, String> status = LoginActivityService.getLoginHistoryReportStatus(customer.Id, '359');
        Test.stopTest();

        System.assertEquals('ERROR', status.get('status'));
        System.assert(String.isNotBlank(status.get('errorMessage')), '404 should return an error message');
        List<System_Action__c> failedActions = [
            SELECT Action__c, Method__c, HTTP_Response_Code__c
            FROM System_Action__c
            WHERE Account__c = :customer.Id
        ];
        System.assertEquals(1, failedActions.size(), 'HTTP 404 should create a System Action');
        System.assertEquals('Login History Report Status', failedActions[0].Action__c);
        System.assertEquals('GET', failedActions[0].Method__c);
        System.assertEquals(404, failedActions[0].HTTP_Response_Code__c);
    }

    @isTest
    static void testOutcomeAndTimestampHelpers() {
        System.assertEquals('Success', LoginActivityService.mapOutcome('SUCCESS'));
        System.assertEquals('Failed', LoginActivityService.mapOutcome('FAILED'));
        System.assertEquals('', LoginActivityService.mapOutcome(null));
        System.assertEquals('Manama', LoginActivityService.toStringValue('Manama'));
        System.assertNotEquals(null, LoginActivityService.parseTimestamp('2026-09-07T12:00:00Z'));
    }

    private static Account createCustomer(String cif) {
        Account acc = new Account(
            LastName = 'Login Activity Customer',
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

    private class QueryCapturingMock implements HttpCalloutMock {
        private Integer statusCode;
        private String body;
        public String endpoint;

        QueryCapturingMock(Integer statusCode, String body) {
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

    private class PagedLoginHistoryMock implements HttpCalloutMock {
        private Integer calls = 0;

        public HTTPResponse respond(HTTPRequest req) {
            calls++;
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(200);
            if (calls == 1) {
                res.setBody('{"items":[{"timestamp":"2026-09-07T12:00:00Z","outcome":"SUCCESS","deviceId":"08b","ipAddress":"203.192.227.60","city":"Manama"}],"hasMore":true,"nextToken":"page-2"}');
            } else {
                res.setBody('{"items":[{"timestamp":"2026-09-07T10:00:00Z","outcome":"FAILED","deviceId":"09c","ipAddress":"10.0.0.1","city":"Riffa"}],"hasMore":false}');
            }
            return res;
        }
    }

    private class ReportRequestMock implements HttpCalloutMock {
        private Integer statusCode;
        private Integer getStatusCode;
        private String postResponseBody;
        private String getResponseBody;
        public String postEndpoint;
        public String postMethod;
        public String getEndpoint;
        public String getMethod;
        public String requestBody;
        public String customerIdHeader;

        ReportRequestMock(Integer statusCode, String postResponseBody, String getResponseBody) {
            this(statusCode, postResponseBody, 200, getResponseBody);
        }

        ReportRequestMock(Integer statusCode, String postResponseBody, Integer getStatusCode, String getResponseBody) {
            this.statusCode = statusCode;
            this.postResponseBody = postResponseBody;
            this.getStatusCode = getStatusCode;
            this.getResponseBody = getResponseBody;
        }

        public HTTPResponse respond(HTTPRequest req) {
            String endpoint = req.getEndpoint() == null ? '' : req.getEndpoint();
            customerIdHeader = req.getHeader('customerId');
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            if (req.getMethod() == 'GET') {
                getEndpoint = endpoint;
                getMethod = req.getMethod();
                res.setStatusCode(getStatusCode == null ? 200 : getStatusCode);
                res.setBody(String.isBlank(getResponseBody) ? '{"data":{"status":"PENDING"}}' : getResponseBody);
                return res;
            }
            postEndpoint = endpoint;
            postMethod = req.getMethod();
            requestBody = req.getBody();
            res.setStatusCode(statusCode);
            res.setBody(postResponseBody);
            return res;
        }
    }
}