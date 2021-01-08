@isTest
private without sharing class EmailQueueJobTest {

	@TestSetup
	static void makeData() {
		EmailQueueDataTest.makeData();
	}

	@isTest
	private static void testQueue() {

		System.assertEquals( 48, [SELECT Id FROM EmailQueue__c].size(), '48 emails in queue' );
		System.assertEquals( 0, [SELECT Id FROM EmailMessage].size(), '0 emails sent before jobs' );

		Test.StartTest();
		EmailQueueData data = new EmailQueueData();

		for ( List<EmailQueue__c> emailQueuesToSend : data.getEmailQueuesSeparated() ) {
			System.enqueueJob( new EmailQueueJob( emailQueuesToSend ) );
		}

		Test.StopTest();

		System.assertEquals( 48, [SELECT Id FROM EmailQueue__c].size(), '48 emails in queue' );
		System.assertEquals( 48, [SELECT Id FROM EmailMessage].size(), '48 emails sent after jobs' );
	}
}