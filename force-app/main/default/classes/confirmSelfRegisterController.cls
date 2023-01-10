global without sharing class confirmSelfRegisterController {
    
    @AuraEnabled
    public static String verificaUser(String userid){
        Boolean redirect = false;
        if(userid != 'redirect'){
            List<User> User =  [Select Id, Email from User where Id = :userid];        
            if (!User.isEmpty()) {
                User[0].IsActive = false;
                update User[0];                
            }else{
               redirect = true; 
            } 
        }else{    
            redirect = true;                        
        }
        
        if(redirect == true){
            String baseURL = URL.getSalesforceBaseUrl().toExternalForm();    		
            return baseURL; 
        }else{
            return 'User Updated';
        }
               
    }
}