global class PagBrasilPaymentCaptureMock implements HttpCalloutMock {
  global String status;

  global PagBrasilPaymentCaptureMock(String status) {
    this.status = status;
  }

  global HttpResponse respond(HttpRequest request) {
    HttpResponse response = new HttpResponse();

    JSONGenerator jsonObject = JSON.createGenerator(false);

    if (this.status == 'error') {
      jsonObject.writeStartObject();
      jsonObject.writeObjectField('error', 'Invalid order.');
      jsonObject.writeEndObject();

      String body = jsonObject.getAsString();

      response.setBody(body);
      response.setStatusCode(412);

      return response;
    }

    Map<String, Object> requestJson = (Map<String, Object>) JSON.deserializeUntyped(
      request.getBody()
    );

    Map<String, Object> order = (Map<String, Object>) requestJson.get('order');

    jsonObject.writeStartObject();

    jsonObject.writeObjectField('order', order.get('order'));

    if (this.status == 'success') {
      jsonObject.writeStringField('status', 'PC');
    }

    if (this.status == 'pending') {
      jsonObject.writeStringField('status', 'WP');
    }

    if (this.status == 'fail') {
      jsonObject.writeStringField('status', 'PF');
    }

    jsonObject.writeStringField('valor', '100.00');

    jsonObject.writeEndObject();

    String body = jsonObject.getAsString();

    response.setBody(body);
    response.setStatusCode(200);

    return response;
  }
}