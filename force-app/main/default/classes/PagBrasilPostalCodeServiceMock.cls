global class PagBrasilPostalCodeServiceMock implements HttpCalloutMock {
  global HttpResponse respond(HttpRequest request) {
    HttpResponse response = new HttpResponse();

    JSONGenerator jsonObject = JSON.createGenerator(false);

    jsonObject.writeStartObject();

    jsonObject.writeStringField('cep', '91330-000');
    jsonObject.writeStringField('logradouro', 'Avenida Doutor Nilo Peçanha');
    jsonObject.writeStringField('complemento', 'de 1121 a 2321 - lado ímpar');
    jsonObject.writeStringField('bairro', 'Três Figueiras');
    jsonObject.writeStringField('localidade', 'Porto Alegre');
    jsonObject.writeStringField('uf', 'RS');

    jsonObject.writeEndObject();

    String body = jsonObject.getAsString();

    response.setBody(body);
    response.setStatusCode(200);

    return response;
  }
}