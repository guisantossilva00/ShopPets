global class PagBrasilPaymentAuthorizationMock implements HttpCalloutMock {
  global String status;
  global String method;

  global PagBrasilPaymentAuthorizationMock(String status, String method) {
    this.status = status;
    this.method = method;
  }

  global HttpResponse respond(HttpRequest request) {
    HttpResponse response = new HttpResponse();

    Map<String, Object> requestJson = (Map<String, Object>) JSON.deserializeUntyped(
      request.getBody()
    );

    Map<String, Object> creditCard = (Map<String, Object>) requestJson.get(
      'creditCard'
    );

    if (this.method == 'C') {
      if (this.status == 'success') {
        response.setBody(
          generateCreditCardSuccessResponse(creditCard, requestJson)
        );
      }

      if (this.status == 'authorized') {
        response.setBody(
          generateCreditCardAuthorizedResponse(creditCard, requestJson)
        );
      }

      if (this.status == 'fail') {
        response.setBody(
          generateCreditCardFailResponse(creditCard, requestJson)
        );
      }
    } else {
      if (this.status == 'pending') {
        response.setBody(
          generateAssynchronousPaymentSuccessResponse(requestJson)
        );
      } else {
        response.setBody(generateAssynchronousPaymentFailResponse(requestJson));
      }
    }

    response.setStatusCode(200);

    return response;
  }

  private static String generateAssynchronousPaymentSuccessResponse(
    Map<String, Object> requestJson
  ) {
    Map<String, Object> order = (Map<String, Object>) requestJson.get('order');

    Map<String, Object> customer = (Map<String, Object>) requestJson.get(
      'customer'
    );

    Map<String, Object> payment = (Map<String, Object>) requestJson.get(
      'payment'
    );

    JSONGenerator jsonObject = JSON.createGenerator(false);
    DateTime today = Date.today();

    jsonObject.writeStartObject();
    jsonObject.writeObjectField('order', order.get('order'));

    jsonObject.writeObjectField(
      'payment_method',
      payment.get('payment_method')
    );

    jsonObject.writeStringField('submission_date', today.format('MM/DD/YYYY'));
    jsonObject.writeStringField('order_status', 'WP');

    jsonObject.writeStringField('payment_date', today.format('MM/DD/YYYY'));
    jsonObject.writeObjectField('amount_brl', order.get('amount_brl'));
    jsonObject.writeObjectField('product_name', order.get('product_name'));

    jsonObject = getDefaultFields(jsonObject, customer);

    jsonObject.writeStringField(
      'order_token',
      '$2y$10$aVIQfOGDxoLg/xgME3ehZuIpo34YREiMnCphJ4XaW9tSiHMCgfWiu'
    );

    jsonObject.writeEndObject();
    return jsonObject.getAsString();
  }

  private static String generateAssynchronousPaymentFailResponse(
    Map<String, Object> requestJson
  ) {
    Map<String, Object> order = (Map<String, Object>) requestJson.get('order');

    Map<String, Object> payment = (Map<String, Object>) requestJson.get(
      'payment'
    );

    Map<String, Object> customer = (Map<String, Object>) requestJson.get(
      'customer'
    );

    JSONGenerator jsonObject = JSON.createGenerator(false);
    DateTime today = Date.today();

    jsonObject.writeStartObject();
    jsonObject.writeObjectField('order', order.get('order'));
    jsonObject.writeStringField('order_status', 'PF');

    jsonObject.writeObjectField(
      'payment_method',
      payment.get('payment_method')
    );

    jsonObject.writeStringField('submission_date', today.format('MM/DD/YYYY'));
    jsonObject.writeObjectField('product_name', order.get('product_name'));

    jsonObject = getDefaultFields(jsonObject, customer);

    jsonObject.writeObjectField('error_code', '06');

    jsonObject.writeEndObject();
    return jsonObject.getAsString();
  }

  private static String generateCreditCardSuccessResponse(
    Map<String, Object> creditCard,
    Map<String, Object> requestJson
  ) {
    Map<String, Object> order = (Map<String, Object>) requestJson.get('order');

    Map<String, Object> customer = (Map<String, Object>) requestJson.get(
      'customer'
    );

    Map<String, Object> payment = (Map<String, Object>) requestJson.get(
      'payment'
    );

    JSONGenerator jsonObject = JSON.createGenerator(false);
    DateTime today = Date.today();

    jsonObject.writeStartObject();
    jsonObject.writeObjectField('order', order.get('order'));

    jsonObject.writeObjectField(
      'payment_method',
      payment.get('payment_method')
    );

    jsonObject.writeStringField('submission_date', today.format('MM/DD/YYYY'));
    jsonObject.writeStringField('order_status', 'PC');

    jsonObject.writeStringField('payment_date', today.format('MM/DD/YYYY'));
    jsonObject.writeObjectField('amount_brl', order.get('amount_brl'));
    jsonObject.writeObjectField('product_name', order.get('product_name'));

    jsonObject = getDefaultFields(jsonObject, customer);
    jsonObject = getCreditCardFields(jsonObject, creditCard);
    jsonObject.writeObjectField(
      'cc_installments',
      payment.get('cc_installments')
    );

    jsonObject.writeStringField(
      'order_token',
      '$2y$10$aVIQfOGDxoLg/xgME3ehZuIpo34YREiMnCphJ4XaW9tSiHMCgfWiu'
    );

    jsonObject.writeEndObject();
    return jsonObject.getAsString();
  }

  private static String generateCreditCardAuthorizedResponse(
    Map<String, Object> creditCard,
    Map<String, Object> requestJson
  ) {
    Map<String, Object> order = (Map<String, Object>) requestJson.get('order');

    Map<String, Object> customer = (Map<String, Object>) requestJson.get(
      'customer'
    );

    Map<String, Object> payment = (Map<String, Object>) requestJson.get(
      'payment'
    );

    JSONGenerator jsonObject = JSON.createGenerator(false);
    DateTime today = Date.today();

    jsonObject.writeStartObject();
    jsonObject.writeObjectField('order', order.get('order'));

    jsonObject.writeObjectField(
      'payment_method',
      payment.get('payment_method')
    );

    jsonObject.writeStringField('submission_date', today.format('MM/DD/YYYY'));
    jsonObject.writeStringField('order_status', 'PA');

    jsonObject.writeStringField('payment_date', today.format('MM/DD/YYYY'));
    jsonObject.writeObjectField('amount_brl', order.get('amount_brl'));
    jsonObject.writeObjectField('product_name', order.get('product_name'));

    jsonObject = getDefaultFields(jsonObject, customer);
    jsonObject = getCreditCardFields(jsonObject, creditCard);
    jsonObject.writeObjectField(
      'cc_installments',
      payment.get('cc_installments')
    );

    jsonObject.writeStringField(
      'order_token',
      '$2y$10$aVIQfOGDxoLg/xgME3ehZuIpo34YREiMnCphJ4XaW9tSiHMCgfWiu'
    );

    jsonObject.writeEndObject();
    return jsonObject.getAsString();
  }

  private static String generateCreditCardFailResponse(
    Map<String, Object> creditCard,
    Map<String, Object> requestJson
  ) {
    Map<String, Object> order = (Map<String, Object>) requestJson.get('order');

    Map<String, Object> payment = (Map<String, Object>) requestJson.get(
      'payment'
    );

    Map<String, Object> customer = (Map<String, Object>) requestJson.get(
      'customer'
    );

    JSONGenerator jsonObject = JSON.createGenerator(false);
    DateTime today = Date.today();

    jsonObject.writeStartObject();
    jsonObject.writeObjectField('order', order.get('order'));
    jsonObject.writeStringField('order_status', 'PF');

    jsonObject.writeObjectField(
      'payment_method',
      payment.get('payment_method')
    );

    jsonObject.writeStringField('submission_date', today.format('MM/DD/YYYY'));
    jsonObject.writeObjectField('product_name', order.get('product_name'));

    jsonObject = getDefaultFields(jsonObject, customer);
    jsonObject = getCreditCardFields(jsonObject, creditCard);
    jsonObject.writeObjectField(
      'cc_installments',
      payment.get('cc_installments')
    );

    jsonObject.writeObjectField('error_code', '01');

    jsonObject.writeEndObject();
    return jsonObject.getAsString();
  }

  private static JSONGenerator getDefaultFields(
    JSONGenerator jsonObject,
    Map<String, Object> customer
  ) {
    jsonObject.writeObjectField('customer_name', customer.get('customer_name'));

    jsonObject.writeObjectField(
      'customer_taxid',
      customer.get('customer_taxid')
    );

    jsonObject.writeObjectField(
      'customer_email',
      customer.get('customer_email')
    );

    jsonObject.writeObjectField(
      'customer_phone',
      customer.get('customer_phone')
    );

    jsonObject.writeObjectField(
      'address_street',
      customer.get('address_street')
    );

    jsonObject.writeObjectField('address_zip', customer.get('address_zip'));
    jsonObject.writeObjectField('address_city', customer.get('address_city'));
    jsonObject.writeObjectField('address_state', customer.get('address_state'));

    return jsonObject;
  }

  private static JSONGenerator getCreditCardFields(
    JSONGenerator jsonObject,
    Map<String, Object> creditCard
  ) {
    jsonObject.writeStringField('authorization_code', '12345');
    jsonObject.writeStringField('cc_brand', 'M');
    jsonObject.writeObjectField('cc_holder', creditCard.get('cc_holder'));
    jsonObject.writeObjectField('cc_number', creditCard.get('cc_number'));
    jsonObject.writeStringField('soft_descriptor', 'PB');

    return jsonObject;
  }
}