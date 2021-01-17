@isTest
private without sharing class EmailQueueJobTest {

	@isTest
	private static void verifyAmountTrackerAdjustsEmailsSent() {

		Integer amount = 15;
		Integer diff = 5;

		insert new EmailQueueSettings__c( AmountSentToday__c = 5000 - diff );
		EmailQueueDataTest.createData( amount, null, true );

		System.assertEquals( amount, [SELECT Id FROM EmailQueue__c].size(), 'amount emails in queue' );
		System.assertEquals( 0, [SELECT Id FROM EmailMessage].size(), '0 emails sent before jobs' );

		Test.StartTest();
		EmailQueueData data = new EmailQueueData( 'Queued' );
		for ( List<EmailQueue__c> emailQueuesToSend : data.getEmailQueuesSeparated() ) {
			System.enqueueJob( new EmailQueueJob( emailQueuesToSend, null ) );
		}
		Test.StopTest();

		System.assertEquals( diff, [SELECT Id FROM EmailMessage].size(), diff + ' emails sent after jobs because capped at 5000 emails' );
		System.assertEquals( amount, [SELECT Id FROM EmailQueue__c].size(), amount + ' emails in queue' );
		System.assertEquals( diff, [SELECT Id FROM EmailQueue__c WHERE Status__c = 'Sent'].size(), 'EmailQueue__c status should have been updated to "Sent" for only 10 records because cap reached' );
		System.assertEquals( amount - diff, [SELECT Id FROM EmailQueue__c WHERE Status__c = 'Queued'].size(), '5 EmailQueue__c records with status "Queued" because max cap reached' );
		System.assertEquals( 0, [SELECT Id FROM EmailQueue__c WHERE Status__c = 'Error'].size(), 'no EmailQueue__c records with status "Error"' );
	}

	@isTest
	private static void testEmailJobs() {

		Integer amount = 15;
		EmailQueueDataTest.createData( amount, null, true );

		System.assertEquals( amount, [SELECT Id FROM EmailQueue__c].size(), 'amount emails in queue' );
		System.assertEquals( 0, [SELECT Id FROM EmailMessage].size(), '0 emails sent before jobs' );

		Test.StartTest();
		EmailQueueData data = new EmailQueueData( 'Queued' );
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

	@isTest
	private static void testEmailJobs_overMax() {

		Integer amount = 1005;
		EmailQueueDataTest.createData( amount, null, true );

		System.assertEquals( amount, [SELECT Id FROM EmailQueue__c].size(), 'amount emails in queue' );
		System.assertEquals( 0, [SELECT Id FROM EmailMessage].size(), '0 emails sent before jobs' );

		Test.StartTest();
		EmailQueueData data = new EmailQueueData( 'Queued' );
		for ( List<EmailQueue__c> emailQueuesToSend : data.getEmailQueuesSeparated() ) {
			System.enqueueJob( new EmailQueueJob( emailQueuesToSend, null ) );
		}
		Test.StopTest();

		System.assert ( [SELECT Id FROM EmailMessage].size() >= 15, 'at least 15 EmailMessage records' );
		System.assert ( [SELECT Id FROM EmailQueue__c].size() >= 15, 'at least 15 emails in EmailQueue' );
		System.assert ( [SELECT Id FROM EmailQueue__c WHERE Status__c = 'Sent'].size() >= 15, 'at least 15 EmailQueues with status sent' );
		System.assert ( [SELECT Id FROM EmailQueue__c WHERE Status__c = 'Queued'].size() >= 5, 'Should still be some unsent emails' ); // scratch org limits to 15 emails total (regardless of X amount of jobs or Y amount of transactions), but sandboxes have a higher limit
	}

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

		Test.StartTest();
		EmailQueueData data = new EmailQueueData( 'Queued' );
		for ( List<EmailQueue__c> emailQueuesToSend : data.getEmailQueuesSeparated() ) {
			System.enqueueJob( new EmailQueueJob( emailQueuesToSend, null ) );
		}
		Test.StopTest();

		System.assertEquals( 0, [SELECT Id FROM EmailMessage].size(), 'no emails sent after jobs as all should fail' );
		System.assertEquals( amount, [SELECT Id FROM EmailQueue__c].size(), amount + ' emails in queue' );
		System.assertEquals( 0, [SELECT Id FROM EmailQueue__c WHERE Status__c = 'Sent'].size(), 'EmailQueue__c status should have been updated to "Sent"' );
		System.assertEquals( 0, [SELECT Id FROM EmailQueue__c WHERE Status__c = 'Queued'].size(), 'no more EmailQueue__c records with status "Queued"' );

		emailQueues = [SELECT Id, Error__c, ErrorType__c FROM EmailQueue__c WHERE Status__c = 'Error'];
		System.assertEquals( amount, emailQueues.size(), 'no EmailQueue__c records with status "Error"' );
		for ( EmailQueue__c emailQueue : emailQueues ) {
			System.assertEquals( 'MALFORMED_ID', emailQueue.ErrorType__c, 'The error message should have been set because all emails had malformed WhatId' );
			System.assertEquals( 'malformed id a003N000002tMTGBAD', emailQueue.Error__c, 'The error message should have been set because all emails had malformed WhatId' );
		}
	}
}