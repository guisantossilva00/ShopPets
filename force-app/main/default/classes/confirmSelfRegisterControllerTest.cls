@isTest
public without sharing class confirmSelfRegisterControllerTest {
	@testSetup static void setup(){
        
        Account acc = Commerce_TestDataFactory.createAccount('test acc');                   
  		insert acc;
        
        Contact contact = Commerce_TestDataFactory.createContact('test firstName', 'test lastName', acc.Id);         
        insert contact;		        
  		
        User user = Commerce_TestDataFactory.createUser('test lastName', contact.id);                       
        insert user;          
        
    }
    
    @IsTest
     static void verificaUserTest() {  
        User user = [Select Id from User where LastName = 'test lastName' LIMIT 1];       
        confirmSelfRegisterController.verificaUser(user.Id);
        confirmSelfRegisterController.verificaUser('456478797879');
        confirmSelfRegisterController.verificaUser('redirect'); 
     }
}