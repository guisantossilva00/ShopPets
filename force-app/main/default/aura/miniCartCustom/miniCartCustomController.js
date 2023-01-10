({
	initialize: function(component, event, helper) {        
        helper.getCartId(component, event, helper);        
    },
    updateCart: function(component, event, helper){       
        helper.updateCart(component, event, helper);    
    },
    decreaseCartItem: function(component, event, helper){       
        helper.updateCartItem(component, event, helper, 'decrease', '');  
    },
    increaseCartItem: function(component, event, helper){       
        helper.updateCartItem(component, event, helper, 'increase', '');              
    },    
    changeQuantityCartItem: function(component, event, helper){       
        var cartItem = event.currentTarget.id.split('-')[1]; 
        var quantity = document.getElementById("quantity-"+cartItem).value;
        helper.updateCartItem(component, event, helper, '', quantity);              
    },
    increaseCartItem: function(component, event, helper){       
        helper.updateCartItem(component, event, helper, 'increase', '');              
    },
    removeCartItem: function(component, event, helper){       
        helper.removeCartItem(component, event, helper);              
    },
    clearCart: function(component, event, helper){       
        helper.clearCart(component, event, helper, 'decrease', '');  
    },
    openModal : function(component, event, helper){
        var cmpTarget = component.find('ModalClearCart');
        var cmpBack = component.find('Modalbackdrop');
        $A.util.addClass(cmpTarget, 'slds-fade-in-open');
        $A.util.addClass(cmpBack, 'slds-backdrop--open');
    },
    closeModal : function(component, event, helper){
        var cmpTarget = component.find('ModalClearCart');
        var cmpBack = component.find('Modalbackdrop');
        $A.util.removeClass(cmpBack,'slds-backdrop--open');
        $A.util.removeClass(cmpTarget, 'slds-fade-in-open');
    },
    closeMiniCart: function(component, event, helper){
        var closeMiniCart = document.getElementsByClassName("cartItens")[0];
        closeMiniCart.style.display = "none";
        
    }
   
})