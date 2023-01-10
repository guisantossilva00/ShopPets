/**
 * PagBrasilQueryUtils class
 */
public class PagBrasilQueryUtils {
  /**
   * Get cart info based on cartId
   */
  public Map<String, Object> getCartInfo(String cartId) {
    WebCart cart = [
      SELECT Id, TotalAmount
      FROM WebCart
      WHERE Id = :cartId
      WITH SECURITY_ENFORCED
    ];

    Map<String, Object> paymentInfo = new Map<String, Object>();
    paymentInfo.put('amount', cart.TotalAmount);

    return paymentInfo;
  }

  /**
   * Get contact data based on accountId
   */
  public Contact getContactDataByAccountId(String accountId) {
    Contact contact = [
      SELECT Id, Name, Email, Phone
      FROM Contact
      WHERE AccountId = :accountId
      LIMIT 1
    ];

    return contact;
  }

  /**
   * Return the account Billing Address
   */
  public Address getAccountBillingAddress(String accountId) {
    Account account = [
      SELECT Id, BillingAddress
      FROM Account
      WHERE Id = :accountId
    ];

    return account.BillingAddress;
  }

  /**
   * Return account last order id
   */
  public String getLastOrderNumberByAccountId(String accountId) {
    Order order = [
      SELECT OrderNumber
      FROM Order
      WHERE AccountId = :accountId
      ORDER BY Id DESC
      LIMIT 1
    ];

    return order.OrderNumber;
  }

  /**
   * Find account last order
   */
  public Order getLastOrderByAccountId(String accountId) {
    Order order = [
      SELECT Id, OrderNumber, Payment_Instructions__c
      FROM Order
      WHERE AccountId = :accountId
      ORDER BY Id DESC
      LIMIT 1
    ];

    return order;
  }

  /**
   * Find WebCart informations base on their Id
   */
  public WebCart getCartInfosById(String cartId) {
    WebCart cart = [
      SELECT Id, WebStoreId, GrandTotalAmount, AccountId
      FROM WebCart
      WHERE Id = :cartId
      LIMIT 1
    ];

    return cart;
  }

  /**
   * Find store active Payment Gateway Id
   */
  public String getPaymentGatewayId(String webStoreId) {
    String paymentGatewayId = [
      SELECT Integration
      FROM StoreIntegratedService
      WHERE ServiceProviderType = 'Payment' AND StoreId = :webStoreId
    ]
    .Integration;

    return paymentGatewayId;
  }

  public String getPaymentProviderId() {
    String paymentProviderId = [
      SELECT Id
      FROM PaymentGatewayProvider
      WHERE DeveloperName = 'PagBrasil'
      LIMIT 1
    ]
    .Id;

    return paymentProviderId;
  }

  /**
   * Get Order based on Cart Id
   */
  public String getOrderIdByCart(String cartId) {
    return [
      SELECT OrderId
      FROM CartCheckoutSession
      WHERE WebCartId = :cartId AND IsArchived = FALSE
    ]
    .OrderId;
  }

  /**
   * Get Order based on Id
   */
  public Order getOrderById(String orderId) {
    return [SELECT Id, OrderNumber, Status FROM Order WHERE Id = :orderId];
  }

  /**
   * Find a order by Order Number
   */
  public Order getOrderByOrderNumber(String orderNumber) {
    Order order = [
      SELECT Id, GrandTotalAmount, Status, OrderNumber
      FROM Order
      WHERE OrderNumber = :orderNumber
      LIMIT 1
    ];

    return order;
  }

  /**
   * Get items of the last WebCart from a Account
   */
  public Map<ID, CartItem> getAccountLastCartItems(String accountId) {
    WebCart cart = [
      SELECT Id
      FROM WebCart
      WHERE AccountId = :accountId
      ORDER BY Id DESC
      LIMIT 1
    ];

    Map<ID, CartItem> cartItems = new Map<ID, CartItem>(
      [SELECT Id, Name, Quantity FROM CartItem WHERE CartId = :cart.Id]
    );

    return cartItems;
  }

  /**
   * Get Account billing address list
   */
  public List<ContactPointAddress> getCurrentAccountBillingAddressList() {
    String parentId = [
      SELECT AccountID
      FROM User
      WHERE Id = :UserInfo.getUserId()
    ]
    .AccountId;

    return [
      SELECT Name, Address
      FROM ContactPointAddress
      WHERE ParentId = :parentId AND AddressType = 'Billing'
    ];
  }

  /**
   * Get current user account id
   */
  public String getUserAccountId(String userId) {
    return [SELECT AccountID FROM User WHERE Id = :userId].AccountId;
  }
}