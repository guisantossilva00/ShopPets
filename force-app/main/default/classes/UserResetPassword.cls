@RestResource(urlMapping='/resetPassword/*')
global with sharing class UserResetPassword {
    
    @Httppost
    global static String doPost(String username){
        
        List<User> users = new List<User>();
        users = [SELECT id, username, name FROM User WHERE username = :username];
        for(User u : users){
            System.resetPassword(u.Id, true);
            return 'E-mail enviado com sucesso!';
        }
        Return 'Não foi possível concluir a redefinição, entre em contato com um administrador.';
    } 
}