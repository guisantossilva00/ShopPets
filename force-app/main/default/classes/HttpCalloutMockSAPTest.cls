@isTest
public class HttpCalloutMockSAPTest{
    @isTest
    public static void respond() {
        HTTPRequest req = new HTTPRequest();
        req.setBody('');
        req.setMethod('POST');
        req.setHeader('Content-type', 'json');
        req.setEndpoint('https://usinasitamarati--homolog.my.salesforce.com/');
        HttpCalloutMockSAP sap = new HttpCalloutMockSAP();
        sap.respond(req);
    }
}