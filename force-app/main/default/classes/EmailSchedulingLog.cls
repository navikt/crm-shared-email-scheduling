public with sharing class EmailSchedulingLog {

	public class LogData {
		@AuraEnabled public Id Id;
		@AuraEnabled public String TargetObjectId;
		@AuraEnabled public String TargetObjectName;
		@AuraEnabled public String Status;
		@AuraEnabled public DateTime DateSent;
		@AuraEnabled public String Subject;
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

		List<LogData> data = new List<LogData>();

		for ( EmailQueue__c email : emailQueue ) {
			LogData ld = new LogData();
			ld.Id = email.Id;
			ld.TargetObjectId = '/' + email.TargetObjectId__c;
			ld.TargetObjectName = contactNames.get( email.TargetObjectId__c );
			ld.Status = getStatus( email.Status__c );
			ld.DateSent = email.LastModifiedDate;
			ld.Subject = templateSubjects.get( email.TemplateId__c );
			data.add( ld );
		}

		return data;
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
