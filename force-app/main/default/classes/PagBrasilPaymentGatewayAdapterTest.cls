@isTest
private class PagBrasilPaymentGatewayAdapterTest {
  @testSetup
  static void setup() {
    PagBrasil_Settings__c settings = new PagBrasil_Settings__c(
      PB_Secret__c = 'mock_secret_phrase',
      PB_Token__c = 'mock_secret_token'
    );
    insert (settings);

    Account account = new Account(Name = 'PagBrasilTestAccount');
    insert (account);

    Contact contact = new Contact(
      LastName = 'PagBrasilTestContact',
      Email = 'support@pagbrasil.com',
      AccountId = account.Id
    );
    insert (contact);

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

    CartDeliveryGroup cartDeliveryGroup = new CartDeliveryGroup(
      CartId = cart.Id,
      Name = 'Default Delivery'
    );
    insert (cartDeliveryGroup);

    CartItem cartItem = new CartItem(
      Name = 'PagBrasilProduct',
      Type = 'Product',
      Quantity = 1,
      CartId = cart.Id,
      CartDeliveryGroupId = cartDeliveryGroup.Id
    );
    insert (cartItem);

    Order order = new Order(
      EffectiveDate = Date.today(),
      Status = 'Draft',
      AccountId = account.Id
    );
    insert (order);
  }

  @isTest
  static void creditCardAuthorizationTest() {
    Test.startTest();
    Test.setMock(
      HttpCalloutMock.class,
      new PagBrasilPaymentAuthorizationMock('success', 'C')
    );

    Account account = getAccount();

    PagBrasilPaymentGatewayAdapter adapter = new PagBrasilPaymentGatewayAdapter();

    commercepayments.AuthorizationRequest authRequest = new commercepayments.AuthorizationRequest(
      100
    );

    authRequest.accountId = account.Id;
    authRequest.additionalData = getCreditCardAdditionalData();
    authRequest.paymentMethod = getRealCreditCard();

    commercepayments.PaymentGatewayContext gatewayContext = new commercepayments.PaymentGatewayContext(
      authRequest,
      commercepayments.RequestType.Authorize
    );

    commercepayments.GatewayResponse response = adapter.processRequest(
      gatewayContext
    );

    System.assert(response instanceof commercepayments.AuthorizationResponse);

    Test.stopTest();
  }

  @isTest
  static void creditCardAuthorizationPATest() {
    Test.startTest();
    Test.setMock(
      HttpCalloutMock.class,
      new PagBrasilPaymentAuthorizationMock('authorized', 'C')
    );

    Account account = getAccount();

    PagBrasilPaymentGatewayAdapter adapter = new PagBrasilPaymentGatewayAdapter();

    commercepayments.AuthorizationRequest authRequest = new commercepayments.AuthorizationRequest(
      100
    );

    authRequest.accountId = account.Id;
    authRequest.additionalData = getCreditCardAdditionalData();
    authRequest.paymentMethod = getRealCreditCard();

    commercepayments.PaymentGatewayContext gatewayContext = new commercepayments.PaymentGatewayContext(
      authRequest,
      commercepayments.RequestType.Authorize
    );

    commercepayments.GatewayResponse response = adapter.processRequest(
      gatewayContext
    );

    System.assert(response instanceof commercepayments.AuthorizationResponse);

    Test.stopTest();
  }

  @isTest
  static void boletoAuthorizationTest() {
    Test.startTest();
    Test.setMock(
      HttpCalloutMock.class,
      new PagBrasilPaymentAuthorizationMock('pending', 'B')
    );

    Account account = getAccount();

    PagBrasilPaymentGatewayAdapter adapter = new PagBrasilPaymentGatewayAdapter();

    commercepayments.AuthorizationRequest authRequest = new commercepayments.AuthorizationRequest(
      100
    );

    authRequest.accountId = account.Id;
    authRequest.additionalData = getBoletoAdditionalData();
    authRequest.paymentMethod = getFakeCreditCard();

    commercepayments.PaymentGatewayContext gatewayContext = new commercepayments.PaymentGatewayContext(
      authRequest,
      commercepayments.RequestType.Authorize
    );

    commercepayments.GatewayResponse response = adapter.processRequest(
      gatewayContext
    );

    System.assert(response instanceof commercepayments.AuthorizationResponse);

    Test.stopTest();
  }

