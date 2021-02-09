@isTest
public without sharing class EmailQueueData_test {
    @isTest
    private static void testGetEmailQueues_queued() {
        createData(48, null, false);

        Test.StartTest();
        EmailQueueData data = new EmailQueueData('Queued');
        List<EmailQueue__c> results = data.getEmailQueues();
        Test.StopTest();

        System.assertEquals(
            48,
            results.size(),
            '48 emails should have been fetched'
        );
    }

    @isTest
    private static void testGetEmailQueues_error() {
        createData(48, null, false);

        Test.StartTest();
        EmailQueueData data = new EmailQueueData('Error');
        List<EmailQueue__c> results = data.getEmailQueues();
        Test.StopTest();

        System.assertEquals(
            0,
            results.size(),
            '0 emails should have been fetched'
        );
    }

    @isTest
    private static void testGetEmailQueues_noInstant() {
        createData(48, null, false);

        Test.StartTest();
        EmailQueueData data = new EmailQueueData('Instant');
        List<EmailQueue__c> results = data.getEmailQueues();
        Test.StopTest();

        System.assertEquals(
            0,
            results.size(),
            '0 emails should have been fetched'
        );
    }

    @isTest
    private static void testGetEmailQueues_Instant() {
        createData(48, null, false);

        List<EmailQueue__c> emailQueue = [SELECT Id FROM EmailQueue__c];
        for (EmailQueue__c queue : emailQueue) {
            queue.Status__c = 'Instant';
        }
        update emailQueue;

        Test.StartTest();
        EmailQueueData data = new EmailQueueData('Instant');
        List<EmailQueue__c> results = data.getEmailQueues();
        Test.StopTest();

        System.assertEquals(
            48,
            results.size(),
            '48 emails should have been fetched'
        );
    }

    @isTest
    private static void testGetEmailQueues_overMax() {
        createData(1245, null, false);

        Test.StartTest();
        EmailQueueData data = new EmailQueueData('Queued');
        List<EmailQueue__c> results = data.getEmailQueues();
        Test.StopTest();

        System.assertEquals(
            1000,
            results.size(),
            '1000 emails should have been fetched, because that\'s the cap'
        );
    }

    @isTest
    private static void testGetEmailQueuesSeparated() {
        createData(657, null, false);

        Test.StartTest();
        EmailQueueData data = new EmailQueueData('Queued');
        List<List<EmailQueue__c>> results = data.getEmailQueuesSeparated();
        Test.StopTest();

        System.assertEquals(
            7,
            results.size(),
            '7 batches of emails should have been fetched'
        );

        for (Integer i = 0; i < results.size() - 1; i++) {
            System.assertEquals(
                100,
                results[i].size(),
                '100 emails in each batch'
            );
        }
        System.assertEquals(
            57,
            results[results.size() - 1].size(),
            '57 emails in the last batch'
        );
    }

    @isTest
    private static void testGetEmailQueuesSeparated_overMax() {
        createData(1450, null, false);

        Test.StartTest();
        EmailQueueData data = new EmailQueueData('Queued');
        List<List<EmailQueue__c>> results = data.getEmailQueuesSeparated();
        Test.StopTest();

        System.assertEquals(
            10,
            results.size(),
            '10 batches of emails should have been fetched'
        );

        for (Integer i = 0; i < results.size(); i++) {
            System.assertEquals(
                100,
                results[i].size(),
                '100 emails in each batch'
            );
        }
    }

    @isTest
    private static void testGetOrgWideEmailId() {
        Test.StartTest();
        EmailQueueData data = new EmailQueueData('Queued');
        Id orgWideEmailId = data.getOrgWideEmailId();
        Test.StopTest();

        // ! can't test, as scratch org will not have the id but sandboxes will
    }

    // TEST DATA
    // -----------------------------------

    public static void createData(
        Integer amount,
        String priority,
        Boolean saveAsActivity
    ) {
        EmailTemplate emailTemplate = new EmailTemplate(
            DeveloperName = 'MY_UNIQUE_TEMPLATE',
            Name = 'MY_UNIQUE_TEMPLATE',
            IsActive = true,
            FolderId = UserInfo.getOrganizationId(),
            UiType = 'sfx',
            TemplateType = 'custom',
            Subject = 'Test',
            HtmlValue = '<html><head></head><body><p>Hei {{{Recipient.Name}}}!.</p></body></html>'
        );
        insert emailTemplate;

        Contact con = new Contact(LastName = 'test', Email = 'test@test.com');
        insert con;

        List<EmailQueue__c> emailQueues = new List<EmailQueue__c>();
        for (Integer i = 0; i < amount; i++) {
            priority = priority != null
                ? priority
                : String.valueOf(Math.mod(i, 5) + 1); // set fixed priority from parameter if not null
            emailQueues.add(
                new EmailQueue__c(
                    Priority__c = priority,
                    SaveAsActivity__c = saveAsActivity,
                    Status__c = 'Queued',
                    TargetObjectId__c = con.Id,
                    TemplateId__c = emailTemplate.Id
                )
            );
        }
        insert emailQueues;
    }
}
