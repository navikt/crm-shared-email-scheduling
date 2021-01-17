public with sharing class EmailQueueData {

	private static final List<OrgWideEmailAddress> ORG_WIDE_ADDRESSES = [SELECT Id FROM OrgWideEmailAddress WHERE Address = 'do-not-reply@info.nav.no' LIMIT 1];
	private static final Id ORG_WIDE_EMAIL_ID =                         ORG_WIDE_ADDRESSES.size() == 1 ? ORG_WIDE_ADDRESSES[0].Id : null;

	private static final Integer MAX_AMOUNT_OF_EMAILS_PER_DAY = 5000; // 5000 is a Salesforce limit
	private static final Integer AMOUNT_OF_EMAILS_PER_BATCH =   100; // 100 email limit per batch
	private static final Integer AMOUNT_OF_BATCHES =            10; // can only call sendEmail 10 times
	private static final Integer MAX_EMAILS_PER_TRANSACTION =   AMOUNT_OF_EMAILS_PER_BATCH * AMOUNT_OF_BATCHES;
	private Integer queryLimit { get; set; }

	private List<EmailQueue__c> emailQueues { get; set; }
	private List<List<EmailQueue__c> > emailQueuesSeparated { get; set; }

	// regular fetch of most prioritised email to fetch
	public EmailQueueData( String status ) {
		fetchEmailLimit();
		createEmailQueues( status );
		createEmailQueuesSeparated();
	}

	// predefined list of emails to send
	public EmailQueueData( List<EmailQueue__c> emailQueues ) {
		fetchEmailLimit();

		if ( emailQueues.size() > this.queryLimit ) {

			List<EmailQueue__c> toSend = new List<EmailQueue__c>();
			List<EmailQueue__c> toQueue = new List<EmailQueue__c>();

			for ( Integer i = 0; i < this.queryLimit; i++ ) {
				toSend.add( emailQueues[i] );
			} for ( Integer i = this.queryLimit; i < emailQueues.size(); i++ ) {
				toQueue.add( emailQueues[i] );
			} for ( EmailQueue__c email : toQueue ) {
				email.Status__c = 'Queued';
			}

			update toQueue;
			this.emailQueues = toSend;
		} else {
			this.emailQueues = emailQueues;
		}

		createEmailQueuesSeparated();
	}
	public void fetchEmailLimit( ) {

		List<EmailQueueSettings__c> settings = [SELECT Id, AmountSentToday__c FROM EmailQueueSettings__c WHERE LastModifiedDate = TODAY ORDER BY AmountSentToday__c DESC];

		Integer emailsSentToday = settings.size() == 0 ? 0 : Integer.valueOf( settings[0].AmountSentToday__c );
		Integer remainingEmailsToday = MAX_AMOUNT_OF_EMAILS_PER_DAY - emailsSentToday;

		// no more emails are allowed to be sent today, so query limit is zero
		if ( remainingEmailsToday <= 0 ) {
			this.queryLimit = 0;
		}

		// the remaining emails allowed to be sent today is less than the transaction limit, so the remaining emails allowed becomes the query limit
		else if ( remainingEmailsToday < MAX_EMAILS_PER_TRANSACTION ) {
			this.queryLimit = remainingEmailsToday;
		}

		// the remaining emails allowed to be sent today is more than the transaction limit, so the transaction limit becomes the query limit
		else {
			this.queryLimit = MAX_EMAILS_PER_TRANSACTION;
		}

	}

	public void createEmailQueues( String status ) {
		this.emailQueues = [SELECT SaveAsActivity__c, WhatId__c, TemplateId__c, TargetObjectId__c, Id FROM EmailQueue__c WHERE Status__c = :status ORDER BY ScheduledPriority__c DESC NULLS LAST LIMIT : this.queryLimit];
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
