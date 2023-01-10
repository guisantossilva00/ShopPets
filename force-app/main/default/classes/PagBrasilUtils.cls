public class PagBrasilUtils {
  /**
   * PagBrasil Payment Methods
   */
  public static final String PAYMENT_METHOD_CREDITCARD = 'C';
  public static final String PAYMENT_METHOD_PECFLASH = 'P';
  public static final String PAYMENT_METHOD_BOLETO = 'B';
  public static final String PAYMENT_METHOD_PIX = 'X';

  /**
   * PagBrasil Payment Status
   */
  public static final String PAYMENT_STATUS_COMPLETED = 'PC';
  public static final String PAYMENT_STATUS_AUTHORIZED = 'PA';
  public static final String PAYMENT_STATUS_FAILED = 'PF';
  public static final String PAYMENT_STATUS_REJECTED = 'PR';
  public static final String PAYMENT_STATUS_WAITING = 'WP';
  public static final String PAYMENT_STATUS_REFUND_REQUESTED = 'RR';
  public static final String PAYMENT_STATUS_REFUND_PROCESSED = 'RP';
  public static final String PAYMENT_STATUS_CHARGEBACK = 'CB';

  /**
   * PagBrasil IPN Status
   */
  public static final String IPN_STATUS_APPROVED = 'A';
  public static final String IPN_STATUS_REFUNDED = 'P';
  public static final String IPN_STATUS_CHARGEBACK = 'C';
  public static final String IPN_STATUS_REJECTED = 'R';
  public static final String IPN_STATUS_FAILED = 'F';

  /**
   * PagBrasil Default Error Messages
   */
  public static final String DEFAULT_ERROR_MESSAGE = 'Erro desconhecido. Por favor, repita o processo de compra ou tente novamente mais tarde.';
  public static final String AUTHORIZATION_ERROR_MESSAGE = 'Não foi possível completar seu pagamento. Por favor, tente novamente.';
  public static final String UNAUTHORIZED_ERROR_MESSAGE = 'Essa loja não está autorizada a aceitar pagamentos.';
  public static final String INVALID_CURRENCY_ERROR_MESSAGE = 'Este gateway só suporta pagamentos em BRL.';

  public static final Map<String, String> ERROR_MESSAGES = new Map<String, String>{
    '01' => 'Pagamento não autorizado pelo banco emissor.',
    '02' => 'Falha no pagamento, por favor entre em contato com o banco emissor.',
    '03' => 'Falha no pagamento, cartão possui restrições. Por favor entre em contato com o banco emissor.',
    '04' => 'Por favor, tente novamente.',
    '05' => 'Pagamento não autorizado pelo banco emissor.',
    '06' => 'Valor inválido.',
    '07' => 'O número do cartão de crédito é inválido.',
    '08' => 'Banco emissor inválido.',
    '09' => 'Limite do cartão de crédito excedido.',
    '10' => 'Cartão de crédito fora da validade.',
    '11' => 'Transação não autorizada pelo banco emissor.',
    '12' => 'Cartão de crédito inativo. Por favor, entre em contato com o banco emissor.',
    '13' => 'Sem resposta do banco emissor.',
    '14' => 'O cartão utilizado não possui permissão para este tipo de transação.',
    '15' => 'O código de segurança do cartão é inválido.',
    '16' => 'O cartão não possui permissão para realizar compras on-line.',
    '17' => 'Número de parcelas inválido.',
    'PR' => 'Pagamento não autorizado, por favor tente novamente mais tarde.'
  };

  /**
   * Get a Payment Group from a WebCart
   */
  public static ConnectApi.PaymentGroupRequest getPaymentGroup(String cartId) {
    ConnectApi.PaymentGroupRequest paymentGroup = new ConnectApi.PaymentGroupRequest();

    paymentGroup.createPaymentGroup = false;
    paymentGroup.currencyIsoCode = UserInfo.getDefaultCurrency();

    String orderId = new PagBrasilQueryUtils().getOrderIdByCart(cartId);

    if (orderId != null && String.isNotEmpty(orderId)) {
      paymentGroup.sourceObjectId = orderId;
    }

    return paymentGroup;
  }

  /**
   * Get Credit Card payment method input
   */
  public static ConnectApi.CardPaymentMethodRequest getCardPaymentMethodInput(
    String paymentType,
    Map<String, Object> paymentInfo
  ) {
    ConnectApi.CardPaymentMethodRequest cardPaymentMethod = new ConnectApi.CardPaymentMethodRequest();

    if (paymentType == PAYMENT_METHOD_CREDITCARD) {
      cardPaymentMethod.cardCategory = ConnectApi.CardCategory.CreditCard;

      cardPaymentMethod.cardHolderName = paymentInfo.get('cardHolderName')
        .toString();

      cardPaymentMethod.cardNumber = paymentInfo.get('cardNumber').toString();
      cardPaymentMethod.cardType = 'Visa';

      if (paymentInfo.get('cvv') != null) {
        cardPaymentMethod.cvv = paymentInfo.get('cvv').toString();
      }

      cardPaymentMethod.expiryMonth = Integer.valueOf(
        paymentInfo.get('expiryMonth')
      );

      cardPaymentMethod.expiryYear = Integer.valueOf(
        paymentInfo.get('expiryYear')
      );

      return cardPaymentMethod;
    }

    cardPaymentMethod.cardCategory = ConnectApi.CardCategory.CreditCard;
    cardPaymentMethod.cardHolderName = 'HOLDER';
    cardPaymentMethod.cardNumber = '0000000000000000';
    cardPaymentMethod.cardType = 'Visa';
    cardPaymentMethod.cvv = '000';
    cardPaymentMethod.expiryMonth = 1;
    cardPaymentMethod.expiryYear = 9999;

    return cardPaymentMethod;
  }

  /**
   * Get authorization payment method
   */
  public static ConnectApi.AuthApiPaymentMethodRequest getAuthPaymentMethod(
    String paymentType,
    Map<String, Object> paymentInfo
  ) {
    ConnectApi.AuthApiPaymentMethodRequest authenticationApiMethod = new ConnectApi.AuthApiPaymentMethodRequest();

    authenticationApiMethod.cardPaymentMethod = getCardPaymentMethodInput(
      paymentType,
      paymentInfo
    );

    return authenticationApiMethod;
  }

  /**
   * Receive a cartItem object and parse all the cart items with their quantity to one string
   */
  public static String parseCartItemsToString(Map<ID, CartItem> cartItems) {
    List<String> products = new List<String>();

    for (ID itemKey : cartItems.keyset()) {
      CartItem item = cartItems.get(itemKey);
      products.add(item.Name + '(Qty:' + item.Quantity + ')');
    }

    return String.join(products, '_');
  }

  /**
   * Round the order amount to 2 decimal places
   */
  public static String formatMoney(Decimal amount) {
    return String.valueOf(amount.round());
  }

  /**
   * Receive expiration month and year and format to MM/YYYY
   */
  public static String formatExpiryDate(
    Integer expiryMonth,
    Integer expiryYear
  ) {
    String month = String.valueOf(expiryMonth);
    String year = String.valueOf(expiryYear);

    if (month.length() == 1) {
      month = '0' + month;
    }

    return month + '/' + year;
  }

  /**
   * Check if the status received is of type Success
   */
  public static Boolean isSuccessStatus(String status) {
    return status == PAYMENT_STATUS_COMPLETED ||
      status == PAYMENT_STATUS_AUTHORIZED;
  }

  /**
   * Check if the status received on IPN is of type Refund
   */
  public static Boolean isIpnRefundStatus(String status) {
    return status == IPN_STATUS_REFUNDED || status == IPN_STATUS_CHARGEBACK;
  }

  /**
   * Check if the payment method is Boleto or PecFlash
   */
  public static Boolean isBoletoOrPEC(String paymentMethod) {
    return paymentMethod == PAYMENT_METHOD_BOLETO ||
      paymentMethod == PAYMENT_METHOD_PECFLASH;
  }

  /**
   * Check if the payment method is assynchronous
   */
  public static Boolean isAssynchronousPaymentMethod(String paymentMethod) {
    return paymentMethod == PAYMENT_METHOD_BOLETO ||
      paymentMethod == PAYMENT_METHOD_PECFLASH ||
      paymentMethod == PAYMENT_METHOD_PIX;
  }

  /**
   * Received error codes and return error messages
   */
  public static String getErrorMessage(String errorId) {
    String errorMessage = ERROR_MESSAGES.get(errorId);

    if (errorMessage != null) {
      return errorMessage;
    }

    return DEFAULT_ERROR_MESSAGE;
  }
}