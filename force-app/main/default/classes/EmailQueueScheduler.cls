
global class EmailQueueScheduler implements Schedulable {

	global void execute( SchedulableContext ctx ) {
		processEmailQueue();
	}

	@AuraEnabled
	public static String processEmailQueue() {
		EmailQueueData data = new EmailQueueData();
		for ( List<EmailQueue__c> emailQueuesToSend : data.getEmailQueuesSeparated() ) {
			// System.enqueueJob( new EmailQueueJob( emailQueuesToSend, data.getOrgWideEmailId() ) );
			List<Messaging.SendEmailResult> emailResults = EmailQueueHelper.sendEmail( emailQueuesToSend, data.getOrgWideEmailId() );
			EmailQueueHelper.updateEmailQueues( emailQueuesToSend, emailResults );
		}

		return 'Started processing ' + data.getEmailQueues().size() + ' queued emails.';
	}
}