@isTest
private class PagBrasilPaymentControllerTest {
  @isTest
  static void getCheckoutInfoTest() {
    Account account = new Account(Name = 'PagBrasilTestAccount');
    insert (account);

    Contact contact = new Contact(
      LastName = 'PagBrasilTestContact',
      Email = 'support@pagbrasil.com',
      Phone = '5135000718',
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

    Test.startTest();
    Test.setMock(HttpCalloutMock.class, new PagBrasilCheckoutSettingsMock());

    Map<String, Object> checkoutInfo = pagBrasilPaymentController.getCheckoutInfo(
      cart.Id
    );

    System.assertEquals('XCDPFB', checkoutInfo.get('payment_methods'));
    System.assertEquals('PCAMOCK', checkoutInfo.get('public_key'));

    Test.stopTest();
  }

  @isTest
  static void requestPixOrderInformationTest() {
    PagBrasil_Settings__c settings = new PagBrasil_Settings__c(
      PB_Secret__c = 'mock_secret_phrase',
      PB_Token__c = 'mock_secret_token'
    );
    insert (settings);

    Test.startTest();
    Test.setMock(
      HttpCalloutMock.class,
      new PagBrasilPaymentCaptureMock('success')
    );

    String jsonBody = PagBrasilPaymentController.requestPixOrderInformation(
      '101001',
      '$2y$10$aVIQfOGDxoLg/xgME3ehZuIpo34YREiMnCphJ4XaW9tSiHMCgfWiu'
    );

    Map<String, String> responseJson = (Map<String, String>) JSON.deserialize(
      jsonBody,
      Map<String, String>.class
    );

    System.assertEquals('101001', responseJson.get('order'));
    System.assertEquals('PC', responseJson.get('status'));

    Test.stopTest();
  }

  @isTest
  static void requestOrderInformationFromOrderNumberTest() {
    PagBrasil_Settings__c settings = new PagBrasil_Settings__c(
      PB_Secret__c = 'mock_secret_phrase',
      PB_Token__c = 'mock_secret_token'
    );
    insert (settings);

    Account account = new Account(Name = 'PagBrasilTestAccount');
    insert (account);

    Order newOrder = new Order(
      EffectiveDate = Date.today(),
      Status = 'Draft',
      AccountId = account.Id
    );
    insert (newOrder);

    Test.startTest();
    Test.setMock(
      HttpCalloutMock.class,
      new PagBrasilPaymentGatewayGetOrderMock()
    );

    Order order = [SELECT Id, OrderNumber FROM Order WHERE Id = :newOrder.Id];
    String orderInformation = PagBrasilPaymentController.requestOrderInformationFromOrderNumber(
      order.OrderNumber
    );

    System.assert(String.isNotEmpty(orderInformation));

    Test.stopTest();
  }

  @isTest
  static void setOrderStatusAsFailed() {
    Account account = new Account(Name = 'PagBrasilTestAccount');
    insert (account);

    Contact contact = new Contact(
      LastName = 'PagBrasilTestContact',
      Email = 'support@pagbrasil.com',
      Phone = '5135000718',
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

    Boolean success = PagBrasilPaymentController.setOrderStatusAsFailed(
      cart.Id
    );

    System.assertEquals(true, success);

    Test.stopTest();
  }

  @isTest
  static void setOrderStatusAsRejected() {
    Account account = new Account(Name = 'PagBrasilTestAccount');
    insert (account);

    Contact contact = new Contact(
      LastName = 'PagBrasilTestContact',
      Email = 'support@pagbrasil.com',
      Phone = '5135000718',
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
    Boolean success = PagBrasilPaymentController.setOrderStatusAsRejected(
      cart.Id
    );

    System.assertEquals(true, success);

    Test.stopTest();
  }
}