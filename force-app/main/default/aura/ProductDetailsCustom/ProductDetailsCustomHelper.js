({
	loadProductDetails: function (component, event, helper) {             
		var queryString = window.location.pathname;
        var productId = queryString.substring(queryString.lastIndexOf('/') + 1);        
        var action = component.get("c.getProductDetails");                    
        action.setParams({productId: productId});
        action.setCallback(this, function(a){
            var rtnValue = a.getReturnValue();                     
			var keyCount  = Object.keys(rtnValue[0]).length;
            if(keyCount > 1){                 
            	component.set("v.ProductDetails",rtnValue);
            }
            
        });
        $A.enqueueAction(action);
	},
    loadProductDescription: function (component, event, helper) {
		var queryString = window.location.pathname;
        var productId = queryString.substring(queryString.lastIndexOf('/') + 1);        
        var action = component.get("c.getProductDescription");                    
        action.setParams({productId: productId});
        action.setCallback(this, function(a){
            var rtnValue = a.getReturnValue();             
            if(rtnValue){
                 component.set("v.productDescription",rtnValue);
            }            
        });
        $A.enqueueAction(action);
	}
})