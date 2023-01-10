@isTest (SeeAllData=true)
public class OrderTriggerHandlerTest {
    @istest    
    public static void dataSetup(){
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
        
        //Forma de Pagamento
        paymentCondition__c pay = new paymentCondition__c();
        pay.name = '05 dias';
        pay.SAPCodeTxt__c = '0000';
        pay.isActive__c = true; 
        Insert pay;
        
        //Área de Vendas
        SalesArea__c salesArea = new SalesArea__c();
        salesArea.SAPCodeTxt__c = '0000';
        salesArea.DistributionChannelTxt__c = '11';
        salesArea.ActivitySectorTxt__c = '10';
        salesArea.isActive__c = true;
        Insert salesArea;
        
        //Equipe de Vendas
        SalesTeam__c team = new SalesTeam__c();
        team.name = 'Super Fast Test Team';
        team.SAPCodeTxt__c = '00';
        Insert team;
        
        //Pedido
        Order salesOrder = new Order();
        salesOrder.Name = '000T3ST3';
        salesOrder.paymentCondition__c = pay.Id;
        salesOrder.AccountId = customer.Id;
        salesOrder.EffectiveDate = System.today();
        salesOrder.SalesAreaLkp__c = salesArea.Id;
        salesOrder.PaymentFormTxt__c = 'C - Cheque - Pagto Fornecedor';
        salesOrder.status = 'Rascunho';
        salesOrder.SalesTeamLkp__c = team.Id;
        salesOrder.isActive__c = true;
        salesOrder.Pricebook2Id = test.getStandardPricebookId();
        salesOrder.OrderNumberTxt__c = '102030';
        salesOrder.DeliveryOption__c = 'CIF - Custos, seguro e frete';
        salesOrder.Status = 'Rascunho';
        insert salesOrder;
        
        //Creating pricebook Entry
        PricebookEntry entry = new PricebookEntry();
        entry.Pricebook2Id = test.getStandardPricebookId();
        entry.Product2Id = orderProduct.Id;
        entry.UnitPrice = 1;
        entry.IsActive = true;
        Insert entry;
        
        //Creating Items
        OrderItem item = new OrderItem();
        item.Product2Id = orderProduct.Id;
        item.OrderId = salesOrder.Id;
        item.Account__c = customer.Id;
        item.Quantity = 1;
        item.isActive__c = true;
        item.UnitPrice = 5;
        item.isActive__c = true;
        item.SalesPriceNmb__c = 5;
        item.PricebookEntryId = entry.Id;
        Insert item;
        
        Order ord = [SELECT Id, name, DeliveryOption__c, RecordTypeId, status FROM Order WHERE name = '000T3ST3' LIMIT 1];
        system.debug(ord);
        system.assertEquals('Rascunho', ord.status);

    }
    @istest    
    public static void pgtoAprovado(){
        
        dataSetup();
        test.startTest();
        Order ord = [SELECT Id, name, DeliveryOption__c, RecordTypeId, status FROM Order WHERE name = '000T3ST3' LIMIT 1];
        ord.Status = 'Pagamento aprovado';
        update ord;
        system.assertEquals('Pagamento aprovado', ord.status);
        test.stopTest();
    }
    
    @istest
    public static void cancelado(){
        dataSetup();
        test.startTest();
        Test.setMock(HttpCalloutMock.class, new HttpCalloutMockSAP());
        Order ord = [SELECT Id, name, DeliveryOption__c, RecordTypeId, status FROM Order WHERE name = '000T3ST3' LIMIT 1];
        ord.status = 'Cancelado';
        ord.OrderNumberTxt__c = '102030';
        update ord;
        system.assertEquals('Cancelado', ord.status);
        test.stopTest();
    }
    
    @istest
    public static void finalizado(){
        dataSetup();
        test.startTest();
        Order ord = [SELECT Id, name, DeliveryOption__c, RecordTypeId, status FROM Order WHERE name = '000T3ST3' LIMIT 1];
        ord.status = 'Finalizado';
        update ord;
        system.assertEquals('Finalizado', ord.status);
        test.stopTest();
    }
}