
global class EmailQueueScheduler implements Schedulable {

	global void execute( SchedulableContext ctx ) {
		processEmailQueue();
	}

	@AuraEnabled
	public static void processEmailQueue() {
		EmailQueueData data = new EmailQueueData();
		for ( List<EmailQueue__c> emailQueuesToSend : data.getEmailQueuesSeparated() ) {
			System.enqueueJob( new EmailQueueJob( emailQueuesToSend ) );
		}
	}
}