@isTest
public without sharing class EmailQueueDataTest {

	@TestSetup
	public static void makeData() {
		EmailTemplate emailTemplate = new EmailTemplate( DeveloperName = 'MY_UNIQUE_TEMPLATE', Name = 'MY_UNIQUE_TEMPLATE', IsActive = true, FolderId = UserInfo.getOrganizationId(), UiType = 'sfx', TemplateType = 'custom', Subject = 'Test', HtmlValue = '<html><head></head><body><p>Hei {{{Recipient.Name}}}!.</p></body></html>' );
		insert emailTemplate;

		Contact con = new Contact( LastName = 'test', Email = 'test@test.com' );
		insert con;

		List<EmailQueue__c> emailQueues = new List<EmailQueue__c>();
		for ( Integer i = 0; i < 48; i++ ) {
			String priority = String.valueOf( Math.mod( i, 5 ) + 1 );
			Boolean saveAsActivity = Math.mod( i, 2 ) == 0;
			emailQueues.add( new EmailQueue__c( Priority__c = priority, SaveAsActivity__c = saveAsActivity, Status__c = 'Queued', TargetObjectId__c = con.Id, TemplateId__c = emailTemplate.Id ) );
		}
		insert emailQueues;
	}

	@isTest
	private static void testGetEmailQueues() {

		Test.StartTest();
		EmailQueueData data = new EmailQueueData();
		List<EmailQueue__c> results = data.getEmailQueues();
		Test.StopTest();

		System.assertEquals( 48, results.size(), '48 emails should have been fetched' );
	}

	@isTest
	private static void testGetEmailQueuesSeparated() {

		Test.StartTest();
		EmailQueueData data = new EmailQueueData();
		List<List<EmailQueue__c> > results = data.getEmailQueuesSeparated();
		Test.StopTest();

		System.assertEquals( 5, results.size(), '10 batches of emails should have been fetched' );

		for ( Integer i = 0; i < 4; i++ ) {
			System.assertEquals( 10, results[i].size(), '10 emails in each batch' );
		}
		System.assertEquals( 8, results[4].size(), '8 emails in the last batch' );
	}
}