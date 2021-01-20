@isTest
private without sharing class EmailSchedulingLogTest {

	@TestSetup
	static void makeData() {
		EmailTemplate emailTemplate = new EmailTemplate( DeveloperName = 'MY_UNIQUE_TEMPLATE', Name = 'MY_UNIQUE_TEMPLATE', IsActive = true, FolderId = UserInfo.getOrganizationId(), UiType = 'sfx', TemplateType = 'custom', Subject = 'HEI OG VELKOMMEN', HtmlValue = '<html><head></head><body><p>Hei {{{Recipient.Name}}}!.</p></body></html>' );
		insert emailTemplate;

		Contact con = new Contact( LastName = 'McSmith', Email = 'test@test.com' );
		insert con;

		Case c = new Case();
		insert c;

		insert new EmailQueue__c( Priority__c = '5', SaveAsActivity__c = true, WhatId__c = c.Id, Status__c = 'Queued', TargetObjectId__c = con.Id, TemplateId__c = emailTemplate.Id );
	}

	@isTest
	private static void testGetLogData() {

		Id recordId = [SELECT Id FROM Case LIMIT 1].Id;

		Test.StartTest();
		List<EmailSchedulingLog.LogData> results = EmailSchedulingLog.getLogData( recordId );
		Test.StopTest();

		EmailQueue__c email = [SELECT Id, LastModifiedDate FROM EmailQueue__c LIMIT 1];
		Contact con = [SELECT Id, Name FROM Contact LIMIT 1];

		System.assertEquals( 1, results.size(), 'one emailqueue for the case' );
		System.assertEquals( 'HEI OG VELKOMMEN', results[0].Id, 'Id should be set' );
		System.assertEquals( 'I utsendingskø', results[0].Status, 'Status should be set' );
		System.assertEquals( email.LastModifiedDate, results[0].DateSent, 'DateSent should be set' );
		System.assertEquals( 'HEI OG VELKOMMEN', results[0].Main, 'Subject should be set' );
		System.assertEquals( 1, results[0].Children.size(), 'should have one child' );
		System.assertEquals( email.Id, results[0].Children[0].Id, 'Id should be set' );
		System.assertEquals( '/' + con.Id, results[0].Children[0].MainUrl, 'MainUrl should be set' );
		System.assertEquals( con.Name, results[0].Children[0].Main, 'Main should be set' );
		System.assertEquals( 'I utsendingskø', results[0].Children[0].Status, 'Status should be set' );
	}

	@isTest
	private static void testGetEmailQueue() {

		Id recordId = [SELECT Id FROM Case LIMIT 1].Id;

		Test.StartTest();
		List<EmailQueue__c> results = EmailSchedulingLog.getEmailQueue( recordId );
		Test.StopTest();

		System.assertEquals( 1, results.size(), 'only one email queue created' );
	}

	@isTest
	private static void testGetTemplateSubjects() {

		Id recordId = [SELECT Id FROM Case LIMIT 1].Id;
		List<EmailQueue__c> emailQueue = EmailSchedulingLog.getEmailQueue( recordId );

		Test.StartTest();
		Map<Id, String> results = EmailSchedulingLog.getTemplateSubjects( emailQueue );
		Test.StopTest();

		EmailTemplate emailTemplate = [SELECT Id FROM EmailTemplate WHERE DeveloperName = 'MY_UNIQUE_TEMPLATE' LIMIT 1];

		System.assertEquals( 1, results.size(), 'only one email queue created and only one email template on it' );
		System.assert (results.containsKey( emailTemplate.Id ), 'only one email queue created and only one email template on it');
		System.assertEquals( 'HEI OG VELKOMMEN', results.get( emailTemplate.Id ), 'only one email queue created and only one email template on it' );
	}

	@isTest
	private static void testGetContactNames() {

		Id recordId = [SELECT Id FROM Case LIMIT 1].Id;
		List<EmailQueue__c> emailQueue = EmailSchedulingLog.getEmailQueue( recordId );

		Test.StartTest();
		Map<Id, String> results = EmailSchedulingLog.getContactNames( emailQueue );
		Test.StopTest();

		Contact con = [SELECT Id FROM Contact LIMIT 1];

		System.assertEquals( 1, results.size(), 'only one email queue created and only one contact on it' );
		System.assert (results.containsKey( con.Id ), 'only one email queue created and only one contact on it');
		System.assertEquals( 'McSmith', results.get( con.Id ), 'only one email queue created and only one contact on it' );
	}

	@isTest
	private static void testCreateData() {

		Id recordId = [SELECT Id FROM Case LIMIT 1].Id;
		List<EmailQueue__c> emailQueue = EmailSchedulingLog.getEmailQueue( recordId );
		Map<Id, String> templateSubjects = EmailSchedulingLog.getTemplateSubjects( emailQueue );
		Map<Id, String> contactNames = EmailSchedulingLog.getContactNames( emailQueue );

		Test.StartTest();
		List<EmailSchedulingLog.LogData> results = EmailSchedulingLog.createData( emailQueue, templateSubjects, contactNames );
		Test.StopTest();

		EmailQueue__c email = [SELECT Id, LastModifiedDate FROM EmailQueue__c LIMIT 1];
		Contact con = [SELECT Id, Name FROM Contact LIMIT 1];

		System.assertEquals( 1, results.size(), 'one emailqueue for the case' );
		System.assertEquals( 'HEI OG VELKOMMEN', results[0].Id, 'Id should be set' );
		System.assertEquals( 'I utsendingskø', results[0].Status, 'Status should be set' );
		System.assertEquals( email.LastModifiedDate, results[0].DateSent, 'DateSent should be set' );
		System.assertEquals( 'HEI OG VELKOMMEN', results[0].Main, 'Subject should be set' );
		System.assertEquals( 1, results[0].Children.size(), 'should have one child' );
		System.assertEquals( email.Id, results[0].Children[0].Id, 'Id should be set' );
		System.assertEquals( '/' + con.Id, results[0].Children[0].MainUrl, 'MainUrl should be set' );
		System.assertEquals( con.Name, results[0].Children[0].Main, 'Main should be set' );
		System.assertEquals( 'I utsendingskø', results[0].Children[0].Status, 'Status should be set' );
	}

	@isTest
	private static void testGetStatus() {
		System.assertEquals( 'Sendt', EmailSchedulingLog.getStatus( 'Sent' ), 'english sent in should be translated' );
		System.assertEquals( 'I utsendingskø', EmailSchedulingLog.getStatus( 'Queued' ), 'english sent in should be translated' );
		System.assertEquals( 'Sender straks', EmailSchedulingLog.getStatus( 'Instant' ), 'english sent in should be translated' );
		System.assertEquals( 'Feil', EmailSchedulingLog.getStatus( 'Error' ), 'english sent in should be translated' );
		System.assertEquals( 'wfrefrefefrfr', EmailSchedulingLog.getStatus( 'wfrefrefefrfr' ), 'english sent in should be translated' );
	}
}