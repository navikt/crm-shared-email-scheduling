public without sharing class EmailQueueInstantSend {

	public static void process( List<EmailQueue__c> emailQueue ) {
		if ( findInstantRecords( emailQueue ).size() > 0 ) {
			EmailQueueScheduler.processEmailQueue( 'Instant' );
		}
	}

	public static List<EmailQueue__c> findInstantRecords( List<EmailQueue__c> emailQueue ) {

		List<EmailQueue__c> filteredQueue = new List<EmailQueue__c>();

		for ( EmailQueue__c queue : emailQueue ) {
			if ( queue.Status__c == 'Instant' ) {
				filteredQueue.add( queue );
			}
		}

		return filteredQueue;
	}
}
