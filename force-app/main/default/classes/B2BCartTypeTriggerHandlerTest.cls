@IsTest
public class B2BCartTypeTriggerHandlerTest {
	
    @IsTest
    public static void insertTest(){
        
        Account account = Commerce_TestDataFactory.createAccount('TestAccount');                   
  		insert account;
        WebStore webStore = Commerce_TestDataFactory.createStore('B2B teste');                
        insert webStore;
        Product2 product = Commerce_TestDataFactory.createProduct('product teste');
        insert product; 
        product.Tipo__c = 'Álcool';
		update product;        
        
        Test.startTest();


        Webcart webcart = Commerce_TestDataFactory.createCart(account.Id, webStore.Id);                
        insert webcart;
        CartDeliveryGroup cartDeliveryGroup = Commerce_TestDataFactory.createCartDelGroup(webcart.Id);                
        insert cartDeliveryGroup;  
        CartItem cartItem = Commerce_TestDataFactory.createCartItem(webcart.Id, cartDeliveryGroup.Id, product.Id);               
        insert cartItem;
        Test.stopTest();
        
        webcart c = [select tipocarrinho__c from webcart where Id =: webcart.id];
        system.debug('teste - > ' + c.TipoCarrinho__c);
        System.assertEquals(c.TipoCarrinho__c, 'Álcool');

  
    }
    
    @IsTest
    public static void updateTest(){
        
        Account account = Commerce_TestDataFactory.createAccount('TestAccount');                   
  		insert account;
        WebStore webStore = Commerce_TestDataFactory.createStore('B2B teste');                
        insert webStore;
        Product2 product = Commerce_TestDataFactory.createProduct('product teste');
        insert product;     
        
        Webcart webcart = Commerce_TestDataFactory.createCart(account.Id, webStore.Id);                
        insert webcart;
        CartDeliveryGroup cartDeliveryGroup = Commerce_TestDataFactory.createCartDelGroup(webcart.Id);                
        insert cartDeliveryGroup;  
        CartItem cartItem = Commerce_TestDataFactory.createCartItem(webcart.Id, cartDeliveryGroup.Id, product.Id);               
        insert cartItem;
        
        
		Test.startTest();
        CartItem cartItem1 = Commerce_TestDataFactory.createCartItem(webcart.Id, cartDeliveryGroup.Id, product.Id);               
        insert cartItem1;
        Test.stopTest();
        
        webcart c = [select tipocarrinho__c from webcart where Id =: webcart.id];
        system.debug('teste - > ' + c.TipoCarrinho__c);
        System.assertEquals(c.TipoCarrinho__c, 'Álcool');
        
    }
}