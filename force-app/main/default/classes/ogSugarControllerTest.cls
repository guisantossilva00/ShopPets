@isTest(SeeAllData=true)
public class ogSugarControllerTest {
    
    @isTest
    public static void getConditions(){
        //Creating customer
        Account customer = new Account();
        customer.Name = 'Any Customer LTDA';
        customer.CNPJTxt__c = '05.594.461/0001-53';
        customer.isActive__c = true;
        customer.SAPCodeTxt__c = '0000';
        customer.TaxDomicileTxt__c = '';
        Insert customer;
        
        PaymentCondition__c condition = new PaymentCondition__c();
        condition.name = 'PT - 0001 - Pagar imediatamente s/dedução';
        condition.SAPCodeTxt__c = '0000';
        condition.isActive__c = true; 
        Insert condition;
        
        
        SalesTeam__c team = new SalesTeam__c();
        team.name = 'Dep Comercial Matriz';
        team.SAPCodeTxt__c = '111';
        Insert team;
        
        //Creating Sales Area
        SalesArea__c salesArea = new SalesArea__c();
        salesArea.PaymentConditionLkp__c = condition.Id;
        salesArea.SAPCodeTxt__c = '0000';
        salesArea.DistributionChannelTxt__c = '11';
        salesArea.ActivitySectorTxt__c = '10';
        salesArea.isActive__c = true;
        salesArea.CustomerLkp__c = customer.id;
        salesArea.SalesTeamLkp__c = team.Id;
        Insert salesArea;
        List<PaymentCondition__c> conditions = ogSugarController.getPaymentOption(team.Id, customer.Id);
        System.assertEquals(true, conditions.size() > 0, 'Deve existir ao menos uma condição de pagamento.');
    }
    
    @isTest
    static void CreateData(){
        //Produto Padrão
        Product2 orderProduct = new Product2();
        orderProduct.name = 'Product Test';
        orderProduct.BasicUnitTxt__c = 'PC';
        orderProduct.SAPCodeTxt__c = '001';
        orderProduct.IsActive = true;
        Insert orderProduct;
        
        PaymentCondition__c condition = new PaymentCondition__c();
        condition.name = 'PT - 0001 - Pagar imediatamente s/dedução';
        condition.SAPCodeTxt__c = '0000';
        condition.isActive__c = true; 
        Insert condition;
        
        SalesTeam__c team = new SalesTeam__c();
        team.name = 'Dep Comercial Matriz';
        team.SAPCodeTxt__c = '111';
        Insert team;
        
        //Creating customer
        Account customer = new Account();
        customer.Name = 'Any Customer LTDA';
        customer.CNPJTxt__c = '05.594.461/0001-53';
        customer.isActive__c = true;
        customer.SAPCodeTxt__c = '0000';
        customer.TaxDomicileTxt__c = '';
        Insert customer;
        
        //Contact Point
        ContactPointAddress add = new ContactPointAddress();
        add.State = 'SP';
        add.City = 'São Paulo';
        add.Country = 'BR';
        add.Name = 'Entrega';
        add.AddressType = 'Shipping';
        add.IsPrimary = true;
        add.IsDefault = true;
        add.ParentId = customer.id;
        insert add;
        
        //Creating Sales Area
        SalesArea__c salesArea = new SalesArea__c();
        salesArea.SAPCodeTxt__c = '0000';
        salesArea.DistributionChannelTxt__c = '11';
        salesArea.ActivitySectorTxt__c = '10';
        salesArea.isActive__c = true;
        salesArea.CustomerLkp__c = customer.id;
        Insert salesArea;
        
        //Creating Sales Area
        SalesArea__c salesAreaB = new SalesArea__c();
        salesAreaB.SAPCodeTxt__c = '0001';
        salesAreaB.DistributionChannelTxt__c = '11';
        salesAreaB.ActivitySectorTxt__c = '10';
        salesAreaB.isActive__c = true;
        salesAreaB.CustomerLkp__c = customer.id;
        Insert salesAreaB;
        
        //Creating pricebook Entry
        PricebookEntry entry = new PricebookEntry();
        entry.Pricebook2Id = test.getStandardPricebookId();
        entry.Product2Id = orderProduct.Id;
        entry.UnitPrice = 1;
        entry.IsActive = true;
        Insert entry;
        
        //Create Order
        Order order = new Order();
        order.Name = 'Unit Test Order';
        order.AccountId = customer.Id;
        order.DateShipmentDte__c = System.today() + 1;
        order.paymentCondition__c = condition.id;
        order.Status = 'Rascunho';
        order.EffectiveDate = System.today();
        order.Pricebook2Id = test.getStandardPricebookId();
        order.DeliveryOption__c = 'CIF - Custos, seguro e frete';
        Insert order;
        
        //Creating Items
        List <OrderItem> itemm = new List <OrderItem>();
        OrderItem item = new OrderItem();
        item.Product2Id = orderProduct.Id;
        item.OrderId = order.Id;
        item.Account__c = customer.Id;
        item.Quantity = 1;
        item.isActive__c = true;
        item.UnitPrice = 5;
        item.isActive__c = true;
        item.SalesPriceNmb__c = 5;
        item.PricebookEntryId = entry.Id;
        itemm.add(item);
        insert itemm;
        
        
        test.startTest();
        ogSugarController.getPaymentOption(team.id, customer.id);        
        ogSugarController.getTeams(customer.id);
        ogSugarController.getAreas(customer.Id, condition.id, team.id);
        ogSugarController.getAccount(customer.id);
        ogSugarController.save(order);
        ogsugarcontroller.getAddresses(customer.Id);
        ogSugarcontroller.getProduct(salesArea.id);
        
        String orderStatus = order.status;
        ogSugarController.saveOrderItens(order, itemm, orderStatus);
        
        ogSugarController.mapPricebookEntry(null, entry.Id);
        test.stopTest();
    }
    
