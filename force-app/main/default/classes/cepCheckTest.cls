@isTest
public with sharing class cepCheckTest {
    
   @isTest
    public static void cepCheckTestSucess() {
        
        CEP__c cep = new CEP__c();
        cep.CepInicio__c = '01000-000';
        cep.CepFim__c = '01999-998';
        cep.Estado__c = 'SP';
        
        insert cep;
        
        List<String> teste = new List<String>();
        teste.add('01258-010,SP');
        
        String acep = '01155-000';
        string estado = 'SP)';
        
        Test.startTest();
        CEPCheck.fetchParams(teste);
        //CEPCheck.check(acep, estado);
        Test.stopTest();
        
    }
    
    @isTest
    public static void cepCheckTestFail() {
        
        CEP__c cep = new CEP__c();
        cep.CepInicio__c = '01000-000';
        cep.CepFim__c = '01999-998';
        cep.Estado__c = 'SP';
        
        insert cep;
        
        List<String> teste = new List<String>();
        teste.add('99999-000,AC');
        
        String acep = '99999-000';
        string estado = 'AC';
        
        Test.startTest();
        CEPCheck.fetchParams(teste);
        //CEPCheck.check(acep, estado);
        Test.stopTest();
        
    }
    
        @isTest
    public static void cepCheckRange() {
        
        CEP__c cep = new CEP__c();
        cep.CepInicio__c = '01000-000';
        cep.CepFim__c = '01000-999';
        cep.Estado__c = 'SP';
        
        insert cep;
        
        List<String> teste = new List<String>();
        teste.add('01001-000,SP');

        Test.startTest();
        CEPCheck.fetchParams(teste);
        Test.stopTest();
        
    }
}