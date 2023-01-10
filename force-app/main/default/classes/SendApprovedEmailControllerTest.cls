@isTest
public without sharing class SendApprovedEmailControllerTest {
    @testSetup static void setup(){                
        Account account = Commerce_TestDataFactory.createAccount('account test');
        insert account;
        
        Contact contact = Commerce_TestDataFactory.createContact('test firstName', 'test lastName', account.Id);         
        insert contact;		        
  		
        User user = Commerce_TestDataFactory.createUser('test lastName', contact.id);                       
        insert user;         
        
    }
    
	@IsTest
     static void SendApprovedEmailTest() { 
         User user = [Select Id from User where LastName = 'test lastName' LIMIT 1];       
         SendApprovedEmailController.SendApprovedEmail(user.Id);
     }
}