    @isTest
    private static Order buildOrder(){
        PaymentCondition__c payCon = new PaymentCondition__c();
        payCon.name = 'A vista';
        payCon.SAPCodeTxt__c = '0000';
        payCon.isActive__c = true; 
        
        
        //Creating customer
        Account customer = new Account();
        customer.Name = 'Any Customer LTDA';
        customer.CNPJTxt__c = '05.594.461/0001-53';
        customer.isActive__c = true;
        customer.SAPCodeTxt__c = '0000';
        Insert customer;
        
        //Create Order
        Order order = new Order();
        order.Name = 'Unit Test Order';
        order.AccountId = customer.Id;
        order.DateShipmentDte__c = System.today() + 1;
        order.paymentCondition__c = payCon.id;
        order.Status = 'Rascunho';
        order.EffectiveDate = System.today();
        order.Pricebook2Id = test.getStandardPricebookId();
        Insert order;
        
        PricebookEntry entry = new PricebookEntry();
        entry.Pricebook2Id = test.getStandardPricebookId();
        entry.Product2Id = buildProducts().get(0).Id;
        entry.UnitPrice = 1;
        entry.IsActive = true;
        Insert entry;
        
        Return order;
    }
    
    @isTest
    private static List<Product2> buildProducts(){
        Product2 productA = new Product2();
        Product2 productB = new Product2();
        
        productA.Name = 'Test-01';
        productA.ProductCode = '001';
        
        productB.Name = 'Test-02';
        productB.ProductCode = '002';
        
        List<Product2> products = new List<Product2>();
        products.add(productA);
        products.add(productB);
        Insert products;
        return products;
    }
    
    @isTest
    private static Account buildAccount(){
        Account acc = new Account();
        acc.name = 'Test-Get-Addresses';
        acc.SAPCodeTxt__c = '9999999';
        acc.CNPJTxt__c = '92.367.433/0001-06';
        Insert acc;
        return acc;
    }
    
    @isTest
    private static SalesActionItems__c buildSalesAction(){
        
        SalesAction__c salesAction = new SalesAction__c();
        salesAction.name = 'Ultra week';
        salesAction.EndDateDte__c = System.today() + 7;
        salesAction.StartDateDte__c = System.today(); 
        salesAction.ObservationTxt__c = 'Ultra week';
        Insert salesAction;
        
        Product2 product = buildProducts().get(0);
        
        SalesActionItems__c item = new SalesActionItems__c();
        item.DiscountNmb__c = 5;
        item.EndVolumeNmb__c = 200;
        item.InitialVolumeNmb__c = 100;
        item.SalesAction__c = salesAction.Id;
        item.ProductLkp__c = product.Id;
        Insert item;
        
        return item;
    }
    
    @isTest static void delivery(){
        CreateData();
        ogSugarController.getDeliveryOption();
    }
    
    @isTest
    public static void hasSalesActions(){
        Test.startTest();
        buildSalesAction();
        List<Boolean> result = ogSugarController.hasSalesActions(null);
        System.assertEquals(1, result.size(), 'Deve haver apenas um valor na lista.');
        System.assertEquals(false, result.get(0), 'O valor da lista deve ser falso.');
        
        List<Product2> products = new List<Product2>();
        products.addAll([SELECT id FROM Product2 WHERE ProductCode = '001']);
        
        result = ogSugarController.hasSalesActions(products);
        System.assertEquals(1, result.size(), 'Deve haver apenas um valor na lista.');
        System.assertEquals(true, result.get(0), 'O valor da lista deve ser verdadeiro.');
        Test.stopTest();
    }
    
    @isTest
    public static void getAllContractValues() {
        Account acc = buildAccount(); 
        
        Test.startTest();
        
        Contract contract = new Contract();
        contract.StartDate = System.today();
        contract.AccountId = acc.Id;
        contract.status = 'Draft';
        Insert contract;
        
        List<Contract> contracts = ogSugarController.getAllContractValues(null);
        System.assertEquals(0, contracts.size(), 'Nenhum contrato deve ser retornado.');
        
        contract.status = 'Activated';
        Update contract;
        contracts = ogSugarController.getAllContractValues(acc.id);
        System.assertNotEquals(null, contracts, 'O contrato não deve ser nulo.');
        
        Test.stopTest();
    }
    
