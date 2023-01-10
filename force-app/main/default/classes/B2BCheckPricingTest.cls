@IsTest
public class B2BCheckPricingTest {
    @testSetup 
    static void setup() {
        
        Account testAccount = Commerce_TestDataFactory.createAccount('TestAccount');                   
        insert testAccount;        
        
        WebStore testWebStore = Commerce_TestDataFactory.createStore('TestWebStore');                
        insert testWebStore;               
        
        Webcart cart = Commerce_TestDataFactory.createCart(testAccount.Id, testWebStore.Id);                
        insert cart;
        
        Product2 product = Commerce_TestDataFactory.createProduct('product teste');
        insert product; 
        
        CartDeliveryGroup CartDeliveryGroup = Commerce_TestDataFactory.createCartDelGroup(cart.Id);                
        insert CartDeliveryGroup;
        
        CartItem cartItem = Commerce_TestDataFactory.createCartItem(cart.Id, CartDeliveryGroup.Id, product.Id);               
        insert cartItem;
    }
    
    @IsTest
    static void pricingSuccessTest(){
        
        List<CartItem> cartItem = [SELECT SalesPrice from CartItem LIMIT 1];
        if(!cartItem.isEmpty()){
            cartItem[0].SalesPrice = 0.00;
            update cartItem;
        }
        
        Test.startTest();
        
        B2BCheckPricing apexSample = new B2BCheckPricing();
        sfdc_checkout.IntegrationInfo integInfo = new sfdc_checkout.IntegrationInfo();
        integInfo.jobId = null;
        WebCart webCart = [SELECT Id FROM WebCart WHERE Name = 'CartTest' LIMIT 1];
        sfdc_checkout.IntegrationStatus integrationResult = apexSample.startCartProcessAsync(integInfo, webCart.Id);
        System.assertEquals(sfdc_checkout.IntegrationStatus.Status.FAILED, integrationResult.status);
        
        Test.stopTest();
    }
    
    @IsTest
    static void pricingFailTest(){
        Test.startTest();
        
        B2BCheckPricing apexSample = new B2BCheckPricing();
        sfdc_checkout.IntegrationInfo integInfo = new sfdc_checkout.IntegrationInfo();
        integInfo.jobId = null;
        WebCart webCart = [SELECT Id FROM WebCart WHERE Name = 'CartTest' LIMIT 1];
        sfdc_checkout.IntegrationStatus integrationResult = apexSample.startCartProcessAsync(integInfo, webCart.Id);
        System.assertEquals(sfdc_checkout.IntegrationStatus.Status.SUCCESS, integrationResult.status);
        
        Test.stopTest();
    }
}