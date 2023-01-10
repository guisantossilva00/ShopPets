({
	verificaUser: function (component, event, helpler) {        
        var queryString = window.location.search;        
        var local = location.protocol + '//' + location.host;
        var urlParams = new URLSearchParams(queryString);
        var userid = urlParams.get("id");        
        if (!userid) {
            userid = 'redirect';
        }
        var action = component.get("c.verificaUser");
        action.setParams({userid:userid.trim()});
        action.setCallback(this, function(a){
            var rtnValue = a.getReturnValue(); 
            if(rtnValue != 'User Updated' && rtnValue == local){                                
                component.set("v.showRegMsg", false);
                window.location.href = "./";
            }else{                
                component.set("v.showRegMsg", true);                
            }
        });
        $A.enqueueAction(action);
        
    }
    
})