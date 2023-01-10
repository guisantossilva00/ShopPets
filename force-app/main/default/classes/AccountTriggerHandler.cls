public class AccountTriggerHandler {
    public static void ContactPoint(){
        List<Account> accounts = (List<Account>) trigger.new;
        List<ContactPointAddress> cpaToInsert = new List<ContactPointAddress>();
        
        for(Account account : accounts){ 
            if(!String.isEmpty(account.SapCodeTxt__c)){
                ContactPointAddress cpaShipping = new ContactPointAddress();
                cpaShipping.Name = account.SAPCodeTxt__c+'-Endereço de entrega';
                cpaShipping.ParentId = account.Id;
                cpaShipping.PostalCode = account.CEPTxt__c;
                cpaShipping.IsDefault = true;
                cpaShipping.IsPrimary = true;
                cpaShipping.Country = account.CountryTxt__c;
                cpaShipping.Street = account.StreetTxt__c;
                cpaShipping.City = account.CityTxt__c;
                cpaShipping.State = account.StateTxt__c;
                cpaShipping.AddressType = 'Shipping';
                cpaToInsert.add(cpaShipping);
            }
        }        
        Database.upsert(cpaToInsert , ContactPointAddress.Name, false);
    }
}