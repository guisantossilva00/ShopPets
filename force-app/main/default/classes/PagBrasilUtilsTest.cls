@isTest
private class PagBrasilUtilsTest {
  @isTest
  static void errorMessagesParserTest() {
    Test.startTest();

    String errorMessage = PagBrasilUtils.getErrorMessage('01');

    System.assertEquals(
      'Pagamento não autorizado pelo banco emissor.',
      errorMessage
    );

    Test.stopTest();
  }

  @isTest
  static void defaultErrorMessageParserTest() {
    Test.startTest();

    String errorMessage = PagBrasilUtils.getErrorMessage('55');

    System.assertEquals(PagBrasilUtils.DEFAULT_ERROR_MESSAGE, errorMessage);
    Test.stopTest();
  }

  @isTest
  static void checkIpnRefundStatusTest() {
    Test.startTest();

    Boolean isRefundStatus = PagBrasilUtils.isIpnRefundStatus('P');

    System.assert(isRefundStatus);
    Test.stopTest();
  }

  @isTest
  static void checkAssynchronousPaymentMethodTest() {
    Test.startTest();

    Boolean isBoleto = PagBrasilUtils.isAssynchronousPaymentMethod('B');
    Boolean isPEC = PagBrasilUtils.isAssynchronousPaymentMethod('P');
    Boolean isPix = PagBrasilUtils.isAssynchronousPaymentMethod('X');

    System.assert(isBoleto);
    System.assert(isPEC);
    System.assert(isPix);

    Test.stopTest();
  }

  @isTest
  static void checkBoletoORPECPaymentMethodTest() {
    Test.startTest();

    Boolean isBoleto = PagBrasilUtils.isBoletoOrPEC('B');
    Boolean isPEC = PagBrasilUtils.isBoletoOrPEC('P');

    System.assert(isBoleto);
    System.assert(isPEC);

    Test.stopTest();
  }

  @isTest
  static void checkGetCreditCardPaymentInputTest() {
    Test.startTest();

    Map<String, Object> paymentInfo = new Map<String, Object>{
      'cardHolderName' => 'CARLOS KNEBEL',
      'cardNumber' => '5555666677778884',
      'cvv' => '123',
      'expiryMonth' => '12',
      'expiryYear' => '29'
    };

    ConnectApi.CardPaymentMethodRequest creditCard = PagBrasilUtils.getCardPaymentMethodInput(
      'C',
      paymentInfo
    );

    System.assertEquals('CARLOS KNEBEL', creditCard.cardHolderName);
    System.assertEquals('5555666677778884', creditCard.cardNumber);
    System.assertEquals('123', creditCard.cvv);
    System.assertEquals(12, creditCard.expiryMonth);
    System.assertEquals(29, creditCard.expiryYear);

    Test.stopTest();
  }

  @isTest
  static void checkGetBoletoPaymentInputTest() {
    Test.startTest();

    Map<String, Object> paymentInfo = new Map<String, Object>{};
    ConnectApi.CardPaymentMethodRequest creditCard = PagBrasilUtils.getCardPaymentMethodInput(
      'B',
      paymentInfo
    );

    System.assertEquals('HOLDER', creditCard.cardHolderName);
    System.assertEquals('0000000000000000', creditCard.cardNumber);
    System.assertEquals('000', creditCard.cvv);
    System.assertEquals(1, creditCard.expiryMonth);
    System.assertEquals(9999, creditCard.expiryYear);

    Test.stopTest();
  }

  @isTest
  static void checkGetAuthorizationPaymentMethodTest() {
    Test.startTest();

    Map<String, Object> paymentInfo = new Map<String, Object>{};
    ConnectApi.AuthApiPaymentMethodRequest authorizationPaymentMethod = PagBrasilUtils.getAuthPaymentMethod(
      'B',
      paymentInfo
    );

    ConnectApi.CardPaymentMethodRequest creditCard = authorizationPaymentMethod.cardPaymentMethod;

    System.assertEquals('HOLDER', creditCard.cardHolderName);
    System.assertEquals('0000000000000000', creditCard.cardNumber);
    System.assertEquals('000', creditCard.cvv);
    System.assertEquals(1, creditCard.expiryMonth);
    System.assertEquals(9999, creditCard.expiryYear);

    Test.stopTest();
  }

