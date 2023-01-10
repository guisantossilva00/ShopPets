@istest(SeeAllData=true)
public class PricebookPDFControllerTest {
    public static PricebookPDFController getInstance(){
        PageReference testPage = Page.PricebookPDF; 
        Test.setCurrentPage(testPage);
        
        Product2 orderProduct = new Product2();
        orderProduct.name = 'Product Test';
        orderProduct.BasicUnitTxt__c = 'PC';
        orderProduct.SAPCodeTxt__c = '0935';
        orderProduct.IsActive = true;
        Insert orderProduct;
        
        paymentCondition__c pay = new paymentCondition__c();
        pay.name = '05 dias';
        pay.SAPCodeTxt__c = '0936';
        pay.isActive__c = true; 
        Insert pay;
     
        List<PaymentConditionVolume__c> paycon = new List<PaymentConditionVolume__c>();
        PaymentConditionVolume__c first = new PaymentConditionVolume__c();
        first.Name = 'Payment Condition - 1';
        first.InitialVolumeNmb__c = 1;
        first.FinalVolumeNmb__c = 999;
        first.ListPriceBln__c = false; 
        first.LowPriceBln__c = false;
        first.MultiplierPriceNmb__c = 1.3;
        first.ProductLkp__c = orderProduct.id;
        first.PaymentConditionLkp__c = pay.id;
        insert first;
       

        //Creating Supplier Center 
        SupplierCenter__c sup = new SupplierCenter__c();
        sup.name = 'Test Supplier';
        sup.isActive__c = true;
        sup.SapCodeTxt__c = '333';
        Insert sup;
        
        Pricebook2 standard = [SELECT IsActive, Id, EffectiveStartDateDte__c, EffectiveEndDateDte__c
                               FROM Pricebook2 WHERE IsStandard = true limit 1];
        standard.IsActive = true;
        standard.EffectiveEndDateDte__c = System.today();
        standard.EffectiveStartDateDte__c = system.today();
        Update standard; 
        
         //Creating pricebook Entry
        PricebookEntry entry = new PricebookEntry();
        entry.Pricebook2Id = standard.Id;
        entry.Product2Id = orderProduct.Id;
        entry.UnitPrice = 1;
        entry.IsActive = true;
        entry.SupplierCenterLkp__c = sup.Id;
        entry.TAXJURCODETxt__c = 'PE 2323213';
        Insert entry;
        
        //Creating Sales Team
        SalesTeam__c team = new SalesTeam__c();
        team.name = 'Super Fast Test Team';
        team.RepresentativeLkp__c = UserInfo.getUserId();
        team.SAPCodeTxt__c = '444';
        Insert team;
        
        Account customer = new Account();
        customer.Name = 'Test';
        customer.SapCodeTxt__c = '5555';
        customer.IsActive__c = true;
        customer.CNPJTxt__c = '04.021.375/0001-99';
        customer.TaxDomicileTxt__c = 'PE 2323213';
        Insert customer;
        
        SalesArea__c area = new SalesArea__c();
        area.SAPCodeTxt__c = '666';
        area.SalesTeamLkp__c = team.Id;
        area.isActive__c = true;
        area.CustomerLkp__c = customer.Id;
        area.SupplierCenterLkp__c = sup.Id;
        Insert area;
        Delete pay;
		
        PricebookPDFController controllerInstance = new PricebookPDFController();
        return controllerInstance;
    }
    
    @istest
    public static void buildOrder(){
        
        Product2 orderProduct = new Product2();
        orderProduct.name = 'Product Test';
        orderProduct.BasicUnitTxt__c = 'PC';
        orderProduct.SAPCodeTxt__c = '777';
        Insert orderProduct;
        
        paymentCondition__c pay = new paymentCondition__c();
        pay.name = '05 dias';
        pay.SAPCodeTxt__c = '888';
        pay.isActive__c = true; 
        Insert pay;
        
        List<PaymentConditionVolume__c> paycon = new List<PaymentConditionVolume__c>();
        PaymentConditionVolume__c first = new PaymentConditionVolume__c();
        first.Name = 'Payment Condition - 1';
        first.InitialVolumeNmb__c = 1;
        first.FinalVolumeNmb__c = 2;
        first.ListPriceBln__c = false; 
        first.LowPriceBln__c = false;
        first.MultiplierPriceNmb__c = 33.33;
        first.ProductLkp__c = orderProduct.id;
        first.PaymentConditionLkp__c = pay.id;
        paycon.add(first);
        insert paycon;
        
        //Creating pricebook Entry
        PricebookEntry entry = new PricebookEntry();
        entry.Pricebook2Id = test.getStandardPricebookId();
        entry.Product2Id = orderProduct.Id;
        entry.UnitPrice = 1;
        entry.IsActive = true;
        Insert entry;
        
        //Creating Supplier Center 
        SupplierCenter__c sup = new SupplierCenter__c();
        sup.name = 'Test Supplier';
        sup.isActive__c = true;
        sup.SapCodeTxt__c = '1199';
        Insert sup;
        
        //Creating Sales Team
        SalesTeam__c team = new SalesTeam__c();
        team.name = 'Super Fast Test Team';
        team.SAPCodeTxt__c = '1198';
        Insert team;
        
        Test.startTest();
        PricebookPDFController controller = getInstance();
        controller.processRecords(paycon);
        test.stopTest();
    }
    
    @istest
    public static void test_method(){
        Product2 orderProduct = new Product2();
        orderProduct.name = 'Product Test';
        orderProduct.BasicUnitTxt__c = 'PC';
        orderProduct.SAPCodeTxt__c = '0729';
        Insert orderProduct;
        
        List<PricebookEntry> entries = new List <PricebookEntry>();
        PricebookEntry entry = new PricebookEntry();
        entry.Pricebook2Id = test.getStandardPricebookId();
        entry.Product2Id = orderProduct.Id;
        entry.UnitPrice = 1;
        entry.IsActive = true;
        entries.add(entry);
        Insert entries;
        
        PricebookPDFController controller2 = getInstance();
        controller2.filterEntries(entries);
    }
    
    @istest
    public static void method_two(){
        
        //Creating Sales Area
        List<SalesArea__c> areas = new List <SalesArea__c>();
        SalesArea__c salesArea = new SalesArea__c();
        salesArea.SAPCodeTxt__c = '999999';
        salesArea.isActive__c = true;
        areas.add(salesArea);
        Insert areas;
        
        //Creating Supplier Center 
        List<SupplierCenter__c> supcenter = new List <SupplierCenter__c>();
        SupplierCenter__c sup = new SupplierCenter__c();
        sup.name = 'Test Supplier';
        sup.isActive__c = true;
        sup.SapCodeTxt__c = '99999999';
        supcenter.add(sup);
        Insert supcenter;
        
        PricebookPDFController controller3 = getInstance();
        controller3.getSuppliersByAreas(areas);
    }
}