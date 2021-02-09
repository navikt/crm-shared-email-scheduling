@isTest
private without sharing class EmailQueueJobHelper_test {
    // 10 emails, 0 fail
    // ------------------------------

    @isTest
    private static void testSendEmail() {
        EmailQueueData_test.createData(10, null, false); // create test data
        EmailQueueData data = new EmailQueueData('Queued'); // fetch data

        Test.StartTest();
        List<Messaging.SendEmailResult> emailResults = EmailQueueJobHelper.sendEmail(
            data.getEmailQueues(),
            null
        );
        Test.StopTest();

        System.assertEquals(10, emailResults.size(), '10 records, 10 emails');
        for (Messaging.SendEmailResult emailResult : emailResults) {
            System.assert(
                emailResult.isSuccess(),
                'All emails should have been sent successfully'
            );
        }
    }

    @isTest
    private static void testUpdateEmailQueues() {
        EmailQueueData_test.createData(10, null, false); // create test data
        EmailQueueData data = new EmailQueueData('Queued'); // fetch data
        List<Messaging.SendEmailResult> emailResults = EmailQueueJobHelper.sendEmail(
            data.getEmailQueues(),
            null
        );

        Test.StartTest();
        EmailQueueJobHelper.updateEmailQueues(
            data.getEmailQueues(),
            emailResults
        );
        Test.StopTest();

        System.assertEquals(
            10,
            [SELECT Id FROM EmailQueue__c WHERE Status__c = 'Sent'].size(),
            'EmailQueue__c status should have been updated to "Sent"'
        );
        System.assertEquals(
            0,
            [SELECT Id FROM EmailQueue__c WHERE Status__c = 'Queued'].size(),
            'no more EmailQueue__c records with status "Queued"'
        );
    }

    // 11 emails, 1 fail
    // ------------------------------

    @isTest
    private static void testSendEmail_oneError() {
        EmailQueueData_test.createData(16, null, false); // create test data
        EmailQueueData data = new EmailQueueData('Queued'); // fetch data

        Test.StartTest();
        List<Messaging.SendEmailResult> emailResults = EmailQueueJobHelper.sendEmail(
            data.getEmailQueues(),
            null
        );
        Test.StopTest();

        System.assertEquals(16, emailResults.size(), '16 records, 16 emails');
        for (Integer i = 0; i < emailResults.size() - 1; i++) {
            System.assert(
                emailResults[i].isSuccess(),
                'All emails but the last should have been sent successfully'
            );
        }
        System.assert(
            !emailResults[emailResults.size() - 1].isSuccess(),
            'Last email should have an error'
        );
        System.assertEquals(
            'Email limit exceeded',
            emailResults[15].getErrors()[0].getMessage(),
            'Last email have exceeded email limit'
        );
    }

    @isTest
    private static void testUpdateEmailQueues_oneError() {
        EmailQueueData_test.createData(16, null, false); // create test data
        EmailQueueData data = new EmailQueueData('Queued'); // fetch data
        List<Messaging.SendEmailResult> emailResults = EmailQueueJobHelper.sendEmail(
            data.getEmailQueues(),
            null
        );

        Test.StartTest();
        EmailQueueJobHelper.updateEmailQueues(
            data.getEmailQueues(),
            emailResults
        );
        Test.StopTest();

        System.assertEquals(
            15,
            [SELECT Id FROM EmailQueue__c WHERE Status__c = 'Sent'].size(),
            'EmailQueue__c status should have been updated to "Sent"'
        );
        System.assertEquals(
            0,
            [SELECT Id FROM EmailQueue__c WHERE Status__c = 'Queued'].size(),
            'no more EmailQueue__c records with status "Queued"'
        );
        System.assertEquals(
            1,
            [SELECT Id FROM EmailQueue__c WHERE Status__c = 'Error'].size(),
            'one EmailQueue__c record with status "Error"'
        );
    }

    // non-equal lists of emails and results
    // ------------------------------

    @isTest
    private static void testUpdateEmailQueues_sizeMismatch() {
        EmailQueueData_test.createData(16, null, false); // create test data
        EmailQueueData data = new EmailQueueData('Queued'); // fetch data
        List<Messaging.SendEmailResult> emailResults = EmailQueueJobHelper.sendEmail(
            data.getEmailQueues(),
            null
        );
        emailResults.remove(1);

        Test.StartTest();
        EmailQueueJobHelper.updateEmailQueues(
            data.getEmailQueues(),
            emailResults
        );
        Test.StopTest();

        System.assertEquals(
            0,
            [SELECT Id FROM EmailQueue__c WHERE Status__c = 'Sent'].size(),
            'EmailQueue__c status should have been updated to "Sent"'
        );
        System.assertEquals(
            0,
            [SELECT Id FROM EmailQueue__c WHERE Status__c = 'Queued'].size(),
            'no more EmailQueue__c records with status "Queued"'
        );
        System.assertEquals(
            16,
            [SELECT Id FROM EmailQueue__c WHERE Status__c = 'Error'].size(),
            'one EmailQueue__c record with status "Error"'
        );
    }

    @isTest
    private static void testUpdateEmailQueueSettings() {
        insert new EmailQueueSettings__c(
            AmountSentToday__c = 245,
            ResetDate__c = Date.today()
        );

        List<EmailQueue__c> emailQueues = new List<EmailQueue__c>();
        for (Integer i = 0; i < 5; i++) {
            emailQueues.add(new EmailQueue__c());
        }

        Test.StartTest();
        EmailQueueJobHelper.updateEmailQueueSettings(emailQueues);
        Test.StopTest();

        List<EmailQueueSettings__c> settings = [
            SELECT Id, AmountSentToday__c
            FROM EmailQueueSettings__c
            WHERE LastModifiedDate = TODAY
        ];
        System.assertEquals(1, settings.size(), 'should be settings for today');
        System.assertEquals(
            250,
            settings[0].AmountSentToday__c,
            'should be settings for today'
        );
    }

    @isTest
    private static void testUpdateEmailQueueSettings_updatedPreviousDay() {
        insert new EmailQueueSettings__c(
            AmountSentToday__c = 245,
            ResetDate__c = Date.today().addDays(-1)
        );

        List<EmailQueueSettings__c> settings = [
            SELECT Id, ResetDate__c, AmountSentToday__c
            FROM EmailQueueSettings__c
            WHERE LastModifiedDate = TODAY
        ];
        System.assertEquals(
            245,
            settings[0].AmountSentToday__c,
            'should be settings for today'
        );
        System.assertEquals(
            Date.today().addDays(-1),
            settings[0].ResetDate__c,
            'should be settings for today'
        );

        List<EmailQueue__c> emailQueues = new List<EmailQueue__c>();
        for (Integer i = 0; i < 5; i++) {
            emailQueues.add(new EmailQueue__c());
        }

        Test.StartTest();
        EmailQueueJobHelper.updateEmailQueueSettings(emailQueues);
        Test.StopTest();

        settings = [
            SELECT Id, ResetDate__c, AmountSentToday__c
            FROM EmailQueueSettings__c
            WHERE LastModifiedDate = TODAY
        ];
        System.assertEquals(1, settings.size(), 'should be settings for today');
        System.assertEquals(
            5,
            settings[0].AmountSentToday__c,
            'should be settings for today'
        );
        System.assertEquals(
            Date.today(),
            settings[0].ResetDate__c,
            'should be settings for today'
        );
    }

    @isTest
    private static void testUpdateEmailQueueSettings_empty() {
        List<EmailQueue__c> emailQueues = new List<EmailQueue__c>();
        for (Integer i = 0; i < 5; i++) {
            emailQueues.add(new EmailQueue__c());
        }

        Test.StartTest();
        EmailQueueJobHelper.updateEmailQueueSettings(emailQueues);
        Test.StopTest();

        List<EmailQueueSettings__c> settings = [
            SELECT Id, AmountSentToday__c
            FROM EmailQueueSettings__c
            WHERE LastModifiedDate = TODAY
        ];
        System.assertEquals(1, settings.size(), 'should be settings for today');
        System.assertEquals(
            5,
            settings[0].AmountSentToday__c,
            'should be settings for today'
        );
    }
}
