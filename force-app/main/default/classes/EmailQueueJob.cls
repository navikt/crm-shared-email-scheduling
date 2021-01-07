
public with sharing class EmailQueueJob implements Queueable, Database.AllowsCallouts {

	private List<EmailQueue__c> emailQueues { get; set; }
	Map<Id, EmailTemplate> emailTemplates { get; set; }

	public EmailQueueJob( List<EmailQueue__c> emailQueues, Map<Id, EmailTemplate> emailTemplates ) {
		this.emailQueues = emailQueues;
		this.emailTemplates = emailTemplates;
	}

	public void execute( QueueableContext context ) {

		// for(Object var : Source) {
		//     Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();

		// 		Id contactId = req.recipientContact != null ? req.recipientContact.Id : req.recipientContactId;

		// 		if ( orgWideEmailId != null && req.useDoNotReply ) { message.setOrgWideEmailAddressId( orgWideEmailId ); }
		// 		if ( templateId != null ) { message.setTemplateId( templateId ); }
		// 		message.setWhatId( req.relatedToId );
		// 		message.setTargetObjectId( contactId );
		// 		message.setSaveAsActivity( req.saveAsActivity );

		// 		messages.add( message );
		// }

	}
}
