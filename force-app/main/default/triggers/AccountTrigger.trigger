trigger AccountTrigger on Account (after insert, after update){
    if(trigger.isAfter && (trigger.isInsert || trigger.isUpdate)){
        AccountTriggerHandler.ContactPoint();
    }
}