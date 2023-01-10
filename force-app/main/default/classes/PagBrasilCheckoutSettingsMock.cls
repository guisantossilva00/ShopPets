global class PagBrasilCheckoutSettingsMock implements HttpCalloutMock {
  global HttpResponse respond(HttpRequest request) {
    HttpResponse response = new HttpResponse();

    JSONGenerator jsonObject = JSON.createGenerator(false);

    jsonObject.writeStartObject();

    jsonObject.writeStringField('payment_methods', 'XCDPFB');
    jsonObject.writeStringField('public_key', 'PCAMOCK');

    jsonObject.writeEndObject();

    String body = jsonObject.getAsString();

    response.setBody(body);
    response.setStatusCode(200);

    return response;
  }
}