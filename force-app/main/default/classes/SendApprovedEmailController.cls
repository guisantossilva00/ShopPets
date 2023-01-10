global without sharing class SendApprovedEmailController {
	@future
    public static void SendApprovedEmail(String userid){
        EmailTemplate et = [SELECT Id, HtmlValue, Subject FROM EmailTemplate WHERE DeveloperName = 'AprovacaoCadastro'];
        User user = [SELECT Id, Email, FirstName, LastName FROM User WHERE Id =: userid];
        Domain siteDomain = [SELECT Domain, DomainType FROM Domain LIMIT 1];        
        String[] toAddresses = new List<String>{ user.Email };
                        
        Messaging.SingleEmailMessage mail = Messaging.renderStoredEmailTemplate(et.Id, user.Id, user.Id);
		mail.setToAddresses(toAddresses);
        mail.setTargetObjectId(user.Id);
        mail.setSubject(mail.getSubject());
        mail.setReplyTo('support@uisa.com');    
        OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'testefullredirect2@yopmail.com'];        
        if ( owea.size() > 0 ) {
            system.debug(owea[0].Id);
            mail.setOrgWideEmailAddressId(owea[0].Id);
        }
        
        String HtmlValue = mail.gethtmlBody().replace('{Login_Url}', 'https://'+siteDomain.Domain);
        mail.sethtmlBody(HtmlValue);
        mail.saveAsActivity = false;

        
        try {
            Messaging.SendEmail(new List<Messaging.SingleEmailMessage>{ mail });
            return;
        } catch (Exception e) {
            System.debug(e.getMessage());
        }
        
    }
}