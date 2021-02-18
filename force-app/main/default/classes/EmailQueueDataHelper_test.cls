@isTest
private without sharing class EmailQueueDataHelper_test {
    @isTest
    private static void testCalculateEmailLimit() {
        Test.StartTest();
        Integer result = EmailQueueDataHelper.calculateEmailLimit();
        Test.StopTest();

        System.assertEquals(1000, result, 'nothing sent yet, so full limit');
    }

    @isTest
    private static void testCalculateEmailLimit_overLimit() {
        insert new EmailQueueSettings__c(AmountSentToday__c = 4995, ResetDate__c = Date.today());

        Test.StartTest();
        Integer result = EmailQueueDataHelper.calculateEmailLimit();
        Test.StopTest();

        System.assertEquals(5, result, '4995 sent, so 5 limit');
    }

    @isTest
    private static void testCalculateEmailLimit_empty() {
        insert new EmailQueueSettings__c(AmountSentToday__c = 5000, ResetDate__c = Date.today());

        Test.StartTest();
        Integer result = EmailQueueDataHelper.calculateEmailLimit();
        Test.StopTest();

        System.assertEquals(0, result, '5000 sent, so no emails for you ☝️');
    }

    @isTest
    private static void testCalculateEmailLimit_exact() {
        insert new EmailQueueSettings__c(AmountSentToday__c = 4000, ResetDate__c = Date.today());

        Test.StartTest();
        Integer result = EmailQueueDataHelper.calculateEmailLimit();
        Test.StopTest();

        System.assertEquals(1000, result, '4000 sent, so 1000 limit');
    }

    @isTest
    private static void testFetchEmailQueues_status() {
        EmailQueueData_test.createData(5, null, true); // create test data

        Test.StartTest();
        List<EmailQueue__c> results = EmailQueueDataHelper.fetchEmailQueues('Queued', 5);
        Test.StopTest();

        System.assertEquals(5, results.size(), 'queried for 5, got 5');
    }

    @isTest
    private static void testFetchEmailQueues_exact() {
        EmailQueueData_test.createData(5, null, true); // create test data
        List<EmailQueue__c> emailQueue = [SELECT Id FROM EmailQueue__c];
        for (EmailQueue__c queue : emailQueue) {
            queue.Status__c = 'Instant';
        }

        List<EmailQueue__c> emailQueues = [SELECT Id FROM EmailQueue__c];

        System.assertEquals(5, [SELECT Id FROM EmailQueue__c].size(), '5 emails in queue');

        List<EmailQueue__c> results = EmailQueueDataHelper.fetchEmailQueues(EmailQueues, 5);
        Test.StartTest();
        Test.StopTest();

        System.assertEquals(5, [SELECT Id FROM EmailQueue__c].size(), '5 emails in queue');
        System.assertEquals(
            5,
            [SELECT Id FROM EmailQueue__c WHERE Status__c = 'Queued'].size(),
            'no more EmailQueue__c records with status "Queued"'
        );
        System.assertEquals(5, results.size(), 'queried for 5, got 5');
    }

    @isTest
    private static void testFetchEmailQueues_recordsLess() {
        EmailQueueData_test.createData(5, null, true); // create test data
        List<EmailQueue__c> emailQueue = [SELECT Id FROM EmailQueue__c];
        for (EmailQueue__c queue : emailQueue) {
            queue.Status__c = 'Instant';
        }
        List<EmailQueue__c> emailQueues = [SELECT Id FROM EmailQueue__c];

        Test.StartTest();
        List<EmailQueue__c> results = EmailQueueDataHelper.fetchEmailQueues(EmailQueues, 7);
        Test.StopTest();

        System.assertEquals(5, results.size(), 'queried for 5, got 5');
    }

    @isTest
    private static void testFetchEmailQueues_MoreThanAllowed() {
        EmailQueueData_test.createData(10, null, true); // create test data
        List<EmailQueue__c> emailQueue = [SELECT Id FROM EmailQueue__c];
        for (EmailQueue__c queue : emailQueue) {
            queue.Status__c = 'Error'; // for testing purposes, instant would cause them to be sent by trigger
        }
        update emailQueue;

        System.assertEquals(10, [SELECT Id FROM EmailQueue__c].size(), '5 emails in queue');

        Test.StartTest();
        List<EmailQueue__c> results = EmailQueueDataHelper.fetchEmailQueues(EmailQueue, 5);
        Test.StopTest();

        System.assertEquals(10, [SELECT Id FROM EmailQueue__c].size(), '5 emails in queue');
        System.assertEquals(
            5,
            [SELECT Id FROM EmailQueue__c WHERE Status__c = 'Queued'].size(),
            'no more EmailQueue__c records with status "Queued"'
        );
        System.assertEquals(
            5,
            [SELECT Id FROM EmailQueue__c WHERE Status__c = 'Error'].size(),
            'no more EmailQueue__c records with status "Queued"'
        );
    }

    @isTest
    private static void testSeparateEmailQueues() {
        EmailQueueData_test.createData(5, null, true); // create test data
        List<EmailQueue__c> emailQueues = EmailQueueDataHelper.fetchEmailQueues('Queued ', 5);

        Test.StartTest();
        List<List<EmailQueue__c>> results = EmailQueueDataHelper.separateEmailQueues(emailQueues);
        Test.StopTest();
    }

    @isTest
    private static void testSeparateEmailQueues_empty() {
        EmailQueueData_test.createData(5, null, true); // create test data
        List<EmailQueue__c> emailQueues = EmailQueueDataHelper.fetchEmailQueues('Queued', 5);

        Test.StartTest();
        List<List<EmailQueue__c>> results = EmailQueueDataHelper.separateEmailQueues(emailQueues);
        Test.StopTest();
    }

    @isTest
    private static void testSeparateEmailQueues_null() {
        EmailQueueData_test.createData(5, null, true); // create test data
        List<EmailQueue__c> emailQueues = EmailQueueDataHelper.fetchEmailQueues('Queued', 5);

        Test.StartTest();
        List<List<EmailQueue__c>> results = EmailQueueDataHelper.separateEmailQueues(emailQueues);
        Test.StopTest();
    }
}
