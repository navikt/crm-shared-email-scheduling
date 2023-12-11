@isTest
private without sharing class EmailQueueScheduler_test {
    @TestSetup
    static void makeData() {
        EmailQueueData_test.createData(48, null, false);
    }

    @isTest
    private static void testSchedule() {
        Test.StartTest();
        String CRON_EXP = '0 0 0 3 9 ? 2024';
        System.schedule('EmailQueueSchedulerTest', CRON_EXP, new EmailQueueScheduler());
        Test.StopTest();

        // ! no tests, as queueable is not possible to run inside scheduled class
        // ! full tests are performed in EmailQueueJobTest
    }

    @isTest
    private static void testSettingsTrackers() {
        Test.StartTest();
        String CRON_EXP = '0 0 0 3 9 ? 2024';
        System.schedule('EmailQueueSchedulerTest', CRON_EXP, new EmailQueueScheduler());
        Test.StopTest();

        List<EmailQueueSettings__c> settings = [
            SELECT Id, AmountSentToday__c
            FROM EmailQueueSettings__c
            WHERE LastModifiedDate = TODAY
        ];
        System.assertEquals(1, settings.size(), 'should be settings for today');
        System.assertEquals(48, settings[0].AmountSentToday__c, 'should be settings for today');
    }

    @isTest
    private static void testGetJobStatus() {
        Test.StartTest();
        List<Id> jobIds = EmailQueueScheduler.processEmailQueue('Queued');
        Test.StopTest();

        System.assertEquals(1, jobIds.size(), 'should only be one batch, and one job');

        Integer finishedJobs = EmailQueueScheduler.getJobStatus(jobIds);

        System.assertEquals(1, finishedJobs, 'should only be one batch, and one job which should be finished');
    }
}
