/**
 * Class containing tests for B2BUtils
 */
@IsTest public with sharing class B2BUtilsTest {
	
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
    
//    @IsTest 
//    static void resolveCommunityIdToWebstoreIdTest() { 
//        User portalAccount = [SELECT Id FROM User Where LastName = 'test lastName' Limit 1];
//        System.runAs ( portalAccount ) { 
//        Id networkId = Network.getNetworkId();
//		//String communityId = '0DB2D0000004Xz7';
//        B2BUtils.resolveCommunityIdToWebstoreId(networkId);
//        }
//    }
    
    @IsTest
    static void getUserAccountIDTest() { 
        //User portalAccount = [SELECT Id FROM User Where LastName = 'test lastName' Limit 1];
        //System.runAs ( portalAccount ) {   
        	B2BUtils.getUserAccountID();
       // }
    }
    
    @IsTest
    static void resolveSortParamTest() { 
        B2BUtils.resolveSortParam('CreatedDateAsc');
    }
}