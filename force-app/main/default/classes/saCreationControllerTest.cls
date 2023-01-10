@isTest
public class saCreationControllerTest {
    
    @istest static void supliers_representatives(){
        saCreationController.suppliers();
        //Creating Supplier Center 
        SupplierCenter__c sup = new SupplierCenter__c();
        sup.name = 'Test Supplier';
        sup.isActive__c = true;
        sup.SapCodeTxt__c = '2131';
        Insert sup;
        
        saCreationController.representatives();
        //Creating Sales Team
        SalesTeam__c team = new SalesTeam__c();
        team.name = 'Super Fast Test Team';
        team.SAPCodeTxt__c = '00';
        Insert team;
        
    }
    @isTest
    public static void clients(){
        Test.startTest();
        Account acc = new Account();
        acc.CNPJTxt__c = '92.367.433/0001-06';
        acc.name = 'Account Test';
        acc.Name__c = 'Account Test';
        acc.SAPCodeTxt__c = 'Test';
        Insert acc;

        SalesTeam__c team = new SalesTeam__c();
        team.Name = 'Team Test';
        Insert team;
        
		SalesArea__c salesArea = new SalesArea__c();
		salesArea.CustomerLkp__c = acc.Id;
	 	salesArea.SalesTeamLkp__c = team.Id;
        salesArea.Name = 'Blackfriday';
        Insert salesArea;
        
        saCreationController.clients(team.Id);
        saCreationController.clients('');

        Test.stopTest();
    }   
    
    @isTest
    public static void products(){
        //ADD LINKED TABLE 
        Test.startTest();
        System.assertNotEquals(null, saCreationController.products(), 'A instância da lista deve estar vazia, não nula.');

        Product2 product = new Product2();
        product.Name = 'Product-Test';
        Test.stopTest();
    }

    @isTest
    public static void save(){
        Test.startTest();
        
        Account acc = new Account();
        acc.CNPJTxt__c = '92.367.433/0001-06';
        acc.name = 'Account Test';
        acc.Name__c = 'Account Test';
        acc.SAPCodeTxt__c = 'Test';
        Insert acc;
        
        SalesTeam__c st = new SalesTeam__c();
        st.Name = 'Sales-Team-Test';
        Insert st; 
        
        SupplierCenter__c sc = new SupplierCenter__c();
        sc.Name = 'Supplier-Center-Test';
        Insert sc;
        
        SalesAction__c salesAct = new SalesAction__c();
        salesAct.Name = 'Sales-Action-Test';
        salesAct.EndDateDte__c = System.today() + 1;
        salesAct.StartDateDte__c = System.Today();
        salesAct.RepresentativeLkp__c = st.Id;
        salesAct.SupplierCenterLkp__c = sc.Id;
        
        Product2 product = new Product2();
        product.Name = 'Product-Test';

        
        SalesActionItems__c item = new SalesActionItems__c();
        item.name = 'Product2-Test';
        item.DiscountNmb__c = 5;
        item.InitialVolumeNmb__c = 1;
        item.EndVolumeNmb__c = 100;
        item.ProductLkp__c = product.Id;
        item.SalesAction__c = null;
        
        SalesActionCustomers__c customer = new SalesActionCustomers__c();
        customer.AccountLkp__c = acc.id;
        customer.Name = 'Customer';
        customer.SalesAction__c = salesAct.Id;
        Insert customer;
          
        saCreationController.save(salesAct, new List<Account>(), new List<SalesActionItems__c> {item});
        Test.stopTest();
    }
    
    @isTest
    public static void createSalesActionCustomers(){
        List <Account> customers = new List <Account>();

        Account acc = new Account();
        acc.CNPJTxt__c = '92.367.433/0001-06';
        acc.name = 'Account Test';
        acc.SAPCodeTxt__c = 'Test';
        Insert acc;
        
        customers.add(acc);
        
        SalesTeam__c st = new SalesTeam__c();
        st.Name = 'Sales-Team-Test';
        Insert st; 
        
        SupplierCenter__c sc = new SupplierCenter__c();
        sc.Name = 'Supplier-Center-Test';
        Insert sc;
        
        SalesAction__c salesAct = new SalesAction__c();
        salesAct.Name = 'Sales-Action-Test';
        salesAct.EndDateDte__c = System.today() + 1;
        salesAct.StartDateDte__c = System.Today();
        salesAct.RepresentativeLkp__c = st.Id;
        salesAct.SupplierCenterLkp__c = sc.Id;
        Insert salesAct;
            
        test.startTest();
        saCreationController.createSalesActionCustomers(salesAct.Id, customers);
        System.assertEquals(1, [SELECT COUNT() FROM SalesActionCustomers__c WHERE Name = 'Account Test']);
        test.stopTest();
    }
}