public inherited sharing class EmailQueueTrigger_sendInstant {
    public static void process(List<EmailQueue__c> emailQueue) {
        List<EmailQueue__c> filteredRecords = findInstantRecords(emailQueue);

        if (filteredRecords.size() > 0) {
            EmailQueueData data = new EmailQueueData(filteredRecords);

            for (List<EmailQueue__c> emailQueuesToSend : data.getEmailQueuesSeparated()) {
                Id jobId = System.enqueueJob(new EmailQueueJob(emailQueuesToSend, data.getOrgWideEmailId()));
            }

            EmailQueueJobHelper.updateEmailQueueSettings(data.getEmailQueues());
        }
    }

    public static List<EmailQueue__c> findInstantRecords(List<EmailQueue__c> emailQueue) {
        List<EmailQueue__c> filteredQueue = new List<EmailQueue__c>();

        for (EmailQueue__c queue : emailQueue) {
            if (queue.Status__c == 'Instant') {
                filteredQueue.add(queue);
            }
        }

        Set<Id> queueIds = new Map<Id, EmailQueue__c>(filteredQueue).keySet();

        return [
            SELECT SaveAsActivity__c, WhatId__c, TemplateId__c, TargetObjectId__c, ToAddress__c, HTMLBody__c, Subject__c, Id
            FROM EmailQueue__c
            WHERE Id IN :queueIds
        ];
    }
}
