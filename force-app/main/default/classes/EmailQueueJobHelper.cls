public with sharing class EmailQueueJobHelper {

	public static List<Messaging.SendEmailResult> sendEmail( List<EmailQueue__c> emailQueues, Id orgWideEmailId ) {

		List<Messaging.SingleEmailMessage> messages = new List<Messaging.SingleEmailMessage>();
		for ( EmailQueue__c emailQueue : emailQueues ) {
			Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
			message.setWhatId(                  emailQueue.WhatId__c );
			message.setTemplateId(              emailQueue.TemplateId__c );
			message.setTargetObjectId(          emailQueue.TargetObjectId__c );
			message.setSaveAsActivity(          emailQueue.SaveAsActivity__c );
			message.setOrgWideEmailAddressId(   orgWideEmailId );
			messages.add( message );
		}

		return Messaging.sendEmail ( messages, false );
	}

	public static void updateEmailQueues( List<EmailQueue__c> emailQueues, List<Messaging.SendEmailResult> emailResults ) {

		if ( emailQueues.size() == emailResults.size() ) {

			for ( Integer i = 0; i < emailQueues.size(); i++ ) {

				if ( emailResults[i].isSuccess() ) {
					emailQueues[i].Status__c = 'Sent';
				}

				else {

					emailQueues[i].Status__c = 'Error';

					List<String> errorMsg = new List<String> ();
					for ( Messaging.SendEmailError error : emailResults[i].getErrors() ) {
						errorMsg.add( error.getStatusCode().name() );
						errorMsg.add( error.getMessage() );
						errorMsg.add( '' );
					}
					emailQueues[i].Error__c = String.join( errorMsg, '\n' );
				}
			}
		}

		// emailQueues and emailResults should always be the same, but handled just in case they're not
		else {

			List<String> emailQueueIds = new List<String>();
			for ( EmailQueue__c emailQueue : emailQueues ) {
				emailQueueIds.add( emailQueue.Id );
			}

			for ( EmailQueue__c emailQueue : emailQueues ) {
				emailQueue.Status__c = 'Error';
				emailQueue.Error__c = 'Some, all or no emails may have been sent. The amount of emailQueues and emailResults are different, so it\'s impossible to know which.\n\nThe other EmailQueue__c records that were in the same batch:\n' + String.join( emailQueueIds, '\n' );
			}
		}

		update emailQueues;
	}
}
