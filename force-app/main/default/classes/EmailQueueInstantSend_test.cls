@isTest
private without sharing class EmailQueueInstantSend_test {
	@isTest
	private static void testInsert() {

		EmailTemplate emailTemplate = new EmailTemplate( DeveloperName = 'MY_UNIQUE_TEMPLATE', Name = 'MY_UNIQUE_TEMPLATE', IsActive = true, FolderId = UserInfo.getOrganizationId(), UiType = 'sfx', TemplateType = 'custom', Subject = 'Test', HtmlValue = '<html><head></head><body><p>Hei {{{Recipient.Name}}}!.</p></body></html>' );
		insert emailTemplate;

		Contact con = new Contact( LastName = 'test', Email = 'test@test.com' );
		insert con;

		List<EmailQueue__c> emailQueues = new List<EmailQueue__c>();
		for ( Integer i = 0; i < 5; i++ ) {
			emailQueues.add( new EmailQueue__c( Priority__c = '1', SaveAsActivity__c = true, Status__c = 'Instant', TargetObjectId__c = con.Id, TemplateId__c = emailTemplate.Id ) );
		}

		Test.StartTest();
		insert emailQueues;
		Test.StopTest();

		System.assertEquals( 5, [SELECT Id FROM EmailMessage].size(), '5 emails sent after jobs' );
		System.assertEquals( 5, [SELECT Id FROM EmailQueue__c].size(), '5 emails in queue' );
		System.assertEquals( 5, [SELECT Id FROM EmailQueue__c WHERE Status__c = 'Sent'].size(), 'EmailQueue__c status should have been updated to "Sent"' );
		System.assertEquals( 0, [SELECT Id FROM EmailQueue__c WHERE Status__c = 'Instant'].size(), 'no EmailQueue__c status should still be "Instant"' );
		System.assertEquals( 0, [SELECT Id FROM EmailQueue__c WHERE Status__c = 'Queued'].size(), 'no more EmailQueue__c records with status "Queued"' );
		System.assertEquals( 0, [SELECT Id FROM EmailQueue__c WHERE Status__c = 'Error'].size(), 'no EmailQueue__c records with status "Error"' );
	}

	@isTest
	private static void testUpdate() {

		EmailQueueData_test.createData( 5, null, true );   // create test data

		List<EmailQueue__c> emailQueue = [SELECT Id FROM EmailQueue__c];
		for ( EmailQueue__c queue : emailQueue ) {
			queue.Status__c = 'Instant';
		}


		Test.StartTest();
		update emailQueue;
		Test.StopTest();

		System.assertEquals( 5, [SELECT Id FROM EmailMessage].size(), '5 emails sent after jobs' );
		System.assertEquals( 5, [SELECT Id FROM EmailQueue__c].size(), '5 emails in queue' );
		System.assertEquals( 5, [SELECT Id FROM EmailQueue__c WHERE Status__c = 'Sent'].size(), 'EmailQueue__c status should have been updated to "Sent"' );
		System.assertEquals( 0, [SELECT Id FROM EmailQueue__c WHERE Status__c = 'Instant'].size(), 'no EmailQueue__c status should still be "Instant"' );
		System.assertEquals( 0, [SELECT Id FROM EmailQueue__c WHERE Status__c = 'Queued'].size(), 'no more EmailQueue__c records with status "Queued"' );
		System.assertEquals( 0, [SELECT Id FROM EmailQueue__c WHERE Status__c = 'Error'].size(), 'no EmailQueue__c records with status "Error"' );
	}

	@isTest
	private static void testCap() {

		insert new EmailQueueSettings__c( AmountSentToday__c = 4995, ResetDate__c = Date.today() );
		EmailQueueData_test.createData( 15, null, true );

		List<EmailQueue__c> emailQueue = [SELECT Id FROM EmailQueue__c];
		for ( EmailQueue__c queue : emailQueue ) {
			queue.Status__c = 'Instant';
		}

		Test.StartTest();
		update emailQueue;
		Test.StopTest();

		System.assertEquals( 5, [SELECT Id FROM EmailMessage].size(), '5 emails sent after jobs' );
		System.assertEquals( 15, [SELECT Id FROM EmailQueue__c].size(), '5 emails in queue' );
		System.assertEquals( 5, [SELECT Id FROM EmailQueue__c WHERE Status__c = 'Sent'].size(), 'EmailQueue__c status should have been updated to "Sent"' );
		System.assertEquals( 0, [SELECT Id FROM EmailQueue__c WHERE Status__c = 'Instant'].size(), 'no EmailQueue__c status should still be "Instant"' );
		System.assertEquals( 10, [SELECT Id FROM EmailQueue__c WHERE Status__c = 'Queued'].size(), 'no more EmailQueue__c records with status "Queued"' );
		System.assertEquals( 0, [SELECT Id FROM EmailQueue__c WHERE Status__c = 'Error'].size(), 'no EmailQueue__c records with status "Error"' );

		List<EmailQueueSettings__c> settings = [SELECT Id, AmountSentToday__c FROM EmailQueueSettings__c WHERE LastModifiedDate = TODAY];
		System.assertEquals( 1, settings.size(), 'should be settings for today' );
		System.assertEquals( 5000, settings[0].AmountSentToday__c, 'should be settings for today' );
	}

	@isTest
	private static void testCap_exact5000() {

		insert new EmailQueueSettings__c( AmountSentToday__c = 4995, ResetDate__c = Date.today() );
		EmailQueueData_test.createData( 5, null, true );

		List<EmailQueue__c> emailQueue = [SELECT Id FROM EmailQueue__c];
		for ( EmailQueue__c queue : emailQueue ) {
			queue.Status__c = 'Instant';
		}

		Test.StartTest();
		update emailQueue;
		Test.StopTest();

		System.assertEquals( 5, [SELECT Id FROM EmailMessage].size(), '5 emails sent after jobs' );
		System.assertEquals( 5, [SELECT Id FROM EmailQueue__c].size(), '5 emails in queue' );
		System.assertEquals( 5, [SELECT Id FROM EmailQueue__c WHERE Status__c = 'Sent'].size(), 'EmailQueue__c status should have been updated to "Sent"' );
		System.assertEquals( 0, [SELECT Id FROM EmailQueue__c WHERE Status__c = 'Instant'].size(), 'no EmailQueue__c status should still be "Instant"' );
		System.assertEquals( 0, [SELECT Id FROM EmailQueue__c WHERE Status__c = 'Queued'].size(), 'no more EmailQueue__c records with status "Queued"' );
		System.assertEquals( 0, [SELECT Id FROM EmailQueue__c WHERE Status__c = 'Error'].size(), 'no EmailQueue__c records with status "Error"' );

		List<EmailQueueSettings__c> settings = [SELECT Id, AmountSentToday__c FROM EmailQueueSettings__c WHERE LastModifiedDate = TODAY];
		System.assertEquals( 1, settings.size(), 'should be settings for today' );
		System.assertEquals( 5000, settings[0].AmountSentToday__c, 'should be settings for today' );
	}
}