@RestResource(urlMapping='/Pricebook/Calculation/')
global class PriceCalculationHelperREST{
    
    @Httppost 
    @AuraEnabled(cacheable=false)
    global static Decimal doPost(String customerDomicile, Id productId, Id salesAreaId, Id paymentConditionId,Decimal quantity){
        Decimal percentage = getVolumePercentage(productId, paymentConditionId, quantity);
        List<SalesArea__c> area = [SELECT SupplierCenterLkp__c FROM SalesArea__c WHERE id =: salesAreaId AND IsActive__c = true];
        String supplierCenterId = null;
        Decimal pricebookValue = 0;
        if(area.size() > 0){
            supplierCenterId = area.get(0).SupplierCenterLkp__c;
            pricebookValue = getPricebookValue(customerDomicile, productId, supplierCenterId);
        }
        return (pricebookValue + (pricebookValue * percentage)).setScale(2);   
    }

    public static Decimal getVolumePercentage(Id productId, Id paymentConditionId, Decimal quantity){
        List<PaymentConditionVolume__c> payConVol = [SELECT MultiplierPriceNmb__c FROM PaymentConditionVolume__c WHERE Productlkp__c =: productId
                                                     AND PaymentConditionLkp__c =: paymentConditionId 
                                                     AND InitialVolumeNmb__c <=: quantity 
                                                     AND FinalVolumeNmb__c >=: quantity 
                                                     AND ActiveBln__c = true
                                                     AND PaymentConditionLkp__r.IsActive__c = true];
        if(payConVol.size() > 0){
            if(payConVol.get(0).MultiplierPriceNmb__c == 0){
                return 0;
            }
            return payConVol.get(0).MultiplierPriceNmb__c/100;
        }
        return 0;
    }
    
    public static Decimal getPricebookValue(String customerDomicile, Id productId, Id supplierCenterId){
        List<PricebookEntry> prices = [SELECT UnitPrice FROM PricebookEntry WHERE TAXJURCodeTxt__c =: customerDomicile
                                       AND Product2Id =: productId AND SupplierCenterLkp__c =: supplierCenterId
                                       AND SupplierCenterLkp__r.IsActive__c = true AND Product2.IsActive = true
                                       AND Pricebook2.PriceBookStatusTxt__c = 'Aprovado' AND Pricebook2.EffectiveStartDateDte__c <= TODAY  
                                       AND Pricebook2.IsActive = true AND Pricebook2.EffectiveEndDateDte__c >= TODAY];
        
        if(prices.size() > 0) return prices.get(0).UnitPrice;
        
        return 0;
    }
    
    
}