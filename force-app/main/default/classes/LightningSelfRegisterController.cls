global without sharing class LightningSelfRegisterController {

    public LightningSelfRegisterController() {

    }

    @TestVisible 
    private static boolean isValidPassword(String password, String confirmPassword) {
        return password == confirmPassword;
    }
    
    @TestVisible 
    private static boolean siteAsContainerEnabled(String communityUrl) {
        Auth.AuthConfiguration authConfig = new Auth.AuthConfiguration(communityUrl,'');
        return authConfig.isCommunityUsingSiteAsContainer();
    }
    
    @TestVisible 
    private static void validatePassword(User u, String password, String confirmPassword) {
        if(!Test.isRunningTest()) {
        Site.validatePassword(u, password, confirmPassword);
        }
        return;
    }
    
    @AuraEnabled
    public static Boolean cepcheck(String cep, String Estado){
        Boolean cepcheck = CEPCheck.check(cep, Estado);
        return cepcheck;
    }
    
    @AuraEnabled
    public static String selfRegister(String CompanyName, String CNPJ, String InscricaoEM, String Phone, String lastname, String Endereco, String CEP, String Numero, String Bairro, String Cidade, String Estado, String EnderecoEntrega, String CEPEntrega, String NumeroEntrega, String BairroEntrega, String CidadeEntrega, String EstadoEntrega, String email, String password, String confirmPassword, String accountId, String regConfirmUrl, String startUrl, Boolean includePassword) {
        Savepoint sp = null;
        try {
            sp = Database.setSavepoint();
            
            if (!lastname.contains(' ')){               
                return 'Por favor, preencha o campo responsável com o nome completo.';
            }
            
            if (email != null || !String.isEmpty(email)) {
                List<User> user =  [Select id from User where email = :email];
                if(user.size() > 0){            
                    return 'Este e-mail já está registrado.';
                }else {
                    Pattern MyPattern = Pattern.compile('^[a-zA-Z0-9._|\\\\%#~`=?&/$^*!}{+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,4}$');
                    Matcher MyMatcher = MyPattern.matcher(email);                
                    if (!MyMatcher.matches()) {
                        return 'O campo E-mail é inválido.';
                    }                    
                }	
            }
            
            if(CNPJ != null || !String.isEmpty(CNPJ)){                
                String cnpjVal = validateCNPJ(CNPJ);
                if(cnpjVal == 'false'){
                    List<Account> AccountC =  [SELECT Id FROM Account WHERE CNPJTxt__c = :CNPJ];
                    if(AccountC.size() > 0){       
                        return 'Este CNPJ já está registrado.';
                    }
                }else{
                    return cnpjVal;
                }
            }
           
            
            User u = new User();
            u.Username = email;
            u.put('Email',email);
            
            String firstname = lastname.substringBefore(' ');
            
            u.FirstName = firstname;
            u.LastName = lastname.substringAfter(' ');
            u.CompanyName = CompanyName;
            u.Phone = Phone; 
            u.CNPJ__c =  CNPJ;                 
			
            List<Account> existingAccount = [SELECT Id FROM Account WHERE Name = :CompanyName LIMIT 1];
            
            if (!existingAccount.isEmpty()) {
                accountId = existingAccount[0].Id;
            } else {
                Account newAccount = new Account();
                newAccount.Name = CompanyName;
                newAccount.Name__c = CompanyName;
                newAccount.ShippingCountry = 'BR';
                newAccount.ShippingCity = CidadeEntrega;
                newAccount.ShippingStreet = EnderecoEntrega + ', ' + NumeroEntrega;
                newAccount.ShippingState = EstadoEntrega;            
                newAccount.ShippingPostalCode = CEPEntrega;
                newAccount.BillingCountry = 'BR';
                newAccount.BillingCity = Cidade;
                newAccount.BillingStreet = Endereco + ', ' + Numero;
                newAccount.BillingState = Estado;            
                newAccount.BillingPostalCode = CEP;
                newAccount.CNPJTxt__c = CNPJ;  
                newAccount.Phone__c = Phone;
                newAccount.StateRegistrationTxt__c = InscricaoEM;
                newAccount.MunicipalRegistrationTxt__c = InscricaoEM; 
                
                newAccount.SAPCodeTxt__c = 'NDA';                                 
                newAccount.CountryTxt__c = 'BR';
                newAccount.CEPTxt__c = CEP;     
                newAccount.StreetTxt__c = Endereco;                
                newAccount.NumberTxt__c = Numero;
                newAccount.NeighborhoodTxt__c = Bairro;               
                newAccount.CityTxt__c = Cidade;
                newAccount.EmailTxt__c = email;
				newAccount.StateTxt__c = Estado;
                                                                                                                                               
                insert newAccount;
                accountId = newAccount.Id;
                createBuyerGroup(accountId);
            }
            
            if (accountId != NULL){
                ContactPointAddress newBillingAddress = new ContactPointAddress();
                newBillingAddress.ParentId = accountId;
                newBillingAddress.AddressType = 'Billing';
                newBillingAddress.IsDefault = TRUE;
                newBillingAddress.name = 'Endereço de Cobrança';
				newBillingAddress.PostalCode = CEP;
                newBillingAddress.City = Cidade;
                newBillingAddress.Country = 'Brazil';
                newBillingAddress.State = Estado;
                newBillingAddress.Street = Endereco + ', ' + Numero;

                insert newBillingAddress;
                
                ContactPointAddress newShippingAddress = new ContactPointAddress();
                newShippingAddress.ParentId = accountId;
                newShippingAddress.AddressType = 'Shipping';
                newShippingAddress.IsDefault = TRUE;
                newShippingAddress.name = 'Endereço de Entrega';
				newShippingAddress.PostalCode = CEPEntrega;
                newShippingAddress.City = CidadeEntrega;
                newShippingAddress.Country = 'Brazil';
                newShippingAddress.State = EstadoEntrega;
                newShippingAddress.Street = EnderecoEntrega + ', ' + NumeroEntrega;

                insert newShippingAddress;
                
            }
            
            String networkId = Network.getNetworkId();

            // If using site to host the community the user should not hit s1 after logging in from mobile.
            if(networkId != null && siteAsContainerEnabled(Network.getLoginUrl(networkId))) {
                u.put('UserPreferencesHideS1BrowserUI',true);
            }
            
            String nickname = ((firstname != null && firstname.length() > 0) ? firstname.substring(0,1) : '' ) + lastname.substring(0,1);
            nickname += String.valueOf(Crypto.getRandomInteger()).substring(1,7);
            u.put('CommunityNickname', nickname);                                
                        
            if (includePassword) {    
                if (!isValidPassword(password, confirmPassword)) {
                    return Label.site.passwords_dont_match;
                }
             	validatePassword(u, password, confirmPassword);
            }
            else {
                password = null;
            }
            
            // lastName is a required field on user, but if it isn't specified, we'll default it to the username
            String userId = Site.createPortalUser(u, accountId, password);
            // create a fake userId for test.
            if (Test.isRunningTest()) {
                userId = 'fakeUserId';           
            }
            if (userId != null) { 
                if (password != null && password.length() > 1) {
                    //ApexPages.PageReference lgn = Site.login(email, password, startUrl);
                    //if(!Test.isRunningTest()) {
                    // aura.redirect(lgn);
                    //}                    
                    
                    ApexPages.PageReference confirmRef = new PageReference('/s/confirmSelfRegister?id='+userId);
                    if(!Test.isRunningTest()) {
                    	aura.redirect(confirmRef);
                    }
                }
                else {
                    ApexPages.PageReference confirmRef = new PageReference(regConfirmUrl);
                    if(!Test.isRunningTest()) {
                    aura.redirect(confirmRef);
                   }

                }
            }
            return null;
        }
        catch (Exception ex) {
            Database.rollback(sp);
            return ex.getMessage();            
        }
    }
    
    @AuraEnabled
    public static String createLeadAlert(String cep, String CompanyName, String email){
        Lead lead = new Lead(LastName = CompanyName, Company = CompanyName, Email = email, CEP__c = cep);
        insert lead;
        if(lead.Id != null || !String.isEmpty(lead.Id)){
            return lead.Id;
        }
        else{
            return null;
        }
    }
    
    @AuraEnabled
    public static void createBuyerGroup(Id accountId){
        
        Account account = [Select Id, Name, IsBuyer from Account where Id =: accountId];
              
        if(account.IsBuyer) {
            return;
        }
            
        BuyerAccount bAccount = new BuyerAccount();
        bAccount.BuyerId = account.Id;
        bAccount.Name = account.Name;
        bAccount.IsActive = true;
        
        insert bAccount;
            
        BuyerGroup buyerGroup = [Select id, Name from BuyerGroup where Name = 'B2B Buyer Group'];
        
        BuyerGroupMember buyerGroupMember = new BuyerGroupMember();
        buyerGroupMember.BuyerGroupId = buyerGroup.Id;
        buyerGroupMember.BuyerId = account.Id;
        
        insert buyerGroupMember;
        
    } 

    
    @AuraEnabled
    public static String setPermissionSetAssignment(String CNPJ){
        List<PermissionSet> permissionSet =  [SELECT Id,Label FROM PermissionSet where Label = 'B2B Commerce User'];
        List<User> User =  [Select id from User where CNPJ__c = :CNPJ];   
        
    	try{
            if(!Test.isRunningTest()) {
            	PermissionSetAssignment psa = new PermissionSetAssignment (PermissionSetId = permissionSet[0].Id , AssigneeId = User[0].Id);
            	insert psa;
            }
        	return null;
        }
        catch (Exception ex) {
            return ex.getMessage(); 
        }
        
    }  
    
    @AuraEnabled
    global static String setExperienceId(String expId) {
        // Return null if there is no error, else it will return the error message 
        try {
            if (expId != null) {
                Site.setExperienceId(expId);   
            }
            return null; 
        } catch (Exception ex) {
            return ex.getMessage();            
        }        
    } 
    
    @AuraEnabled
    public static String getAddressData(String cep) {
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('https://viacep.com.br/ws/' + cep + '/json/');
        request.setMethod('GET');
        HttpResponse response = http.send(request);

        if (response.getStatusCode() == 200) {
            String respJson = '[' + response.getBody() + ']';
            List<address> cepList = (List<address>) JSON.deserialize(respJson, List<address>.class);
            String error = cepList[0].erro;
            if (error == 'true') {
                return 'Não encontrado';
            } else {
                return respJson;
            }
        } else {
            return 'Não encontrado';
        }
    }
    
    public class address {
        public String cep;
        public String logradouro;
        public String complemento;
        public String bairro;
        public String localidade;
        public String uf;
        public String ibge;
        public String gia;
        public String ddd;
        public String siafi;
        public String erro;
    }
    
    @AuraEnabled
	public static String validateCNPJ(String isCNPJ) {
        
        String CNPJ = isCNPJ.replace('.', '').replace('-', '').replace('/', '');
        
    	 if (CNPJ.equals('00000000000000') || CNPJ.equals('11111111111111') ||
            CNPJ.equals('22222222222222') || CNPJ.equals('33333333333333') ||
            CNPJ.equals('44444444444444') || CNPJ.equals('55555555555555') ||
            CNPJ.equals('66666666666666') || CNPJ.equals('77777777777777') ||
            CNPJ.equals('88888888888888') || CNPJ.equals('99999999999999') ||
             (CNPJ.length() != 14)) {
                 return 'O campo CNPJ é inválido.';
          }
        
        Integer sm, i, r, num, peso, dig13, dig14;
        List<String> cnpjString = CNPJ.split('');
          sm = 0;
          peso = 2;
          
        for (i=11; i>=0; i--) {
            num = Integer.valueOf(cnpjString[i]);
            sm = sm + (num * peso);
            peso = peso + 1;
            if (peso == 10) {
                peso = 2;
            }
          }

        r = math.mod(sm, 11);
        
        if ((r == 0) || (r == 1)){
            dig13 = 0;
        } else {
        	dig13 = Integer.valueOf(11-r);
        }

		// Calculo do 2o. Digito Verificador
        sm = 0;
        peso = 2;
        
        for (i=12; i>=0; i--) {
            num = Integer.valueOf(cnpjString[i]);
            sm = sm + (num * peso);
            peso = peso + 1;
            if (peso == 10){
                peso = 2;
            }
        }

        r = math.mod(sm, 11);
        
        if ((r == 0) || (r == 1)){
            dig14 = 0;
        }else {
            dig14 = Integer.valueOf(11-r);
        }

		// Verifica se os dígitos calculados conferem com os dígitos informados.
        if (dig13 == Integer.valueOf(cnpjString[12]) && dig14 == Integer.valueOf(cnpjString[13])) {
        	return 'false';
        
        }else{
        	return 'O campo CNPJ é inválido.' ;
       	}   
  	}
    @AuraEnabled
	public static String validateCheckAddress(String checkResult) {
        if (checkResult == 'true'){
            return 'true';
        }else{
            return 'false';
        }
    }
}