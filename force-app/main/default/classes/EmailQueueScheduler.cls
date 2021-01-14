
global without sharing class EmailQueueScheduler implements Schedulable {

	global void execute( SchedulableContext ctx ) {
		processEmailQueue();
	}

	@AuraEnabled
	public static List<Id> processEmailQueue() {
		EmailQueueData data = new EmailQueueData();
		List<Id> jobIds = new List<Id>();
		for ( List<EmailQueue__c> emailQueuesToSend : data.getEmailQueuesSeparated() ) {
			Id jobId = System.enqueueJob( new EmailQueueJob( emailQueuesToSend, data.getOrgWideEmailId() ) );
			jobIds.add( jobId );
		}

		return jobIds;
	}

	@AuraEnabled
	public static Integer getJobStatus( List<Id> jobIds ) {

		// TODO check for failed jobs and throw AuraException
		return [SELECT COUNT() FROM AsyncApexJob WHERE JobType = 'Queueable' AND Status = 'Completed' AND Id IN : jobIds];
	}
}