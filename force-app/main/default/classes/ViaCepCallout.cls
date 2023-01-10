public class ViaCepCallout {
    public static HttpResponse getInfoFromExternalService(String cep) {
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://viacep.com.br/ws/'+cep+'/json/');
        req.setMethod('GET');
        Http h = new Http();
        HttpResponse res = h.send(req);
        return res;
    }
}