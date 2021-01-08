
public with sharing class EmailQueueJob implements Queueable, Database.AllowsCallouts {

	private List<EmailQueue__c> emailQueues { get; set; }

	public EmailQueueJob( List<EmailQueue__c> emailQueues ) {
		this.emailQueues = emailQueues;
	}

	public void execute( QueueableContext context ) {

		List<Messaging.SingleEmailMessage> messages = new List<Messaging.SingleEmailMessage>();

		for ( EmailQueue__c emailQueue : this.emailQueues ) {

			Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();

			// message.setOrgWideEmailAddressId( orgWideEmailId );
			message.setWhatId(          emailQueue.WhatId__c );
			message.setTemplateId(      emailQueue.TemplateId__c );
			message.setTargetObjectId(  emailQueue.TargetObjectId__c );
			message.setSaveAsActivity(  emailQueue.SaveAsActivity__c );

			messages.add( message );
		}

		List<Messaging.SendEmailResult> results = Messaging.sendEmail ( messages, false );
	}
}
