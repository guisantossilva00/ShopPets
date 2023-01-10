/**
 * PagBrasilPaymentServiceAdapter class
 */
public class PagBrasilPaymentServiceAdapter {
  /**
   * Payment Services
   */
  private static PagBrasilPaymentAuthorizationService authorizationService;
  private static PagBrasilPaymentCaptureService captureService;

  /**
   * Return the Payment Service Instance according Gateway Context
   */
  public static PagBrasilAbstractPaymentService getServiceInstance(
    commercepayments.paymentGatewayContext gatewayContext
  ) {
    commercepayments.RequestType requestType = gatewayContext.getPaymentRequestType();

    /**
     * Authorization Service
     */
    if (requestType == commercepayments.RequestType.Authorize) {
      authorizationService = new PagBrasilPaymentAuthorizationService(
        gatewayContext
      );
      return authorizationService;
    }

    /**
     * Capture Service
     */
    if (requestType == commercepayments.RequestType.Capture) {
      captureService = new PagBrasilPaymentCaptureService(gatewayContext);
      return captureService;
    }

    return null;
  }
}