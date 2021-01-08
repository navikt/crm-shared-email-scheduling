@isTest
private without sharing class EmailQueueJobTest {

	@isTest
	private static void testQueue() {

		EmailQueueDataTest.createData( 24, null, false );

		System.assertEquals( 24, [SELECT Id FROM EmailQueue__c].size(), '24 emails in queue' );
		System.assertEquals( 0, [SELECT Id FROM EmailMessage].size(), '0 emails sent before jobs' );

		Test.StartTest();
		EmailQueueData data = new EmailQueueData();

		for ( List<EmailQueue__c> emailQueuesToSend : data.getEmailQueuesSeparated() ) {
			System.enqueueJob( new EmailQueueJob( emailQueuesToSend, null ) );
		}

		Test.StopTest();

		System.assertEquals( 24, [SELECT Id FROM EmailQueue__c].size(), '24 emails in queue' );
		System.assertEquals( 15, [SELECT Id FROM EmailQueue__c WHERE Status__c = 'Sent'].size(), 'EmailQueue__c status should have been updated to "Sent" for 15 (max in tests)' );
		System.assertEquals( 0, [SELECT Id FROM EmailQueue__c WHERE Status__c = 'Queued'].size(), 'no more EmailQueue__c records with status "Queued"' );
		System.assertEquals( 9, [SELECT Id FROM EmailQueue__c WHERE Status__c = 'Error'].size(), 'no EmailQueue__c records with status "Error"' );

	}
}