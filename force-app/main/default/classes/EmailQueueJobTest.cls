@isTest
private without sharing class EmailQueueJobTest {

	@isTest
	private static void testEmailJobs() {

		Integer amount = 15;
		EmailQueueDataTest.createData( amount, null, true );

		System.assertEquals( amount, [SELECT Id FROM EmailQueue__c].size(), 'amount emails in queue' );
		System.assertEquals( 0, [SELECT Id FROM EmailMessage].size(), '0 emails sent before jobs' );
		System.assertEquals( 0, Limits.getEmailInvocations(), 'zero emails sent' );

		Test.StartTest();
		EmailQueueData data = new EmailQueueData();
		for ( List<EmailQueue__c> emailQueuesToSend : data.getEmailQueuesSeparated() ) {
			System.enqueueJob( new EmailQueueJob( emailQueuesToSend, null ) );
		}
		Test.StopTest();

		System.assertEquals( amount, [SELECT Id FROM EmailMessage].size(), amount + ' emails sent after jobs' );
		System.assertEquals( amount, [SELECT Id FROM EmailQueue__c].size(), amount + ' emails in queue' );
		System.assertEquals( amount, [SELECT Id FROM EmailQueue__c WHERE Status__c = 'Sent'].size(), 'EmailQueue__c status should have been updated to "Sent"' );
		System.assertEquals( 0, [SELECT Id FROM EmailQueue__c WHERE Status__c = 'Queued'].size(), 'no more EmailQueue__c records with status "Queued"' );
		System.assertEquals( 0, [SELECT Id FROM EmailQueue__c WHERE Status__c = 'Error'].size(), 'no EmailQueue__c records with status "Error"' );
	}


	// @isTest
	// private static void testEmailJobs_limitExceeded() {
	// 	system.debug( 'getLimitEmailInvocations: ' + Limits.getLimitEmailInvocations() );
	// 	system.debug( 'getEmailInvocations: ' + Limits.getEmailInvocations() );

	// 	Integer amount = 15;
	// 	EmailQueueDataTest.createData( amount, null, true );

	// 	System.assertEquals( amount, [SELECT Id FROM EmailQueue__c].size(), 'amount emails in queue' );
	// 	System.assertEquals( 0, [SELECT Id FROM EmailMessage].size(), '0 emails sent before jobs' );
	// 	System.assertEquals( 0, Limits.getEmailInvocations(), 'zero emails sent' );

	// 	Test.StartTest();
	// 	EmailQueueData data = new EmailQueueData();
	// 	for ( List<EmailQueue__c> emailQueuesToSend : data.getEmailQueuesSeparated() ) {
	// 		System.enqueueJob( new EmailQueueJob( emailQueuesToSend, null ) );
	// 	}
	// 	Test.StopTest();

	// 	System.assertEquals( amount, [SELECT Id FROM EmailQueue__c].size(), amount + ' emails in queue' );
	// 	System.assertEquals( amount, [SELECT Id FROM EmailMessage].size(), amount + ' emails sent before jobs' );

	// 	insert new EmailQueue__c( Priority__c = '1', SaveAsActivity__c = true, Status__c = 'Queued', TargetObjectId__c = [SELECT Id FROM Contact LIMIT 1].Id, TemplateId__c = [SELECT Id FROM EmailTemplate LIMIT 1].Id );

	// 	data = new EmailQueueData();
	// 	system.debug( 'getLimitEmailInvocations: ' + Limits.getLimitEmailInvocations() );
	// 	system.debug( 'getEmailInvocations: ' + Limits.getEmailInvocations() );

	// 	System.assertEquals( 0, data.getEmailQueues().size(), 'no EmailQueue__c records fetched because the email limit is exceeded' );
	// }

	@isTest
	private static void testEmailJobs_malformedId() {

		Integer amount = 15;
		EmailQueueDataTest.createData( amount, null, true );

		List<EmailQueue__c> emailQueues = [SELECT Id FROM EmailQueue__c];
		for ( EmailQueue__c emailQueue : emailQueues ) {
			emailQueue.WhatId__c = 'a003N000002tMTGBAD'; // malformed ID
		}
		update emailQueues;

		System.assertEquals( amount, [SELECT Id FROM EmailQueue__c].size(), 'amount emails in queue' );
		System.assertEquals( 0, [SELECT Id FROM EmailMessage].size(), '0 emails sent before jobs' );
		System.assertEquals( 0, Limits.getEmailInvocations(), 'zero emails sent' );

		Test.StartTest();
		EmailQueueData data = new EmailQueueData();
		for ( List<EmailQueue__c> emailQueuesToSend : data.getEmailQueuesSeparated() ) {
			System.enqueueJob( new EmailQueueJob( emailQueuesToSend, null ) );
		}
		Test.StopTest();

		System.assertEquals( 0, [SELECT Id FROM EmailMessage].size(), 'no emails sent after jobs as all should fail' );
		System.assertEquals( amount, [SELECT Id FROM EmailQueue__c].size(), amount + ' emails in queue' );
		System.assertEquals( 0, [SELECT Id FROM EmailQueue__c WHERE Status__c = 'Sent'].size(), 'EmailQueue__c status should have been updated to "Sent"' );
		System.assertEquals( 0, [SELECT Id FROM EmailQueue__c WHERE Status__c = 'Queued'].size(), 'no more EmailQueue__c records with status "Queued"' );

		emailQueues = [SELECT Id, Error__c FROM EmailQueue__c WHERE Status__c = 'Error'];
		System.assertEquals( amount, emailQueues.size(), 'no EmailQueue__c records with status "Error"' );
		for ( EmailQueue__c emailQueue : emailQueues ) {
			System.assertEquals( 'MALFORMED_ID\nmalformed id a003N000002tMTGBAD', emailQueue.Error__c, 'The error message should have been set because all emails had malformed WhatId' );
		}
	}
}