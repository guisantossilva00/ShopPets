@isTest
public class ParceirosSAPTest {
    
    @isTest
    public static void ParceirosSAPTest(){
        
        //Creating customer
        Account customer = new Account();
        
        customer.Name = 'Any Customer LTDA';
        customer.CNPJTxt__c = '05.594.461/0001-53';
        customer.isActive__c = true;
        customer.SAPCodeTxt__c = '0000';
        Insert customer;

        test.startTest();
        ParceirosSAP orderSAP = new ParceirosSAP(customer);
        test.stopTest();
    }
}