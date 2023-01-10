public class saCreationController {
    //Sales action creation controller 
    
    @AuraEnabled(cacheable=true)
    public static List<SupplierCenter__c> suppliers(){
        return [SELECT id, Name FROM SupplierCenter__c WHERE isActive__c = true ORDER BY Name ASC];
    }

    @AuraEnabled(cacheable=true)
    public static List<SalesTeam__c> representatives(){
        return [SELECT id, Name, AccountGroup__c FROM SalesTeam__c WHERE isActive__c = true ORDER BY Name ASC];
    }

    @AuraEnabled(cacheable=false)
    public static List<Account> clients(String representativeId){
        List<SalesArea__c> selection = [SELECT CustomerLkp__c FROM SalesArea__c WHERE CustomerLkp__c !=null AND SalesTeamLkp__c != null AND SalesTeamLkp__c =: representativeId];
        if(selection.size() > 0){
            List<String> clist = new List<String>();
            for(Salesarea__c area : selection){
                clist.add(area.CustomerLkp__c);
            }
            List<Account> cdisp = [SELECT id, Name, SAPCodeTxt__c FROM Account WHERE SAPCodeTxt__c != null AND id IN: clist ORDER BY Name ASC];
            return cdisp;
        }
        return new List<Account>();
    }

    @AuraEnabled(cacheable=true)
    public static List<Product2> products(){
        //ADD LINKED TABLE WHERE
        List<Product2> products = [SELECT Id, Name FROM Product2 ORDER BY Name ASC];
        if(products == null || products.size() == 0){
            products = new List<Product2>();
        }
        return products;
    }

   
    @AuraEnabled(cacheable=false)
    public static void save(SalesAction__c salesAction, List<Account> clients, List<SalesActionItems__c> salesActionItens){
        System.debug(clients);
        Insert salesAction;
        for(SalesActionItems__c item : salesActionItens){
            item.SalesAction__c = salesAction.Id;
        }
        Insert salesActionItens;
        createSalesActionCustomers(salesAction.Id, clients);
    }
    
    @TestVisible
	private static void createSalesActionCustomers(String salesActionId, List<Account> clients){
        List <SalesActionCustomers__c> salesActionCustomers = new List <SalesActionCustomers__c>();
        for (Account client : clients) {
        	SalesActionCustomers__c customer = new SalesActionCustomers__c();
            customer.Name = client.Name;
            customer.AccountLkp__c = client.Id;
            customer.SalesAction__c = salesActionId;
            salesActionCustomers.add(customer);
        }
        Insert salesActionCustomers;
    }
}