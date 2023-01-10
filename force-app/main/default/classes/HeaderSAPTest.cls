@isTest
public class HeaderSAPTest {
    @testSetup
    public static void createData(){
        //Creating product 
        Product2 orderProduct = new Product2();
        orderProduct.name = 'Product Test';
        orderProduct.BasicUnitTxt__c = 'PC';
        Insert orderProduct;
        
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
        
        //Creating pricebook Entry
        PricebookEntry entry = new PricebookEntry();
        entry.Pricebook2Id = test.getStandardPricebookId();
        entry.Product2Id = orderProduct.Id;
        entry.UnitPrice = 12;
        entry.IsActive = true;
        
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
        salesOrder.SalesTeamLkp__c = team.Id;
        salesOrder.isActive__c = true;
        salesOrder.Pricebook2Id = test.getStandardPricebookId();
        salesOrder.DeliveryOption__c = 'CIF - Custos, seguro e frete';
        Insert salesOrder;
        
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
        
        String incoterms2 = 'CIF - Custos, seguro e frete';

        HeaderSAP orderSAP = new HeaderSAP(salesOrder, team.SAPCodeTxt__c, pay.SAPCodeTxt__c);
        HeaderSAP orderStatusSAP = new HeaderSAP(salesOrder);
    }
}