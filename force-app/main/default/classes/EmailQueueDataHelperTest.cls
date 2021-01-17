@isTest
private without sharing class EmailQueueDataHelperTest {

	@isTest
	private static void testGetEmailLimit() {

		Test.StartTest();
		Integer result = EmailQueueDataHelper.getEmailLimit();
		Test.StopTest();

		System.assertEquals( 1000, result, 'nothing sent yet, so full limit' );
	}

	@isTest
	private static void testGetEmailLimit_overLimit() {

		insert new EmailQueueSettings__c( AmountSentToday__c = 4995 );

		Test.StartTest();
		Integer result = EmailQueueDataHelper.getEmailLimit();
		Test.StopTest();

		System.assertEquals( 5, result, '4995 sent, so 5 limit' );
	}

	@isTest
	private static void testGetEmailLimit_exact() {

		insert new EmailQueueSettings__c( AmountSentToday__c = 4000 );

		Test.StartTest();
		Integer result = EmailQueueDataHelper.getEmailLimit();
		Test.StopTest();

		System.assertEquals( 1000, result, '4000 sent, so 1000 limit' );
	}

	@isTest
	private static void testGetEmailQueue_status() {

		EmailQueueDataTest.createData( 5, null, true );   // create test data

		Test.StartTest();
		List<EmailQueue__c> results = EmailQueueDataHelper.getEmailQueue( 'Queued', 5 );
		Test.StopTest();

		System.assertEquals( 5, results.size(), 'queried for 5, got 5' );
	}

	@isTest
	private static void testGetEmailQueue_recordsExact() {

		EmailQueueDataTest.createData( 5, null, true );   // create test data
		List<EmailQueue__c> emailQueue = [SELECT Id FROM EmailQueue__c];
		for ( EmailQueue__c queue : emailQueue ) {
			queue.Status__c = 'Instant';
		}

		List<EmailQueue__c> emailQueues = [SELECT Id FROM EmailQueue__c];

		System.assertEquals( 5, [SELECT Id FROM EmailQueue__c].size(), '5 emails in queue' );

		List<EmailQueue__c> results = EmailQueueDataHelper.getEmailQueue( emailQueues, 5 );
		Test.StartTest();
		Test.StopTest();

		System.assertEquals( 5, [SELECT Id FROM EmailQueue__c].size(), '5 emails in queue' );
		System.assertEquals( 5, [SELECT Id FROM EmailQueue__c WHERE Status__c = 'Queued'].size(), 'no more EmailQueue__c records with status "Queued"' );
		System.assertEquals( 5, results.size(), 'queried for 5, got 5' );
	}

	@isTest
	private static void testGetEmailQueue_recordsLess() {

		EmailQueueDataTest.createData( 5, null, true );   // create test data
		List<EmailQueue__c> emailQueue = [SELECT Id FROM EmailQueue__c];
		for ( EmailQueue__c queue : emailQueue ) {
			queue.Status__c = 'Instant';
		}
		List<EmailQueue__c> emailQueues = [SELECT Id FROM EmailQueue__c];

		Test.StartTest();
		List<EmailQueue__c> results = EmailQueueDataHelper.getEmailQueue( emailQueues, 7 );
		Test.StopTest();

		System.assertEquals( 5, results.size(), 'queried for 5, got 5' );
	}

	@isTest
	private static void testGetEmailQueue_recordsMoreThanAllowed() {

		EmailQueueDataTest.createData( 10, null, true );   // create test data
		List<EmailQueue__c> emailQueue = [SELECT Id FROM EmailQueue__c];
		for ( EmailQueue__c queue : emailQueue ) {
			queue.Status__c = 'Error'; // for testing purposes, instant would cause them to be sent by trigger
		}
		update emailQueue;

		System.assertEquals( 10, [SELECT Id FROM EmailQueue__c].size(), '5 emails in queue' );

		Test.StartTest();
		List<EmailQueue__c> results = EmailQueueDataHelper.getEmailQueue( emailQueue, 5 );
		Test.StopTest();

		System.assertEquals( 10, [SELECT Id FROM EmailQueue__c].size(), '5 emails in queue' );
		System.assertEquals( 5, [SELECT Id FROM EmailQueue__c WHERE Status__c = 'Queued'].size(), 'no more EmailQueue__c records with status "Queued"' );
		System.assertEquals( 5, [SELECT Id FROM EmailQueue__c WHERE Status__c = 'Error'].size(), 'no more EmailQueue__c records with status "Queued"' );
	}

	@isTest
	private static void testGetEmailQueuesSeparated() {

		EmailQueueDataTest.createData( 5, null, true );   // create test data
		List<EmailQueue__c> emailQueues = EmailQueueDataHelper.getEmailQueue( 'Queued', 5 );

		Test.StartTest();
		List<List<EmailQueue__c> > results = EmailQueueDataHelper.getEmailQueuesSeparated( emailQueues );
		Test.StopTest();
	}

	@isTest
	private static void testGetEmailQueuesSeparated_empty() {

		EmailQueueDataTest.createData( 5, null, true );   // create test data
		List<EmailQueue__c> emailQueues = EmailQueueDataHelper.getEmailQueue( 'Queued', 5 );

		Test.StartTest();
		List<List<EmailQueue__c> > results = EmailQueueDataHelper.getEmailQueuesSeparated( emailQueues );
		Test.StopTest();
	}

	@isTest
	private static void testGetEmailQueuesSeparated_null() {

		EmailQueueDataTest.createData( 5, null, true );   // create test data
		List<EmailQueue__c> emailQueues = EmailQueueDataHelper.getEmailQueue( 'Queued', 5 );

		Test.StartTest();
		List<List<EmailQueue__c> > results = EmailQueueDataHelper.getEmailQueuesSeparated( emailQueues );
		Test.StopTest();
	}
}