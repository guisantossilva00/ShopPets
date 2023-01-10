@isTest
private class PagBrasilPaymentConfirmationRestTest {
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

    Product2 product = new Product2(Name = 'PagBrasil Product');
    insert (product);

    PricebookEntry pricebookEntry = new PricebookEntry(
      UnitPrice = 0.00,
      Pricebook2Id = Test.getStandardPricebookId(),
      Product2Id = product.Id,
      IsActive = true
    );
    insert (pricebookEntry);

    Order order = new Order(
      EffectiveDate = Date.today(),
      Status = 'Draft',
      AccountId = account.Id,
      Pricebook2Id = Test.getStandardPricebookId()
    );
    insert (order);

    OrderItem orderItem = new OrderItem(
      OrderId = order.Id,
      PricebookEntryId = pricebookEntry.Id,
      description = 'PagBrasil Product',
      Quantity = 1,
      UnitPrice = 0.00
    );
    insert (orderItem);
  }

  @isTest
  static void invalidSecretTokenTest() {
    RestRequest request = new RestRequest();
    RestResponse response = new RestResponse();

    Account account = getAccount();
    Order order = getOrder(account.Id);

    String json =
      '{"secret":"invalid_secret_phrase","payment_method":"C","order":"' +
      order.OrderNumber +
      '","amount_brl":"9.90","payment_status":"A"}';

    request.addHeader('httpMethod', 'POST');
    request.requestUri = '/services/apexrest/ipn';
    request.requestBody = Blob.valueof(json);

    RestContext.request = request;
    RestContext.response = response;

    Test.startTest();

    String success = PagBrasilPaymentConfirmationRest.receiveIpn();
    System.assert(success.equals('Error Receiving IPN'));

    Test.stopTest();
  }

  @isTest
  static void receiveCreditCardPaymentNotificationTest() {
    RestRequest request = new RestRequest();
    RestResponse response = new RestResponse();

    Account account = getAccount();
    Order order = getOrder(account.Id);

    List<String> statusList = new List<String>{
      PagBrasilUtils.IPN_STATUS_APPROVED,
      PagBrasilUtils.IPN_STATUS_REFUNDED,
      PagBrasilUtils.IPN_STATUS_CHARGEBACK,
      PagBrasilUtils.IPN_STATUS_REJECTED,
      PagBrasilUtils.IPN_STATUS_FAILED
    };

    Test.startTest();

    for (String status : statusList) {
      String json =
        '{"secret":"mock_secret_phrase","payment_method":"C","order":"' +
        order.OrderNumber +
        '","amount_brl":"9.90","payment_status":"' +
        status +
        '"}';

      request.addHeader('httpMethod', 'POST');
      request.requestUri = '/services/apexrest/ipn';
      request.requestBody = Blob.valueof(json);

      RestContext.request = request;
      RestContext.response = response;

      String success = PagBrasilPaymentConfirmationRest.receiveIpn();
      System.assert(success.contains('Received successfully'));
    }

    Test.stopTest();
  }

  @isTest
  static void receiveBoletoPaymentNotificationTest() {
    RestRequest request = new RestRequest();
    RestResponse response = new RestResponse();

    Account account = getAccount();
    Order order = getOrder(account.Id);

    String json =
      '{"secret":"mock_secret_phrase","payment_method":"B","boleto_list":[{"order": "' +
      order.OrderNumber +
      '","payment_date": "12/28/2021","amount_paid": "92.98","amount_due": "92.98"}]}';

    request.addHeader('httpMethod', 'POST');
    request.requestUri = '/services/apexrest/ipn';
    request.requestBody = Blob.valueof(json);

    RestContext.request = request;
    RestContext.response = response;

    Test.startTest();

    String success = PagBrasilPaymentConfirmationRest.receiveIpn();
    System.assert(success.contains('Received successfully'));

    Test.stopTest();
  }

  @isTest
  static void emptyBoletoNotificationTest() {
    RestRequest request = new RestRequest();
    RestResponse response = new RestResponse();

    String json = '{"secret":"mock_secret_phrase","payment_method":"B","boleto_list":[]}';

    request.addHeader('httpMethod', 'POST');
    request.requestUri = '/services/apexrest/ipn';
    request.requestBody = Blob.valueof(json);

    RestContext.request = request;
    RestContext.response = response;

    Test.startTest();

    String success = PagBrasilPaymentConfirmationRest.receiveIpn();
    System.assert(success.equals('Error Receiving IPN'));

    Test.stopTest();
  }

  @isTest
  static void invalidAmountBoletoPaymentNotificationTest() {
    RestRequest request = new RestRequest();
    RestResponse response = new RestResponse();

    Account account = getAccount();
    Order order = getOrder(account.Id);

    String json =
      '{"secret":"mock_secret_phrase","payment_method":"B","boleto_list":[{"order": "' +
      order.OrderNumber +
      '","payment_date": "12/28/2021","amount_paid": "50.98","amount_due": "92.98"}]}';

    request.addHeader('httpMethod', 'POST');
    request.requestUri = '/services/apexrest/ipn';
    request.requestBody = Blob.valueof(json);

    RestContext.request = request;
    RestContext.response = response;

    Test.startTest();

    String success = PagBrasilPaymentConfirmationRest.receiveIpn();
    System.assert(success.contains('Received successfully'));

    Test.stopTest();
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
}