  @isTest
  static void boletoFailedAuthorizationTest() {
    Test.startTest();
    Test.setMock(
      HttpCalloutMock.class,
      new PagBrasilPaymentAuthorizationMock('fail', 'B')
    );

    Account account = getAccount();

    PagBrasilPaymentGatewayAdapter adapter = new PagBrasilPaymentGatewayAdapter();

    commercepayments.AuthorizationRequest authRequest = new commercepayments.AuthorizationRequest(
      100
    );

    authRequest.accountId = account.Id;
    authRequest.additionalData = getBoletoAdditionalData();
    authRequest.paymentMethod = getFakeCreditCard();

    commercepayments.PaymentGatewayContext gatewayContext = new commercepayments.PaymentGatewayContext(
      authRequest,
      commercepayments.RequestType.Authorize
    );

    commercepayments.GatewayResponse response = adapter.processRequest(
      gatewayContext
    );

    System.assert(response instanceof commercepayments.AuthorizationResponse);

    Test.stopTest();
  }

  @isTest
  static void creditCardAuthorizationFailTest() {
    Test.startTest();
    Test.setMock(
      HttpCalloutMock.class,
      new PagBrasilPaymentAuthorizationMock('fail', 'C')
    );

    Account account = getAccount();

    PagBrasilPaymentGatewayAdapter adapter = new PagBrasilPaymentGatewayAdapter();

    commercepayments.AuthorizationRequest authRequest = new commercepayments.AuthorizationRequest(
      100
    );

    authRequest.accountId = account.Id;
    authRequest.additionalData = getCreditCardAdditionalData();
    authRequest.paymentMethod = getRealCreditCard();

    commercepayments.PaymentGatewayContext gatewayContext = new commercepayments.PaymentGatewayContext(
      authRequest,
      commercepayments.RequestType.Authorize
    );

    commercepayments.GatewayResponse response = adapter.processRequest(
      gatewayContext
    );

    System.assert(response instanceof commercepayments.AuthorizationResponse);

    Test.stopTest();
  }

  @isTest
  static void creditCardCaptureSuccessTest() {
    Account account = getAccount();
    Order order = getOrder(account.Id);

    PaymentAuthorization auth = initializeAuthObject(order.OrderNumber);

    Test.startTest();
    Test.setMock(
      HttpCalloutMock.class,
      new PagBrasilPaymentCaptureMock('success')
    );

    PagBrasilPaymentGatewayAdapter adapter = new PagBrasilPaymentGatewayAdapter();

    commercepayments.CaptureRequest captureRequest = new commercepayments.CaptureRequest(
      100,
      auth.Id
    );

    Map<String, String> additionalData = new Map<String, String>{
      'token' => '$2y$10$aVIQfOGDxoLg/xgME3ehZuIpo34YREiMnCphJ4XaW9tSiHMCgfWiu'
    };

    captureRequest.accountId = account.Id;
    captureRequest.additionalData = additionalData;

    commercepayments.PaymentGatewayContext gatewayContext = new commercepayments.PaymentGatewayContext(
      captureRequest,
      commercepayments.RequestType.Capture
    );

    commercepayments.GatewayResponse response = adapter.processRequest(
      gatewayContext
    );

    System.assert(response instanceof commercepayments.CaptureResponse);

    Test.stopTest();
  }

  @isTest
  static void creditCardCapturePendingTest() {
    Account account = getAccount();
    Order order = getOrder(account.Id);

    PaymentAuthorization auth = initializeAuthObject(order.OrderNumber);

    Test.startTest();
    Test.setMock(
      HttpCalloutMock.class,
      new PagBrasilPaymentCaptureMock('pending')
    );

    PagBrasilPaymentGatewayAdapter adapter = new PagBrasilPaymentGatewayAdapter();

    commercepayments.CaptureRequest captureRequest = new commercepayments.CaptureRequest(
      100,
      auth.Id
    );

    Map<String, String> additionalData = new Map<String, String>{
      'token' => '$2y$10$aVIQfOGDxoLg/xgME3ehZuIpo34YREiMnCphJ4XaW9tSiHMCgfWiu'
    };

    captureRequest.accountId = account.Id;
    captureRequest.additionalData = additionalData;

    commercepayments.PaymentGatewayContext gatewayContext = new commercepayments.PaymentGatewayContext(
      captureRequest,
      commercepayments.RequestType.Capture
    );

    commercepayments.GatewayResponse response = adapter.processRequest(
      gatewayContext
    );

    System.assert(response instanceof commercepayments.CaptureResponse);

    Test.stopTest();
  }

