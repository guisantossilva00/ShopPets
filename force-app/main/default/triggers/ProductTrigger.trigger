trigger ProductTrigger on Product2 (after insert, before update, before insert){
    if(trigger.isAfter && (trigger.isInsert)){
        if(!Test.isRunningTest()) ProductTriggerHandler.ProductOrder();
    }
    if(trigger.isBefore && (trigger.isInsert || trigger.isUpdate)){
        ProductTriggerHandler.formatNameDescription();
        if(trigger.isUpdate){
            ProductTriggerHandler.fixedManualDescription();
        }
    }
}