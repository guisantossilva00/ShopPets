trigger OrderItemTrigger on OrderItem (before insert, before update) {
    if(trigger.isBefore && (trigger.isInsert || trigger.isUpdate)){
        OrderItemTriggerHandler.valueDuringAction();
    }
}