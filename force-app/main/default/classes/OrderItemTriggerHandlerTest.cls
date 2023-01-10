@isTest 
public class OrderItemTriggerHandlerTest {
    @isTest(seeAllData=true)
    public static void valueDuringAction(){
        //Produto Padrão
        Product2 orderProduct = new Product2();
        orderProduct.name = 'Product Test';
        orderProduct.BasicUnitTxt__c = 'PC';
        orderProduct.SAPCodeTxt__c = '001';
        orderProduct.IsActive = true;
        Insert orderProduct;
        
        //Conta
        Account customer = new Account();
        customer.Name = 'Atonit LTDA';
        customer.CNPJTxt__c = '12.345.678/0001-00';
        customer.isActive__c = true;
        customer.SAPCodeTxt__c = '0000';
        customer.CEPTxt__c = '87300410';
        customer.CountryTxt__c = 'BR';
        customer.StreetTxt__c = 'Rua Santa Catarina, 1787';
        customer.CityTxt__c = 'Campo Mourão'; 
        customer.StateTxt__c = 'PR';
        Insert customer;
        
        //Creating Sales Team
        SalesTeam__c team = new SalesTeam__c();
        team.name = 'Super Fast Test Team';
        team.SAPCodeTxt__c = '00';
        Insert team;
        
        //Pedido
        String recordTypeSales = Schema.SObjectType.Order.getRecordTypeInfosByName().get('Sales').getRecordTypeId();
        Order salesOrder = new Order();
        salesOrder.Name = '000T3ST3';
        salesOrder.AccountId = customer.Id;
        salesOrder.EffectiveDate = System.today();
        salesOrder.PaymentFormTxt__c = 'C - Cheque - Pagto Fornecedor';
        salesOrder.isActive__c = true;
        salesOrder.Pricebook2Id = test.getStandardPricebookId();
        salesOrder.DeliveryOption__c = 'CIF - Custos, seguro e frete';
        salesOrder.Status = 'Rascunho';
        salesOrder.RecordTypeId = recordTypeSales;
        salesOrder.SalesTeamLkp__c = team.id;
        insert salesOrder;
        
        //Creating pricebook Entry
        PricebookEntry entry = new PricebookEntry();
        entry.Pricebook2Id = test.getStandardPricebookId();
        entry.Product2Id = orderProduct.Id;
        entry.UnitPrice = 1;
        entry.IsActive = true;
        Insert entry;
        
        SalesAction__c salesAct = new SalesAction__c();
        salesAct.Name = 'Black friday';
        salesAct.StartDateDte__c = system.today();
        salesAct.EndDateDte__c = system.today();
        Insert salesAct;
        
        List<SalesActionCustomers__c> customers = new List<SalesActionCustomers__c>(); 
        SalesActionCustomers__c scustomers = new SalesActionCustomers__c();
        scustomers.AccountLkp__c = customer.id;
        scustomers.Name = 'Customer';
        scustomers.SalesAction__c = salesAct.Id;
        customers.add(scustomers);
        Insert customers;
        system.debug('Sales Action Customers:' + customers);
        
        //Creating Items
        OrderItem item = new OrderItem();
        item.Product2Id = orderProduct.Id;
        item.OrderId = salesOrder.Id;
        item.Account__c = customer.Id;
        item.Quantity = 1;
        item.isActive__c = true;
        item.UnitPrice = 5;
        item.SalesPriceNmb__c = 5;
        item.PricebookEntryId = entry.Id;
        Insert item;
        
        item.UnitPrice = 10;
        Update item;
    }
    @IsTest
    static void test(){
        
        Test.startTest();
        OrderItemTriggerHandler.testMock();
        Test.stopTest();
    }
}