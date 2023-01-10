@isTest(SeeAllData=true)
public class IntegrationSAPTest {
    private static void createData(){
        //Creating product 
        Product2 orderProduct = new Product2();
        orderProduct.name = 'Product Test';
        orderProduct.BasicUnitTxt__c = 'PC';
        orderProduct.SAPCodeTxt__c = '001';
        Insert orderProduct;
        
        Product2 orderProductB = new Product2();
        orderProductB.name = 'Taxa de Entrega';
        orderProductB.BasicUnitTxt__c = 'PC';
        orderProductB.SAPCodeTxt__c = '002';
        Insert orderProductB;
        
        Product2 orderProductC = new Product2();
        orderProductC.name = 'Taxa de Entrega';
        orderProductC.BasicUnitTxt__c = 'PC';
        orderProductC.SAPCodeTxt__c = '003';
        Insert orderProductC;
        
        //Creating Supplier Center 
        SupplierCenter__c sup = new SupplierCenter__c();
        sup.name = 'Test Supplier';
        sup.isActive__c = true;
        sup.SapCodeTxt__c = '2131';
        Insert sup;
        
        //Creatin Product Available
        ProductsAvailable__c available = new ProductsAvailable__c();
        available.Name = 'Product Test';
        available.SupplierCenterLkp__c = sup.Id;
        available.isActive__c = true;
        available.ProductLkp__c = orderProduct.Id;
        Insert available;
        
        ProductsAvailable__c availableB = new ProductsAvailable__c();
        availableB.Name = 'Product Test B';
        availableB.SupplierCenterLkp__c = sup.Id;
        availableB.isActive__c = true;
        availableB.ProductLkp__c = orderProductB.Id;
        Insert availableB;
        
        ProductsAvailable__c availableC = new ProductsAvailable__c();
        availableC.Name = 'Product Test C';
        availableC.SupplierCenterLkp__c = sup.Id;
        availableC.isActive__c = true;
        availableC.ProductLkp__c = orderProductC.Id;
        Insert availableC;
        
        //Creating pricebook Entry
        PricebookEntry entry = new PricebookEntry();
        entry.Pricebook2Id = test.getStandardPricebookId();
        entry.Product2Id = orderProduct.Id;
        entry.UnitPrice = 1;
        entry.IsActive = true;
        Insert entry;
        
        PricebookEntry entryB = new PricebookEntry();
        entryB.Pricebook2Id = test.getStandardPricebookId();
        entryB.Product2Id = orderProductB.Id;
        entryB.UnitPrice = 2;
        entryB.IsActive = true;
        Insert entryB;
        
        PricebookEntry entryC = new PricebookEntry();
        entryC.Pricebook2Id = test.getStandardPricebookId();
        entryC.Product2Id = orderProductC.Id;
        entryC.UnitPrice = 1;
        entryC.IsActive = true;
        Insert entryC;
        
        //Creating customer
        Account customer = new Account();
        customer.Name = 'Any Customer LTDA';
        customer.CNPJTxt__c = '05.594.461/0001-53';
        customer.isActive__c = true;
        customer.SAPCodeTxt__c = '0000';
        Insert customer;
        
        //Creating Sales Area
        SalesArea__c salesArea = new SalesArea__c();
        salesArea.SAPCodeTxt__c = '0000';
        salesArea.isActive__c = true;
        Insert salesArea;
        
        //Creating Payment Condition
        paymentCondition__c pay = new paymentCondition__c();
        pay.name = '05 dias';
        pay.SAPCodeTxt__c = '0000';
        pay.isActive__c = true; 
        Insert pay;
        
        //Creating Sales Team
        SalesTeam__c team = new SalesTeam__c();
        team.name = 'Super Fast Test Team';
        team.SAPCodeTxt__c = '00';
        Insert team;
        
        //Creating Order
        Order salesOrder = new Order();
        salesOrder.Name = '000T3ST3';
        salesOrder.paymentCondition__c = pay.Id;
        salesOrder.AccountId = customer.Id;
        salesOrder.EffectiveDate = System.today();
        salesOrder.SalesAreaLkp__c = salesArea.Id;
        salesOrder.SalesType__c = 'ZVPE - Venda Pronta Entrega';
        salesOrder.PaymentFormTxt__c = 'C - Cheque - Pagto Fornecedor';
        salesOrder.status = 'Rascunho';
        salesOrder.AccountId = customer.Id;
        salesOrder.SalesTeamLkp__c = team.Id;
        salesOrder.isActive__c = true;
        salesOrder.Pricebook2Id = test.getStandardPricebookId();
        salesOrder.DeliveryOption__c = 'CIF - Custos, seguro e frete';

        
        Insert salesOrder;
        
        //Creating Items
        OrderItem item = new OrderItem();
        item.Product2Id = orderProductB.Id;
        item.OrderId = salesOrder.Id;
        item.Account__c = customer.Id;
        item.Quantity = 1;
        item.UnitPrice = 5;
        item.isActive__c = true;
        item.SalesPriceNmb__c = 5;
        item.PricebookEntryId = entry.Id;
        Insert item;
        
        OrderItem itemB = new OrderItem();
        
        itemB.Product2Id = orderProduct.Id;
        itemB.OrderId = salesOrder.Id;
        itemB.Account__c = customer.Id;
        itemB.Quantity = 5;
        itemB.UnitPrice = 5;
        itemB.isActive__c = true;
        itemB.SalesPriceNmb__c = 5;
        itemB.PricebookEntryId = entryB.Id;
        Insert itemB;
        
        OrderItem itemC = new OrderItem();
        
        itemC.Product2Id = orderProductC.Id;
        itemC.OrderId = salesOrder.Id;
        itemC.Account__c = customer.Id;
        itemC.Quantity = 1;
        itemC.UnitPrice = 0;
        itemC.isActive__c = true;
        itemC.PricebookEntryId = entryC.Id;
        Insert itemC;
    }
    
