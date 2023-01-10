@isTest (SeeAllData=true)
public class PriceCalculationHelperRESTTest {
    
    @istest
    public static void method_test(){
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
        
        paymentConditionVolume__c payConVol = new paymentConditionVolume__c();
        payConVol.name = 'Tabela';
        payConVol.ActiveBln__c = true; 
        payConVol.PaymentConditionLkp__c = pay.Id;
        payConVol.InitialVolumeNmb__c = 10;
        payConVol.FinalVolumeNmb__c = 20;
        payConVol.MultiplierPriceNmb__c = 0.1;
        payConVol.ProductLkp__c = orderProduct.Id;
        Insert payConVol;
        
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
        
        Test.startTest();
        PriceCalculationHelperRest.doPost(customerDomicile, productId, salesAreaId, paymentConditionId, quantity);
        PriceCalculationHelperRest.getVolumePercentage(productId, null, quantity);
        PriceCalculationHelperRest.getVolumePercentage(productId, paymentConditionId, quantity);
        payConVol.MultiplierPriceNmb__c = 0;
        Update payConVol;
        PriceCalculationHelperRest.getVolumePercentage(productId, paymentConditionId, quantity);
        PriceCalculationHelperRest.getPricebookValue(customerDomicile, productId, supplierCenterId);
        test.stopTest();
    }
    
}