  @isTest
  static void creditCardCaptureFailTest() {
    Test.setMock(
      HttpCalloutMock.class,
      new PagBrasilPaymentCaptureMock('fail')
    );

    Account account = getAccount();
    Order order = getOrder(account.Id);

    PaymentAuthorization auth = initializeAuthObject(order.OrderNumber);

    Test.startTest();

    PagBrasilPaymentGatewayAdapter adapter = new PagBrasilPaymentGatewayAdapter();

    commercepayments.CaptureRequest captureRequest = new commercepayments.CaptureRequest(
      100,
      auth.Id
    );

    Map<String, String> additionalData = new Map<String, String>{
      'token' => '$2y$10$aVIQfOGDxoLg/xgME3ehZuIpo34YREiMnCphJ4XaW9tSiHMCgfWiu'
    };

    captureRequest.accountId = account.Id;
    captureRequest.additionalData = additionalData;

    commercepayments.PaymentGatewayContext gatewayContext = new commercepayments.PaymentGatewayContext(
      captureRequest,
      commercepayments.RequestType.Capture
    );

    commercepayments.GatewayResponse response = adapter.processRequest(
      gatewayContext
    );

    System.assert(response instanceof commercepayments.CaptureResponse);

    Test.stopTest();
  }

  @isTest
  static void invalidOrderCaptureTest() {
    Account account = getAccount();
    Order order = getOrder(account.Id);

    PaymentAuthorization auth = initializeAuthObject(order.OrderNumber);

    Test.startTest();
    Test.setMock(
      HttpCalloutMock.class,
      new PagBrasilPaymentCaptureMock('error')
    );

    PagBrasilPaymentGatewayAdapter adapter = new PagBrasilPaymentGatewayAdapter();

    commercepayments.CaptureRequest captureRequest = new commercepayments.CaptureRequest(
      100,
      auth.Id
    );

    Map<String, String> additionalData = new Map<String, String>{
      'token' => '$2y$10$aVIQfOGDxoLg/xgME3ehZuIpo34YREiMnCphJ4XaW9tSiHMCgfWiu'
    };

    captureRequest.accountId = account.Id;
    captureRequest.additionalData = additionalData;

    commercepayments.PaymentGatewayContext gatewayContext = new commercepayments.PaymentGatewayContext(
      captureRequest,
      commercepayments.RequestType.Capture
    );

    commercepayments.GatewayResponse response = adapter.processRequest(
      gatewayContext
    );

    System.assert(response instanceof commercepayments.CaptureResponse);

    Test.stopTest();
  }

  @isTest
  static void invalidBillingAddressTest() {
    Account account = getAccount();

    PagBrasilPaymentGatewayAdapter adapter = new PagBrasilPaymentGatewayAdapter();

    commercepayments.AuthorizationRequest authRequest = new commercepayments.AuthorizationRequest(
      100
    );

    Map<String, String> wrongAdditionalData = new Map<String, String>{
      'paymentType' => 'C',
      'taxId' => '191.000.000-00',
      'cardInstallments' => '12',
      'billingFullAddress' => 'Av Dr Nilo Peçanha, 1221|Porto Alegre'
    };

    authRequest.accountId = account.Id;
    authRequest.additionalData = wrongAdditionalData;
    authRequest.paymentMethod = getRealCreditCard();

    commercepayments.PaymentGatewayContext gatewayContext = new commercepayments.PaymentGatewayContext(
      authRequest,
      commercepayments.RequestType.Authorize
    );

    commercepayments.GatewayResponse response = adapter.processRequest(
      gatewayContext
    );

    System.debug(response instanceof commercepayments.GatewayErrorResponse);
  }

  @isTest
  static void emptyGatewayContextTest() {
    PagBrasilPaymentGatewayAdapter adapter = new PagBrasilPaymentGatewayAdapter();

    commercepayments.GatewayResponse response = adapter.processRequest(null);

    System.assert(response instanceof commercepayments.GatewayErrorResponse);
  }

  @isTest
  static void notSupportedPaymentServiceTest() {
    PagBrasilPaymentGatewayAdapter adapter = new PagBrasilPaymentGatewayAdapter();

    commercepayments.SaleRequest saleRequest = new commercepayments.SaleRequest(
      100
    );

    commercepayments.PaymentGatewayContext gatewayContext = new commercepayments.PaymentGatewayContext(
      saleRequest,
      commercepayments.RequestType.Sale
    );

    commercepayments.GatewayResponse response = adapter.processRequest(
      gatewayContext
    );

    System.assert(response instanceof commercepayments.GatewayErrorResponse);
  }

