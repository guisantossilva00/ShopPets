@isTest
private class PagBrasilPaymentGatewayNotificationTest {
  @isTest(SeeAllData=true)
  static void creditCardNotificationTest() {
    Map<String, Object> request = new Map<String, Object>{
      'secret' => 'mock_secret_phrase',
      'payment_method' => 'C',
      'order' => '1010001',
      'amount_brl' => '100.00',
      'payment_status' => 'A',
      'authorization_code' => '12345',
      'cc_auth' => '0'
    };

    Test.startTest();

    PagBrasilPaymentNotificationService pagBrasilPaymentNotificationService = new PagBrasilPaymentNotificationService();
    Boolean processPayments = pagBrasilPaymentNotificationService.processEverythingElse(
      request
    );

    Test.stopTest();
  }

  @isTest
  static void refundNotificationTest() {
    Map<String, Object> request = new Map<String, Object>{
      'secret' => 'mock_secret_phrase',
      'payment_method' => 'B',
      'order' => '1010001',
      'payment_status' => 'P',
      'amount_brl' => '100.00',
      'amount_refunded' => '100.00'
    };

    Test.startTest();

    PagBrasilPaymentNotificationService pagBrasilPaymentNotificationService = new PagBrasilPaymentNotificationService();
    Boolean processPayments = pagBrasilPaymentNotificationService.processEverythingElse(
      request
    );

    System.debug(processPayments);

    Test.stopTest();
  }

  @isTest
  static void refundChargebackNotificationTest() {
    Map<String, Object> request = new Map<String, Object>{
      'secret' => 'mock_secret_phrase',
      'payment_method' => 'C',
      'order' => '1010001',
      'payment_status' => 'C',
      'amount_brl' => '100.00',
      'amount_refunded' => '100.00'
    };

    Test.startTest();

    PagBrasilPaymentNotificationService pagBrasilPaymentNotificationService = new PagBrasilPaymentNotificationService();
    Boolean processPayments = pagBrasilPaymentNotificationService.processEverythingElse(
      request
    );

    System.debug(processPayments);

    Test.stopTest();
  }

  @isTest
  static void assynchronousPaymentsNotificationTest() {
    Map<String, String> boleto = new Map<String, String>{
      'order' => '1010001',
      'payment_date' => '12/13/2021',
      'amount_paid' => '90.00',
      'amount_due' => '100.00'
    };

    Map<String, String> boletoAmount = new Map<String, String>{
      'order' => '1010001',
      'payment_date' => '12/13/2021',
      'amount_paid' => '110.00',
      'amount_due' => '100.00'
    };

    List<Object> listBoleto = new List<Object>();

    listBoleto.add(boleto);
    listBoleto.add(boletoAmount);

    Test.startTest();

    PagBrasilPaymentNotificationService pagBrasilPaymentNotificationService = new PagBrasilPaymentNotificationService();
    Boolean processPayments = pagBrasilPaymentNotificationService.processBoletoAndPEC(
      listBoleto
    );

    System.debug(processPayments);

    Test.stopTest();
  }

  @isTest
  static void assynchronousPaymentsFailNotificationTest() {
    List<Object> listBoleto = new List<Object>();

    Test.startTest();

    PagBrasilPaymentNotificationService pagBrasilPaymentNotificationService = new PagBrasilPaymentNotificationService();
    Boolean processPayments = pagBrasilPaymentNotificationService.processBoletoAndPEC(
      listBoleto
    );

    System.debug(processPayments);

    Test.stopTest();
  }
}