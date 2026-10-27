public with sharing class CaseInsuranceWarningController {

    private static final String CONFIG_DEV_NAME = 'Default';
    private static final Decimal DEFAULT_AGE_THRESHOLD = 65;
    private static final Decimal DEFAULT_CREDIT_LIMIT_THRESHOLD = 25000;
    private static final String DEFAULT_EXCLUDED_SEGMENTS = 'Staff';

    @AuraEnabled(cacheable=true)
    public static Result checkEligibility(Id caseId) {
        Result result = new Result();
        result.showWarning = false;
        result.warningMessage = 'Customer not eligible for Insurance. Please route the case to Contact center until Approval received.';

        if (caseId == null) {
            return result;
        }

        List<Case> cases = [
            SELECT Id,
                   AccountId,
                   cc_Approved_Credit_Limit__c,
                   Account.Segment__pc,
                   Account.Age__pc
            FROM Case
            WHERE Id = :caseId
            LIMIT 1
        ];

        if (cases.isEmpty()) {
            return result;
        }

        Case c = cases[0];
        Config config = getConfig();

        String segment = c.Account != null ? c.Account.Segment__pc : null;
        Decimal age    = c.Account != null ? c.Account.Age__pc : null;
        Decimal creditLimit  = c.cc_Approved_Credit_Limit__c;

        // Skip warning for excluded segments (e.g. Staff)
        if (String.isNotBlank(segment)
            && config.excludedSegments.contains(segment.trim().toLowerCase())) {
            return result;
        }

        Boolean ageExceeds   = age   != null && age   > config.ageThreshold;
        Boolean limitExceeds = creditLimit != null && creditLimit > config.creditLimitThreshold;

        if (ageExceeds || limitExceeds) {
    result.showWarning = true;

    String ageThresholdStr   = config.ageThreshold.stripTrailingZeros().toPlainString();
    String creditLimitStr    = config.creditLimitThreshold.stripTrailingZeros().toPlainString();

    List<String> reasons = new List<String>();
    if (ageExceeds) {
        reasons.add('Customer age exceeds ' + ageThresholdStr);
    }
    if (limitExceeds) {
        reasons.add('Credit limit is above ' + creditLimitStr);
    }

    result.warningMessage = String.join(reasons, ' and ')
        + '. Insurance flag has been automatically unchecked as Customer not eligible for Insurance.'
        + ' Please route the case to Contact center until Approval received.';
}

        return result;
    }

    private static Config getConfig() {
        Config config = new Config();
        config.ageThreshold          = DEFAULT_AGE_THRESHOLD;
        config.creditLimitThreshold  = DEFAULT_CREDIT_LIMIT_THRESHOLD;
        config.excludedSegments      = new Set<String>{ DEFAULT_EXCLUDED_SEGMENTS.toLowerCase() };

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

    public class Result {
        @AuraEnabled public Boolean showWarning;
        @AuraEnabled public String  warningMessage;
    }

    private class Config {
        Decimal ageThreshold;
        Decimal creditLimitThreshold;
        Set<String> excludedSegments;
    }
}