public class TestarEmail {

    public static void enviarEmail() {
        messaging.SingleEmailMessage criarMeuEmail = new Messaging.SingleEmailMessage();
             
        criarMeuEmail.setToAddresses(new List<String> {'guisantossilva00@gmail.com'});
        criarMeuEmail.setSubject('Agradecimento');

        OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'superemail@suaemoresa.com'];        

        criarMeuEmail.setOrgWideEmailAddressId(owea[0].Id);
        
        Messaging.sendEmail(new List<messaging.SingleEmailMessage> {criarMeuEmail});
    }
}