public with sharing class EmailSchedulingLogHelper {

	public static Map<Id, List<EmailQueue__c> > getEmailQueueSubjectAsKey( List<EmailQueue__c> emailQueue, Map<Id, String> templateSubjects ) {

		Map<Id, List<EmailQueue__c> > emailQueueIdAsKey = new Map<Id, List<EmailQueue__c> >();
		for ( EmailQueue__c email : emailQueue ) {
			if ( emailQueueIdAsKey.containsKey( email.TemplateId__c ) ) {
				emailQueueIdAsKey.get( email.TemplateId__c ).add( email );
			} else {
				emailQueueIdAsKey.put( email.TemplateId__c, new List<EmailQueue__c> { email } );
			}
		}

		return emailQueueIdAsKey;
	}

	public static List<EmailSchedulingLog.LogChildren> createChildren( List<EmailQueue__c> emailQueueChildren, Map<Id, String> contactNames ) {
		List<EmailSchedulingLog.LogChildren> children = new List<EmailSchedulingLog.LogChildren>();

		for ( EmailQueue__c email : emailQueueChildren ) {

			EmailSchedulingLog.LogChildren child = new EmailSchedulingLog.LogChildren();
			child.name = email.Id;

			child.label = contactNames.get( email.TargetObjectId__c );
			child.TargetObjectId = email.TargetObjectId__c;
			child.metatext = getStatus( email.Status__c );

			children.add( child );
		}

		return children;
	}

	public static String getStatus( String status ) {
		switch on status {
			when 'Sent' {
				return 'Sendt';
			} when 'Queued' {
				return '⏱ I utsendingskø';
			} when 'Instant' {
				return '⏱ Sendes straks';
			} when 'Error' {
				return '❌ Feilet ved utsending, kontakt en administrator';
			} when else {
				return status;
			}
		}
	}

	public static String getParentMetatext( List<EmailQueue__c> emailQueueChildren ) {

		for ( EmailQueue__c children : emailQueueChildren ) {
			switch on children.Status__c {
				when 'Queued' {
					return '⏱ I utsendingskø';
				} when 'Instant' {
					return '⏱ Sendes straks';
				} when 'Error' {
					return '❌ En eller flere e-poster feiler, klikk for mer informasjon';
				} when else {}
			}
		}

		Datetime d = emailQueueChildren[0].LastModifiedDate;

		return 'Sendt (' + d.day() + '.' + d.month() + '.' + d.year() + ')';
	}
}