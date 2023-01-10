@isTest
public without sharing class miniCartCustomControllerTest {
    @testSetup static void setup(){                
        Account account = Commerce_TestDataFactory.createAccount('account test');
        insert account;
        
        Contact contact = Commerce_TestDataFactory.createContact('contact test','test', account.Id);
        insert contact;
        
        User user = Commerce_TestDataFactory.createUser('last name user test', contact.Id);
        insert user;               
        
        Product2 product = Commerce_TestDataFactory.createProduct('Product test');
        insert product; 
        
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
    static void getCartIdControllerTest() {
        //User portalAccount = [SELECT Id FROM User Where LastName = 'test lastName' Limit 1];
        //System.runAs ( portalAccount ) {   
        	miniCartCustomController.getCartIdController();
        //}
    }
    
    @IsTest
    static void getMiniCartTest() {
        List<WebCart> cart =  [SELECT Id FROM WebCart WHERE Name = 'CartTest'];
        miniCartCustomController.getMiniCart(cart[0].Id);       
    }
    
    @IsTest
    static void updateCartControllerTest() { 
        List<WebCart> cart =  [SELECT Id FROM WebCart WHERE Name = 'CartTest'];
		List<CartItem> cartItens = [SELECT Id, CartId , Product2Id, Quantity, SalesPrice FROM CartItem WHERE Name = 'CartItem'];                    
        miniCartCustomController.updateCartController(cart[0].Id, cartItens[0].Id,'increase','');
        miniCartCustomController.updateCartController(cart[0].Id, cartItens[0].Id,'decrease','');
        miniCartCustomController.updateCartController(cart[0].Id, cartItens[0].Id,'carousel','10');
        miniCartCustomController.updateCartController(cart[0].Id, cartItens[0].Id,'','5');
    }
    
    @IsTest
    static void clearCartControllerTest() {        
        List<WebCart> cart =  [SELECT Id FROM WebCart WHERE Name = 'CartTest'];        
        miniCartCustomController.clearCartController(cart[0].Id);
    }
    
    @IsTest
    static void removeCartItemControllerTest() {        
        List<WebCart> cart =  [SELECT Id FROM WebCart WHERE Name = 'CartTest'];
        List<CartItem> cartItens = [SELECT Id, CartId , Product2Id, Quantity, SalesPrice FROM CartItem WHERE Name = 'CartItem'];            
        miniCartCustomController.removeCartItemController(cart[0].Id, cartItens[0].Id);
    }
}