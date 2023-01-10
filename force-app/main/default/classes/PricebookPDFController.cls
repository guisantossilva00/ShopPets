@testvisible
public class PricebookPDFController {
    
    public boolean hasError {get; private set;}
    public String errorMessage {get; private set;}    
     
    public List<String> conditionNames {get; private set;}
    public Map<String, List<String>> conditionsMap {get;private set;}
    
    public List<SupplierCenter__c> suppliers {get; private set;}
    public Set<String> suppliersIds {private get; private set;}
    public Set<String> accountsIds {private get; private set;}
    public List<String> nameConditions {get; private set;}
    public List<PricebookEntry> pricebooks{get; private set;}
    
    public List<PaymentConditionVolume__c> payConVolumes {private get; private set;}
    public Map<String, List<PaymentConditionVolume__c>> payConVolDivide {get; private set;}
    public List<PaymentConditionVolume__c> volumesToShow {get; private set;}
    public List<Product2> products {get; private set;}
    
    public Set<String> teams {get; private set;}
    
     
    public PricebookPDFController(){
        this.hasError = false;
        this.errorMessage = '';
        this.volumesToShow = new List<PaymentConditionVolume__c>();
		this.nameConditions = new List<String>();
        this.payConVolDivide = new Map<String, List<PaymentConditionVolume__c>>();
        this.conditionsMap = new Map<String, List<String>>(); 
        Set<String> productsIds = new Set<String>();
        this.products = new List<Product2>();
        
        this.payConVolumes = [SELECT Id, Name, PaymentConditionLkp__c, PaymentConditionLkp__r.SapCodeTxt__c, InitialVolumeNmb__c, TableColumnNmb__c, TableLineNmb__c ,FinalVolumeNmb__c, MultiplierPriceNmb__c, 
                              ProductLkp__c,  ProductLkp__r.Name, PaymentConditionLkp__r.Name FROM PaymentConditionVolume__c WHERE 
                              ProductLkp__c != null AND ProductLkp__r.isActive = true AND ActiveBln__c = true AND 
                              PaymentConditionLkp__c != null AND PaymentConditionLkp__r.SapCodeTxt__c != null 
                              AND PaymentConditionLkp__r.IsActive__c = true ORDER BY TableLineNmb__c ASC, TableColumnNmb__c ASC, ProductLkp__c ASC, InitialVolumeNmb__c ASC, PaymentConditionLkp__r.name ASC];
         
        if(this.payConVolumes.size() > 0){
            for(PaymentConditionVolume__c payConVol : payConVolumes){
                String productId = payConVol.ProductLkp__c;
                if(!productsIds.contains(productId)){
                    productsIds.add(productId);
                    Product2 toIterate = new Product2();
                    toIterate.name = payConVol.ProductLkp__r.Name; 
                    toIterate.id = productId;
                    this.products.add(toIterate);   
                }
            }
            mapConditions();
            processRecords(this.payConVolumes);
        }
        
        RepresentativeAccess ra = new RepresentativeAccess();
        this.suppliers = getSuppliersByAreas(ra.getAreas(UserInfo.getUserId()));
        Set<String> domiciles = ra.getCustomerDomiciles(UserInfo.getUserId(), this.accountsIds);
        this.pricebooks = getEntries(domiciles);
        if(this.pricebooks.size() > 0){
            System.debug(this.pricebooks.size()+'SIZE ENTRIES');
            for(PricebookEntry entry : pricebooks){
                String key = entry.Product2Id;
                if(!this.payConVolDivide.containsKey(key)){
                    PaymentConditionVolume__c payConVol = new PaymentConditionVolume__c();
                    payConVol.Name = 'Preço base';
                    payConVol.ProductLkp__c = entry.Product2Id;
                    payConVol.MultiplierPriceNmb__c = 0;
                    payConVol.InitialVolumeNmb__c = 1;
                    payConVol.FinalVolumeNmb__c = 999;
                    List<PaymentConditionVolume__c> conditionBase = new List<PaymentConditionVolume__c>();
                    conditionBase.add(payConVol);
                    this.payConVolDivide.put(key, conditionBase);
                    this.volumesToShow.add(payConVol);
                }
                if(!this.conditionsMap.containsKey(key)){
                    List<String> basePrice = new List<String>();
                    basePrice.add('Preço base');
                    this.conditionsMap.put(key, basePrice);
                }
            }
        } else {
            this.errorMessage = 'Nenhum catálogo de preço definido para o representante.';
            this.hasError = true;
        }
        
    }
    public List<PricebookEntry> getEntries(Set<String> domiciles){
        return filterEntries([SELECT Product2Id, Product2.Name, UnitPrice, Product2.SapCodeTxt__c, TAXJURCODETxt__c,SupplierCenterLkp__r.SapCodeTxt__c FROM PricebookEntry WHERE IsActive = true
                AND Pricebook2.IsActive = true AND Pricebook2.EffectiveEndDateDte__c >= TODAY
                AND Pricebook2.EffectiveStartDateDte__c <= TODAY
                AND SupplierCenterLkp__c IN : this.suppliersIds AND TAXJURCODETxt__c IN : domiciles
                AND Product2.IsActive = true ORDER BY SupplierCenterLkp__r.Name, TAXJURCODETxt__c ASC limit 1000]);
    }
    
