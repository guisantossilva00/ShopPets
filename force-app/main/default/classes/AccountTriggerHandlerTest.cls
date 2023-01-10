@isTest
public class AccountTriggerHandlerTest {
    @isTest static void contactPointtest(){
        
        Account account = new Account();
        account.Name = 'Any Customer LTDA';
        account.CNPJTxt__c = '05.594.461/0001-53';
        account.isActive__c = true;
        account.SAPCodeTxt__c = '0000';
        account.CEPTxt__c = '87300410';
        account.CountryTxt__c = 'BR';
        account.StreetTxt__c = 'Rua Santa Catarina, 1787';
        account.CityTxt__c = 'Campo Mourão'; 
        account.StateTxt__c = 'PR';
        
        Insert account;
    }
}