  @isTest
  static void authorizationGatewayServerErrorTest() {
    Test.startTest();
    Test.setMock(
      HttpCalloutMock.class,
      new PagBrasilPaymentInternalServerErrorMock()
    );

    Account account = getAccount();

    PagBrasilPaymentGatewayAdapter adapter = new PagBrasilPaymentGatewayAdapter();

    commercepayments.AuthorizationRequest authRequest = new commercepayments.AuthorizationRequest(
      100
    );

    authRequest.accountId = account.Id;
    authRequest.additionalData = getCreditCardAdditionalData();
    authRequest.paymentMethod = getRealCreditCard();

    commercepayments.PaymentGatewayContext gatewayContext = new commercepayments.PaymentGatewayContext(
      authRequest,
      commercepayments.RequestType.Authorize
    );

    commercepayments.GatewayResponse response = adapter.processRequest(
      gatewayContext
    );

    Test.stopTest();

    System.assert(response instanceof commercepayments.AuthorizationResponse);
  }

  private static Account getAccount() {
    Account account = [
      SELECT Id
      FROM Account
      WHERE Name = 'PagBrasilTestAccount'
    ];
    return account;
  }

  private static Order getOrder(String accountId) {
    Order order = [
      SELECT OrderNumber
      FROM Order
      WHERE AccountId = :accountId
      LIMIT 1
    ];
    return order;
  }

  private static commercepayments.AuthApiPaymentMethodRequest getRealCreditCard() {
    commercepayments.CardPaymentMethodRequest cardPaymentMethod = new commercepayments.CardPaymentMethodRequest(
      commercepayments.CardCategory.CreditCard
    );

    cardPaymentMethod.cardType = commercepayments.CardType.Visa;
    cardPaymentMethod.cardHolderName = 'CARLOS KNEBEL';
    cardPaymentMethod.cardNumber = '4984123412341234';
    cardPaymentMethod.cvv = '123';
    cardPaymentMethod.expiryMonth = 1;
    cardPaymentMethod.expiryYear = 29;

    commercepayments.AuthApiPaymentMethodRequest authApiPaymentMethodRequest = new commercepayments.AuthApiPaymentMethodRequest(
      cardPaymentMethod
    );

    return authApiPaymentMethodRequest;
  }

  private static commercepayments.AuthApiPaymentMethodRequest getFakeCreditCard() {
    commercepayments.CardPaymentMethodRequest cardPaymentMethod = new commercepayments.CardPaymentMethodRequest(
      commercepayments.CardCategory.CreditCard
    );

    cardPaymentMethod.cardType = commercepayments.CardType.Visa;
    cardPaymentMethod.cardHolderName = 'HOLDER';
    cardPaymentMethod.cardNumber = '0000000000000000';
    cardPaymentMethod.cvv = '000';
    cardPaymentMethod.expiryMonth = 1;
    cardPaymentMethod.expiryYear = 9999;

    commercepayments.AuthApiPaymentMethodRequest authApiPaymentMethodRequest = new commercepayments.AuthApiPaymentMethodRequest(
      cardPaymentMethod
    );

    return authApiPaymentMethodRequest;
  }

  private static Map<String, String> getCreditCardAdditionalData() {
    Map<String, String> additionalData = new Map<String, String>{
      'paymentType' => 'C',
      'taxId' => '191.000.000-00',
      'cardInstallments' => '12',
      'billingFullAddress' => 'Av Dr Nilo Peçanha, 1221|Porto Alegre|RS|91330-000',
      'visitorId' => '06c2b72d44238cf0f0bef99f0a7712b9'
    };

    return additionalData;
  }

  private static Map<String, String> getBoletoAdditionalData() {
    Map<String, String> additionalData = new Map<String, String>{
      'paymentType' => 'B',
      'taxId' => '191.000.000-00',
      'billingFullAddress' => 'Av Dr Nilo Peçanha, 1221|Porto Alegre|RS|91330-000'
    };

    return additionalData;
  }

  private static PaymentAuthorization initializeAuthObject(String orderNumber) {
    PaymentAuthorization auth = new PaymentAuthorization();

    auth.Amount = 100;
    auth.Status = 'Processed';
    auth.ProcessingMode = 'External';
    auth.GatewayRefNumber = orderNumber;

    insert (auth);
    return auth;
  }
}