public with sharing class PagBrasilPaymentController {
  /**
   * Checkout Flow State
   */
  private static final String PAYMENT_STATE = 'Payment Info';

  /**
   * Request to external service to find checkout settings
   */
  @AuraEnabled
  public static Map<String, Object> getCheckoutInfo(String cartId) {
    return PagBrasilRequestUtils.getCheckoutInfo(cartId);
  }

  /**
   * Set order status as failed
   */
  @AuraEnabled
  public static Boolean setOrderStatusAsFailed(String cartId) {
    PagBrasilQueryUtils queryUtils = new PagBrasilQueryUtils();

    String orderId = queryUtils.getOrderIdByCart(cartId);
    Order order = queryUtils.getOrderById(orderId);

    order.Status = PagBrasilUtils.PAYMENT_STATUS_FAILED;
    update order;

    return true;
  }

  /**
   * Set order status as rejected
   */
  @AuraEnabled
  public static Boolean setOrderStatusAsRejected(String cartId) {
    PagBrasilQueryUtils queryUtils = new PagBrasilQueryUtils();

    String orderId = queryUtils.getOrderIdByCart(cartId);
    Order order = queryUtils.getOrderById(orderId);

    order.Status = PagBrasilUtils.PAYMENT_STATUS_REJECTED;
    update order;

    return true;
  }

  /**
   * Make a external request to get order details
   */
  @AuraEnabled
  public static String requestOrderInformationFromOrderNumber(
    String orderNumber
  ) {
    HttpRequest request = new HttpRequest();

    Pagbrasil_Settings__c settings = Pagbrasil_Settings__c.getOrgDefaults();

    request.setEndpoint('callout:PagBrasil/api/order/get');
    request.setHeader('Content-Type', 'application/x-www-form-urlencoded');
    request.setMethod('POST');

    String token = EncodingUtil.urlEncode(settings.PB_Token__c, 'UTF-8');
    String secret = EncodingUtil.urlEncode(settings.PB_Secret__c, 'UTF-8');

    String body = String.format(
      'pbtoken={0}&secret={1}&order={2}',
      new List<string>{ token, secret, orderNumber }
    );
    request.setBody(body);

    Http http = new Http();
    HTTPResponse response = http.send(request);

    Dom.Document doc = response.getBodyDocument();
    Dom.XMLNode docRequest = doc.getRootElement();

    String status = docRequest.getChildElement('order_status', null).getText();
    Order order = new PagBrasilQueryUtils().getOrderByOrderNumber(orderNumber);

    order.Status = status;
    update order;

    response.setHeader(
      'Content-Type',
      'application/x-www-form-urlencoded; charset=ISO-8859-1'
    );

    return response.getBody();
  }

  /**
   * Make a external request to find pix details
   */
  @AuraEnabled
  public static String requestPixOrderInformation(
    String orderId,
    String token
  ) {
    Map<String, String> order = new Map<String, String>{
      'id' => orderId,
      'token' => token
    };

    String body = new PagBrasilRequestUtils().mountCaptureRequest(order);
    HttpRequest request = new HttpRequest();

    request.setEndpoint(PagBrasilRequestUtils.REQUEST_ENDPOINT_GETORDER);

    request.setHeader('Content-Type', 'text/json');
    request.setHeader('Content-Length', String.valueOf(body.length()));
    request.setHeader('Referer', Url.getOrgDomainUrl().toString());

    request.setMethod('POST');
    request.setBody(body);

    Http http = new Http();
    HTTPResponse response = http.send(request);

    return response.getBody();
  }

  /**
   * Get order information based on OrderSummary Id
   */
  @AuraEnabled
  public static String requestOrderInformationFromSummary(String summaryId) {
    OrderSummary summary = [
      SELECT OrderNumber
      FROM OrderSummary
      WHERE Id = :summaryId
    ];

    return requestOrderInformationFromOrderNumber(summary.OrderNumber);
  }

  /**
   * Function that get cart info and pay the order
   */
  @AuraEnabled(cacheable=false)
  public static Map<String, Object> makePayment(
    String paymentType,
    String cartId,
    Map<String, Object> paymentInfo,
    Map<String, Object> paymentBillingAddress
  ) {
    WebCart cart = new PagBrasilQueryUtils().getCartInfosById(cartId);
    String paymentGatewayId = new PagBrasilQueryUtils()
      .getPaymentGatewayId(cart.webStoreId);

    if (paymentGatewayId == null || String.isEmpty(paymentGatewayId)) {
      throw new AuraHandledException(PagBrasilUtils.UNAUTHORIZED_ERROR_MESSAGE);
    }

    ConnectApi.AuthorizationResponse response = authorizePayment(
      paymentGatewayId,
      paymentType,
      paymentInfo,
      paymentBillingAddress,
      cart
    );

    if (response.gatewayResponse.gatewayResultCodeDescription == null) {
      return new Map<String, Object>{ 'success' => 'false' };
    }

    Order order = new PagBrasilQueryUtils()
      .getLastOrderByAccountId(cart.AccountId);

    ConnectApi.CaptureResponse captureResponse = capturePayment(
      response.paymentAuthorization,
      order.Id,
      response.gatewayResponse.gatewayResultCodeDescription
    );

    order.Payment_Instructions__c = response.gatewayResponse.gatewayResultCodeDescription;
    update order;

    Map<String, Object> syncResponse = new Map<String, Object>{
      'success' => 'true',
      'token' => response.gatewayResponse.gatewayResultCodeDescription,
      'order' => order.OrderNumber
    };

    return syncResponse;
  }

  /**
   * Method responsable for handle checkout informations and make a authorization request to the gateway
   */
  private static ConnectApi.AuthorizationResponse authorizePayment(
    String paymentGatewayId,
    String paymentType,
    Map<String, Object> paymentInfo,
    Map<String, Object> paymentBillingAddress,
    WebCart cart
  ) {
    ConnectApi.AuthorizationRequest authorizationRequest = new ConnectApi.AuthorizationRequest();

    authorizationRequest.currencyIsoCode = UserInfo.getDefaultCurrency();
    if (authorizationRequest.currencyIsoCode != 'BRL') {
      throw new AuraHandledException(
        PagBrasilUtils.INVALID_CURRENCY_ERROR_MESSAGE
      );
    }

    authorizationRequest.paymentGatewayId = paymentGatewayId;
    authorizationRequest.amount = cart.GrandTotalAmount;
    authorizationRequest.accountId = cart.AccountId;

    authorizationRequest.effectiveDate = Datetime.now();

    authorizationRequest.paymentGroup = PagBrasilUtils.getPaymentGroup(cart.Id);
    authorizationRequest.paymentMethod = PagBrasilUtils.getAuthPaymentMethod(
      paymentType,
      paymentInfo
    );

    Map<String, String> additionalData = new Map<String, String>();

    String fullAddress = String.format(
      '{0}|{1}|{2}|{3}',
      new List<string>{
        paymentBillingAddress.get('Street').toString(),
        paymentBillingAddress.get('City').toString(),
        paymentBillingAddress.get('State').toString(),
        paymentBillingAddress.get('PostalCode').toString()
      }
    );

    additionalData.put('billingFullAddress', fullAddress);
    additionalData.put('paymentType', paymentType);
    additionalData.put('taxId', paymentInfo.get('taxId').toString());

    if (
      paymentInfo.get('visitorId') != null &&
      String.isNotEmpty(paymentInfo.get('visitorId').toString())
    ) {
      additionalData.put('visitorId', paymentInfo.get('visitorId').toString());
    }

    if (
      paymentType == PagBrasilAbstractPaymentService.PAYMENT_METHOD_CREDITCARD
    ) {
      additionalData.put(
        'cardInstallments',
        paymentInfo.get('cardInstallments').toString()
      );
    }

    authorizationRequest.additionalData = additionalData;

    ConnectApi.AuthorizationResponse authorizationResponse = ConnectApi.Payments.authorize(
      authorizationRequest
    );

    if (authorizationResponse.error != null) {
      throw new AuraHandledException(
        PagBrasilUtils.AUTHORIZATION_ERROR_MESSAGE
      );
    }

    return authorizationResponse;
  }

  /**
   * Method responsable for handle checkout informations and make a capture request to the gateway
   */
  private static ConnectApi.CaptureResponse capturePayment(
    ConnectApi.PaymentAuthorizationResponse authorization,
    String order,
    String token
  ) {
    ConnectApi.CaptureRequest captureRequest = new ConnectApi.CaptureRequest();
    ConnectApi.PaymentGroupRequest paymentGroup = new ConnectApi.PaymentGroupRequest();

    paymentGroup.createPaymentGroup = true;
    paymentGroup.sourceObjectId = order;
    paymentGroup.currencyIsoCode = UserInfo.getDefaultCurrency();

    captureRequest.amount = authorization.amount;
    captureRequest.accountId = authorization.accountId;
    captureRequest.paymentGroup = paymentGroup;

    Map<String, String> additionalData = new Map<String, String>();
    additionalData.put('token', token);

    captureRequest.additionalData = additionalData;

    ConnectApi.CaptureResponse captureResponse = ConnectApi.Payments.capture(
      captureRequest,
      authorization.id
    );

    return captureResponse;
  }
}