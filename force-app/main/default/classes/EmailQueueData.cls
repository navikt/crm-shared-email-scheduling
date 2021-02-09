public with sharing class EmailQueueData {
    private static final List<OrgWideEmailAddress> ORG_WIDE_ADDRESSES = [
        SELECT Id
        FROM OrgWideEmailAddress
        WHERE Address = 'do-not-reply@info.nav.no'
        LIMIT 1
    ];
    private static final Id ORG_WIDE_EMAIL_ID = ORG_WIDE_ADDRESSES.size() == 1
        ? ORG_WIDE_ADDRESSES[0].Id
        : null;

    private Integer queryLimit { get; set; }
    private List<EmailQueue__c> emailQueues { get; set; }
    private List<List<EmailQueue__c>> emailQueuesSeparated { get; set; }

    // regular fetch of most prioritised email to fetch
    public EmailQueueData(String status) {
        this.queryLimit = EmailQueueDataHelper.calculateEmailLimit();
        this.emailQueues = EmailQueueDataHelper.fetchEmailQueues(
            status,
            this.queryLimit
        );
        this.emailQueuesSeparated = EmailQueueDataHelper.separateEmailQueues(
            this.emailQueues
        );
    }

    // predefined list of emails to send
    public EmailQueueData(List<EmailQueue__c> emailQueues) {
        this.queryLimit = EmailQueueDataHelper.calculateEmailLimit();
        this.emailQueues = EmailQueueDataHelper.fetchEmailQueues(
            emailQueues,
            this.queryLimit
        );
        this.emailQueuesSeparated = EmailQueueDataHelper.separateEmailQueues(
            this.emailQueues
        );
    }

    public List<EmailQueue__c> getEmailQueues() {
        return this.emailQueues;
    }

    public List<List<EmailQueue__c>> getEmailQueuesSeparated() {
        return this.emailQueuesSeparated;
    }

    public Id getOrgWideEmailId() {
        return ORG_WIDE_EMAIL_ID;
    }
}
