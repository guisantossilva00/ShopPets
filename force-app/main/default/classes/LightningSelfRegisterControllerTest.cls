@IsTest(SeeAllData = true)
public without sharing class LightningSelfRegisterControllerTest {

 /* Verifies that IsValidPassword method with various password combinations. */
 @IsTest
 static void testIsValidPassword() {
  System.assert(LightningSelfRegisterController.isValidPassword('password?@12334', 'password?@12334') == true);
  System.assert(LightningSelfRegisterController.isValidPassword('password?@12334', 'dummyPassword') == false);
  System.assert(LightningSelfRegisterController.isValidPassword('password?@12334', null) == false);
  System.assert(LightningSelfRegisterController.isValidPassword(null, 'fakePwd') == false);
 }

 @IsTest
 static void testSiteAsContainerEnabled() {
  System.assertNotEquals(null, LightningSelfRegisterController.siteAsContainerEnabled('https://portaleu1-developer-edition.eu11.force.com'));
 }
    
 @IsTest
 static void testValidatePassword() { 
  Account acc = Commerce_TestDataFactory.createAccount('test1 acc1');                   
  insert acc;
     
  Contact contact = Commerce_TestDataFactory.createContact('test1 firstName1', 'test1 lastName1', acc.Id);         
  insert contact;	
     
  User user = Commerce_TestDataFactory.createUser('test1 lastName1', contact.id);                       
  insert user;          
        
  LightningSelfRegisterController.validatePassword(user, '123', '123');
 }

 /* Verifies the selfRegistration method flow with various invalid inputs */
 @IsTest
 static void testSelfRegistration() {
  Map < String, String > paramsMap = initializeParams();
  System.assertNotEquals(null, paramsMap);       
  System.assertNotEquals(null, LightningSelfRegisterController.selfRegister(paramsMap.get('CompanyName'),paramsMap.get('CNPJ'),paramsMap.get('InscricaoEM'),paramsMap.get('Phone'), paramsMap.get('lastName'), paramsMap.get('Endereco'),paramsMap.get('CEP'),paramsMap.get('Numero'),paramsMap.get('Bairro'),paramsMap.get('Cidade'),paramsMap.get('Estado'), paramsMap.get('Endereco'),paramsMap.get('CEP'),paramsMap.get('Numero'),paramsMap.get('Bairro'),paramsMap.get('Cidade'),paramsMap.get('Estado'),paramsMap.get('email'), paramsMap.get('password'), paramsMap.get('confirmPasswordWrong'), null, paramsMap.get('regConfirmUrl'), paramsMap.get('startUrl'), true));
  System.assertNotEquals(null, LightningSelfRegisterController.selfRegister(paramsMap.get('CompanyName'),paramsMap.get('CNPJ'),paramsMap.get('InscricaoEM'),paramsMap.get('Phone'), 'teste', paramsMap.get('Endereco'),paramsMap.get('CEP'),paramsMap.get('Numero'),paramsMap.get('Bairro'),paramsMap.get('Cidade'),paramsMap.get('Estado'), paramsMap.get('Endereco'),paramsMap.get('CEP'),paramsMap.get('Numero'),paramsMap.get('Bairro'),paramsMap.get('Cidade'),paramsMap.get('Estado'), 'email', paramsMap.get('password'), paramsMap.get('confirmPasswordWrong'), null, paramsMap.get('regConfirmUrl'), paramsMap.get('startUrl'), true));
  System.assertNotEquals(null, LightningSelfRegisterController.selfRegister(paramsMap.get('CompanyName'),paramsMap.get('CNPJ'),paramsMap.get('InscricaoEM'),paramsMap.get('Phone'), 'teste', paramsMap.get('Endereco'),paramsMap.get('CEP'),paramsMap.get('Numero'),paramsMap.get('Bairro'),paramsMap.get('Cidade'),paramsMap.get('Estado'), paramsMap.get('Endereco'),paramsMap.get('CEP'),paramsMap.get('Numero'),paramsMap.get('Bairro'),paramsMap.get('Cidade'),paramsMap.get('Estado'), paramsMap.get('email'), paramsMap.get('password'), paramsMap.get('confirmPasswordWrong'), null, paramsMap.get('regConfirmUrl'), paramsMap.get('startUrl'), true));
 }


 /* Verifies the selfRegistration flow for valid inputs */
 @IsTest
 static void testSelfRegisterWithProperCredentials() {
  Map < String, String > paramsMap = initializeParams(); 
  Account account = Commerce_TestDataFactory.createAccount('test acc');                   
  insert account;
  LightningSelfRegisterController.selfRegister(paramsMap.get('CompanyName'),paramsMap.get('CNPJ'),paramsMap.get('InscricaoEM'),paramsMap.get('Phone'), paramsMap.get('lastName'), paramsMap.get('Endereco'),paramsMap.get('CEP'),paramsMap.get('Numero'),paramsMap.get('Bairro'),paramsMap.get('Cidade'),paramsMap.get('Estado'),paramsMap.get('email'), paramsMap.get('Endereco'),paramsMap.get('CEP'),paramsMap.get('Numero'),paramsMap.get('Bairro'),paramsMap.get('Cidade'),paramsMap.get('Estado'), paramsMap.get('password'), paramsMap.get('confirmPasswordCorrect'), account.Id, paramsMap.get('regConfirmUrl'), paramsMap.get('startUrl'), true);
 }

 /* Verifies SelfRegistration flow with an accounId that is created within the test */
 @IsTest
 static void testSelfRegisterWithCreatedAccount() {
  Account account = Commerce_TestDataFactory.createAccount('test acc');                   
  insert account;    
  Map < String, String > paramsMap = initializeParams();     
  LightningSelfRegisterController.selfRegister(paramsMap.get('CompanyName'),paramsMap.get('CNPJ'),paramsMap.get('InscricaoEM'),paramsMap.get('Phone'), paramsMap.get('lastName'), paramsMap.get('Endereco'),paramsMap.get('CEP'),paramsMap.get('Numero'),paramsMap.get('Bairro'),paramsMap.get('Cidade'),paramsMap.get('Estado'), paramsMap.get('Endereco'),paramsMap.get('CEP'),paramsMap.get('Numero'),paramsMap.get('Bairro'),paramsMap.get('Cidade'),paramsMap.get('Estado'), paramsMap.get('email'), paramsMap.get('password'), paramsMap.get('confirmPasswordCorrect'), account.Id, paramsMap.get('regConfirmUrl'), paramsMap.get('startUrl'), true);
 }

 @IsTest
 static void setPermissionSetAssignmentTest() {            
  	 System.assertEquals(null, LightningSelfRegisterController.setPermissionSetAssignment('93.086.731/0001-82'));
 }
    
 @IsTest
 static void cepcheckTest() {            
  	 LightningSelfRegisterController.cepcheck('00000-000','SP');
 }
    
 @IsTest
 static void createLeadAlertTest() {            
  	 LightningSelfRegisterController.createLeadAlert('00000-000','Test','test@test.com');
 }
    
 @isTest
 static void validateCNPJTest() { 
     Test.startTest();                      
     LightningSelfRegisterController.validateCNPJ('34.234.423/4242-34');	
     LightningSelfRegisterController.validateCNPJ('11.111.111/1111-11');
     LightningSelfRegisterController.validateCNPJ('53.692.281/0001-57');
     Test.stopTest();
 }
 
 @isTest
 static void setExperienceIdTest() {
     LightningSelfRegisterController.setExperienceId('');
     LightningSelfRegisterController.setExperienceId(null);
 }

 @IsTest
 static void LightningSelfRegisterControllerInstantiation() {
  LightningSelfRegisterController controller = new LightningSelfRegisterController();
  System.assertNotEquals(controller, null);
 }
    
 @isTest
 static void getAddressDataTest() { 
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new ViaCepHttpCalloutMock());        
     	HttpResponse res = ViaCepCallout.getInfoFromExternalService('03360015');               
        LightningSelfRegisterController.getAddressData('03360015');	
        LightningSelfRegisterController.getAddressData(null);
        LightningSelfRegisterController.getAddressData('96180000');
        Test.stopTest();
 }

 /* Helper method to initialize the parameters required for SelfRegistration. */
 private static Map < String, String > initializeParams() {
  Map < String, String > paramsMap = new Map < String, String > ();  
  
  String CompanyName = 'test';
  String CNPJ = '09.503.803/0001-33';
  String InscricaoEM = '123456789';     
  String Phone = '(11) 99999-9999';     
  String lastName = 'User teste';
  String Endereco = 'test';
  String CEP = '99999-999';
  String Numero = '9';
  String Bairro = 'test';
  String Cidade = 'test';
  String Estado = 'test';      
  String email = 'testUser@salesforce.com';
  String password = 'testuser123';
  String confirmPasswordCorrect = 'testuser123';
  String confirmPasswordWrong = 'wrongpassword';
  String accountId = 'testuser123';
  String regConfirmUrl = 'http://registration-confirm.com';
  String startUrl = 'http://my.company.salesforce.com';   
     
  paramsMap.put('CompanyName', CompanyName);
  paramsMap.put('CNPJ', CNPJ);
  paramsMap.put('InscricaoEM', InscricaoEM);
  paramsMap.put('Phone', Phone);
  paramsMap.put('lastName', lastName);     
  paramsMap.put('Endereco', Endereco);
  paramsMap.put('CEP', CEP);
  paramsMap.put('Numero', Numero);
  paramsMap.put('Bairro', Bairro);
  paramsMap.put('Cidade', Cidade);
  paramsMap.put('Estado', Estado);       
  paramsMap.put('email', email);
  paramsMap.put('password', password);
  paramsMap.put('confirmPasswordCorrect', confirmPasswordCorrect);
  paramsMap.put('confirmPasswordWrong', confirmPasswordWrong);
  paramsMap.put('accountId', accountId);
  paramsMap.put('regConfirmUrl', regConfirmUrl);
  paramsMap.put('startUrl', startUrl);
  return paramsMap;
 }
  
 @isTest
 static void testCreateBuyerGroup() {
     Account acc = Commerce_TestDataFactory.createAccount('test1 acc1');                   
  	 insert acc;
     LightningSelfRegisterController.createBuyerGroup(acc.Id);
     LightningSelfRegisterController.createBuyerGroup(acc.Id);
 }
    
 @isTest
 static void testeCreateBuyerGroup() {
     LightningSelfRegisterController.validateCheckAddress('true');
     LightningSelfRegisterController.validateCheckAddress('false');
 }
}