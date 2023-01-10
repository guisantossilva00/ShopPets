public class CartItemTriggerHandler {

    public static Boolean productCartItemType(CartItem ci){
        Product2 product = [SELECT Id, Tipo__c FROM Product2 WHERE Id =: ci.Product2Id LIMIT 1];
        WebCart cart = [SELECT Id, TipoCarrinho__c FROM WebCart WHERE Id =: ci.CartId LIMIT 1];

        if(product.Tipo__c != cart.TipoCarrinho__c || cart.TipoCarrinho__c != 'Vazio'){
            return true;
        }else{
            return false;
        }

    }
    
}