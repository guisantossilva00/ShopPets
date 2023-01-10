@isTest
public class OrderUpsertRESTTest {
    
    @isTest(seeAllData = true)
    public static void createData(){
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        
        req.requestURI = '/Order/';  //Request URL
        req.httpMethod = 'Patch';//HTTP Request Type
        RestContext.request = req;
        RestContext.response= res;
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
        salesOrder.CustomIdTxt__c = '123';
        salesOrder.Pricebook2Id = test.getStandardPricebookId();
        salesOrder.DeliveryOption__c = 'CIF - Custos, seguro e frete';
        
        Insert salesOrder;
        OrderUpsertREST.doPatch(true, new List<Order>{salesOrder});
    }
}