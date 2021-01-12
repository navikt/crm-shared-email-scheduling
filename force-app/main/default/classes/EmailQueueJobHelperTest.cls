@isTest
private without sharing class EmailQueueJobHelperTest {

	// 10 emails, 0 fail
	// ------------------------------

	@isTest
	private static void testSendEmail() {

		EmailQueueDataTest.createData( 10, null, false );   // create test data
		EmailQueueData data = new EmailQueueData();         // fetch data

		Test.StartTest();
		List<Messaging.SendEmailResult> emailResults = EmailQueueJobHelper.sendEmail( data.getEmailQueues(), null );
		Test.StopTest();

		System.assertEquals( 10, emailResults.size(), '10 records, 10 emails' );
		for ( Messaging.SendEmailResult emailResult : emailResults ) {
			System.assert (emailResult.isSuccess(), 'All emails should have been sent successfully');
		}
	}

	@isTest
	private static void testUpdateEmailQueues() {

		EmailQueueDataTest.createData( 10, null, false );   // create test data
		EmailQueueData data = new EmailQueueData();         // fetch data
		List<Messaging.SendEmailResult> emailResults = EmailQueueJobHelper.sendEmail( data.getEmailQueues(), null );

		Test.StartTest();
		EmailQueueJobHelper.updateEmailQueues( data.getEmailQueues(), emailResults );
		Test.StopTest();

		System.assertEquals( 10, [SELECT Id FROM EmailQueue__c WHERE Status__c = 'Sent'].size(), 'EmailQueue__c status should have been updated to "Sent"' );
		System.assertEquals( 0, [SELECT Id FROM EmailQueue__c WHERE Status__c = 'Queued'].size(), 'no more EmailQueue__c records with status "Queued"' );
	}

	// 11 emails, 1 fail
	// ------------------------------

	@isTest
	private static void testSendEmail_oneError() {

		EmailQueueDataTest.createData( 16, null, false );   // create test data
		EmailQueueData data = new EmailQueueData();         // fetch data

		Test.StartTest();
		List<Messaging.SendEmailResult> emailResults = EmailQueueJobHelper.sendEmail( data.getEmailQueues(), null );
		Test.StopTest();


		System.assertEquals( 16, emailResults.size(), '16 records, 16 emails' );
		for ( Integer i = 0; i < emailResults.size() - 1; i++ ) {
			System.assert (emailResults[i].isSuccess(), 'All emails but the last should have been sent successfully');
		}
		System.assert (!emailResults[emailResults.size() - 1].isSuccess(), 'Last email should have an error');
		System.assertEquals( 'Email limit exceeded', emailResults[15].getErrors()[0].getMessage(), 'Last email have exceeded email limit' );
	}

	@isTest
	private static void testUpdateEmailQueues_oneError() {

		EmailQueueDataTest.createData( 16, null, false );   // create test data
		EmailQueueData data = new EmailQueueData();         // fetch data
		List<Messaging.SendEmailResult> emailResults = EmailQueueJobHelper.sendEmail( data.getEmailQueues(), null );

		Test.StartTest();
		EmailQueueJobHelper.updateEmailQueues( data.getEmailQueues(), emailResults );
		Test.StopTest();

		System.assertEquals( 15, [SELECT Id FROM EmailQueue__c WHERE Status__c = 'Sent'].size(), 'EmailQueue__c status should have been updated to "Sent"' );
		System.assertEquals( 0, [SELECT Id FROM EmailQueue__c WHERE Status__c = 'Queued'].size(), 'no more EmailQueue__c records with status "Queued"' );
		System.assertEquals( 1, [SELECT Id FROM EmailQueue__c WHERE Status__c = 'Error'].size(), 'one EmailQueue__c record with status "Error"' );
	}

	// non-equal lists of emails and results
	// ------------------------------

	@isTest
	private static void testUpdateEmailQueues_sizeMismatch() {

		EmailQueueDataTest.createData( 16, null, false );   // create test data
		EmailQueueData data = new EmailQueueData();         // fetch data
		List<Messaging.SendEmailResult> emailResults = EmailQueueJobHelper.sendEmail( data.getEmailQueues(), null );
		emailResults.remove( 1 );

		Test.StartTest();
		EmailQueueJobHelper.updateEmailQueues( data.getEmailQueues(), emailResults );
		Test.StopTest();

		System.assertEquals( 0, [SELECT Id FROM EmailQueue__c WHERE Status__c = 'Sent'].size(), 'EmailQueue__c status should have been updated to "Sent"' );
		System.assertEquals( 0, [SELECT Id FROM EmailQueue__c WHERE Status__c = 'Queued'].size(), 'no more EmailQueue__c records with status "Queued"' );
		System.assertEquals( 16, [SELECT Id FROM EmailQueue__c WHERE Status__c = 'Error'].size(), 'one EmailQueue__c record with status "Error"' );
	}
}