  @isTest
  static void checkGetPaymentGroupTest() {
    Account account = new Account(Name = 'PagBrasilTestAccount');
    insert (account);

    WebStore webStore = new WebStore(
      Name = 'PagBrasilTestWebStore',
      OptionsGuestBrowsingEnabled = false
    );
    insert (webStore);

    WebCart cart = new WebCart(
      Name = 'Cart',
      WebStoreId = webStore.Id,
      AccountId = account.Id
    );
    insert (cart);

    Order order = new Order(
      EffectiveDate = Date.today(),
      Status = 'Draft',
      AccountId = account.Id
    );
    insert (order);

    CartCheckoutSession cartCheckoutSession = new CartCheckoutSession(
      Name = 'Cart',
      State = 'Payment Info',
      IsArchived = false,
      WebCartId = cart.Id,
      OrderId = order.Id
    );
    insert (cartCheckoutSession);

    Test.startTest();

    ConnectApi.PaymentGroupRequest paymentGroupRequest = PagBrasilUtils.getPaymentGroup(
      cart.Id
    );

    System.assertEquals(order.Id, paymentGroupRequest.sourceObjectId);

    Test.stopTest();
  }

  @isTest
  static void getCartInfoQueryTest() {
    Account account = new Account(Name = 'PagBrasilTestAccount');
    insert (account);

    WebStore webStore = new WebStore(
      Name = 'PagBrasilTestWebStore',
      OptionsGuestBrowsingEnabled = false
    );
    insert (webStore);

    WebCart cart = new WebCart(
      Name = 'Cart',
      WebStoreId = webStore.Id,
      AccountId = account.Id
    );
    insert (cart);

    Test.startTest();

    PagBrasilQueryUtils pagBrasilQueryUtils = new PagBrasilQueryUtils();
    Map<String, Object> paymentInfo = pagBrasilQueryUtils.getCartInfo(cart.Id);

    System.assertEquals(0.00, paymentInfo.get('amount'));

    Test.stopTest();
  }

  @isTest
  static void getContactInfoByAccountIdTest() {
    Account account = new Account(Name = 'PagBrasilTestAccount');
    insert (account);

    Contact contact = new Contact(
      LastName = 'PagBrasilTestContact',
      Email = 'support@pagbrasil.com',
      Phone = '5135000718',
      AccountId = account.Id
    );
    insert (contact);

    Test.startTest();

    PagBrasilQueryUtils pagBrasilQueryUtils = new PagBrasilQueryUtils();
    Contact foundContact = pagBrasilQueryUtils.getContactDataByAccountId(
      account.Id
    );

    System.assertEquals('PagBrasilTestContact', foundContact.Name);
    System.assertEquals('support@pagbrasil.com', foundContact.Email);
    System.assertEquals('5135000718', foundContact.Phone);

    Test.stopTest();
  }

  @isTest
  static void getAccountBillingAddressTest() {
    Account account = new Account(
      Name = 'PagBrasilTestAccount',
      BillingPostalCode = '91330000',
      BillingStreet = 'Av Dr Nilo Peçanha 1221',
      BillingCity = 'Porto Alegre',
      BillingCountry = 'Brasil',
      BillingState = 'Rio Grande do Sul'
    );
    insert (account);

    Test.startTest();

    PagBrasilQueryUtils pagBrasilQueryUtils = new PagBrasilQueryUtils();
    Address foundBillingAddress = pagBrasilQueryUtils.getAccountBillingAddress(
      account.Id
    );

    System.assertEquals('91330000', foundBillingAddress.getPostalCode());
    System.assertEquals(
      'Av Dr Nilo Peçanha 1221',
      foundBillingAddress.getStreet()
    );
    System.assertEquals('Porto Alegre', foundBillingAddress.getCity());
    System.assertEquals('Brasil', foundBillingAddress.getCountry());
    System.assertEquals('Rio Grande do Sul', foundBillingAddress.getState());

    Test.stopTest();
  }

