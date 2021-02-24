trigger EmailQueueTrigger on EmailQueue__c(before insert, before update, after insert, after update) {
    if (Trigger.isBefore) {
        EmailQueueTrigger_setTemplate.verifyTemplateId(Trigger.new);
    } else if (Trigger.isAfter) {
        EmailQueueTrigger_sendInstant.process(Trigger.new);
    }
}
