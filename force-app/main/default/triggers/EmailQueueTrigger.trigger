trigger EmailQueueTrigger on EmailQueue__c ( after insert, after update ) {
	EmailQueueInstantSend.process( Trigger.new );
}