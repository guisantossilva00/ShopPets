trigger B2BCartTypeTrigger on WebCart (before insert, before update) {
	switch on Trigger.operationType{
        when BEFORE_INSERT {
            for(WebCart wc : Trigger.New){
				B2BCartTypeTriggerHandler.cartTypeHandler(wc);
            }
        }
		when BEFORE_UPDATE {
			for(WebCart wc : Trigger.New){
				B2BCartTypeTriggerHandler.cartTypeHandler(wc);
            }
        }
    }
}