    @isTest
    public static void getTableValue(){
        Product2 product = buildProducts().get(0);
        
        Test.startTest();
        
        //Produto Padrão
        Product2 orderProduct = new Product2();
        orderProduct.name = 'Product Test';
        orderProduct.BasicUnitTxt__c = 'PC';
        orderProduct.SAPCodeTxt__c = '001';
        orderProduct.IsActive = true;
        orderProduct.Tipo__c = 'Açúcar';
        Insert orderProduct;
        
        //Forma de Pagamento
        paymentCondition__c pay = new paymentCondition__c();
        pay.name = '05 dias';
        pay.SAPCodeTxt__c = '0000';
        pay.isActive__c = true; 
        Insert pay;
        
        //Sales Área
        SalesArea__c salesArea = new SalesArea__c();
        salesArea.SAPCodeTxt__c = '0000';
        salesArea.DistributionChannelTxt__c = '11';
        salesArea.ActivitySectorTxt__c = '10';
        salesArea.isActive__c = true;
        Insert salesArea;
        
        //Creating Supplier Center 
        SupplierCenter__c sup = new SupplierCenter__c();
        sup.name = 'Test Supplier';
        sup.isActive__c = true;
        sup.SapCodeTxt__c = '2131';
        Insert sup;
        
        //Verificação
        String customerDomicile = 'MT 5106505';
        Id supplierCenterId = sup.id;
        Id salesAreaId = SalesArea.id;
        
        Id ProductId = orderProduct.Id;
        String paymentConditionId = pay.id;
        Decimal Quantity = 10;
        
        ogsugarcontroller.getTableValue(customerDomicile, productId, salesAreaId, paymentConditionId, quantity);
        Test.stopTest();
    }
    
    @isTest
    public static void getOrderName(){
        
        Test.startTest();
        
        Order order = buildOrder();
        System.assertEquals('', ogSugarController.getOrderName(''), 'O nome do pedido não pode ser gerado.');
        System.assertNotEquals('', ogSugarController.getOrderName(order.Id), 'O nome do pedido deve ser gerado automaticamente.');
        
        Test.stopTest();
    }
    
    @isTest
    public static void deleteOrderAndOrderItem(){
        
        Test.startTest();
        
        //Creating product 
        Product2 orderProduct = new Product2();
        orderProduct.name = 'Product Test';
        orderProduct.BasicUnitTxt__c = 'PC';
        Insert orderProduct;
        
        //Creating pricebook Entry
        PricebookEntry entry = new PricebookEntry();
        entry.Pricebook2Id = test.getStandardPricebookId();
        entry.Product2Id = orderProduct.Id;
        entry.UnitPrice = 1;
        entry.IsActive = true;
        //Insert entry;
        
        Order order = buildOrder();
        String accId = buildAccount().Id;
        OrderItem orderItem = new OrderItem();
        orderItem.Account__c = accId;
        orderItem.DateShipmentDte__c = System.today() + 1;
        orderItem.OrderId = order.Id;
        orderItem.PricebookEntryId = entry.Id;
        orderItem.UnitPrice = 1;
        orderItem.Quantity = 1;
        //Insert orderItem;
        
        ogSugarController.deleteOrder(order.Id);
        List<OrderItem> orderItens = [SELECT Id, PriceBookEntryId FROM OrderItem WHERE OrderId =: order.Id];
        System.assertEquals(0, orderItens.size(), 'Os itens do pedido devem ser deletados.');
        
        List<Order> orders = [SELECT id FROM Order WHERE id =: order.Id];
        System.assertEquals(0, orders.size(), 'O pedido deve ser deletado.');
        
        //order = buildOrder();
        
        orderItem = new OrderItem();
        orderItem.Account__c = accId;
        orderItem.DateShipmentDte__c = System.today() + 1;
        orderItem.OrderId = order.Id;
        orderItem.PricebookEntryId = entry.Id;
        //Insert orderItem;
        
        ogSugarController.deleteOrderItem(orderItem.Id);
        
        orderItens = [SELECT id FROM OrderItem WHERE id =: orderItem.Id];
        System.assertEquals(0, orderItens.size(), 'O item do pedido deve ser deletado.');
        
        Test.stopTest();
        
    }
    
    @isTest
    public static void saveOrderItens(){
        Test.setMock(HttpCalloutMock.class, new HttpCalloutMockSAP());
        Order salesOrder = buildOrder();
        
        PricebookEntry pbe = [SELECT id, Product2Id FROM PricebookEntry WHERE Pricebook2Id =: salesOrder.Pricebook2Id limit 1];
        OrderItem oItem = new OrderItem(OrderId = salesOrder.Id);
        oItem.PricebookEntryId = pbe.Id;
        oItem.UnitPrice = 1;
        oItem.Product2Id = pbe.product2Id;
        oItem.Quantity = 1;
        
        ogSugarController.saveOrderItens(salesOrder, new List<OrderItem>{oItem}, 'Finalizado');
    }
}