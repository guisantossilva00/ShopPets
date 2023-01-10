@isTest
private class ProductTriggerHandlerTest {
    @isTest static void test(){
       ProductTriggerHandler.testMock();
    }
    
    @isTest (SeeAllData=true) static void ProductOrder(){
        test.startTest();
        Product2 prd = new Product2();
        prd.Name = 'Product Test';
        prd.SAPCodeTxt__c = '001';
        prd.IsActive = true;
        insert prd;
       
        prd.IsActive = false;
        Update prd;
    }
}