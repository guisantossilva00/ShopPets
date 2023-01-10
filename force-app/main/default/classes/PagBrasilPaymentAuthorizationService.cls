/**
 * PagBrasilPaymentAuthorizationService class
 */
public class PagBrasilPaymentAuthorizationService extends PagBrasilAbstractPaymentService {
  /**
   * PagBrasilPaymentAuthorizationService constructor
   */
  public PagBrasilPaymentAuthorizationService(
    commercepayments.paymentGatewayContext gatewayContext
  ) {
    super(gatewayContext);
  }

  /**
   * Override abstract buildRequest method and make the request to Gateway
   */
  public override HttpRequest buildRequest() {
    String requestJson = buildRequestBody(
      (commercepayments.AuthorizationRequest) gatewayContext.getPaymentRequest()
    );

    HttpRequest request = new HttpRequest();

    request.setTimeout(REQUEST_TIMEOUT_MS);
    request.setEndpoint(REQUEST_ENDPOINT_ADDORDER);

    request.setHeader('Content-Type', 'text/json');
    request.setHeader('Content-Length', String.valueOf(requestJson.length()));
    request.setHeader('Referer', Url.getOrgDomainUrl().toString());

    request.setMethod('POST');
    request.setBody(requestJson);

    return request;
  }

  /**
   * Override abstract buildResponse method and parse response to Gateway
   */
  public override commercepayments.GatewayResponse buildResponse(
    HttpResponse response
  ) {
    commercepayments.AuthorizationResponse authResponse = new commercepayments.AuthorizationResponse();

    Map<String, String> responseJson = (Map<String, String>) JSON.deserialize(
      response.getBody(),
      Map<String, String>.class
    );

    authResponse.setGatewayDate(System.now());

    if (response.getStatusCode() != 200) {
      String error = responseJson.get('error');

      if (error != null) {
        authResponse.setGatewayMessage(error);
      }

      authResponse.setSalesforceResultCodeInfo(PAYMENT_FAILED);
      return authResponse;
    }

    String orderStatus = responseJson.get('order_status');
    String paymentMethod = responseJson.get('payment_method');

    if (paymentMethod == PAYMENT_METHOD_CREDITCARD) {
      authResponse.setGatewayResultCode(orderStatus);

      if (PagBrasilUtils.isSuccessStatus(orderStatus)) {
        authResponse.setAmount(Double.valueOf(responseJson.get('amount_brl')));
        authResponse.setGatewayAuthCode(responseJson.get('authorization_code'));
        authResponse.setGatewayReferenceNumber(responseJson.get('order'));

        authResponse.setGatewayResultCodeDescription(
          responseJson.get('order_token')
        );

        if (orderStatus == PAYMENT_STATUS_COMPLETED) {
          authResponse.setGatewayMessage('Pagamento aprovado.');
        }

        if (orderStatus == PAYMENT_STATUS_AUTHORIZED) {
          authResponse.setGatewayMessage('Pagamento pré-autorizado.');
        }

        authResponse.setSalesforceResultCodeInfo(PAYMENT_SUCCESS);
      } else {
        if (responseJson.get('error_code') != null) {
          String error = PagBrasilUtils.getErrorMessage(
            responseJson.get('error_code')
          );

          authResponse.setGatewayMessage(error);
        }

        authResponse.setSalesforceResultCodeInfo(PAYMENT_FAILED);
      }
    }

    if (PagBrasilUtils.isAssynchronousPaymentMethod(paymentMethod)) {
      authResponse.setGatewayResultCode(orderStatus);

      if (orderStatus == PAYMENT_STATUS_PENDING) {
        authResponse.setAmount(Double.valueOf(0));
        authResponse.setGatewayReferenceNumber(responseJson.get('order'));
        authResponse.setGatewayResultCodeDescription(
          responseJson.get('order_token')
        );

        authResponse.setGatewayMessage('Pagamento pendente.');
        authResponse.setSalesforceResultCodeInfo(PAYMENT_SUCCESS);
      } else {
        authResponse.setSalesforceResultCodeInfo(PAYMENT_FAILED);

        if (responseJson.get('error_code') != null) {
          String error = PagBrasilUtils.getErrorMessage(
            responseJson.get('error_code')
          );

          authResponse.setGatewayMessage(error);
        }
      }
    }

    return authResponse;
  }

  /**
   * Build the request body string with JSON
   */
  private String buildRequestBody(
    commercepayments.AuthorizationRequest authRequest
  ) {
    commercepayments.CardPaymentMethodRequest buyerCreditCard = authRequest.paymentMethod.cardPaymentMethod;

    String paymentType = authRequest.additionalData.get('paymentType');
    String visitorId = authRequest.additionalData.get('visitorId');

    PagBrasilQueryUtils queryUtils = new PagBrasilQueryUtils();

    Map<ID, CartItem> cartItems = queryUtils.getAccountLastCartItems(
      authRequest.accountId
    );

    String[] billingAddress = authRequest.additionalData.get(
        'billingFullAddress'
      )
      .split('\\|');

    if (billingAddress.size() != 4) {
      throw new PagBrasilValidationException(
        'Não foi possível resgatar os dados de endereço corretamente.'
      );
    }

    Contact contact = queryUtils.getContactDataByAccountId(
      authRequest.accountId
    );

    if (String.isEmpty(contact.Email)) {
      contact.Email = '-';
    }

    if (String.isEmpty(contact.Phone)) {
      contact.Phone = '-';
    }

    String orderId = queryUtils.getLastOrderNumberByAccountId(
      authRequest.accountId
    );

    String amount = PagBrasilUtils.formatMoney(
      Decimal.valueOf(authRequest.amount)
    );

    String productsName = PagBrasilUtils.parseCartItemsToString(cartItems);

    Map<String, String> order = new Map<String, String>{
      'order' => orderId,
      'amount_brl' => amount,
      'product_name' => productsName
    };

    Map<String, String> payment = new Map<String, String>{
      'payment_method' => paymentType
    };

    if (visitorId != null && String.isNotEmpty(visitorId)) {
      payment.put('visitor_id', visitorId);
    }

    Map<String, String> customer = new Map<String, String>{
      'customer_email' => contact.Email,
      'customer_name' => contact.Name,
      'customer_phone' => contact.Phone,
      'address_street' => billingAddress[0],
      'address_city' => billingAddress[1],
      'address_state' => billingAddress[2],
      'address_zip' => billingAddress[3]
    };

    customer.put('customer_taxid', authRequest.additionalData.get('taxId'));

    if (paymentType == PAYMENT_METHOD_CREDITCARD) {
      payment.put(
        'cc_installments',
        authRequest.additionalData.get('cardInstallments')
      );

      String expirationDate = PagBrasilUtils.formatExpiryDate(
        buyerCreditCard.expiryMonth,
        buyerCreditCard.expiryYear
      );

      Map<String, String> creditCard = new Map<String, String>{
        'cc_holder' => buyerCreditCard.cardHolderName,
        'cc_number' => buyerCreditCard.cardNumber,
        'cc_cvv' => buyerCreditCard.cvv,
        'cc_expiration' => expirationDate,
        'cc_auth' => PAYMENT_CREDITCARD_AUTH_AND_CAPTURE
      };

      return new PagBrasilRequestUtils()
        .mountCreditCardRequest(order, customer, payment, creditCard);
    }

    return new PagBrasilRequestUtils()
      .mountAssynchronousPaymentRequest(order, customer, payment);
  }
}