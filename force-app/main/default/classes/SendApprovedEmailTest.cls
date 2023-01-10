@isTest
public class SendApprovedEmailTest {
	@testSetup static void setup(){                
        Account acc = Commerce_TestDataFactory.createAccount('test acc');                   
  		insert acc;
        
        Contact contact = Commerce_TestDataFactory.createContact('test firstName', 'test lastName', acc.Id);         
        insert contact;		        
  		
        User user = Commerce_TestDataFactory.createUser('test lastName', contact.id);                       
        insert user;          
        
    }
    
    @isTest static void SendEditApprovedEmailTest() {        
        
        User user = [Select Id from User where LastName = 'test lastName' LIMIT 1];       
        user.IsActive = true;
        update user;
    }
}