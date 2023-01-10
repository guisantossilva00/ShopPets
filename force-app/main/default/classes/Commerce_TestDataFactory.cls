public with sharing class Commerce_TestDataFactory {
    
    public static UserRole createRole(string name){
        return new UserRole(DeveloperName = name, Name = name);
    }
    
    public static Address createAddress(){
        Address address = new Address();
        return address;
    }
    
    public static Account createAccount(String name){
        
        Account account = new Account();
        account.Name = name;
        account.CNPJTxt__c = '62.141.550/0001-88';
        account.Name__c = name;
        account.SAPCodeTxt__c = '0123456789101112';
        //account.BillingCity = adress;
        account.ShippingCountry = 'Brasil';
        account.ShippingStreet = 'Rua Feliz 12';
        account.ShippingCity = 'sao paulo';
        account.ShippingPostalCode = '01414-001';
        account.ShippingState = 'sao paulo';
        account.BillingCountry = 'Brasil';
        account.BillingStreet = 'Rua Feliz 12';
		account.BillingCity = 'sao paulo';
		account.BillingPostalCode = '01414-001';
        account.BillingState = 'sao paulo';
        return account;             
    }	
    
    public static Contact createContact(String firstName, String lastName, Id accountId){
        
        Contact contact = new Contact();
        contact.FirstName = firstName;
        contact.LastName = lastName;
        contact.AccountId = accountId;
        contact.Email = 'test@yopmail.com';
        
        return contact;        
    }
    
    public static User createUser(String lastName, Id contactId){
        
        Profile profile = [SELECT Id, Name FROM Profile Where Name = 'UISA Customer Community Plus Login User' Limit 1];
             
        User user = new User();
        user.Username = System.currentTimeMillis() + 'usertest@yopmail.com';
        user.FirstName = 'teste';
        user.LastName = lastName;
        user.Alias = String.valueOf(System.currentTimeMillis()).substring(0,8);
        user.CommunityNickname = String.valueOf(System.currentTimeMillis()).substring(0,8);
        user.TimeZoneSidKey = 'America/Sao_Paulo';
        user.EmailEncodingKey = 'ISO-8859-1';
        user.LocaleSidKey = 'pt_BR';
        user.LanguageLocaleKey = 'pt_BR';
        user.Email = 'test@yopmail.com';
        user.ProfileId = profile.Id;
        user.ContactId = contactId;
        user.IsActive = true;
                
        return user;
    }
    
    public static User createUserAdmin(String lastName, Id roleId){
        
        Profile profile = [SELECT Id, Name FROM Profile Where Name = 'System Administrator' or Name = 'Administrador do sistema' Limit 1];
              
        User user = new User();
        user.Username = System.currentTimeMillis() + 'usertest@yopmail.com';
        user.FirstName = 'teste';
        user.LastName = lastName;
        user.Alias = 'admin';
        user.CommunityNickname = 'usrBps';
        user.TimeZoneSidKey = 'America/Sao_Paulo';
        user.EmailEncodingKey = 'ISO-8859-1';
        user.LocaleSidKey = 'pt_BR';
        user.LanguageLocaleKey = 'pt_BR';
        user.Email = 'test@yopmail.com';
        user.ProfileId = profile.Id;
        user.IsActive = true;      
        user.UserRoleId = roleId;
        return user;
    }
    
    public static BuyerGroup createBuyerGroupCommerce() {
        
        BuyerGroup buyerGroup = new BuyerGroup();
        buyerGroup.Name = 'Grupo Comprador';
        
        return buyerGroup;
        
    }
    
    public static Product2 createProduct(String name){
        
        Product2 product = new Product2();
        product.Name = name;
        product.GrossWeightNmb__c = 500.000;
        product.Tipo__c = 'Álcool';
        product.Embalagem__c = 'Caixa';
		product.Fabricante__c = 'UISA';
        product.Validade__c = Date.valueOf('2028-11-01');
        product.QuantidadeLiquida__c = '5 kg';
        product.Conservacao__c = 'Manter em local limpo, seco e livre do sol.';
        product.Ingredientes__c = 'Lorem ipsum';
            
        return product;    
    }   
    
    public static Pricebook2 createPricebook(String name){
        
        Pricebook2 pricebook = new Pricebook2();
        pricebook.Name = name;
        pricebook.IsActive = true;
        
        return pricebook;
    }
    
    public static BuyerGroupPricebook createBuyerPricebook(Id buyerGroupId, Id pricebookId){
        
        BuyerGroupPricebook bgPricebook = new BuyerGroupPricebook();
        bgPricebook.BuyerGroupId = buyerGroupId;
        bgPricebook.Pricebook2Id = pricebookId;
        
        return bgPricebook;
    }
    
    public static PricebookEntry createPricebookEntryStandard (Id productId){
        
        PricebookEntry pricebookEntry = new PricebookEntry();
        pricebookEntry.Pricebook2Id = test.getStandardPricebookId();
        pricebookEntry.Product2Id = productId;
        pricebookEntry.UnitPrice = 0;               
        
        return pricebookEntry;     
    }
    
    public static PricebookEntry createPricebookEntry (Id pricebookId, Id productId){
        
        PricebookEntry pricebookEntry = new PricebookEntry();
        pricebookEntry.Pricebook2Id = pricebookId;
        pricebookEntry.Product2Id = productId;
        pricebookEntry.UnitPrice = 100;      
        
        
        return pricebookEntry;     
    }
    
    public static WebStore createStore(string name){
        
        WebStore store = new WebStore();
        store.Name = name;
        store.OptionsGuestBrowsingEnabled = true;
        store.DefaultLanguage = 'pt_BR';
        
        return store;
        
    }
    
    public static WebCart createCart(Id accountId, Id webStoreId){
        
        Webcart cart = new WebCart();
        cart.AccountId = accountId;
        cart.WebStoreId = webStoreId;
        cart.Name = 'CartTest';
        cart.TipoCarrinho__c = 'Álcool';
        
        return cart;        
    }
    
    public static CartDeliveryGroup createCartDelGroup(Id cartId){
        
        CartDeliveryGroup cartDelGroup = new CartDeliveryGroup();
        cartDelGroup.CartId = cartId;
        cartDelGroup.Name = 'CartDeliveryGroupTest';
        
        return cartDelGroup;   
    }
    
    public static CartItem createCartItem(Id cartId, Id cartDelGroupId, Id productId){
        
        CartItem cartItem = new CartItem();
        cartItem.CartId = cartId;
        cartItem.CartDeliveryGroupId = cartDelGroupId;
        cartItem.Name = 'CartItem';
        cartItem.Product2Id = productId;
        cartItem.Quantity = 5;
        cartItem.ListPrice = 100;
        cartItem.SalesPrice = 100;
        cartItem.TotalLineAmount = 100;
        cartItem.Type = 'Product';
        cartItem.TotalPrice = cartItem.Quantity * cartItem.SalesPrice;
        
        return cartItem;
    }
    
    public static Order createOrder(Id cartId, Id accountId, Id pricebookId){
                
        Order order = new Order();
        order.AccountId = accountId;
        order.Pricebook2Id = pricebookId;
        order.Status = 'Activated';
        order.EffectiveDate = System.today(); 

        return order;
    }
    
    public static Order createOrderDraft(Id cartId, Id accountId, Id pricebookId){
                
        Order order = new Order();
        order.AccountId = accountId;
        order.Pricebook2Id = pricebookId;
        order.Status = 'Draft';
        order.EffectiveDate = System.today(); 

        return order;
    }
    
    public static OrderDeliveryGroup createOrderDelGroup(Id orderId){
        
        OrderDeliveryGroup orderDelGroup = new OrderDeliveryGroup();
        orderDelGroup.OrderId = orderId;
        
        return orderDelGroup;
    }
    
    public static OrderItem createOrderItem(Id orderId, Id product2Id, Id pricebookEntryId){
        
        OrderItem orderItem = new OrderItem();
        orderItem.OrderId = orderId;
        orderItem.Product2Id = product2Id;
        orderItem.Quantity = 1;
        orderItem.PricebookEntryId = pricebookEntryId;
        orderItem.UnitPrice = 100;
        orderItem.TotalLineAmount = 100;
		orderItem.ListPrice = 100;        
        
        return orderItem;
        
    }
    
    public static ContactPointAddress createContactPointAddress(Id accountId, String AddressType){
        
        ContactPointAddress pointAddress = new ContactPointAddress(); 
        pointAddress.Name = 'Test pointAddress';
        pointAddress.Country = 'BR';
		pointAddress.City = 'São Paulo';
        pointAddress.Street = 'Rua Teste';
        pointAddress.State = 'SP';            
        pointAddress.PostalCode = '99999-999';
        pointAddress.AddressType = AddressType;
        pointAddress.ParentId = accountId;
        pointAddress.IsDefault = TRUE;
        
        return pointAddress;
        
    }
    
    public static TipoFrete__c createTipoFrete(){
        TipoFrete__c tipoFrete = new TipoFrete__c();
        tipoFrete.Name = 'Padrao';
        tipoFrete.Estado__c = 'Todos';
        tipoFrete.Cidade__c = 'Todas';
        tipoFrete.Custo__c = 100.00;
        tipoFrete.CustoMinimo__c = 10.00;
        tipoFrete.NomeOperadora__c = 'Teste';
        tipoFrete.Ativo__c = TRUE;
        return tipoFrete;
    }
    

}