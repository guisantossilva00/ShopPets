@IsTest
public class B2BCheckInventoryTest {
    
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
        
		insertCartItem(cart.Id, cartDeliveryGroup.Id);
    }
    
    @isTest
    static void testCart(){
        
        Test.startTest();
        
        B2BCheckInventory apexSample = new B2BCheckInventory();
        sfdc_checkout.IntegrationInfo integInfo = new sfdc_checkout.IntegrationInfo();
        integInfo.jobId = null;
        WebCart webCart = [SELECT Id FROM WebCart WHERE Name = 'CartTest' LIMIT 1];
        sfdc_checkout.IntegrationStatus integrationResult = apexSample.startCartProcessAsync(integInfo, webCart.Id);
        System.assertEquals(sfdc_checkout.IntegrationStatus.Status.SUCCESS, integrationResult.status);
        
        Test.stopTest();
    }
    
    @isTest 
    static void testEmptyCart() {
       	deleteCartItem();
        Test.startTest();
        
        B2BCheckInventory apexSample = new B2BCheckInventory();
        sfdc_checkout.IntegrationInfo integInfo = new sfdc_checkout.IntegrationInfo();
        integInfo.jobId = null;
        WebCart webCart = [SELECT Id FROM WebCart WHERE Name = 'CartTest' LIMIT 1];
        sfdc_checkout.IntegrationStatus integrationResult = apexSample.startCartProcessAsync(integInfo, webCart.Id);

        // Validate: IntegrationStatus.Status is FAILED.
        // and a new CartValidationOutput record with level 'Error' was created.
        System.assertEquals(sfdc_checkout.IntegrationStatus.Status.FAILED, integrationResult.status);
        List<CartValidationOutput> cartValidationOutputs = [SELECT Id, Message FROM CartValidationOutput WHERE Level = 'Error'];
        System.assertEquals(1, cartValidationOutputs.size());
        
        // Validate: The sample text that the cart is empty is returned as the failure output 
        System.assertEquals('Looks like your cart is empty.', cartValidationOutputs.get(0).Message);
        Test.stopTest();

        // Undo the emptying of the cart we did at the start of the test
        insertCartItem(webCart.Id);
    }
    
    static void insertCartItem(String cartId) {
        List<CartDeliveryGroup> cartDeliveryGroups = [SELECT Id FROM CartDeliveryGroup WHERE CartId = :cartId LIMIT 1];

        insertCartItem(cartId, cartDeliveryGroups.get(0).Id);
    }
    
    static void insertCartItem(String cartId, String cartDeliveryGroupId) {
        CartItem cartItem = new CartItem(
            CartId=cartId, 
            Sku='SKU_Test1', 
            Quantity=3.0, 
            Type='Product', 
            Name='TestProduct', 
            CartDeliveryGroupId=cartDeliveryGroupId
        );
        insert cartItem;
    }

    // Deletes the single cart item    
    static void deleteCartItem() {
        CartItem cartItem = [SELECT Id FROM CartItem WHERE Name = 'TestProduct' LIMIT 1];
        delete cartItem;
    }
    
}