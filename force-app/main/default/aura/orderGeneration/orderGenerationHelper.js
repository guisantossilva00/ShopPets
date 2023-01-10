({
	continue : function(component, event) {
    	var option = component.get("v.type");
        if(option == "Nenhum"){
            this.toastValidation();
        }
    	if(option == "Energia"){
    		component.set("v.noneOrder", false);
    		component.set("v.energyOrder", true);
		}	
        if(option == "Açúcar"){
            component.set("v.noneOrder", false);
    		component.set("v.sugarOrder", true);
        }
 	},
 
 	select : function(component, event) {
    	component.set("v.type", event.target.value);
 	},
        
    cancel : function (component, event){
        var close = $A.get("e.force:closeQuickAction");
        close.fire();
    },
        
    returnAura : function (component, event){
        component.set("v.type", "Nenhum");
    	component.set("v.energyOrder", false);
        component.set("v.sugarOrder", false);
        component.set("v.noneOrder", true);
    }, 
        
    close : function(){
        $A.get("e.force:closeQuickAction").fire();
    },
        
    toastValidation : function(){
		var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title: "Selecione o tipo de pedido",
            message: "O tipo de pedido deve ser selecionado para continuar.",
            type: "Warning"});
        toastEvent.fire(); 
    }
})