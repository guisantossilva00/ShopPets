@IsTest
public class B2BShippingProvidersTest {
    
    @testSetup 
    static void setup() {
       
        Account account = Commerce_TestDataFactory.createAccount('TestAccount');                   
  		insert account;
        WebStore webStore = Commerce_TestDataFactory.createStore('B2B teste');                
        insert webStore;
        
        Webcart webcart = Commerce_TestDataFactory.createCart(account.Id, webStore.Id);                
        insert webcart;
        CartDeliveryGroup cartDeliveryGroup = Commerce_TestDataFactory.createCartDelGroup(webcart.Id);                
        insert cartDeliveryGroup;  
        Product2 product = Commerce_TestDataFactory.createProduct('product teste');
        insert product;  
        CartItem cartItem = Commerce_TestDataFactory.createCartItem(webcart.Id, cartDeliveryGroup.Id, product.Id);               
        insert cartItem;
        
        TipoFrete__c tipoFrete = Commerce_TestDataFactory.createTipoFrete();                       
        insert tipoFrete;
        
    }
    
    @isTest
    static void failTest(){

        Test.startTest();
        
        B2BShippingProviders apexSample = new B2BShippingProviders();
        sfdc_checkout.IntegrationInfo integInfo = new sfdc_checkout.IntegrationInfo();
        WebCart webCart = [SELECT Id FROM WebCart WHERE Name='CartTest' LIMIT 1];
        webCart.TipoCarrinho__c = 'Açúcar';
        update webCart;
        integInfo.jobId = null;
        sfdc_checkout.IntegrationStatus integrationResult = apexSample.startCartProcessAsync(integInfo, webCart.Id);
        System.assertEquals(sfdc_checkout.IntegrationStatus.Status.success, integrationResult.status);
        Test.stopTest();

    }
    
    @isTest
    static void successTest(){
        
        Account a = [SELECT Id FROM Account WHERE Name = 'TestAccount' LIMIT 1];
        ContactPointAddress cpa = Commerce_TestDataFactory.createContactPointAddress(a.id, 'Shipping');                              
        insert cpa;
        
        Test.startTest();
        
        B2BShippingProviders apexSample = new B2BShippingProviders();
        sfdc_checkout.IntegrationInfo integInfo = new sfdc_checkout.IntegrationInfo();
        WebCart webCart = [SELECT Id, TipoCarrinho__c FROM WebCart WHERE Name='CartTest' LIMIT 1];
        integInfo.jobId = null;
        sfdc_checkout.IntegrationStatus integrationResult = apexSample.startCartProcessAsync(integInfo, webCart.Id);
        System.assertEquals(sfdc_checkout.IntegrationStatus.Status.Success, integrationResult.status);
        
        Test.stopTest();
    }
    
    @isTest
    static void successTestWithODM(){
        
        Account a = [SELECT Id FROM Account WHERE Name = 'TestAccount' LIMIT 1];
        ContactPointAddress cpa = Commerce_TestDataFactory.createContactPointAddress(a.id, 'Shipping');                              
        insert cpa;
        Product2 p = [SELECT Id FROM Product2 WHERE Name = 'product teste' LIMIT 1];
        
        Test.startTest();
        
        insertOrderDeliveryMethod(p.Id);
        
        B2BShippingProviders apexSample = new B2BShippingProviders();
        sfdc_checkout.IntegrationInfo integInfo = new sfdc_checkout.IntegrationInfo();
        WebCart webCart = [SELECT Id, TipoCarrinho__c FROM WebCart WHERE Name='CartTest' LIMIT 1];
        integInfo.jobId = null;
        sfdc_checkout.IntegrationStatus integrationResult = apexSample.startCartProcessAsync(integInfo, webCart.Id);
        System.assertEquals(sfdc_checkout.IntegrationStatus.Status.Success, integrationResult.status);
        
        Test.stopTest();
    }
    
    
    static void insertCartItem(String cartId) {
        
        CartDeliveryGroup cartDeliveryGroups = [SELECT Id FROM CartDeliveryGroup WHERE CartId = :cartId LIMIT 1];
        Product2 product = [SELECT Id FROM Product2 WHERE Name = 'product teste' LIMIT 1];
        CartItem cartItem = Commerce_TestDataFactory.createCartItem(cartId, cartDeliveryGroups.Id, product.Id);               
        insert cartItem;
        
    }
    
    static void insertOrderDeliveryMethod(String productId){
        
        OrderDeliveryMethod defaultOrderDeliveryMethod = new OrderDeliveryMethod(
                    Name = 'Padrao 1',
                    Carrier = 'shippingOption.Name',
                    isActive = true,
                    ProductId = null,
                    ClassOfService = 'shippingOption.NomeOperadora__c'
                );
                insert(defaultOrderDeliveryMethod);
    }
    
    // Deletes the single cart item    
    static void deleteCartItem() {
        CartItem cartItem = [SELECT Id FROM CartItem WHERE Name = 'CartItem' LIMIT 1];
        delete cartItem;
    }
    
    @isTest
    static void cartTypeDiffer(){
        
        Account a = [SELECT Id FROM Account WHERE Name = 'TestAccount' LIMIT 1];
        ContactPointAddress cpa = Commerce_TestDataFactory.createContactPointAddress(a.id, 'Shipping');                              
        insert cpa;
        
        WebCart c = [SELECT TipoCarrinho__c FROM WebCart WHERE Name =: 'CartTest' LIMIT 1];
        c.TipoCarrinho__c = 'Açúcar';
        update c;
        
        Product2 p = [SELECT Tipo__c FROM Product2 WHERE Name =: 'product teste' LIMIT 1];
        p.Tipo__c = 'Açúcar';
        update p;
        
        
        Test.startTest();
        
        B2BShippingProviders apexSample = new B2BShippingProviders();
        sfdc_checkout.IntegrationInfo integInfo = new sfdc_checkout.IntegrationInfo();
        WebCart webCart = [SELECT Id, TipoCarrinho__c FROM WebCart WHERE Name='CartTest' LIMIT 1];
        integInfo.jobId = null;
        sfdc_checkout.IntegrationStatus integrationResult = apexSample.startCartProcessAsync(integInfo, webCart.Id);
        System.assertEquals(sfdc_checkout.IntegrationStatus.Status.Success, integrationResult.status);
        
        Test.stopTest();
    }
}