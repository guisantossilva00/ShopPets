@isTest
public without sharing class ProductControllerTest {
    @testSetup static void setup(){        
        Product2 product = Commerce_TestDataFactory.createProduct('product test');
        insert product;
        
        Pricebook2 pricebook = Commerce_TestDataFactory.createPricebook('B2B');
        insert pricebook;
        
        PricebookEntry pricebookEntry = Commerce_TestDataFactory.createPricebookEntryStandard(product.Id);
        insert pricebookEntry;
		
		Account account = Commerce_TestDataFactory.createAccount('account test');
        insert account;

		WebStore store = Commerce_TestDataFactory.createStore('Store');
        insert store;
        
        Webcart cart = Commerce_TestDataFactory.createCart(account.Id, store.Id);
        insert cart;

    }
    @IsTest
    static void getImageIdTest() { 
        Product2 productid = [SELECT Id FROM Product2 WHERE Name = 'product test' Limit 1];
        ProductController.getImageId(productid.Id);
    }
    @IsTest
    static void getProductsTest() { 
        Integer pageNumber = 1;
        ProductController.getProducts(pageNumber, 600);
        ProductController.getProducts(pageNumber, 800);
        ProductController.getProducts(pageNumber, 1100);
    }
    @IsTest
    static void getCategoryAcucarTest() { 
        Integer pageNumber = 1;
        ProductController.getCategoryAcucar(pageNumber, 600);
        ProductController.getCategoryAcucar(pageNumber, 800);
        ProductController.getCategoryAcucar(pageNumber, 1100);
    }
    @IsTest
    static void getCategoryAlcoolTest() { 
        Integer pageNumber = 1;
        ProductController.getCategoryAlcool(pageNumber, 600);
        ProductController.getCategoryAlcool(pageNumber, 800);
        ProductController.getCategoryAlcool(pageNumber, 1100);
    }
    @IsTest
    static void getRelatedProducts() { 
        Integer pageNumber = 1;
        ProductController.getRelatedProducts(pageNumber, 600, '1234');
        ProductController.getRelatedProducts(pageNumber, 800, '1234');
        ProductController.getRelatedProducts(pageNumber, 1100, '1234');
    }
    @IsTest
    static void getProductPriceTest() { 
        Product2 productid = [SELECT Id FROM Product2 WHERE Name = 'product test' Limit 1];
        ProductController.getProductPrice(productid.Id);
    }
    @IsTest
    static void getCartItemTest() { 
        WebCart cart =  [SELECT Id FROM WebCart WHERE Name = 'CartTest'];
        Product2 productid = [SELECT Id FROM Product2 WHERE Name = 'product test' Limit 1];
        ProductController.getCartItem(cart.Id, productid.Id);
    }
    @IsTest
    static void createCartTest() { 
        ProductController.createCart();
    }
    @IsTest
    static void createCartItemTest() { 
		WebCart cart =  [SELECT Id FROM WebCart WHERE Name = 'CartTest'];
        Product2 productid = [SELECT Id FROM Product2 WHERE Name = 'product test' Limit 1];
        ProductController.createCartItem(cart.Id, productid.Id, '1');
    }
}