@isTest
public with sharing class ProductDetailsControllerTest {
    
    @testSetup static void setup(){                
        Product2 product = Commerce_TestDataFactory.createProduct('Product test');
        insert product;
        
    }
    
	 @isTest
     static void getProductDetailsTest() {
        Product2 product = [SELECT Id, Embalagem__c, Fabricante__c, Validade__c, QuantidadeLiquida__c, Conservacao__c, Ingredientes__c FROM Product2 WHERE Name = 'Product test' LIMIT 1];
        ProductDetailsController.getProductDetails(product.Id); 
     }
    
     @isTest
     static void getProductDescriptionTest() {
        Product2 product = [SELECT Id, Embalagem__c, Fabricante__c, Validade__c, QuantidadeLiquida__c, Conservacao__c, Ingredientes__c FROM Product2 WHERE Name = 'Product test' LIMIT 1];	
        ProductDetailsController.getProductDescription(product.Id); 
     }
    
}