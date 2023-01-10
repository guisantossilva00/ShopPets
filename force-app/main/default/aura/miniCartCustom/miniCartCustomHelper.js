({
	loadMiniCart: function (component, event, helper) {                
        var cartId = component.get("v.cartId");                        
        var action = component.get("c.getMiniCart");       
        action.setParams({cartId:cartId});
        action.setCallback(this, function(a){
            var rtnValue = a.getReturnValue();
            if (rtnValue == null) {
                component.set("v.errorMessage",rtnValue);
                component.set("v.showError",true);
            }else{
                
                if(rtnValue.length > 0 ){
                    for(var i = 0; i < rtnValue.length; i++){                    
                        rtnValue[i][12] = parseFloat(rtnValue[i][3]).toFixed(2).replace('.', ',').replace(/(\d)(?=(\d{3})+(?!\d))/g, '$1.');
                        rtnValue[i][13] = parseFloat(rtnValue[i][7]).toFixed(2).replace('.', ',').replace(/(\d)(?=(\d{3})+(?!\d))/g, '$1.');
                        rtnValue[i][14] = parseFloat(rtnValue[i][8]).toFixed(2).replace('.', ',').replace(/(\d)(?=(\d{3})+(?!\d))/g, '$1.');
                        //378
                    }                        
                    component.set('v.CartItens',rtnValue);                        
                    var ele = document.getElementById("hiddenQuantity");
                    ele.value = rtnValue[0][9];
                    var eventchange = new Event('change');
                    ele.dispatchEvent(eventchange);
					document.getElementById("cartTotalItens").innerHTML = rtnValue[0][9];
                    document.getElementById("cartTotalPrice").innerHTML = rtnValue[0][8];
                }else{
                    component.set('v.CartItens','');
                }                    
            }
        });
        
        $A.enqueueAction(action); 
	},
    updateCart: function (component, event, helper) { 
        helper.getCartId(component, event, helper);
        // $A.get('e.force:refreshView').fire();
    },
    updateCartItem: function (component, event, helper, origin, quantity) {
        var load = document.getElementById("loadingSpinnerContainer");
        $A.util.removeClass(load, 'hide');
        var cartItem = event.currentTarget.id.split('-')[1];
        var decrease = document.getElementById("decrease-"+cartItem);
        $A.util.removeClass(decrease, 'dis');
        if(!origin && quantity == 0){
            quantity = 1;            
        }        
        if(origin == 'decrease' && document.getElementById("quantity-"+cartItem).value == 1){                        
            $A.util.addClass(decrease, 'dis');
            $A.util.addClass(load, 'hide');
        }else{             
            var cartId = component.get("v.cartId");
            var action = component.get("c.updateCartController");
            action.setParams({cartId: cartId, cartItem: cartItem, origin: origin, quantity: quantity});
            action.setCallback(this, function(a){
                var rtnValue = a.getReturnValue();            
                if (rtnValue == null) {
                    component.set("v.errorMessage",rtnValue);
                    component.set("v.showError",true);
                }else{                
                    var itemPrice = document.getElementById("itemPrice-"+cartItem).getAttribute('data-val');                    
                    document.getElementById("quantity-"+cartItem).value = rtnValue;                 
                    if(rtnValue == 1){                        
            			$A.util.addClass(decrease, 'dis');
                    }
                    document.getElementById("itemTotalPrice-"+cartItem).innerHTML = (rtnValue * itemPrice).toFixed(2).replace('.', ',').replace(/(\d)(?=(\d{3})+(?!\d))/g, '$1.');                                   
                    document.getElementById("itemTotalPrice-"+cartItem).setAttribute('data-val',(rtnValue * itemPrice));
                    helper.updateCartData();                 
                }
            });
        }

        $A.enqueueAction(action);
	},
    getCartId: function (component, event, helper) {
        var action = component.get("c.getCartIdController");
        action.setCallback(this, function(a){
            var rtnValue = a.getReturnValue();
            if (rtnValue != null) {
            	component.set('v.cartId',rtnValue);
                helper.loadMiniCart(component, event, helper);
            }
        });
        $A.enqueueAction(action);
	},
    clearCart: function (component, event, helper) {
        var cartId = component.get("v.cartId");
        var action = component.get("c.clearCartController");
        action.setParams({cartId:cartId});
        action.setCallback(this, function(a){
            var rtnValue = a.getReturnValue();
            if (rtnValue == null) {
            	window.location.href = "/";
            }
        });
        $A.enqueueAction(action);
	},
    updateCartData: function () {
        var quantityItemCart = document.getElementsByClassName('quantityItemCart');
        var totalItens = 0;
        for(var i = 0; i < quantityItemCart.length; i++){
            totalItens = parseInt(totalItens) + parseInt(quantityItemCart[i].value);  
        }
        document.getElementById("cartTotalItens").innerHTML = totalItens;
        
        var ele = document.getElementById("hiddenQuantity");
        ele.value = totalItens;
        var eventchange = new Event('change');
        ele.dispatchEvent(eventchange);
                
        var itemTotalPrice = document.getElementsByClassName('itemTotalPrice');
        var totalPriceItens = 0;         
        for(var k = 0; k < itemTotalPrice.length; k++){              
            totalPriceItens = totalPriceItens + parseFloat(itemTotalPrice[k].getAttribute('data-val'));  
        }
        document.getElementById("cartTotalPrice").innerHTML = totalPriceItens.toFixed(2).replace('.', ',').replace(/(\d)(?=(\d{3})+(?!\d))/g, '$1.');           
        var load = document.getElementById("loadingSpinnerContainer");
        $A.util.addClass(load, 'hide');
        var queryString = window.location.href;		        
    	if(queryString.indexOf('/s/cart') != -1){
            $A.get('e.force:refreshView').fire();
        }
	},
    removeCartItem: function (component, event, helper) {
        var load = document.getElementById("loadingSpinnerContainer");
        $A.util.removeClass(load, 'hide');
        var cartId = component.get("v.cartId");
        var cartItem = event.currentTarget.id.split('-')[1];
        var action = component.get("c.removeCartItemController");
        action.setParams({cartId:cartId, cartItem:cartItem});
        action.setCallback(this, function(a){
            var rtnValue = a.getReturnValue();
            if (rtnValue == null) {
                var element = document.getElementById(cartItem); 
                element.parentNode.removeChild(element);
                helper.updateCartData(); 
            }                        
        });        
        $A.enqueueAction(action);
	}
})