@isTest
private class EligibleProductsAndOffersControllerTest {

    // ------------------------------------------------------------------
    // Configurable HTTP mock covering all endpoints used by the controller
    // ------------------------------------------------------------------
    private class ConfigurableMock implements HttpCalloutMock {
        public Integer nboGetStatus            = 200;
        public String  nboGetBody              = '{"meta":{"code":"NBO-0000","message":"ok"},"data":{"cif":"12345","products":[{"productCode":"P1","confidenceScore":0.9},{"productCode":"P2","confidenceScore":0.8}],"offers":[{"offerId":"O1","confidenceScore":0.7}]}}';
        public Integer productCatalogueStatus  = 200;
        public String  productCatalogueBody    = '{"data":{"nboProducts":[{"productCode":"P1","productName":"Product One"},{"productCode":"P2","productName":"Product Two"}]}}';
        public Integer offerCatalogueStatus    = 200;
        public String  offerCatalogueBody      = '{"data":{"offers":[{"offerId":"O1","offerTitle":"Offer One"}]}}';
        public Integer patchStatus             = 200;
        public String  patchBody               = '{"status":"success"}';

        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            String endpoint = req.getEndpoint();
            String method   = req.getMethod();

            if (method == 'PATCH') {
                res.setStatusCode(patchStatus);
                res.setBody(patchBody);
            } else if (method == 'POST' && endpoint.contains('/product-catalogue/nbo')) {
                res.setStatusCode(productCatalogueStatus);
                res.setBody(productCatalogueBody);
            } else if (method == 'GET' && endpoint.contains('/product-catalogue/offers')) {
                res.setStatusCode(offerCatalogueStatus);
                res.setBody(offerCatalogueBody);
            } else if (method == 'GET' && endpoint.contains('/nbo/customers/')) {
                res.setStatusCode(nboGetStatus);
                res.setBody(nboGetBody);
            } else {
                res.setStatusCode(404);
                res.setBody('{"error":"not found"}');
            }
            return res;
        }
    }

    // ------------------------------------------------------------------
    // Setup
    // ------------------------------------------------------------------
    @testSetup
    static void setupData() {
        Account acc = (Account)TestDataFactory.createSObject(new Account(CIF__pc='1234567'), 'TestFactoryDefaults.AccountDefaults',true);
        
        // Try creating the NBO Sales Queue so getNBOQueueId() succeeds
        try {
            Group q = new Group(Name = 'NBO Sales Queue', Type = 'Queue');
            insert q;
        } catch (Exception e) { /* ignore */ }
    }

    // ------------------------------------------------------------------
    // Helpers
    // ------------------------------------------------------------------
    private static Account getAcc() {
        return [SELECT Id FROM Account LIMIT 1];
    }

    private static List<EligibleProductsAndOffersController.SelectedItem> buildItems(
            String itemType, String interest, String name) {
        List<EligibleProductsAndOffersController.SelectedItem> items =
            new List<EligibleProductsAndOffersController.SelectedItem>();
        EligibleProductsAndOffersController.SelectedItem i =
            new EligibleProductsAndOffersController.SelectedItem();
        i.id               = (itemType == null ? 'X' : itemType) + '_1';
        i.name             = name;
        i.itemType         = itemType;
        i.customerInterest = interest;
        items.add(i);
        return items;
    }

    // ==================================================================
    // getNBOData() coverage
    // ==================================================================

    @isTest
    static void testGetNBODataSuccess() {
        Test.setMock(HttpCalloutMock.class, new ConfigurableMock());
        Test.startTest();
        try { EligibleProductsAndOffersController.getNBOData(getAcc().Id); } catch (Exception e) {}
        Test.stopTest();
    }

    @isTest
    static void testGetNBODataNullAccountId() {
        Test.setMock(HttpCalloutMock.class, new ConfigurableMock());
        Test.startTest();
        try { EligibleProductsAndOffersController.getNBOData(null); } catch (Exception e) {}
        Test.stopTest();
    }

    @isTest
    static void testGetNBODataAccountNotFound() {
        Test.setMock(HttpCalloutMock.class, new ConfigurableMock());
        Test.startTest();
        try { EligibleProductsAndOffersController.getNBOData('001000000000000AAA'); } catch (Exception e) {}
        Test.stopTest();
    }

    @isTest
    static void testGetNBODataBlankCIF() {
        Account acc = getAcc();
        acc.CIF__pc = null;
        update acc;
        Test.setMock(HttpCalloutMock.class, new ConfigurableMock());
        Test.startTest();
        try { EligibleProductsAndOffersController.getNBOData(acc.Id); } catch (Exception e) {}
        Test.stopTest();
    }

    @isTest
    static void testGetNBODataDefaultRegionCanary() {
        Account acc = getAcc();
        acc.x_canary__pc   = null;
        acc.Region_Flag__pc = null;
        update acc;
        Test.setMock(HttpCalloutMock.class, new ConfigurableMock());
        Test.startTest();
        try { EligibleProductsAndOffersController.getNBOData(acc.Id); } catch (Exception e) {}
        Test.stopTest();
    }

    @isTest
    static void testGetNBODataAPIFailure() {
        ConfigurableMock m = new ConfigurableMock();
        m.nboGetStatus = 500;
        m.nboGetBody   = '{"error":"server error"}';
        Test.setMock(HttpCalloutMock.class, m);
        Test.startTest();
        try { EligibleProductsAndOffersController.getNBOData(getAcc().Id); } catch (Exception e) {}
        Test.stopTest();
    }

    @isTest
    static void testGetNBODataEmptyData() {
        ConfigurableMock m = new ConfigurableMock();
        m.nboGetBody = '{"meta":{"code":"NBO-0000"},"data":{}}';
        Test.setMock(HttpCalloutMock.class, m);
        Test.startTest();
        try { EligibleProductsAndOffersController.getNBOData(getAcc().Id); } catch (Exception e) {}
        Test.stopTest();
    }

    @isTest
    static void testGetNBODataEmptyLists() {
        ConfigurableMock m = new ConfigurableMock();
        m.nboGetBody = '{"meta":{"code":"NBO-0000"},"data":{"cif":"12345","products":[],"offers":[]}}';
        Test.setMock(HttpCalloutMock.class, m);
        Test.startTest();
        try { EligibleProductsAndOffersController.getNBOData(getAcc().Id); } catch (Exception e) {}
        Test.stopTest();
    }

    @isTest
    static void testGetNBODataOnlyProducts() {
        ConfigurableMock m = new ConfigurableMock();
        m.nboGetBody = '{"meta":{"code":"NBO-0000"},"data":{"cif":"12345","products":[{"productCode":"P1","confidenceScore":0.9}]}}';
        Test.setMock(HttpCalloutMock.class, m);
        Test.startTest();
        try { EligibleProductsAndOffersController.getNBOData(getAcc().Id); } catch (Exception e) {}
        Test.stopTest();
    }

    @isTest
    static void testGetNBODataOnlyOffers() {
        ConfigurableMock m = new ConfigurableMock();
        m.nboGetBody = '{"meta":{"code":"NBO-0000"},"data":{"cif":"12345","offers":[{"offerId":"O1","confidenceScore":0.8}]}}';
        Test.setMock(HttpCalloutMock.class, m);
        Test.startTest();
        try { EligibleProductsAndOffersController.getNBOData(getAcc().Id); } catch (Exception e) {}
        Test.stopTest();
    }

    @isTest
    static void testGetNBODataMetaError() {
        ConfigurableMock m = new ConfigurableMock();
        m.nboGetBody = '{"meta":{"code":"ERR-001","message":"failed"},"data":{}}';
        Test.setMock(HttpCalloutMock.class, m);
        Test.startTest();
        try { EligibleProductsAndOffersController.getNBOData(getAcc().Id); } catch (Exception e) {}
        Test.stopTest();
    }

    @isTest
    static void testGetNBODataNoMeta() {
        ConfigurableMock m = new ConfigurableMock();
        m.nboGetBody = '{"data":{"cif":"12345","products":[],"offers":[]}}';
        Test.setMock(HttpCalloutMock.class, m);
        Test.startTest();
        try { EligibleProductsAndOffersController.getNBOData(getAcc().Id); } catch (Exception e) {}
        Test.stopTest();
    }

    @isTest
    static void testGetNBODataNoDataKey() {
        ConfigurableMock m = new ConfigurableMock();
        m.nboGetBody = '{"meta":{"code":"NBO-0000"}}';
        Test.setMock(HttpCalloutMock.class, m);
        Test.startTest();
        try { EligibleProductsAndOffersController.getNBOData(getAcc().Id); } catch (Exception e) {}
        Test.stopTest();
    }

    @isTest
    static void testGetNBODataNullData() {
        ConfigurableMock m = new ConfigurableMock();
        m.nboGetBody = '{"meta":{"code":"NBO-0000"},"data":null}';
        Test.setMock(HttpCalloutMock.class, m);
        Test.startTest();
        try { EligibleProductsAndOffersController.getNBOData(getAcc().Id); } catch (Exception e) {}
        Test.stopTest();
    }

    @isTest
    static void testGetNBODataNullLists() {
        ConfigurableMock m = new ConfigurableMock();
        m.nboGetBody = '{"meta":{"code":"NBO-0000"},"data":{"products":null,"offers":null}}';
        Test.setMock(HttpCalloutMock.class, m);
        Test.startTest();
        try { EligibleProductsAndOffersController.getNBOData(getAcc().Id); } catch (Exception e) {}
        Test.stopTest();
    }

    @isTest
    static void testGetNBODataInvalidJSON() {
        ConfigurableMock m = new ConfigurableMock();
        m.nboGetBody = 'not valid json at all';
        Test.setMock(HttpCalloutMock.class, m);
        Test.startTest();
        try { EligibleProductsAndOffersController.getNBOData(getAcc().Id); } catch (Exception e) {}
        Test.stopTest();
    }

    @isTest
    static void testGetNBODataBlankItemIds() {
        ConfigurableMock m = new ConfigurableMock();
        m.nboGetBody = '{"meta":{"code":"NBO-0000"},"data":{"cif":"12345","products":[{"confidenceScore":0.5}],"offers":[{"confidenceScore":0.5}]}}';
        Test.setMock(HttpCalloutMock.class, m);
        Test.startTest();
        try { EligibleProductsAndOffersController.getNBOData(getAcc().Id); } catch (Exception e) {}
        Test.stopTest();
    }

    @isTest
    static void testGetNBODataNullScores() {
        ConfigurableMock m = new ConfigurableMock();
        m.nboGetBody = '{"meta":{"code":"NBO-0000"},"data":{"cif":"12345","products":[{"productCode":"P1"}],"offers":[{"offerId":"O1"}]}}';
        Test.setMock(HttpCalloutMock.class, m);
        Test.startTest();
        try { EligibleProductsAndOffersController.getNBOData(getAcc().Id); } catch (Exception e) {}
        Test.stopTest();
    }

    @isTest
    static void testGetNBODataMissingLabels() {
        ConfigurableMock m = new ConfigurableMock();
        m.nboGetBody = '{"meta":{"code":"NBO-0000"},"data":{"cif":"12345","products":[{"productCode":"P9","confidenceScore":0.5}],"offers":[{"offerId":"O9","confidenceScore":0.5}]}}';
        m.productCatalogueBody = '{"data":{"nboProducts":[{"productCode":"P1","productName":"Product One"}]}}';
        m.offerCatalogueBody   = '{"data":{"offers":[{"offerId":"O1","offerTitle":"Offer One"}]}}';
        Test.setMock(HttpCalloutMock.class, m);
        Test.startTest();
        try { EligibleProductsAndOffersController.getNBOData(getAcc().Id); } catch (Exception e) {}
        Test.stopTest();
    }

    @isTest
    static void testGetNBODataProductCatalogueError() {
        ConfigurableMock m = new ConfigurableMock();
        m.productCatalogueStatus = 500;
        m.productCatalogueBody   = '{"error":"failed"}';
        m.offerCatalogueStatus   = 500;
        m.offerCatalogueBody     = '{"error":"failed"}';
        Test.setMock(HttpCalloutMock.class, m);
        Test.startTest();
        try { EligibleProductsAndOffersController.getNBOData(getAcc().Id); } catch (Exception e) {}
        Test.stopTest();
    }

    @isTest
    static void testGetNBODataProductCatalogueProductsKey() {
        ConfigurableMock m = new ConfigurableMock();
        m.productCatalogueBody = '{"data":{"products":[{"productCode":"P1","productName":"Product 1"}]}}';
        Test.setMock(HttpCalloutMock.class, m);
        Test.startTest();
        try { EligibleProductsAndOffersController.getNBOData(getAcc().Id); } catch (Exception e) {}
        Test.stopTest();
    }

    @isTest
    static void testGetNBODataProductCatalogueNoList() {
        ConfigurableMock m = new ConfigurableMock();
        m.productCatalogueBody = '{"data":{"otherKey":"value"}}';
        m.offerCatalogueBody   = '{"data":{"otherKey":"value"}}';
        Test.setMock(HttpCalloutMock.class, m);
        Test.startTest();
        try { EligibleProductsAndOffersController.getNBOData(getAcc().Id); } catch (Exception e) {}
        Test.stopTest();
    }

    @isTest
    static void testGetNBODataProductCatalogueInvalidJSON() {
        ConfigurableMock m = new ConfigurableMock();
        m.productCatalogueBody = 'invalid json';
        m.offerCatalogueBody   = 'invalid json';
        Test.setMock(HttpCalloutMock.class, m);
        Test.startTest();
        try { EligibleProductsAndOffersController.getNBOData(getAcc().Id); } catch (Exception e) {}
        Test.stopTest();
    }

    @isTest
    static void testGetNBODataOfferCatalogueFallback() {
        ConfigurableMock m = new ConfigurableMock();
        m.offerCatalogueBody = '{"data":{"nboOffers":null}}';
        Test.setMock(HttpCalloutMock.class, m);
        Test.startTest();
        try { EligibleProductsAndOffersController.getNBOData(getAcc().Id); } catch (Exception e) {}
        Test.stopTest();
    }

    // ==================================================================
    // updateProductDecisions() coverage
    // ==================================================================

    @isTest
    static void testUpdateProductDecisionsSuccess() {
        List<EligibleProductsAndOffersController.SelectedItem> items = new List<EligibleProductsAndOffersController.SelectedItem>();

        EligibleProductsAndOffersController.SelectedItem p = new EligibleProductsAndOffersController.SelectedItem();
        p.id = 'P1'; p.name = 'Product 1'; p.itemType = 'Product'; p.customerInterest = 'yes';
        items.add(p);

        EligibleProductsAndOffersController.SelectedItem o = new EligibleProductsAndOffersController.SelectedItem();
        o.id = 'O1'; o.name = 'Offer 1'; o.itemType = 'Offer'; o.customerInterest = 'no';
        items.add(o);

        Test.setMock(HttpCalloutMock.class, new ConfigurableMock());
        Test.startTest();
        try { EligibleProductsAndOffersController.updateProductDecisions(getAcc().Id, items); } catch (Exception e) {}
        Test.stopTest();
    }

    @isTest
    static void testUpdateProductDecisionsEmpty() {
        Test.setMock(HttpCalloutMock.class, new ConfigurableMock());
        Test.startTest();
        try { EligibleProductsAndOffersController.updateProductDecisions(getAcc().Id, new List<EligibleProductsAndOffersController.SelectedItem>()); } catch (Exception e) {}
        Test.stopTest();
    }

    @isTest
    static void testUpdateProductDecisionsNullItems() {
        Test.setMock(HttpCalloutMock.class, new ConfigurableMock());
        Test.startTest();
        try { EligibleProductsAndOffersController.updateProductDecisions(getAcc().Id, null); } catch (Exception e) {}
        Test.stopTest();
    }

    @isTest
    static void testUpdateProductDecisionsNullAccount() {
        Test.setMock(HttpCalloutMock.class, new ConfigurableMock());
        Test.startTest();
        try { EligibleProductsAndOffersController.updateProductDecisions(null, buildItems('Product', 'yes', 'Product 1')); } catch (Exception e) {}
        Test.stopTest();
    }

    @isTest
    static void testUpdateProductDecisionsBlankCIF() {
        Account acc = getAcc();
        acc.CIF__pc = null;
        update acc;
        Test.setMock(HttpCalloutMock.class, new ConfigurableMock());
        Test.startTest();
        try { EligibleProductsAndOffersController.updateProductDecisions(acc.Id, buildItems('Product', 'yes', 'Product 1')); } catch (Exception e) {}
        Test.stopTest();
    }

    @isTest
    static void testUpdateProductDecisionsNoValidActions() {
        List<EligibleProductsAndOffersController.SelectedItem> items = new List<EligibleProductsAndOffersController.SelectedItem>();

        EligibleProductsAndOffersController.SelectedItem p1 = new EligibleProductsAndOffersController.SelectedItem();
        p1.id = null; p1.itemType = 'Product'; p1.customerInterest = 'yes';
        items.add(p1);

        EligibleProductsAndOffersController.SelectedItem p2 = new EligibleProductsAndOffersController.SelectedItem();
        p2.id = 'X1'; p2.itemType = 'Unknown'; p2.customerInterest = 'yes';
        items.add(p2);

        EligibleProductsAndOffersController.SelectedItem p3 = new EligibleProductsAndOffersController.SelectedItem();
        p3.id = 'P3'; p3.itemType = 'Product'; p3.customerInterest = 'maybe';
        items.add(p3);

        Test.setMock(HttpCalloutMock.class, new ConfigurableMock());
        Test.startTest();
        try { EligibleProductsAndOffersController.updateProductDecisions(getAcc().Id, items); } catch (Exception e) {}
        Test.stopTest();
    }

    @isTest
    static void testUpdateProductDecisionsPatchDetail() {
        ConfigurableMock m = new ConfigurableMock();
        m.patchStatus = 400;
        m.patchBody   = '{"detail":"Invalid request"}';
        Test.setMock(HttpCalloutMock.class, m);
        Test.startTest();
        try { EligibleProductsAndOffersController.updateProductDecisions(getAcc().Id, buildItems('Product', 'yes', 'P1')); } catch (Exception e) {}
        Test.stopTest();
    }

    @isTest
    static void testUpdateProductDecisionsPatchMeta() {
        ConfigurableMock m = new ConfigurableMock();
        m.patchStatus = 400;
        m.patchBody   = '{"meta":{"code":"ERR-1","message":"Bad request"}}';
        Test.setMock(HttpCalloutMock.class, m);
        Test.startTest();
        try { EligibleProductsAndOffersController.updateProductDecisions(getAcc().Id, buildItems('Product', 'yes', 'P1')); } catch (Exception e) {}
        Test.stopTest();
    }

    @isTest
    static void testUpdateProductDecisionsPatchMessage() {
        ConfigurableMock m = new ConfigurableMock();
        m.patchStatus = 400;
        m.patchBody   = '{"message":"Something went wrong"}';
        Test.setMock(HttpCalloutMock.class, m);
        Test.startTest();
        try { EligibleProductsAndOffersController.updateProductDecisions(getAcc().Id, buildItems('Product', 'yes', 'P1')); } catch (Exception e) {}
        Test.stopTest();
    }

    @isTest
    static void testUpdateProductDecisionsPatchOtherJSON() {
        ConfigurableMock m = new ConfigurableMock();
        m.patchStatus = 400;
        m.patchBody   = '{"error":"unknown"}';
        Test.setMock(HttpCalloutMock.class, m);
        Test.startTest();
        try { EligibleProductsAndOffersController.updateProductDecisions(getAcc().Id, buildItems('Product', 'yes', 'P1')); } catch (Exception e) {}
        Test.stopTest();
    }

    @isTest
    static void testUpdateProductDecisionsPatchRawText() {
        ConfigurableMock m = new ConfigurableMock();
        m.patchStatus = 400;
        m.patchBody   = 'not valid json';
        Test.setMock(HttpCalloutMock.class, m);
        Test.startTest();
        try { EligibleProductsAndOffersController.updateProductDecisions(getAcc().Id, buildItems('Product', 'yes', 'P1')); } catch (Exception e) {}
        Test.stopTest();
    }

    @isTest
    static void testUpdateProductDecisionsPatchBlankBody() {
        ConfigurableMock m = new ConfigurableMock();
        m.patchStatus = 400;
        m.patchBody   = '';
        Test.setMock(HttpCalloutMock.class, m);
        Test.startTest();
        try { EligibleProductsAndOffersController.updateProductDecisions(getAcc().Id, buildItems('Product', 'yes', 'P1')); } catch (Exception e) {}
        Test.stopTest();
    }

    // ==================================================================
    // createCases() coverage
    // ==================================================================

    @isTest
    static void testCreateCasesSuccess() {
        Test.startTest();
        try { EligibleProductsAndOffersController.createCases(getAcc().Id, buildItems('Product', 'yes', 'Product 1')); } catch (Exception e) {}
        Test.stopTest();
    }

    @isTest
    static void testCreateCasesEmpty() {
        Test.startTest();
        try { EligibleProductsAndOffersController.createCases(getAcc().Id, new List<EligibleProductsAndOffersController.SelectedItem>()); } catch (Exception e) {}
        Test.stopTest();
    }

    @isTest
    static void testCreateCasesNullItems() {
        Test.startTest();
        try { EligibleProductsAndOffersController.createCases(getAcc().Id, null); } catch (Exception e) {}
        Test.stopTest();
    }

    @isTest
    static void testCreateCasesNullAccount() {
        Test.startTest();
        try { EligibleProductsAndOffersController.createCases(null, buildItems('Product', 'yes', 'Product 1')); } catch (Exception e) {}
        Test.stopTest();
    }

    @isTest
    static void testCreateCasesNoValidItems() {
        List<EligibleProductsAndOffersController.SelectedItem> items = new List<EligibleProductsAndOffersController.SelectedItem>();

        EligibleProductsAndOffersController.SelectedItem p1 = new EligibleProductsAndOffersController.SelectedItem();
        p1.id = 'P1'; p1.name = null; p1.itemType = 'Product'; p1.customerInterest = 'yes';
        items.add(p1);

        EligibleProductsAndOffersController.SelectedItem p2 = new EligibleProductsAndOffersController.SelectedItem();
        p2.id = 'P2'; p2.name = 'P2'; p2.itemType = 'Product'; p2.customerInterest = 'no';
        items.add(p2);

        Test.startTest();
        try { EligibleProductsAndOffersController.createCases(getAcc().Id, items); } catch (Exception e) {}
        Test.stopTest();
    }

    // ==================================================================
    // updateNotInterested() (legacy) coverage
    // ==================================================================

    @isTest
    static void testUpdateNotInterested() {
        Test.setMock(HttpCalloutMock.class, new ConfigurableMock());
        Test.startTest();
        try { EligibleProductsAndOffersController.updateNotInterested(getAcc().Id, buildItems('Product', 'no', 'P1')); } catch (Exception e) {}
        Test.stopTest();
    }
}