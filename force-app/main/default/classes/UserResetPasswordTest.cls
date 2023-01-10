@isTest
Public class UserResetPasswordTest {
    
    @IsTest(seeAllData=true) 
    public static void testdoPost(){
        
        User u = new user();
        u.LastName = 'testAppRest';
        u.Email = 'testAppRest@test.com';
        u.Alias = 'Tcode';
        u.Username = 'testerandomicouisa@atonit.com.br';
        u.LocaleSidKey = 'en_US';
        u.TimeZoneSidKey = 'GMT';
        u.ProfileID = [SELECT id FROM profile WHERE Name Like '%Administrador do sistema%' OR Name Like 'System Administrator'].Id;
        u.LanguageLocaleKey = 'en_US';
        u.EmailEncodingKey = 'UTF-8';
        Insert u;
        UserResetPassword.doPost(u.username);
        UserResetPassword.doPost('user@user.user.test');

    }
}