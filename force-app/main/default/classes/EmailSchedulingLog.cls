public with sharing class EmailSchedulingLog {

	public class LogData {
		@AuraEnabled public String Id;
		@AuraEnabled public String Main;
		@AuraEnabled public String MainUrl;
		@AuraEnabled public String Status;
		@AuraEnabled public DateTime DateSent;
		@AuraEnabled public List<LogChildren> Children;
	}

	public class LogChildren {
		@AuraEnabled public Id Id;
		@AuraEnabled public String MainUrl;
		@AuraEnabled public String Main;
		@AuraEnabled public String Status;
		@AuraEnabled public DateTime DateSent;
	}

	@AuraEnabled(cacheable = true)
	public static List<LogData> getLogData( Id recordId ) {

		List<EmailQueue__c> emailQueue = getEmailQueue( recordId );
		Map<Id, String> templateSubjects = getTemplateSubjects( emailQueue );
		Map<Id, String> contactNames = getContactNames( emailQueue );

		return createData( emailQueue, templateSubjects, contactNames );
	}

	public static List<EmailQueue__c> getEmailQueue( Id recordId ) {
		return [SELECT Id, TargetObjectId__c, Status__c, TemplateId__c, LastModifiedDate FROM EmailQueue__c WHERE WhatId__c = : recordId ORDER BY LastModifiedDate DESC];
	}

	public static Map<Id, String> getTemplateSubjects( List<EmailQueue__c> emailQueue ) {

		Set<Id> templateIds = new Set<Id>();
		for ( EmailQueue__c email : emailQueue ) {
			templateIds.add( email.TemplateId__c );
		}

		List<EmailTemplate> emailTemplates = [SELECT Id, Subject FROM EmailTemplate WHERE Id IN : templateIds];

		Map<Id, String> templateSubjects = new Map<Id, String>();
		for ( EmailTemplate emailTemplate : emailTemplates ) {
			templateSubjects.put( emailTemplate.Id, emailTemplate.Subject );
		}

		return templateSubjects;
	}

	public static Map<Id, String> getContactNames( List<EmailQueue__c> emailQueue ) {

		Set<Id> contactIds = new Set<Id>();
		for ( EmailQueue__c email : emailQueue ) {
			contactIds.add( email.TargetObjectId__c );
		}

		List<Contact> contacts = [SELECT Id, Name FROM Contact WHERE Id IN : contactIds];

		Map<Id, String> contactNames = new Map<Id, String>();
		for ( Contact contact : contacts ) {
			contactNames.put( contact.Id, contact.Name );
		}

		return contactNames;
	}

	public static List<LogData> createData( List<EmailQueue__c> emailQueue, Map<Id, String> templateSubjects, Map<Id, String> contactNames ) {

		Map<String, List<EmailQueue__c> > emailQueueSubjectKey = new Map<String, List<EmailQueue__c> >();

		for ( EmailQueue__c email : emailQueue ) {
			if ( emailQueueSubjectKey.containsKey( templateSubjects.get( email.TemplateId__c ) ) ) {
				emailQueueSubjectKey.get( templateSubjects.get( email.TemplateId__c ) ).add( email );
			} else {
				emailQueueSubjectKey.put( templateSubjects.get( email.TemplateId__c ), new List<EmailQueue__c> { email } );
			}
		}

		List<LogData> parents = new List<LogData>();

		for ( String subject : emailQueueSubjectKey.keySet() ) {

			List<EmailQueue__c> emailQueueChildren = emailQueueSubjectKey.get( subject );

			LogData parent = new LogData();
			parent.Id = subject;
			parent.Main = subject;
			parent.MainUrl = '';
			parent.Status = getStatus( emailQueue[0].Status__c );
			parent.DateSent = emailQueue[0].LastModifiedDate;

			List<LogChildren> children = new List<LogChildren>();

			for ( EmailQueue__c email : emailQueueChildren ) {

				LogChildren child = new LogChildren();
				child.Id = email.Id;

				child.Main = contactNames.get( email.TargetObjectId__c );
				child.MainUrl = '/' + email.TargetObjectId__c;

				child.Status = getStatus( email.Status__c );
				parent.DateSent = email.LastModifiedDate;

				children.add( child );
			}
			parent.Children = children;
			parents.add( parent );
		}

		return parents;
	}

	public static String getStatus( String status ) {
		switch on status {
			when 'Sent' {
				return 'Sendt';
			} when 'Queued' {
				return 'I utsendingskø';
			} when 'Instant' {
				return 'Sender straks';
			} when 'Error' {
				return 'Feil';
			} when else {
				return status;
			}
		}
	}
}
