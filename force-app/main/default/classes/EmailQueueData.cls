public with sharing class EmailQueueData {

	private static final List<OrgWideEmailAddress> ORG_WIDE_ADDRESSES = [SELECT Id FROM OrgWideEmailAddress WHERE Address = 'do-not-reply@info.nav.no' LIMIT 1];
	private static final Id ORG_WIDE_EMAIL_ID = ORG_WIDE_ADDRESSES.size() == 1 ? ORG_WIDE_ADDRESSES[0].Id : null;

	private static final Integer AMOUNT_OF_EMAILS_LEFT = Limits.getLimitEmailInvocations();
	private static final Integer MAX_EMAILS_TO_QUERY = 350; // 350 emails / 10 emails per batch => 35 batches

	private List<EmailQueue__c> emailQueues { get; set; }
	private List<List<EmailQueue__c> > emailQueuesSeparated { get; set; }
	private Map<Id, EmailTemplate> emailTemplates { get; set; }

	public EmailQueueData() {
		createEmailQueues();
		createEmailQueuesSeparated();
		createEmailTemplates();
	}

	public static void createEmailQueues() {
	}

	public static void createEmailQueuesSeparated() {
	}

	public static void createEmailTemplates() {
	}

	public List<List<EmailQueue__c> > getEmailQueuesSeparated() {
		return this.emailQueuesSeparated;
	}

	public Map<Id, EmailTemplate> getEmailTemplates() {
		return this.emailTemplates;
	}
}
