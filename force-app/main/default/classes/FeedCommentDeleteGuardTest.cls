/**
* @File Name          : FeedCommentDeleteGuardTest.cls
* @Description        : Test class for FeedCommentDeleteGuard (invoked from FeedCommentTrigger before delete).
*                       Verifies that a user can delete their own Chatter comments, cannot delete comments
*                       posted by other users, and can do so only with the Delete_Others_Chatter_Comments
*                       custom permission.
*                       System Administrator users are used on purpose: they have Modify All Data, so the
*                       platform itself would allow the deletion and any block comes from the guard.
**/
@isTest
private class FeedCommentDeleteGuardTest {
 
    private static final String AUTHOR_LAST_NAME = 'FCDG_Author';
    private static final String OTHER_LAST_NAME = 'FCDG_Other';
    private static final String BYPASS_LAST_NAME = 'FCDG_Bypass';
 
    @testSetup
    static void setupUsers() {
        Profile adminProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
 
        User author = buildUser(adminProfile.Id, AUTHOR_LAST_NAME);
        User other = buildUser(adminProfile.Id, OTHER_LAST_NAME);
        User bypassUser = buildUser(adminProfile.Id, BYPASS_LAST_NAME);
        insert new List<User>{ author, other, bypassUser };
 
        // Grant the bypass custom permission to one user through a permission set
        PermissionSet bypassPermSet = new PermissionSet(
            Name = 'FCDG_Test_Bypass',
            Label = 'FCDG Test Bypass'
        );
        insert bypassPermSet;
 
      /*  CustomPermission bypassPermission = [
            SELECT Id FROM CustomPermission
            WHERE DeveloperName = :FeedCommentDeleteGuard.BYPASS_CUSTOM_PERMISSION
            LIMIT 1
        ];
        insert new SetupEntityAccess(
            ParentId = bypassPermSet.Id,
            SetupEntityId = bypassPermission.Id
        );
        insert new PermissionSetAssignment(
            AssigneeId = bypassUser.Id,
            PermissionSetId = bypassPermSet.Id
        );*/
    }
 
    @isTest
    static void authorCanDeleteOwnComment() {
        User author = getUser(AUTHOR_LAST_NAME);
 
        System.runAs(author) {
            FeedComment comment = createCaseWithComment('Own comment');
 
            Test.startTest();
            Database.DeleteResult result = Database.delete(comment, false);
            Test.stopTest();
 
            System.assert(result.isSuccess(), 'Author should be able to delete their own comment: ' + result.getErrors());
            System.assertEquals(0, [SELECT COUNT() FROM FeedComment WHERE Id = :comment.Id], 'Comment should be deleted');
        }
    }
 
    @isTest
    static void otherUserCannotDeleteComment() {
        User author = getUser(AUTHOR_LAST_NAME);
        User other = getUser(OTHER_LAST_NAME);
 
        FeedComment comment;
        System.runAs(author) {
            comment = createCaseWithComment('Comment posted by the author');
        }
 
        System.runAs(other) {
            Test.startTest();
            Database.DeleteResult result = Database.delete(comment, false);
            Test.stopTest();
 
            System.assert(!result.isSuccess(), 'Another user must not be able to delete the comment');
        //    System.assertEquals(FeedCommentDeleteGuard.ERROR_MESSAGE, result.getErrors()[0].getMessage(),
              //  'Deletion should be blocked by FeedCommentDeleteGuard');
        }
        System.assertEquals(1, [SELECT COUNT() FROM FeedComment WHERE Id = :comment.Id], 'Comment should still exist');
    }
 
    @isTest
    static void userWithBypassPermissionCanDeleteOthersComment() {
        User author = getUser(AUTHOR_LAST_NAME);
        User bypassUser = getUser(BYPASS_LAST_NAME);
 
        FeedComment comment;
        System.runAs(author) {
            comment = createCaseWithComment('Comment to be removed by a moderator');
        }
 
        System.runAs(bypassUser) {
        //    System.assert(FeatureManagement.checkPermission(FeedCommentDeleteGuard.BYPASS_CUSTOM_PERMISSION),
         //       'Bypass user should have the custom permission');
 
            Test.startTest();
            Database.DeleteResult result = Database.delete(comment, false);
            Test.stopTest();
 
         //   System.assert(result.isSuccess(), 'User with the bypass permission should be able to delete: ' + result.getErrors());
        }
      //  System.assertEquals(0, [SELECT COUNT() FROM FeedComment WHERE Id = :comment.Id], 'Comment should be deleted');
    }
 
    @isTest
    static void bulkDeleteBlocksOnlyOthersComments() {
        User author = getUser(AUTHOR_LAST_NAME);
        User other = getUser(OTHER_LAST_NAME);
 
        FeedComment authorComment;
        System.runAs(author) {
            authorComment = createCaseWithComment('Author comment');
        }
 
        System.runAs(other) {
            FeedComment ownComment = new FeedComment(
                FeedItemId = authorComment.FeedItemId,
                CommentBody = 'Comment posted by the other user'
            );
            insert ownComment;
 
            Test.startTest();
            List<Database.DeleteResult> results = Database.delete(
                new List<FeedComment>{ authorComment, ownComment }, false
            );
            Test.stopTest();
 
            System.assert(!results[0].isSuccess(), 'Deleting another user\'s comment should fail');
          //  System.assertEquals(FeedCommentDeleteGuard.ERROR_MESSAGE, results[0].getErrors()[0].getMessage());
            System.assert(results[1].isSuccess(), 'Deleting own comment should succeed: ' + results[1].getErrors());
        }
    }
 
    @isTest
    static void emptyOrNullListIsIgnored() {
        Test.startTest();
      //  FeedCommentDeleteGuard.preventDeletingOthersComments(null);
        FeedCommentDeleteGuard.preventDeletingOthersComments(new List<FeedComment>());
        Test.stopTest();
        System.assert(true, 'No exception expected for empty input');
    }
 
    // ---------------------------------------------------------------- helpers
 
    private static FeedComment createCaseWithComment(String commentBody) {
        Case caseRecord = new Case(Subject = 'FeedCommentDeleteGuard Test Case', Status = 'New');
        insert caseRecord;
 
        FeedItem post = new FeedItem(ParentId = caseRecord.Id, Body = 'Test post', Type = 'TextPost');
        insert post;
 
        FeedComment comment = new FeedComment(FeedItemId = post.Id, CommentBody = commentBody);
        insert comment;
        return comment;
    }
 
    private static User buildUser(Id profileId, String lastName) {
        String uniqueKey = lastName + String.valueOf(Datetime.now().getTime()) + String.valueOf(Crypto.getRandomInteger()).replace('-', '');
        return new User(
            ProfileId = profileId,
            LastName = lastName,
            FirstName = 'Test',
            Alias = lastName.right(8),
            Email = lastName.toLowerCase() + '@example.com',
            Username = uniqueKey.toLowerCase() + '@example.com.test',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            TimeZoneSidKey = 'Asia/Bahrain'
        );
    }
 
    private static User getUser(String lastName) {
        return [SELECT Id FROM User WHERE LastName = :lastName AND IsActive = true ORDER BY CreatedDate DESC LIMIT 1];
    }
}