  @isTest
  static void getAccountLastOrderNumberByAccountIdTest() {
    Account account = new Account(Name = 'PagBrasilTestAccount');
    insert (account);

    Order order = new Order(
      EffectiveDate = Date.today(),
      Status = 'Draft',
      AccountId = account.Id
    );
    insert (order);

    String orderNumber = [
      SELECT OrderNumber
      FROM Order
      WHERE AccountId = :account.Id
      LIMIT 1
    ]
    .OrderNumber;

    Test.startTest();

    PagBrasilQueryUtils pagBrasilQueryUtils = new PagBrasilQueryUtils();
    String foundOrderNumber = pagBrasilQueryUtils.getLastOrderNumberByAccountId(
      account.Id
    );

    System.assertEquals(orderNumber, foundOrderNumber);

    Test.stopTest();
  }

  @isTest
  static void getAccountLastOrderByAccountIdTest() {
    Account account = new Account(Name = 'PagBrasilTestAccount');
    insert (account);

    Order order = new Order(
      EffectiveDate = Date.today(),
      Status = 'Draft',
      AccountId = account.Id
    );
    insert (order);

    Test.startTest();

    PagBrasilQueryUtils pagBrasilQueryUtils = new PagBrasilQueryUtils();
    Order foundOrder = pagBrasilQueryUtils.getLastOrderByAccountId(account.Id);

    System.assertEquals(order.Id, foundOrder.Id);

    Test.stopTest();
  }

  @isTest
  static void getCartInfoByIdTest() {
    Account account = new Account(Name = 'PagBrasilTestAccount');
    insert (account);

    WebStore webStore = new WebStore(
      Name = 'PagBrasilTestWebStore',
      OptionsGuestBrowsingEnabled = false
    );
    insert (webStore);

    WebCart cart = new WebCart(
      Name = 'Cart',
      WebStoreId = webStore.Id,
      AccountId = account.Id
    );
    insert (cart);

    Test.startTest();

    PagBrasilQueryUtils pagBrasilQueryUtils = new PagBrasilQueryUtils();
    WebCart foundCart = pagBrasilQueryUtils.getCartInfosById(cart.Id);

    System.assertEquals(cart.Id, foundCart.Id);
    System.assertEquals(webStore.Id, foundCart.webStoreId);

    Test.stopTest();
  }

  @isTest
  static void getOrderByOrderNumberTest() {
    Account account = new Account(Name = 'PagBrasilTestAccount');
    insert (account);

    Order order = new Order(
      EffectiveDate = Date.today(),
      Status = 'Draft',
      AccountId = account.Id
    );
    insert (order);

    String orderNumber = [
      SELECT OrderNumber
      FROM Order
      WHERE AccountId = :account.Id
      LIMIT 1
    ]
    .OrderNumber;

    Test.startTest();

    PagBrasilQueryUtils pagBrasilQueryUtils = new PagBrasilQueryUtils();
    Order foundOrder = pagBrasilQueryUtils.getOrderByOrderNumber(orderNumber);

    System.assertEquals(orderNumber, foundOrder.OrderNumber);

    Test.stopTest();
  }

  @isTest(SeeAllData=true)
  static void getPaymentGatewayIdTest() {
    String webStoreId = [SELECT Id FROM WebStore LIMIT 1].Id;

    PagBrasilQueryUtils pagBrasilQueryUtils = new PagBrasilQueryUtils();
    String gatewayId = pagBrasilQueryUtils.getPaymentGatewayId(webStoreId);

    Test.startTest();

    System.assert(String.isNotEmpty(gatewayId));

    Test.stopTest();
  }
}