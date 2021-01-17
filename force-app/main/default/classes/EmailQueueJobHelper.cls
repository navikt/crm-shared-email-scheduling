public without sharing class EmailQueueJobHelper {

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
					List<String> errorType = new List<String> ();
					for ( Messaging.SendEmailError error : emailResults[i].getErrors() ) {
						errorType.add( error.getStatusCode().name() );
						errorMsg.add( error.getMessage() );
					}
					emailQueues[i].ErrorType__c = String.join( errorType, ', ' );
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

	public static void updateEmailQueueSettings( List<EmailQueue__c> emailQueues ) {

		List<EmailQueueSettings__c> settings = [SELECT Id, LastModifiedDate, ResetDate__c, AmountSentToday__c FROM EmailQueueSettings__c ORDER BY LastModifiedDate DESC LIMIT 1];

		// never created before
		if ( settings.size() == 0 ) {
			insert new EmailQueueSettings__c( AmountSentToday__c = emailQueues.size(), ResetDate__c = Date.today() );
		}

		else {
			// was updated previously today
			if ( settings[0].ResetDate__c == Date.today() ) {
				settings[0].AmountSentToday__c += emailQueues.size();
			}
			// previous day
			else {
				settings[0].AmountSentToday__c = emailQueues.size();
				settings[0].ResetDate__c = Date.today();
			}
			update settings;
		}
	}
}