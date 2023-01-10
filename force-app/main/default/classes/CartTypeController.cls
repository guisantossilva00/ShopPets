public class CartTypeController {
    
    @AuraEnabled(Cacheable=true)
    public static Boolean isSameType(String cartId, String productId){
        WebCart cart = getWebCart(cartId);
        Product2 product = getProduct(productId);
        
        if(product.Tipo__c == cart.TipoCarrinho__c || cart.TipoCarrinho__c == 'Vazio'){
            return true;
        }else{
			return false;
        }
    }

    private static WebCart getWebCart(String cartId){
        return [
            SELECT Id, TipoCarrinho__c 
            FROM WebCart 
            WHERE ID =: cartId 
            LIMIT 1
        ];
    }
    
    private static Product2 getProduct(String productId){
        return [
            SELECT Id, Tipo__c 
            FROM Product2 
            WHERE ID =: productId 
            LIMIT 1
        ];
    }
    
}