global class HttpCalloutMockSAP implements HttpCalloutMock {
    global HTTPResponse respond(HTTPRequest req) {
        HttpResponse response = new HttpResponse();
        
        String username = 'test';
        String password = 'test';
        
        Blob headerValue = Blob.valueOf(username + ':' + password);
        String authorizationHeader = 'BASIC ' +EncodingUtil.base64Encode(headerValue);
        req.setHeader('Authorization', authorizationHeader);
        req.setMethod('POST');
        req.setHeader('Content-Type','application/json');
        
        response.setBody('{"VBELN":"0000000","MESSAGE":"A ordem de venda foi inserida com sucesso."}');
        response.setStatus('Success');
        response.setStatusCode(201);
        return response;
    }
}