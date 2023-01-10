/**
 * Class containing tests for CartItemTriggerHandlerTest
 */
@IsTest public with sharing class CartItemTriggerHandlerTest {
	
    @testSetup static void setup(){        
        Product2 product = Commerce_TestDataFactory.createProduct('product test');
        insert product;
		
		Account account = Commerce_TestDataFactory.createAccount('accountType test');
        insert account;

		WebStore store = Commerce_TestDataFactory.createStore('Store');
        insert store;
        
        Webcart cart = Commerce_TestDataFactory.createCart(account.Id, store.Id);
        insert cart;
	
        CartDeliveryGroup cartDelGroup = Commerce_TestDataFactory.createCartDelGroup(cart.Id);
        insert cartDelGroup;
        
        CartItem cartItem = Commerce_TestDataFactory.createCartItem(cart.Id, cartDelGroup.Id, product.Id);
        insert cartItem;
    }
    
    @IsTest
    static void productCartItemTypeTest() { 
		Account account =  [SELECT Id FROM Account WHERE account.name = 'accountType test'];
        Webcart cart =  [SELECT Id FROM WebCart WHERE AccountId =: account.id LIMIT 1];
		CartItem cartItem =  [SELECT Id, Product2Id, CartId FROM CartItem WHERE CartId =: cart.id LIMIT 1];
        CartItemTriggerHandler.productCartItemType(cartItem);
    }
    
}