    @isTest
    public static void buildData(){
        createData();
        Test.setMock(HttpCalloutMock.class, new HttpCalloutMockSAP());
        Test.startTest();
        IntegrationSAP.buildData([SELECT id, SalesType__c, SalesOrganizationFml__c, DistributionChannelFml__c, ActivitySectorFml__c,
                                  SalesOfficeFml__c, AccountId, OrderNumber, PaymentFormTxt__c, EffectiveDate, CreatedDate, PaymentCondition__c,
                                  SalesAreaLkp__c, SalesTeamLkp__c, DeliveryOption__c, Cidade__c, RecordTypeId FROM Order WHERE name = '000T3ST3']);
        Test.stopTest();
    }
    
    @isTest
    public static void getItems(){
        createData();
        Test.startTest();
        List<OrderItem> orderItems = IntegrationSAP.getItems([SELECT id FROM Order WHERE name = '000T3ST3' limit 1]);
        System.assertEquals(3, orderItems.size(), 'A quantidade de itens do pedido deve ser igual a 3!');
        Test.stopTest();
    }
    
    @isTest
    public static void getProductAvailables(){
        createData();
        Test.startTest();
        IntegrationSAP.getItems([SELECT id FROM Order WHERE name = '000T3ST3' limit 1]);
        List<OrderItem> orderItems = IntegrationSAP.getItems([SELECT id FROM Order WHERE name = '000T3ST3' limit 1]);
        Map<String, ProductsAvailable__c> mapped = IntegrationSAP.getProductAvailables(orderItems);
        System.assertEquals(3, mapped.keySet().size(), 'A quantidade de produtos disponíveis deve ser igual a 3!');
        Test.stopTest();
    }
    
    @isTest
    public static void getCustomer(){
        createData();
        Account customer = IntegrationSAP.getCustomer([SELECT AccountId FROM Order WHERE name = '000T3ST3' limit 1]);
        System.assertNotEquals(null, customer, 'A conta não deve ser nula!');
        Order salesOrder = [SELECT AccountId FROM Order WHERE name = '000T3ST3' limit 1];
        customer = IntegrationSAP.getCustomer(salesOrder);
    }
    
    @isTest
    public static void buildDataCommerce(){
        createData();
        Test.setMock(HttpCalloutMock.class, new HttpCalloutMockSAP());
        Test.startTest();
        IntegrationSAP.buildDataCommerce([SELECT id, SalesType__c, SalesOrganizationFml__c, DistributionChannelFml__c, ActivitySectorFml__c,
                                          SalesOfficeFml__c, AccountId, OrderNumber, PaymentFormTxt__c, EffectiveDate, CreatedDate, PaymentCondition__c,
                                          SalesAreaLkp__c, SalesTeamLkp__c, DeliveryOption__c, Cidade__c, RecordTypeId FROM Order WHERE name = '000T3ST3']);
        Test.stopTest();
    }
    
    @isTest
    public static void sendOrderStatus(){
        createData();
        Test.setMock(HttpCalloutMock.class, new HttpCalloutMockSAP());
        String json = '';
        integrationSAP.sendOrderStatus(System.JSON.serialize(json));
    }
}