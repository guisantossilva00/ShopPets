@IsTest
public class B2BCheckTaxTest {
    
    @testSetup 
    static void setup() {
        Account account = Commerce_TestDataFactory.createAccount('test acc');                   
  		insert account;
        WebStore store = Commerce_TestDataFactory.createStore('B2B teste');                
        insert store;
        Webcart webcart = Commerce_TestDataFactory.createCart(account.Id, store.Id);                
        insert webcart;
        CartDeliveryGroup cartDeliveryGroup = Commerce_TestDataFactory.createCartDelGroup(webcart.Id);                
        insert cartDeliveryGroup;  
        Product2 product = Commerce_TestDataFactory.createProduct('product teste');
        insert product;  
        CartItem cartItem = Commerce_TestDataFactory.createCartItem(webcart.Id, cartDeliveryGroup.Id, product.Id);               
        insert cartItem;
    }
    
    @isTest static void testClass() {
        Test.startTest();
		B2BCheckTax apexTest = new B2BCheckTax();
        sfdc_checkout.IntegrationInfo integInfo = new sfdc_checkout.IntegrationInfo();
        integInfo.jobId = null;
        WebCart webCart = [SELECT Id FROM WebCart WHERE Name = 'CartTest' LIMIT 1];
        sfdc_checkout.IntegrationStatus integrationResult = apexTest.startCartProcessAsync(integInfo, webCart.Id);
        System.assertEquals(sfdc_checkout.IntegrationStatus.Status.SUCCESS, integrationResult.status);
        Test.stopTest();
    }
    
}