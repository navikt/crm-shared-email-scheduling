@isTest
private without sharing class EmailQueueTrigger_setTemplateTest {
    @TestSetup
    static void makeData() {
        List<EmailTemplate> templates = new List<EmailTemplate>();

        templates.add(
            new EmailTemplate(
                DeveloperName = 'MY_UNIQUE_TEMPLATE',
                Name = 'MY_UNIQUE_TEMPLATE',
                IsActive = true,
                FolderId = UserInfo.getOrganizationId(),
                UiType = 'sfx',
                TemplateType = 'custom',
                Subject = 'Test',
                HtmlValue = '<html><head></head><body><p>Hei {{{Recipient.Name}}}!.</p></body></html>'
            )
        );

        templates.add(
            new EmailTemplate(
                DeveloperName = 'MY_OTHER_TEMPLATE',
                Name = 'MY_OTHER_TEMPLATE',
                IsActive = true,
                FolderId = UserInfo.getOrganizationId(),
                UiType = 'sfx',
                TemplateType = 'custom',
                Subject = 'Test',
                HtmlValue = '<html><head></head><body><p>Hei {{{Recipient.Name}}}!.</p></body></html>'
            )
        );

        Database.insert(templates, false);
    }

    @isTest
    private static void testVerifyTemplateId() {
        Contact con = new Contact(LastName = 'test', Email = 'test@test.com');
        insert con;

        List<EmailQueue__c> emailQueues = new List<EmailQueue__c>();
        for (Integer i = 0; i < 10; i++) {
            emailQueues.add(
                new EmailQueue__c(
                    Priority__c = '1',
                    SaveAsActivity__c = true,
                    Status__c = 'Queued',
                    TargetObjectId__c = con.Id,
                    TemplateName__c = 'MY_UNIQUE_TEMPLATE'
                )
            );
        }

        Test.StartTest();
        insert emailQueues;
        Test.StopTest();

        Id templateId = [SELECT Id FROM EmailTemplate WHERE DeveloperName = 'MY_UNIQUE_TEMPLATE' LIMIT 1].Id;

        emailQueues = [SELECT Id, TemplateId__c FROM EmailQueue__c];

        System.assertEquals(10, emailQueues.size(), 'should be 10 inserted');
        for (EmailQueue__c emailQueue : emailQueues) {
            System.assertEquals(
                templateId,
                emailQueue.TemplateId__c,
                'TemplateId__c should be set from TemplateName__c'
            );
        }
    }

    @isTest
    private static void testVerifyTemplateId_multipleTemplates() {
        Contact con = new Contact(LastName = 'test', Email = 'test@test.com');
        insert con;

        List<EmailQueue__c> emailQueues = new List<EmailQueue__c>();
        emailQueues.add(
            new EmailQueue__c(
                Priority__c = '1',
                SaveAsActivity__c = true,
                Status__c = 'Queued',
                TargetObjectId__c = con.Id,
                TemplateName__c = 'MY_UNIQUE_TEMPLATE'
            )
        );

        emailQueues.add(
            new EmailQueue__c(
                Priority__c = '1',
                SaveAsActivity__c = true,
                Status__c = 'Queued',
                TargetObjectId__c = con.Id,
                TemplateName__c = 'MY_OTHER_TEMPLATE'
            )
        );

        Test.StartTest();
        insert emailQueues;
        Test.StopTest();

        Id otherTemplateId = [SELECT Id FROM EmailTemplate WHERE DeveloperName = 'MY_OTHER_TEMPLATE' LIMIT 1].Id;
        Id uniqueTemplateId = [SELECT Id FROM EmailTemplate WHERE DeveloperName = 'MY_UNIQUE_TEMPLATE' LIMIT 1].Id;

        emailQueues = [SELECT Id, TemplateId__c, TemplateName__c FROM EmailQueue__c];

        System.assertEquals(2, emailQueues.size(), 'should be 10 inserted');
        for (EmailQueue__c emailQueue : emailQueues) {
            if (emailQueue.TemplateName__c == 'MY_UNIQUE_TEMPLATE') {
                System.assertEquals(
                    uniqueTemplateId,
                    emailQueue.TemplateId__c,
                    'TemplateId__c should be set from TemplateName__c'
                );
            } else {
                System.assertEquals(
                    otherTemplateId,
                    emailQueue.TemplateId__c,
                    'TemplateId__c should be set from TemplateName__c'
                );
            }
        }
    }

    @isTest
    private static void testVerifyTemplateId_setBothIdAndName() {
        Contact con = new Contact(LastName = 'test', Email = 'test@test.com');
        insert con;

        Id templateId = [SELECT Id FROM EmailTemplate WHERE DeveloperName = 'MY_UNIQUE_TEMPLATE' LIMIT 1].Id;

        List<EmailQueue__c> emailQueues = new List<EmailQueue__c>();
        for (Integer i = 0; i < 10; i++) {
            emailQueues.add(
                new EmailQueue__c(
                    Priority__c = '1',
                    SaveAsActivity__c = true,
                    Status__c = 'Queued',
                    TargetObjectId__c = con.Id,
                    TemplateName__c = 'MY_OTHER_TEMPLATE',
                    TemplateId__c = templateId
                )
            );
        }

        Test.StartTest();
        insert emailQueues;
        Test.StopTest();

        emailQueues = [SELECT Id, TemplateId__c FROM EmailQueue__c];

        System.assertEquals(10, emailQueues.size(), 'should be 10 inserted');
        for (EmailQueue__c emailQueue : emailQueues) {
            System.assertEquals(
                templateId,
                emailQueue.TemplateId__c,
                'TemplateId__c should be the original value and not changed from TemplateName__c because TemplateId__c should always override'
            );
        }
    }

    @isTest
    private static void testGetTemplateNames() {
        Contact con = new Contact(LastName = 'test', Email = 'test@test.com');
        insert con;

        List<EmailQueue__c> emailQueues = new List<EmailQueue__c>();
        emailQueues.add(
            new EmailQueue__c(
                Priority__c = '1',
                SaveAsActivity__c = true,
                Status__c = 'Queued',
                TargetObjectId__c = con.Id,
                TemplateName__c = 'MY_UNIQUE_TEMPLATE'
            )
        );

        Test.StartTest();
        Set<String> templateNames = EmailQueueTrigger_setTemplate.getTemplateNames(emailQueues);
        Test.StopTest();

        System.assertEquals(1, templateNames.size(), 'should only be one template');
        System.assert(templateNames.contains('MY_UNIQUE_TEMPLATE'), 'should be the only template name');
    }

    @isTest
    private static void testGetTemplates() {
        Contact con = new Contact(LastName = 'test', Email = 'test@test.com');
        insert con;

        List<EmailQueue__c> emailQueues = new List<EmailQueue__c>();
        emailQueues.add(
            new EmailQueue__c(
                Priority__c = '1',
                SaveAsActivity__c = true,
                Status__c = 'Queued',
                TargetObjectId__c = con.Id,
                TemplateName__c = 'MY_UNIQUE_TEMPLATE'
            )
        );
        Set<String> templateNames = EmailQueueTrigger_setTemplate.getTemplateNames(emailQueues);

        Test.StartTest();
        Map<String, Id> emailTemplates = EmailQueueTrigger_setTemplate.getTemplates(templateNames);
        Test.StopTest();

        Id templateId = [SELECT Id FROM EmailTemplate WHERE DeveloperName = 'MY_UNIQUE_TEMPLATE' LIMIT 1].Id;

        System.assertEquals(1, emailTemplates.size(), 'only one email template name sent in, one returned');
        System.assertEquals(
            templateId,
            emailTemplates.get('MY_UNIQUE_TEMPLATE'),
            'template Id for MY_UNIQUE_TEMPLATE should be fetched'
        );
    }

    @isTest
    private static void testSetTemplateId() {
        Contact con = new Contact(LastName = 'test', Email = 'test@test.com');
        insert con;

        List<EmailQueue__c> emailQueues = new List<EmailQueue__c>();
        emailQueues.add(
            new EmailQueue__c(
                Priority__c = '1',
                SaveAsActivity__c = true,
                Status__c = 'Queued',
                TargetObjectId__c = con.Id,
                TemplateName__c = 'MY_UNIQUE_TEMPLATE'
            )
        );

        Set<String> templateNames = EmailQueueTrigger_setTemplate.getTemplateNames(emailQueues);
        Map<String, Id> emailTemplates = EmailQueueTrigger_setTemplate.getTemplates(templateNames);

        Test.StartTest();
        List<EmailQueue__c> changedEmailQueues = EmailQueueTrigger_setTemplate.setTemplateId(
            emailQueues,
            emailTemplates
        );
        Test.StopTest();

        Id templateId = [SELECT Id FROM EmailTemplate WHERE DeveloperName = 'MY_UNIQUE_TEMPLATE' LIMIT 1].Id;

        System.assertEquals(1, changedEmailQueues.size(), 'only one email queue sent in, one returned');
        for (EmailQueue__c changedEmailQueue : changedEmailQueues) {
            System.assertEquals(
                templateId,
                changedEmailQueue.TemplateId__c,
                'should have added the correct template ID'
            );
        }
    }
}
