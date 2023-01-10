({
    initialize: function(component, event, helper) {
        $A.get("e.siteforce:registerQueryEventMap").setParams({"qsToEvent" : helper.qsToEventMap}).fire();
        $A.get("e.siteforce:registerQueryEventMap").setParams({"qsToEvent" : helper.qsToEventMap2}).fire();        
    },
    
    verificaCep: function (component, event, helper) {        
        helper.verificaCep(component, event, helper);
    },
    
    handleSelfRegister: function (component, event, helpler) {
        helpler.handleSelfRegister(component, event, helpler);
    },
    
    createLead: function (component, event, helpler) {
        helpler.createLead(component, event, helpler);
    },
    
    backSelfRegister: function (component, event, helpler) {
        helpler.backSelfRegister(component, event, helpler);
    },
    
    setStartUrl: function (component, event, helpler) {
        var startUrl = event.getParam('startURL');
        if(startUrl) {
            component.set("v.startUrl", startUrl);
        }
    },
    
    setExpId: function (component, event, helper) {
        var expId = event.getParam('expid');
        if (expId) {
            component.set("v.expid", expId);
        }
        helper.setBrandingCookie(component, event, helper);
    },
    
    onKeyUp: function(component, event, helpler){
        //checks for "enter" key
        if (event.getParam('keyCode')===13) {
            helpler.handleSelfRegister(component, event, helpler);
        }
    },
    
    mascaraCEP: function(component, event, helpler){        
        helpler.handleMascaraCEP(component, event, helpler);
    },
    
    mascaraCEP2: function(component, event, helpler){        
        helpler.handleMascaraCEP2(component, event, helpler);
    },
    
    mascaraCNPJ: function(component, event, helpler){   
        helpler.handleMascaraCNPJ(component, event, helpler);
    }, 
    
    mascaraTel: function(component, event, helpler){        
        helpler.handleMascaraTel(component, event, helpler);
    },  
    
    mascaraUF: function(component, event, helpler){         
       helpler.mascaraUF(component, event, helpler);
    }, 
    
    mascaraNumero: function(component, event, helpler){         
       helpler.mascaraNumero(component, event, helpler);
    },
    
    mascaraInscricao: function(component, event, helpler){         
       helpler.mascaraInscricao(component, event, helpler);
    },
    
    onCheck: function(component, event, helpler) {
		var checkCmp = component.find("checkbox_entrega").get("v.value");
        component.find("checkResult").set("v.value", checkCmp);
	 },
})