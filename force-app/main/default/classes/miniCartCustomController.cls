global  without sharing  class miniCartCustomController {
    
    @AuraEnabled(cacheable=true)
    public static String getCartIdController(){        
        List<WebCart> cart =  [SELECT Id, TotalAmount, TotalProductCount FROM WebCart WHERE CreatedBy.id =: UserInfo.getUserId() and (Status = 'Active' or Status = 'Checkout') limit 1];        
        if(cart.size() > 0){
            return cart[0].Id;
        }else{
            return null;
        }        
    }
        
    @AuraEnabled
    public static List<List<String>> getMiniCart(String cartId){                                		
        List<WebCart> cart =  [SELECT Id, TotalAmount, TotalProductCount FROM WebCart WHERE Id =: cartId and Status = 'Active'];
        List<List<String>> dataItens = new List<List<String>>();        
        List<CartItem> cartItens = new List<CartItem>();
        
        if(cart.size() > 0){
            
            //List<WebCart> cart =  [SELECT Id, TotalAmount, TotalProductCount FROM WebCart WHERE CreatedBy.id = '00517000008qt1FAAQ' and Status = 'Active'];        
            List<Network> community = [SELECT id FROM Network limit 1];
            
            cartItens = [SELECT Id, CartId , Product2Id, Quantity, SalesPrice FROM CartItem WHERE CartId =: cart[0].Id and SalesPrice != null order by CreatedDate desc];
        
            for(CartItem cartItem : cartItens){
    
                List<String> dataItens2 = new List<String>();
    
                List<Product2> products = [SELECT Id, Name, StockKeepingUnit FROM Product2 WHERE Id =: cartItem.Product2Id];
                dataItens2.add(cartItem.Id);
                dataItens2.add(cartItem.Product2Id);            
                dataItens2.add(String.valueOf(cartItem.Quantity));            
                dataItens2.add(String.valueOf(cartItem.SalesPrice));
                          
                if(products[0].Id != null || !String.isEmpty(products[0].Id)){
                    for(Product2 product : products){
                        
                        dataItens2.add(product.Name);
                        dataItens2.add(product.StockKeepingUnit);
                        
                        List<ProductMedia> productImage = [SELECT Id, ElectronicMediaId FROM ProductMedia WHERE ProductId =: product.Id limit 1];            	                
                        List<String> ElectronicMediaId =  new List<String>();
                        if(productImage.size() > 0){
                            ElectronicMediaId.add(productImage[0].ElectronicMediaId);                                              
                            ConnectApi.ManagedContentVersionCollection resp = ConnectApi.ManagedContent.getManagedContentByIds(community[0].id,ElectronicMediaId,null,null,'pt_BR','');
                            String productImageId = String.valueOf(resp.items[0]).split('contentKey=')[1].split(',')[0];
                            if(productImageId != null){
                                dataItens2.add(productImageId);
                            }
                        }else{
                            dataItens2.add('not-found');
                        }
                        
                    }
                }
                dataItens2.add(String.valueOf(cartItem.SalesPrice * cartItem.Quantity));
                dataItens2.add(String.valueOf(cart[0].TotalAmount));
                dataItens2.add(String.valueOf(cart[0].TotalProductCount));
                dataItens2.add(String.valueOf(cart[0].Id));
                dataItens2.add(String.valueOf(community[0].Id));            
                dataItens.add(dataItens2);
            }   
        }
        return dataItens;               
    }
    
    @AuraEnabled
    public static String updateCartController(String cartId, String cartItem, String origin, String quantity){        
        List<WebStore> webStore = [SELECT Id, Name FROM WebStore limit 1];        
        List<User> user =  [SELECT Id, AccountId FROM User WHERE Id =: UserInfo.getUserId() ];
        List<CartItem> cartItens = [SELECT Id, Quantity FROM CartItem WHERE Id =: cartItem];
        ConnectApi.CartItemInput cartItemInput = new ConnectApi.CartItemInput();
        if(origin  == 'decrease'){
        	cartItemInput.quantity = String.valueOf(cartItens[0].Quantity - 1);    
        }else if(origin  == 'increase'){
            cartItemInput.quantity = String.valueOf(cartItens[0].Quantity + 1);
        }else if (origin  == 'carousel'){
            cartItemInput.quantity =  String.valueOf(cartItens[0].Quantity + Integer.valueof(quantity));
        }
        else{
            cartItemInput.quantity = quantity;
        }
        if (!Test.isRunningTest()) {
        	ConnectApi.CommerceCart.updateCartItem(webStore[0].id,user[0].AccountId, cartId, cartItem, cartItemInput);        
        }
        return cartItemInput.quantity;
    }
    
    @AuraEnabled
    public static String clearCartController(String cartId){        
        List<WebStore> webStore = [SELECT Id, Name FROM WebStore limit 1];        
        List<User> user =  [SELECT Id, AccountId FROM User WHERE Id =: UserInfo.getUserId() ];
        List<CartItem> cartItens = [SELECT Id, CartId , Product2Id, Quantity, SalesPrice FROM CartItem WHERE CartId =: cartId and SalesPrice != null order by CreatedDate desc];            
        for(CartItem cartItem : cartItens){
            if (!Test.isRunningTest()) {
            	ConnectApi.CommerceCart.deleteCartItem(webStore[0].id,user[0].AccountId,cartId, cartItem.Id);
            }
		}
        return null;
    }
    
    @AuraEnabled
    public static String removeCartItemController(String cartId, String cartItem){        
        List<WebStore> webStore = [SELECT Id, Name FROM WebStore limit 1];        
        List<User> user =  [SELECT Id, AccountId FROM User WHERE Id =: UserInfo.getUserId() ];
        if (!Test.isRunningTest()) {
        	ConnectApi.CommerceCart.deleteCartItem(webStore[0].id,user[0].AccountId,cartId, cartItem);
        }
        return null;
    }
}