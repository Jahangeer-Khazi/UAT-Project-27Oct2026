public with sharing class FeedCommentDeleteGuard {
    public static void preventDeletingOthersComments(List<FeedComment> comments) {
        // Admins/moderators who should keep the ability get this custom permission
        if (FeatureManagement.checkPermission('Bypass_FeedComment_Restriction')) {
            return;
        }
        Id currentUserId = UserInfo.getUserId();
        for (FeedComment fc : comments) {
            System.debug(fc.CreatedById);
            System.debug(currentUserId);
            if (fc.CreatedById != currentUserId) {
                fc.addError('You can only Edit/delete comments that you posted.');
            }
        }
    }
}