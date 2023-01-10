@RestResource(urlMapping='/ipn')
global with sharing class PagBrasilPaymentConfirmationRest {
  @HttpPost
  global static String receiveIpn() {
    RestRequest request = RestContext.request;
    RestResponse response = Restcontext.response;

    String jsonString = request.requestBody.toString();
    Map<String, Object> requestJson = (Map<String, Object>) JSON.deserializeUntyped(
      jsonString
    );

    Boolean success = false;
    Pagbrasil_Settings__c settings = Pagbrasil_Settings__c.getOrgDefaults();

    if (requestJson.get('secret') != settings.PB_Secret__c) {
      response.statusCode = 412;
      return 'Error Receiving IPN';
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
      response.statusCode = 200;
      return 'Received successfully in ' + Datetime.now();
    }

    response.statusCode = 412;
    return 'Error Receiving IPN';
  }

  private static Boolean processEverythingElse(Map<String, Object> request) {
    String status = String.valueOf(request.get('payment_status'));
    String orderNumber = String.valueOf(request.get('order'));

    Order order = findOrder(orderNumber);

    if (PagBrasilUtils.isIpnRefundStatus(status)) {
      Double amountRefunded = Double.valueOf(request.get('amount_refunded'));

      if (status == PagBrasilUtils.IPN_STATUS_REFUNDED) {
        order.Status = PagBrasilUtils.PAYMENT_STATUS_REFUND_PROCESSED;
      }

      if (status == PagBrasilUtils.IPN_STATUS_CHARGEBACK) {
        order.Status = PagBrasilUtils.PAYMENT_STATUS_CHARGEBACK;
      }

      update order;
      return true;
    }

    if (status == PagBrasilUtils.IPN_STATUS_APPROVED) {
      order.Status = PagBrasilUtils.PAYMENT_STATUS_COMPLETED;
    }

    if (status == PagBrasilUtils.IPN_STATUS_REJECTED) {
      order.Status = PagBrasilUtils.PAYMENT_STATUS_REJECTED;
    }

    if (status == PagBrasilUtils.IPN_STATUS_FAILED) {
      order.Status = PagBrasilUtils.PAYMENT_STATUS_FAILED;
    }

    update order;
    return true;
  }

  private static Boolean processBoletoAndPEC(List<Object> boletoList) {
    if (boletoList.size() == 0) {
      return false;
    }

    for (Object boleto : boletoList) {
      Map<String, Object> boletoData = (Map<String, Object>) boleto;

      String orderNumber = String.valueOf(boletoData.get('order'));
      Double amountPaid = Double.valueOf(boletoData.get('amount_paid'));
      Double amountDue = Double.valueOf(boletoData.get('amount_due'));

      Order order = findOrder(orderNumber);

      if (amountPaid >= amountDue) {
        order.Status = PagBrasilUtils.PAYMENT_STATUS_COMPLETED;
      }

      if (amountPaid < amountDue) {
        order.Status = PagBrasilUtils.PAYMENT_STATUS_WAITING;
      }

      update order;
    }

    return true;
  }

  private static Order findOrder(String orderNumber) {
    return new PagBrasilQueryUtils().getOrderByOrderNumber(orderNumber);
  }
}