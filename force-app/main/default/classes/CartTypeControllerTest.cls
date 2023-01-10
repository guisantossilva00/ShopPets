/**
 * Class containing tests for CartTypeController
 */
@IsTest public with sharing class CartTypeControllerTest {
    
    @testSetup static void setup(){        
        Product2 product = Commerce_TestDataFactory.createProduct('product test');
        insert product;
		
		Account account = Commerce_TestDataFactory.createAccount('accountType test');
        insert account;

		WebStore store = Commerce_TestDataFactory.createStore('Store');
        insert store;
        
        Webcart cart = Commerce_TestDataFactory.createCart(account.Id, store.Id);
        insert cart;

    }
    
	@IsTest
    static void isSameTypeTest() { 
		WebCart cart =  [SELECT Id FROM WebCart WHERE Name = 'CartTest'];
        Product2 productid = [SELECT Id FROM Product2 WHERE Name = 'product test' Limit 1];
        CartTypeController.isSameType(cart.Id, productid.Id);
    }
}