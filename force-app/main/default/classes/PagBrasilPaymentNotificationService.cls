/**
 * PagBrasilPaymentNotificationService class
 */
public with sharing class PagBrasilPaymentNotificationService {
  /**
   * Receive notification context and process payments notification
   */
  public commercepayments.GatewayNotificationResponse process(
    commercepayments.PaymentGatewayNotificationContext notificationContext
  ) {
    commercepayments.PaymentGatewayNotificationRequest gatewayNotificationRequest = notificationContext.getPaymentGatewayNotificationRequest();
    String notificationRequest = gatewayNotificationRequest.getRequestBody()
      .toString();

    commercepayments.GatewayNotificationResponse notificationResponse = new commercepayments.GatewayNotificationResponse();

    Map<String, Object> requestJson = (Map<String, Object>) JSON.deserializeUntyped(
      notificationRequest
    );

    Boolean success = false;
    Pagbrasil_Settings__c settings = Pagbrasil_Settings__c.getOrgDefaults();

    if (requestJson.get('secret').toString() != settings.PB_Secret__c) {
      notificationResponse.setResponseBody(Blob.valueOf('Error receiving IPN'));
      notificationResponse.setStatusCode(412);

      return notificationResponse;
    }

    String paymentMethod = (String) requestJson.get('payment_method');
    String paymentStatus = (String) requestJson.get('payment_status');

    if (
      paymentStatus == null &&
      PagBrasilUtils.isBoletoOrPEC(paymentMethod) &&
      !PagBrasilUtils.isIpnRefundStatus(paymentStatus)
    ) {
      List<Object> boletoList = (List<Object>) requestJson.get('boleto_list');
      success = processBoletoAndPEC(boletoList);
    } else {
      success = processEverythingElse(requestJson);
    }

    if (success) {
      notificationResponse.setResponseBody(
        Blob.valueOf('Received successfully in ' + Datetime.now())
      );

      notificationResponse.setStatusCode(200);
      return notificationResponse;
    }

    notificationResponse.setResponseBody(Blob.valueOf('Error receiving IPN'));
    notificationResponse.setStatusCode(412);

    return notificationResponse;
  }

  /**
   * Process payment notification from payment methods such as CreditCard, Pix and also Order Refunds
   */
  @testVisible
  private Boolean processEverythingElse(Map<String, Object> request) {
    String status = String.valueOf(request.get('payment_status'));
    String orderNumber = String.valueOf(request.get('order'));

    if (PagBrasilUtils.isIpnRefundStatus(status)) {
      commercepayments.ReferencedRefundNotification refundNotification = new commercepayments.ReferencedRefundNotification();
      Double amountRefunded = Double.valueOf(request.get('amount_refunded'));

      refundNotification.setStatus(commercepayments.NotificationStatus.Success);
      refundNotification.setGatewayReferenceNumber(orderNumber);
      refundNotification.setAmount(amountRefunded);

      if (status == PagBrasilUtils.IPN_STATUS_REFUNDED) {
        refundNotification.setGatewayMessage(
          'Pagamento reembolsado. Valor reembolsado: ' +
          String.valueOf(amountRefunded)
        );
      }

      if (status == PagBrasilUtils.IPN_STATUS_CHARGEBACK) {
        refundNotification.setGatewayMessage(
          'Pagamento reembolsado (chargeback). Valor reembolsado: ' +
          String.valueOf(amountRefunded)
        );
      }

      commercepayments.NotificationSaveResult saveResult = commercepayments.NotificationClient.record(
        refundNotification
      );

      System.debug(saveResult.isSuccess());
      System.debug(saveResult.getErrorMessage());

      if (!saveResult.isSuccess()) {
        System.debug('Error: ' + saveResult.getErrorMessage());
        System.debug('Code: ' + saveResult.getStatusCode());

        return false;
      }

      System.debug('Notification accepted by platform');
      return true;
    }

    commercepayments.CaptureNotification notification = new commercepayments.CaptureNotification();

    Double amount = Double.valueOf(request.get('amount_brl'));

    notification.setGatewayReferenceNumber(orderNumber);
    notification.setAmount(amount);
    notification.setGatewayDate(System.now());

    notification.setStatus(commercepayments.NotificationStatus.Success);

    notification.setGatewayMessage('Pagamento confirmado pela PagBrasil.');
    notification.setGatewayResultCode(status);

    commercepayments.NotificationSaveResult saveResult = commercepayments.NotificationClient.record(
      notification
    );

    return true;
  }

  /**
   * Receive a payments list and process Boleto and PEC payment notifications
   */
  @testVisible
  private Boolean processBoletoAndPEC(List<Object> boletoList) {
    if (boletoList.size() == 0) {
      return false;
    }

    for (Object boleto : boletoList) {
      Map<String, Object> boletoData = (Map<String, Object>) boleto;

      commercepayments.CaptureNotification notification = new commercepayments.CaptureNotification();

      String orderNumber = String.valueOf(boletoData.get('order'));
      Double amountPaid = Double.valueOf(boletoData.get('amount_paid'));
      Double amountDue = Double.valueOf(boletoData.get('amount_due'));

      notification.setGatewayReferenceNumber(orderNumber);
      notification.setAmount(amountPaid);
      notification.setGatewayDate(System.now());

      if (amountPaid >= amountDue) {
        notification.setStatus(commercepayments.NotificationStatus.Success);
        notification.setGatewayMessage('Pagamento confirmado pela PagBrasil.');
        notification.setGatewayResultCode('PC');
      }

      if (amountPaid < amountDue) {
        notification.setStatus(commercepayments.NotificationStatus.Failed);
        notification.setGatewayMessage(
          'Pagamento efetivo confirmado pela PagBrasil: R$' +
          String.valueOf(amountPaid)
        );
      }

      commercepayments.NotificationSaveResult saveResult = commercepayments.NotificationClient.record(
        notification
      );
    }

    return true;
  }
}