/**
 * PagBrasilPaymentCaptureService class
 */
public class PagBrasilPaymentCaptureService extends PagBrasilAbstractPaymentService {
  /**
   * PagBrasilPaymentCaptureService constructor
   */
  public PagBrasilPaymentCaptureService(
    commercepayments.paymentGatewayContext gatewayContext
  ) {
    super(gatewayContext);
  }

  /**
   * Override abstract buildRequest method and make the request to Gateway
   */
  public override HttpRequest buildRequest() {
    String requestJson = buildRequestBody(
      (commercepayments.CaptureRequest) gatewayContext.getPaymentRequest()
    );

    HttpRequest request = new HttpRequest();

    request.setTimeout(REQUEST_TIMEOUT_MS);
    request.setEndpoint(REQUEST_ENDPOINT_GETORDER);

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
    commercepayments.CaptureResponse captureResponse = new commercepayments.CaptureResponse();

    Map<String, String> responseJson = new Map<String, String>{};

    if (String.isNotEmpty(response.getBody())) {
      responseJson = (Map<String, String>) JSON.deserialize(
        response.getBody(),
        Map<String, String>.class
      );
    }

    if (response.getStatusCode() != 200) {
      if (String.isNotEmpty(response.getBody())) {
        String error = responseJson.get('error');
        if (error != null) {
          captureResponse.setGatewayMessage(error);
        }
      }
      captureResponse.setSalesforceResultCodeInfo(PAYMENT_FAILED);
    }

    if (response.getStatusCode() == 200) {
      String status = responseJson.get('status');
      captureResponse.setGatewayResultCode(status);

      if (
        status == PAYMENT_STATUS_PENDING ||
        status == PAYMENT_STATUS_AUTHORIZED
      ) {
        captureResponse.setAsync(true);
        captureResponse.setSalesforceResultCodeInfo(PAYMENT_SUCCESS);
      }

      if (status == PAYMENT_STATUS_COMPLETED) {
        captureResponse.setSalesforceResultCodeInfo(PAYMENT_SUCCESS);
      }

      if (status == PAYMENT_STATUS_FAILED) {
        captureResponse.setSalesforceResultCodeInfo(PAYMENT_FAILED);
      }

      captureResponse.setAmount(Double.valueOf(responseJson.get('valor')));
      captureResponse.setGatewayReferenceNumber(responseJson.get('order'));
    }

    captureResponse.setGatewayDate(System.now());
    return captureResponse;
  }

  /**
   * Build the request body string with JSON
   */
  private String buildRequestBody(
    commercepayments.CaptureRequest captureRequest
  ) {
    String orderId = new PagBrasilQueryUtils()
      .getLastOrderNumberByAccountId(captureRequest.accountId);

    Map<String, String> order = new Map<String, String>{
      'id' => orderId,
      'token' => captureRequest.additionalData.get('token')
    };

    return new PagBrasilRequestUtils().mountCaptureRequest(order);
  }
}