    public List<PricebookEntry> filterEntries(List<PricebookEntry> entries){
        if(entries.size() > 0){
            Set<String> supplierCenterProduct = new Set<String>();
            List<PricebookEntry> filteredEntries = new List<PricebookEntry>();
            for(PricebookEntry entry : entries){
                String key = entry.SupplierCenterLkp__c+''+entry.Product2Id+''+entry.TAXJURCODETxt__c;
                if(!supplierCenterProduct.contains(key)){
                    filteredEntries.add(entry);
                    supplierCenterProduct.add(key);
                }
            }
            return filteredEntries;
        } 
        return new List<PricebookEntry>();
    }
    public List<SupplierCenter__c> getSuppliersByAreas(List<SalesArea__c> areas){
        if(areas.size() > 0){
            this.suppliersIds = new Set<String>();
            this.accountsIds = new Set<String>();
            for(SalesArea__c area : areas){
                this.suppliersIds.add(area.SupplierCenterLkp__c);
                this.accountsIds.add(area.CustomerLkp__c);
            }
            System.debug(this.suppliersIds.size()+'SIZE SUPP');
            List<SupplierCenter__c> suppliersCenters = [SELECT Id, Name, SapCodeTxt__c FROM SupplierCenter__c WHERE id IN : this.suppliersIds
                                                        ORDER BY Name];
            if(suppliersCenters.size() > 0){
                return suppliersCenters;
            }
        }
        return new List<SupplierCenter__c>();
    }
    
    public with sharing class RepresentativeAccess {
        
        public Set<String> getCustomerDomiciles(String userId, Set<String> accountsIds){
            List<Account> accounts = [SELECT TaxDomicileTxt__c FROM Account WHERE Id IN : accountsIds AND OwnerId =: userId AND TaxDomicileTxt__c != null];
            Set<String> domiciles = new Set<String>();
            if(accounts.size() > 0){
                for(Account acc : accounts){
                   domiciles.add(acc.TaxDomicileTxt__c);
                }
            }
            return domiciles;
        }
        
        public List<SalesArea__c> getAreas(String userId){
            return [SELECT CustomerLkp__c, SupplierCenterLkp__c FROM SalesArea__c WHERE SupplierCenterLkp__c != null 
                    AND SupplierCenterLkp__r.IsActive__c = true AND IsActive__c  = true AND OwnerId =: userId];
        }
    }
     
    //Get all Payment conditions
    public void mapConditions(){
        
        this.conditionsMap = new Map<String, List<String>>();
        List<String> conditions; 
        this.conditionNames = new List<String>();
        for(PaymentConditionVolume__c payConVol : this.payConVolumes){
            String payConName = payConVol.PaymentConditionLkp__r.SapCodeTxt__c;
            
            if(!this.conditionNames.contains(payConName)){
                this.conditionNames.add(payConName);
            }
            if(this.conditionsMap.containsKey(payConVol.ProductLkp__c)){
                
                conditions = this.conditionsMap.get(payConVol.ProductLkp__c);
                
                if(!conditions.contains(payConName)){
                    conditions.add(payConName);
                }
                
            } else { 
                conditions = new List<String>();
                conditions.add(payConVol.PaymentConditionLkp__r.SapCodeTxt__c);
                this.conditionsMap.put(payConVol.ProductLkp__c, conditions);
            }
        }
    }
    
    //Process records to divide in lists for every [inital volume - final volume].
    @testvisible
    public void processRecords(List<PaymentConditionVolume__c> payConVolumes){
        
        Set<String> volumesAddeds = new Set<String>();
        
        for(PaymentConditionVolume__c payConVol : payConVolumes){
            String key = payConVol.ProductLkp__c;
            String productPerVolume = key+'-'+payConVol.InitialVolumeNmb__c+'-'+payConVol.FinalVolumeNmb__c;
            if(!volumesAddeds.contains(productPerVolume)){
                this.volumesToShow.add(payConVol);
                volumesAddeds.add(productPerVolume);
            }
            
            if(payConVolDivide.containsKey(key)){
                payConVolDivide.get(key).add(payConVol);
            } else {
                List<PaymentConditionVolume__c> newRecords = new List<PaymentConditionVolume__c>();
                newRecords.add(payConVol);
                payConVolDivide.put(key, newRecords);
            }  
            String fullName = payConVol.PaymentConditionLkp__r.SapCodeTxt__c+' - '+payConVol.PaymentConditionLkp__r.Name;
            if(!this.nameConditions.contains(fullName)){
                this.nameConditions.add(fullName);
            }
        }
    }
}