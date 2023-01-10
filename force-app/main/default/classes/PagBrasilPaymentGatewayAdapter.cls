/**
 * PagBrasilPaymentGatewayAdapter class
 */
global with sharing class PagBrasilPaymentGatewayAdapter implements commercepayments.PaymentGatewayAsyncAdapter, commercepayments.PaymentGatewayAdapter {
  /**
   * Receive the Gateway Context and instance the service to process the payment
   */
  public commercepayments.GatewayResponse processRequest(
    commercepayments.paymentGatewayContext gatewayContext
  ) {
    if (gatewayContext == null) {
      return new commercepayments.GatewayErrorResponse(
        '400',
        'Gateway context cannot be null'
      );
    }

    PagBrasilAbstractPaymentService service = PagBrasilPaymentServiceAdapter.getServiceInstance(
      gatewayContext
    );

    if (service != null) {
      return service.executePayment();
    }

    return new commercepayments.GatewayErrorResponse(
      '400',
      'Service not found'
    );
  }

  /**
   * Reiceve the Gateway Context and process the gateway notification (IPN)
   */
  public commercepayments.GatewayNotificationResponse processNotification(
    commercepayments.PaymentGatewayNotificationContext gatewayNotificationContext
  ) {
    PagBrasilPaymentNotificationService notificationService = new PagBrasilPaymentNotificationService();
    return notificationService.process(gatewayNotificationContext);
  }
}