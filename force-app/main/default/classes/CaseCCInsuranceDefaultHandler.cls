public without sharing class CaseCCInsuranceDefaultHandler {

    private static final String CONFIG_DEV_NAME = 'Default';
    private static final Decimal DEFAULT_AGE_THRESHOLD = 65;
    private static final Decimal DEFAULT_CREDIT_LIMIT_THRESHOLD = 25000;
    private static final String DEFAULT_EXCLUDED_SEGMENTS = 'Staff';

    public static void setDefaultCCInsurance(List<Case> newCases) {
        setDefaultCCInsurance(newCases, null);
    }

    public static void setDefaultCCInsurance(List<Case> newCases, Map<Id, Case> oldMap) {
        if (newCases == null || newCases.isEmpty()) {
            return;
        }

        Set<Id> accountIds = new Set<Id>();

        for (Case c : newCases) {
            Case oldCase = oldMap == null ? null : oldMap.get(c.Id);

            if (shouldRecalculate(c, oldCase) && c.AccountId != null) {
                accountIds.add(c.AccountId);
            }
        }

        Map<Id, Account> accountMap = new Map<Id, Account>();

        if (!accountIds.isEmpty()) {
            accountMap = new Map<Id, Account>([
                SELECT Id, Segment__pc, Age__pc
                FROM Account
                WHERE Id IN :accountIds
            ]);
        }

        Config config = getConfig();

        for (Case c : newCases) {
            Case oldCase = oldMap == null ? null : oldMap.get(c.Id);

            if (!shouldRecalculate(c, oldCase)) {
                continue;
            }

            Account customer = c.AccountId == null ? null : accountMap.get(c.AccountId);

            c.Interest_Option_CC_Insured__c = isEligible(c, customer, config);
        }
    }

    private static Boolean shouldRecalculate(Case c, Case oldCase) {

        if (oldCase == null) {
            return true;   // Before Insert / no old record
        }
       
        return c.AccountId != oldCase.AccountId
            || c.cc_Requested_Credit_Limit__c != oldCase.cc_Requested_Credit_Limit__c;
    }

    private static Boolean isEligible(Case c, Account customer, Config config) {
    if (customer == null) {
        System.debug(LoggingLevel.ERROR, '❌ Customer (Account) is NULL for Case: ' + c.Id);
        return false;
    }

    String segment = customer.Segment__pc;
    Decimal age = customer.Age__pc;
    Decimal requestedLimit = c.cc_Requested_Credit_Limit__c;

    System.debug(LoggingLevel.ERROR, '🔍 CHECKING CASE: ' + c.Id);
    System.debug(LoggingLevel.ERROR, '👉 Data -> Segment: "' + segment + '", Age: ' + age + ', Limit: ' + requestedLimit);
    System.debug(LoggingLevel.ERROR, '👉 Config -> Thresholds (Age: ' + config.ageThreshold + ', Limit: ' + config.creditLimitThreshold + '), Excluded: ' + config.excludedSegments);

    if (String.isBlank(segment)) {
        System.debug(LoggingLevel.ERROR, '❌ FAILED: Segment is blank/null.');
        return false;
    }

    if (config.excludedSegments.contains(segment.trim().toLowerCase())) {
        System.debug(LoggingLevel.ERROR, '❌ FAILED: Segment "' + segment + '" is in the excluded list.');
        return false;
    }

    if (age == null || age > config.ageThreshold) {
        System.debug(LoggingLevel.ERROR, '❌ FAILED: Age is null or > ' + config.ageThreshold);
        return false;
    }

    if (requestedLimit == null || requestedLimit > config.creditLimitThreshold) {
        System.debug(LoggingLevel.ERROR, '❌ FAILED: Limit is null or > ' + config.creditLimitThreshold);
        return false;
    }

    System.debug(LoggingLevel.ERROR, '✅ SUCCESS: Case is Eligible!');
    return true;
}

    private static Config getConfig() {
        Config config = new Config();
        config.ageThreshold = DEFAULT_AGE_THRESHOLD;
        config.creditLimitThreshold = DEFAULT_CREDIT_LIMIT_THRESHOLD;
        config.excludedSegments = new Set<String>{ DEFAULT_EXCLUDED_SEGMENTS.toLowerCase() };

        CC_Insurance_Default_Config__mdt md =
            CC_Insurance_Default_Config__mdt.getInstance(CONFIG_DEV_NAME);

        if (md != null) {
            if (md.Age_Threshold__c != null) {
                config.ageThreshold = md.Age_Threshold__c;
            }

            if (md.Credit_Limit_Threshold__c != null) {
                config.creditLimitThreshold = md.Credit_Limit_Threshold__c;
            }

            if (String.isNotBlank(md.Excluded_Segments__c)) {
                config.excludedSegments = new Set<String>();

                for (String s : md.Excluded_Segments__c.split(',')) {
                    if (String.isNotBlank(s)) {
                        config.excludedSegments.add(s.trim().toLowerCase());
                    }
                }
            }
        }

        return config;
    }

    private class Config {
        Decimal ageThreshold;
        Decimal creditLimitThreshold;
        Set<String> excludedSegments;
    }
}