/**
 * PagBrasilAbstractPaymentService class
 */
public abstract class PagBrasilAbstractPaymentService {
  /**
   * Salesforce Payment Result Status
   */
  public static final commercepayments.SalesforceResultCodeInfo PAYMENT_SUCCESS = toCodeInfo(
    commercepayments.SalesforceResultCode.Success
  );

  public static final commercepayments.SalesforceResultCodeInfo PAYMENT_FAILED = toCodeInfo(
    commercepayments.SalesforceResultCode.Decline
  );

  /**
   * PagBrasil Payment Methods
   */
  public static final String PAYMENT_METHOD_CREDITCARD = 'C';
  public static final String PAYMENT_METHOD_PECFLASH = 'P';
  public static final String PAYMENT_METHOD_BOLETO = 'B';
  public static final String PAYMENT_METHOD_PIX = 'X';

  /**
   * PagBrasil Payment Status
   */
  public static final String PAYMENT_STATUS_COMPLETED = 'PC';
  public static final String PAYMENT_STATUS_AUTHORIZED = 'PA';
  public static final String PAYMENT_STATUS_PENDING = 'WP';
  public static final String PAYMENT_STATUS_FAILED = 'PF';

  /**
   * PagBrasil CreditCard Auth
   */
  public static final String PAYMENT_CREDITCARD_AUTH_ONLY = '1';
  public static final String PAYMENT_CREDITCARD_AUTH_AND_CAPTURE = '0';

  /**
   * PagBrasil API Request Timeout
   */
  public static final Integer REQUEST_TIMEOUT_MS = 30 * 1000;

  /**
   * PagBrasil API Endpoints
   */
  public static final String REQUEST_ENDPOINT_ADDORDER = '/api/control/?method=addOrder';
  public static final String REQUEST_ENDPOINT_GETORDER = '/api/control/?method=getOrderDirect';

  /**
   * Gateway Context
   */
  protected commercepayments.paymentGatewayContext gatewayContext;

  /**
   * PagBrasilAbstractPaymentService constructor
   */
  public PagBrasilAbstractPaymentService(
    commercepayments.paymentGatewayContext gatewayContext
  ) {
    this.gatewayContext = gatewayContext;
  }

  /**
   * Make the payment on the instantiated service
   */
  public commercepayments.GatewayResponse executePayment() {
    commercepayments.PaymentsHttp http = new commercepayments.PaymentsHttp();

    try {
      HttpRequest request = buildRequest();
      HttpResponse response = http.send(request);

      return buildResponse(response);
    } catch (PagBrasilValidationException e) {
      return getGatewayResponseError(e);
    }
  }

  /**
   * Abstract class to build payment request
   */
  public abstract HttpRequest buildRequest();

  /**
   * Abstract class to build payment response
   */
  public abstract commercepayments.GatewayResponse buildResponse(
    HttpResponse response
  );

  /**
   * Parse Salesforce Result to Code Info
   */
  private static commercepayments.SalesforceResultCodeInfo toCodeInfo(
    commercepayments.SalesforceResultCode code
  ) {
    return new commercepayments.SalesforceResultCodeInfo(code);
  }

  /**
   * Receive error getting response from gateway and returns
   */
  private commercepayments.GatewayErrorResponse getGatewayResponseError(
    Exception e
  ) {
    return new commercepayments.GatewayErrorResponse('412', e.getMessage());
  }
}