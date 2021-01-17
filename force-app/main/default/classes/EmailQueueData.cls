public with sharing class EmailQueueData {

	private static final List<OrgWideEmailAddress> ORG_WIDE_ADDRESSES = [SELECT Id FROM OrgWideEmailAddress WHERE Address = 'do-not-reply@info.nav.no' LIMIT 1];
	private static final Id ORG_WIDE_EMAIL_ID =                         ORG_WIDE_ADDRESSES.size() == 1 ? ORG_WIDE_ADDRESSES[0].Id : null;

	private static final Integer AMOUNT_OF_EMAILS_PER_BATCH =   100; // 100 email limit per batch
	private static final Integer AMOUNT_OF_BATCHES =            10; // can only call sendEmail 10 times
	private static final Integer MAX_EMAILS_TO_QUERY =          AMOUNT_OF_EMAILS_PER_BATCH * AMOUNT_OF_BATCHES;

	private List<EmailQueue__c> emailQueues { get; set; }
	private List<List<EmailQueue__c> > emailQueuesSeparated { get; set; }

	// regular fetch of most prioritised email to fetch
	public EmailQueueData( String status ) {
		createEmailQueues( status );
		createEmailQueuesSeparated();
	}

	// predefined list of emails to send
	public EmailQueueData( List<EmailQueue__c> emailQueues ) {
		this.emailQueues = emailQueues;
		createEmailQueuesSeparated();
	}

	public void createEmailQueues( String status ) {
		this.emailQueues = [SELECT SaveAsActivity__c, WhatId__c, TemplateId__c, TargetObjectId__c, Id FROM EmailQueue__c WHERE Status__c = :status ORDER BY ScheduledPriority__c DESC NULLS LAST LIMIT : MAX_EMAILS_TO_QUERY];
	}

	public void createEmailQueuesSeparated() {

		List<List<EmailQueue__c> > emailQueuesSeparated = new List<List<EmailQueue__c> >();
		List<EmailQueue__c> emailQueues = new List<EmailQueue__c>();
		Integer i = 1;

		for ( EmailQueue__c emailQueue : this.emailQueues ) {
			emailQueues.add( emailQueue );

			if ( Math.mod( i, AMOUNT_OF_EMAILS_PER_BATCH ) == 0 ) {
				emailQueuesSeparated.add( emailQueues );
				emailQueues = new List<EmailQueue__c>();
			}

			i++;
		}

		if ( Math.mod( i, AMOUNT_OF_EMAILS_PER_BATCH ) != 0 && !emailQueues.isEmpty() ) {
			emailQueuesSeparated.add( emailQueues );
		}

		this.emailQueuesSeparated = emailQueuesSeparated;
	}

	public List<EmailQueue__c> getEmailQueues() {
		return this.emailQueues;
	}

	public List<List<EmailQueue__c> > getEmailQueuesSeparated() {
		return this.emailQueuesSeparated;
	}

	public Id getOrgWideEmailId() {
		return ORG_WIDE_EMAIL_ID;
	}
}
