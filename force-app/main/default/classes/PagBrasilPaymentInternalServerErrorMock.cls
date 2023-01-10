global class PagBrasilPaymentInternalServerErrorMock implements HttpCalloutMock {
  global HttpResponse respond(HttpRequest request) {
    HttpResponse response = new HttpResponse();

    response.setBody('{"error": "Invalid credentials."}');
    response.setStatusCode(412);

    return response;
  }
}