public with sharing class EmailSchedulingLog {

	public class LogData {
		@AuraEnabled public String name; // id
		@AuraEnabled public String label;
		@AuraEnabled public Id TargetObjectId;
		@AuraEnabled public Boolean expanded;
		@AuraEnabled public String metatext;
		@AuraEnabled public List<LogChildren> items;
	}

	public class LogChildren {
		@AuraEnabled public String name; // id
		@AuraEnabled public String label;
		@AuraEnabled public Id TargetObjectId;
		@AuraEnabled public String metatext;
	}

	@AuraEnabled(cacheable = true)
	public static List<LogData> getLogData( Id recordId ) {

		List<EmailQueue__c> emailQueue = getEmailQueue( recordId );
		Map<Id, String> templateSubjects = getTemplateSubjects( emailQueue );
		Map<Id, String> contactNames = getContactNames( emailQueue );
		List<LogData> logData = createData( emailQueue, templateSubjects, contactNames );

		return logData;
	}


	// ------------------------------------------------
	// --------------- HELPER FUNCTIONS ---------------
	// ------------------------------------------------

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

		Map<String, List<EmailQueue__c> > emailQueueSubjectKey = EmailSchedulingLogHelper.getEmailQueueSubjectAsKey( emailQueue, templateSubjects );

		List<LogData> parents = new List<LogData>();
		for ( String subject : emailQueueSubjectKey.keySet() ) {

			LogData parent = new LogData();
			parent.name = subject;
			parent.label = subject;
			parent.expanded = false;

			List<EmailQueue__c> emailQueueChildren = emailQueueSubjectKey.get( subject );
			parent.metatext = EmailSchedulingLogHelper.getParentMetatext( emailQueueChildren );
			parent.items = EmailSchedulingLogHelper.createChildren( emailQueueChildren, contactNames );

			parents.add( parent );
		}

		return parents;
	}
}
