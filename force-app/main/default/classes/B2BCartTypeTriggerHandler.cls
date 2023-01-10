public class B2BCartTypeTriggerHandler {
    
    public static void cartTypeHandler(WebCart webCart){
        	changeCartType(webCart);
    }
    
    private static void changeCartType(WebCart cart){
        
        // verificar qual o tipo de produto que foi adicionado ao carrinho.
        // acessar o carrinho, verificar o cartItem.
        // alterar o tipo do carrinho para o tipo do produto.
        // se o carrinho estiver vazio, retornar o tipo como nulo.

        List <WebCart> cartToUpdate = new List<WebCart>();
        
        if(!CartIsEmpty(cart.Id)){
            List <CartItem> cartItemList = [SELECT Product2Id FROM CartItem WHERE CartId =: cart.id ORDER BY LastModifiedDate LIMIT 1];
            Set <Id> productsIdSet = new Set <Id>();
            
            for(CartItem ci : cartItemList){
                productsIdSet.add(ci.Product2Id);
            }
            
            List <Product2> productsList = [SELECT 	Tipo__c FROM Product2 WHERE Id IN : productsIdSet ORDER BY LastModifiedDate LIMIT 1];
            String productType;
            
            if(!productsList.isEmpty()){
                Product2 p = productsList[0];
                productType = p.Tipo__c;
            }
            
			cart.TipoCarrinho__c = productType;    
        }else{
            cart.TipoCarrinho__c = 'Vazio';
        }
        
    }
    
    private static Boolean CartIsEmpty(String webCartId){
        Integer i = [SELECT COUNT() FROM CartItem WHERE CartId =: webCartId];
        if(i == 0){
            return true;
        }else{
            return false;
        }             
    }
    
}