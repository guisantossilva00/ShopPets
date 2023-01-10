@isTest
public class Commerce_TestDataFactoryTest {
    
    @testSetup 
    static void setup(){
        UserRole role;
        
        System.runAs(new User(Id=UserInfo.getUserId())) {
            role = Commerce_TestDataFactory.createRole('Papel');            
            insert role;
        }
        
        User userAdmin = Commerce_TestDataFactory.createUserAdmin('AdminUser', role.Id);
        insert userAdmin;
        
    }
    
	@isTest
	static void createPricebookEntryStandardTest() {
        
        Product2 product = Commerce_TestDataFactory.createProduct('Product test');
        insert product;
        Commerce_TestDataFactory.createPricebookEntryStandard(product.Id);
    }
    
    @isTest
	static void createCartItemTest() {
        User userAdmin = [Select Id from User where LastName = 'AdminUser']; 
        
        System.runAs(userAdmin){
            //Address address2 = Commerce_TestDataFactory.createAddress();
            //insert address2;
            
        	Account account = Commerce_TestDataFactory.createAccount('account test');
            insert account;
            
            Contact contact = Commerce_TestDataFactory.createContact('contact test','test', account.Id);
            insert contact;
            
            User user = Commerce_TestDataFactory.createUser('last name user test', contact.Id);
            insert user;
            
            BuyerGroup buyerGroup = Commerce_TestDataFactory.createBuyerGroupCommerce();
            insert buyerGroup;
            
            Product2 product = Commerce_TestDataFactory.createProduct('Product test');
            insert product;
            
            Pricebook2 pricebook = Commerce_TestDataFactory.createPricebook('Pricebook Test');
            insert pricebook;
            
            BuyerGroupPricebook bgPricebook = Commerce_TestDataFactory.createBuyerPricebook(buyerGroup.Id, pricebook.Id);
            insert bgPricebook;
            
            PricebookEntry pricebookEntryStandard = Commerce_TestDataFactory.createPricebookEntryStandard(product.Id);
            insert pricebookEntryStandard;
            
            PricebookEntry pricebookEntry = Commerce_TestDataFactory.createPricebookEntry(pricebook.Id, pricebookEntryStandard.Product2Id);
            insert pricebookEntry;
            
            WebStore store = Commerce_TestDataFactory.createStore('Store');
            insert store;
            
            Webcart cart = Commerce_TestDataFactory.createCart(account.Id, store.Id);
            insert cart;
            
            CartDeliveryGroup cartDelGroup = Commerce_TestDataFactory.createCartDelGroup(cart.Id);
            insert cartDelGroup;
            
            Commerce_TestDataFactory.createCartItem(cart.Id, cartDelGroup.Id, product.Id);    
        }
        
    }
    
    @isTest
	static void createOrderDelGroupTest() {
        User userAdmin = [Select Id from User where LastName = 'AdminUser']; 
        
        System.runAs(userAdmin){
            Account account = Commerce_TestDataFactory.createAccount('account test');
            insert account;
            
            Contact contact = Commerce_TestDataFactory.createContact('contact test','test', account.Id);
            insert contact;
            
            User user = Commerce_TestDataFactory.createUser('last name user test', contact.Id);
            insert user;
            
            BuyerGroup buyerGroup = Commerce_TestDataFactory.createBuyerGroupCommerce();
            insert buyerGroup;
            
            Product2 product = Commerce_TestDataFactory.createProduct('Product test');
            insert product;
            
            Pricebook2 pricebook = Commerce_TestDataFactory.createPricebook('Pricebook Test');
            insert pricebook;
            
            BuyerGroupPricebook bgPricebook = Commerce_TestDataFactory.createBuyerPricebook(buyerGroup.Id, pricebook.Id);
            insert bgPricebook;
            
            PricebookEntry pricebookEntryStandard = Commerce_TestDataFactory.createPricebookEntryStandard(product.Id);
            insert pricebookEntryStandard;
            
            PricebookEntry pricebookEntry = Commerce_TestDataFactory.createPricebookEntry(pricebook.Id, pricebookEntryStandard.Product2Id);
            insert pricebookEntry;
            
            WebStore store = Commerce_TestDataFactory.createStore('Store');
            insert store;
            
            Webcart cart = Commerce_TestDataFactory.createCart(account.Id, store.Id);
            insert cart;
            
            CartDeliveryGroup cartDelGroup = Commerce_TestDataFactory.createCartDelGroup(cart.Id);
            insert cartDelGroup;
            
            CartItem cartItem = Commerce_TestDataFactory.createCartItem(cart.Id, cartDelGroup.Id, product.Id);
            insert cartItem;
            
            Order order = Commerce_TestDataFactory.createOrderDraft(cart.Id, account.Id, pricebookEntry.Pricebook2Id);
            insert order;
            
            Commerce_TestDataFactory.createOrderDelGroup(order.Id);
        }
    }
    
    @isTest
	static void createOrderItemTest() {
        User userAdmin = [Select Id from User where LastName = 'AdminUser']; 
        
        System.runAs(userAdmin){
            
            Account account = Commerce_TestDataFactory.createAccount('account test');
            insert account;
            
            Contact contact = Commerce_TestDataFactory.createContact('contact test','test', account.Id);
            insert contact;
            
            User user = Commerce_TestDataFactory.createUser('last name user test', contact.Id);
            insert user;
            
            BuyerGroup buyerGroup = Commerce_TestDataFactory.createBuyerGroupCommerce();
            insert buyerGroup;
            
            Product2 product = Commerce_TestDataFactory.createProduct('Product test');
            insert product;
            
            Pricebook2 pricebook = Commerce_TestDataFactory.createPricebook('Pricebook Test');
            insert pricebook;
            
            BuyerGroupPricebook bgPricebook = Commerce_TestDataFactory.createBuyerPricebook(buyerGroup.Id, pricebook.Id);
            insert bgPricebook;
            
            PricebookEntry pricebookEntryStandard = Commerce_TestDataFactory.createPricebookEntryStandard(product.Id);
            insert pricebookEntryStandard;
            
            PricebookEntry pricebookEntry = Commerce_TestDataFactory.createPricebookEntry(pricebook.Id, pricebookEntryStandard.Product2Id);
            insert pricebookEntry;
            
            WebStore store = Commerce_TestDataFactory.createStore('Store');
            insert store;
            
            Webcart cart = Commerce_TestDataFactory.createCart(account.Id, store.Id);
            insert cart;
            
            CartDeliveryGroup cartDelGroup = Commerce_TestDataFactory.createCartDelGroup(cart.Id);
            insert cartDelGroup;
            
            CartItem cartItem = Commerce_TestDataFactory.createCartItem(cart.Id, cartDelGroup.Id, product.Id);
            insert cartItem;
            
            Order order = Commerce_TestDataFactory.createOrderDraft(cart.Id, account.Id, pricebookEntry.Pricebook2Id);
            insert order;
            
            Commerce_TestDataFactory.createOrderItem(order.Id, product.Id, order.Pricebook2Id);
        }
    }
    
    @isTest
	static void createContactPointAddressTest() {
        Account account = Commerce_TestDataFactory.createAccount('account test');
        insert account;
        ContactPointAddress pointAddress = Commerce_TestDataFactory.createContactPointAddress(account.Id , 'Shipping');
        insert pointAddress;
    }
    
    @isTest
	static void createTipoFreteTest() {
        TipoFrete__c tipoFrete = Commerce_TestDataFactory.createTipoFrete();
        insert tipoFrete;
    }

}