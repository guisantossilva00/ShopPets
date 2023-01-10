trigger OrderTrigger on Order (before update, after update){
    switch on Trigger.operationType{
        when AFTER_UPDATE{
            OrderTriggerHandler.orderSAP();
            OrderTriggerHandler.orderStatusUpdateSAP();
        }
        when BEFORE_UPDATE{
            OrderTriggerHandler.setStatus();
        }
    }
}