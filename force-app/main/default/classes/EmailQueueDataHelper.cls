public without sharing class EmailQueueDataHelper {
    private static final Integer MAX_AMOUNT_OF_EMAILS_PER_DAY = 5000; // 5000 is a Salesforce limit
    private static final Integer AMOUNT_OF_EMAILS_PER_BATCH = 100; // 100 email limit per batch
    private static final Integer AMOUNT_OF_BATCHES = 10; // can only call sendEmail 10 times
    private static final Integer MAX_EMAILS_PER_TRANSACTION = AMOUNT_OF_EMAILS_PER_BATCH * AMOUNT_OF_BATCHES;

    public static Integer calculateEmailLimit() {
        List<EmailQueueSettings__c> settings = [
            SELECT Id, AmountSentToday__c
            FROM EmailQueueSettings__c
            WHERE LastModifiedDate = TODAY
            ORDER BY AmountSentToday__c DESC
        ];

        Integer emailsSentToday = settings.size() == 0 ? 0 : Integer.valueOf(settings[0].AmountSentToday__c);
        Integer remainingEmailsToday = MAX_AMOUNT_OF_EMAILS_PER_DAY - emailsSentToday;

        // no more emails are allowed to be sent today, so query limit is zero
        if (remainingEmailsToday <= 0) {
            return 0;
        } else if (remainingEmailsToday < MAX_EMAILS_PER_TRANSACTION) {
            // the remaining emails allowed to be sent today is less than the transaction limit, so the remaining emails allowed becomes the query limit
            return remainingEmailsToday;
        } else {
            // the remaining emails allowed to be sent today is more than the transaction limit, so the transaction limit becomes the query limit
            return MAX_EMAILS_PER_TRANSACTION;
        }
    }

    public static List<EmailQueue__c> fetchEmailQueues(String status, Integer queryLimit) {
        return [
            SELECT SaveAsActivity__c, WhatId__c, TemplateId__c, TargetObjectId__c, ToAddress__c, HTMLBody__c, Subject__c, Id
            FROM EmailQueue__c
            WHERE Status__c = :status
            ORDER BY ScheduledPriority__c DESC NULLS LAST
            LIMIT :queryLimit
        ];
    }

    public static List<EmailQueue__c> fetchEmailQueues(List<EmailQueue__c> emailQueues, Integer queryLimit) {
        if (emailQueues.size() > queryLimit) {
            List<EmailQueue__c> toSend = new List<EmailQueue__c>();
            List<EmailQueue__c> toQueue = new List<EmailQueue__c>();

            for (Integer i = 0; i < queryLimit; i++) {
                toSend.add(emailQueues[i]);
            }
            for (Integer i = queryLimit; i < emailQueues.size(); i++) {
                toQueue.add(emailQueues[i]);
            }
            for (EmailQueue__c email : toQueue) {
                email.Status__c = 'Queued';
            }

            update toQueue;

            return toSend;
        } else {
            return emailQueues;
        }
    }

    public static List<List<EmailQueue__c>> separateEmailQueues(List<EmailQueue__c> emailQueues) {
        List<List<EmailQueue__c>> emailQueuesBatches = new List<List<EmailQueue__c>>();
        List<EmailQueue__c> emailQueuesSeparated = new List<EmailQueue__c>();
        Integer i = 1;

        if (emailQueues.size() == 0) {
            return emailQueuesBatches;
        }

        for (EmailQueue__c emailQueue : emailQueues) {
            emailQueuesSeparated.add(emailQueue);

            if (Math.mod(i, AMOUNT_OF_EMAILS_PER_BATCH) == 0) {
                emailQueuesBatches.add(emailQueuesSeparated);
                emailQueuesSeparated = new List<EmailQueue__c>();
            }

            i++;
        }

        if (Math.mod(i, AMOUNT_OF_EMAILS_PER_BATCH) != 0 && !emailQueuesSeparated.isEmpty()) {
            emailQueuesBatches.add(emailQueuesSeparated);
        }

        return emailQueuesBatches;
    }
}
