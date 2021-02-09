public without sharing class EmailQueueJob implements Queueable, Database.AllowsCallouts {
    private List<EmailQueue__c> emailQueues { get; set; }
    private Id orgWideEmailId { get; set; }

    public EmailQueueJob(List<EmailQueue__c> emailQueues, Id orgWideEmailId) {
        this.emailQueues = emailQueues;
        this.orgWideEmailId = orgWideEmailId;
    }

    public void execute(QueueableContext context) {
        List<Messaging.SendEmailResult> emailResults = EmailQueueJobHelper.sendEmail(
            this.emailQueues,
            this.orgWideEmailId
        );
        EmailQueueJobHelper.updateEmailQueues(this.emailQueues, emailResults);
    }
}
