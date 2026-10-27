trigger FeedCommentTrigger on FeedComment (after insert, after update, before delete, before update) {
    Set<Id> feedItemIds = new Set<Id>();
    Boolean RestrictFeedCommentEdit = Boolean.valueOf(System.Label.FeedCommentAccess);
       
    if (Trigger.isBefore) {
        if (Trigger.isDelete && RestrictFeedCommentEdit){
             FeedCommentDeleteGuard.preventDeletingOthersComments(Trigger.old);
        } 
        if(Trigger.isUpdate && RestrictFeedCommentEdit){
            system.debug('inside3');
             FeedCommentDeleteGuard.preventDeletingOthersComments(Trigger.new);
        }
       
        return;
    } 
    for (FeedComment feedComment : Trigger.new) {
        feedItemIds.add(feedComment.FeedItemId);
    }

    
    Map<Id, FeedItem> feedItemMap = new Map<Id, FeedItem>(
        [SELECT Id, ParentId FROM FeedItem WHERE Id IN :feedItemIds]
    );
    
    Set<Id> caseIds = new Set<Id>();
    for (FeedItem feedItem : feedItemMap.values()) {
        if (feedItem.ParentId.getSObjectType() == Case.sObjectType) {
            caseIds.add(feedItem.ParentId);
        }
    }
    
    if (!caseIds.isEmpty()) {
        List<Case> caseRecords = [SELECT Id, Recent_Updates__c FROM Case WHERE Id IN :caseIds];
        for (Case caseRec : caseRecords) {
            caseRec.Recent_Updates__c = true;
        }
        update caseRecords;
    }
}