/**
 * Class containing tests for B2BGetInfo
 */
@IsTest public with sharing class B2BGetInfoTest {
	
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
    static void getProductTest() { 
        Product2 product = [SELECT Id FROM Product2 Where Name = 'product test' Limit 1];
        Account acc = [SELECT Id FROM Account Where Name = 'account test' Limit 1];
        B2BGetInfo.getProduct('0DB2D0000004Xz7', product.Id, acc.Id);
    }
    
    @IsTest
    static void checkProductIsInStockTest() { 
        Product2 product = [SELECT Id FROM Product2 Where Name = 'product test' Limit 1];
        B2BGetInfo.checkProductIsInStock(product.Id);
    }
    
    @IsTest
    static void getCartSummaryTest() { 
        Account acc = [SELECT Id FROM Account Where Name = 'account test' Limit 1];
        B2BGetInfo.getCartSummary('0DB2D0000004Xz7', acc.Id);
    }
    
    @IsTest
    static void addToCartTest() { 
        Product2 product = [SELECT Id FROM Product2 Where Name = 'product test' Limit 1];
        Account acc = [SELECT Id FROM Account Where Name = 'account test' Limit 1];
        B2BGetInfo.addToCart('0DB2D0000004Xz7', product.Id, '1', acc.Id);
    }
    
    @IsTest
    static void createAndAddToListTest() { 
        Product2 product = [SELECT Id FROM Product2 Where Name = 'product test' Limit 1];
        Account acc = [SELECT Id FROM Account Where Name = 'account test' Limit 1];
        B2BGetInfo.createAndAddToList('0DB2D0000004Xz7', product.Id, 'teste', acc.Id);
    }
    
    @IsTest
    static void getWishlistTest() { 
        Account acc = [SELECT Id FROM Account Where Name = 'account test' Limit 1];
        B2BGetInfo.getWishlist('0DB2D0000004Xz7', acc.Id, true);
    }
    
    @IsTest
    static void addProductToWishlistTest() { 
        Product2 product = [SELECT Id FROM Product2 Where Name = 'product test' Limit 1];
        B2BGetInfo.addProductToWishlist('0DB2D0000004Xz7', '1234', product.Id);
    }
    
    @IsTest
    static void getProductPriceTest() { 
        Product2 product = [SELECT Id FROM Product2 Where Name = 'product test' Limit 1];
        Account acc = [SELECT Id FROM Account Where Name = 'account test' Limit 1];
        B2BGetInfo.getProductPrice('0DB2D0000004Xz7', product.Id, acc.Id);
    }
    
    @IsTest
    static void deleteWishlistTest() { 
        B2BGetInfo.deleteWishlist('0DB2D0000004Xz7', '1234', '5678');
    }
    
    @IsTest
    static void removeWishlistItemTest() { 
        Product2 product = [SELECT Id FROM Product2 Where Name = 'product test' Limit 1];
        B2BGetInfo.removeWishlistItem('0DB2D0000004Xz7', '1234', '5678', product.Id);
    }
    
    @IsTest
    static void updateWishlistTest() { 
        B2BGetInfo.updateWishlist('0DB2D0000004Xz7', '1234', '5678', 'newTEst');
    }
    
    @IsTest
    static void createListTest() { 
        Product2 product = [SELECT Id FROM Product2 Where Name = 'product test' Limit 1];
        B2BGetInfo.createList('0DB2D0000004Xz7', 'newList', '5678');
    }
    
    @IsTest
    static void addWishlistToCartTest() { 
        B2BGetInfo.addWishlistToCart('0DB2D0000004Xz7', '1234', '5678', 'newTEst');
    }
    
    @IsTest
    static void getWishlistWithSummaryTest() { 
        B2BGetInfo.getWishlistWithSummary('0DB2D0000004Xz7', '1234', true, 'productFields', 'CreatedDateAsc');
    }
}