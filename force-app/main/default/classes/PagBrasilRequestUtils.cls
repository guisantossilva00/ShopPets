/**
 * PagBrasilRequestUtils class
 */
public class PagBrasilRequestUtils {
  /**
   * PagBrasil Endpoints
   */
  public static final String REQUEST_ENDPOINT_GETORDER = 'https://iframe.pagbrasil.com/api/control/?method=getOrderDirect';
  public static final String REQUEST_ENDPOINT_SERVICE = 'https://service.pagbrasil.com/salesforce/api/settings';

  /**
   * Get checkout settings
   */
  public static Map<String, Object> getCheckoutInfo(String cartId) {
    PagBrasilQueryUtils pagbrasilQueryUtils = new PagBrasilQueryUtils();

    Map<String, Object> cartInfo = pagbrasilQueryUtils.getCartInfo(cartId);
    String providerId = pagbrasilQueryUtils.getPaymentProviderId();

    HttpRequest request = new HttpRequest();

    String domain = String.valueOf(Url.getOrgDomainUrl().toExternalForm());
    String amount = String.valueOf(cartInfo.get('amount'));

    String endpoint = String.format(
      '{0}?merchant={1}&amount={2}&provider={3}',
      new List<String>{ REQUEST_ENDPOINT_SERVICE, domain, amount, providerId }
    );

    request.setEndpoint(endpoint);
    request.setHeader('Content-Type', 'application/json');
    request.setHeader('Referer', domain);
    request.setMethod('GET');

    Http http = new Http();
    HttpResponse response = http.send(request);

    Map<String, Object> responseJson = (Map<String, Object>) JSON.deserializeUntyped(
      response.getBody()
    );

    String accountId = new PagBrasilQueryUtils()
      .getUserAccountId(UserInfo.getUserId());

    responseJson.put('account_id', accountId);

    return responseJson;
  }

  /**
   * Get the addOrder JSON to build request
   */
  public String mountCreditCardRequest(
    Map<String, String> order,
    Map<String, String> customer,
    Map<String, String> payment,
    Map<String, String> creditCard
  ) {
    JSONGenerator jsonObject = JSON.createGenerator(false);
    jsonObject.writeStartObject();

    Pagbrasil_Settings__c settings = Pagbrasil_Settings__c.getOrgDefaults();

    /**
     * Merchant object
     */
    jsonObject.writeFieldName('merchant');
    jsonObject.writeStartObject();
    jsonObject.writeStringField('pbtoken', settings.PB_Token__c);
    jsonObject.writeEndObject();

    /**
     * Customer object
     */
    jsonObject.writeFieldName('customer');
    jsonObject.writeStartObject();

    for (String key : customer.keySet()) {
      jsonObject.writeStringField(key, customer.get(key));
    }

    jsonObject.writeEndObject();

    /**
     * Order object
     */
    jsonObject.writeFieldName('order');
    jsonObject.writeStartObject();

    for (String key : order.keySet()) {
      jsonObject.writeStringField(key, order.get(key));
    }

    jsonObject.writeEndObject();

    /**
     * Creditcard object
     */
    jsonObject.writeFieldName('creditCard');
    jsonObject.writeStartObject();

    for (String key : creditCard.keySet()) {
      jsonObject.writeStringField(key, creditCard.get(key));
    }

    jsonObject.writeEndObject();

    /**
     * Payment object
     */
    jsonObject.writeFieldName('payment');
    jsonObject.writeStartObject();

    for (String key : payment.keySet()) {
      jsonObject.writeStringField(key, payment.get(key));
    }

    jsonObject.writeEndObject();

    jsonObject.writeEndObject();
    return jsonObject.getAsString();
  }

  /**
   * Get the addOrder JSON to build request for assynchronous payment methods
   */
  public String mountAssynchronousPaymentRequest(
    Map<String, String> order,
    Map<String, String> customer,
    Map<String, String> payment
  ) {
    JSONGenerator jsonObject = JSON.createGenerator(false);
    jsonObject.writeStartObject();

    Pagbrasil_Settings__c settings = Pagbrasil_Settings__c.getOrgDefaults();

    /**
     * Merchant object
     */
    jsonObject.writeFieldName('merchant');
    jsonObject.writeStartObject();
    jsonObject.writeStringField('pbtoken', settings.PB_Token__c);
    jsonObject.writeEndObject();

    /**
     * Customer object
     */
    jsonObject.writeFieldName('customer');
    jsonObject.writeStartObject();

    for (String key : customer.keySet()) {
      jsonObject.writeStringField(key, customer.get(key));
    }

    jsonObject.writeEndObject();

    /**
     * Order object
     */
    jsonObject.writeFieldName('order');
    jsonObject.writeStartObject();

    for (String key : order.keySet()) {
      jsonObject.writeStringField(key, order.get(key));
    }

    jsonObject.writeEndObject();

    /**
     * Payment object
     */
    jsonObject.writeFieldName('payment');
    jsonObject.writeStartObject();

    for (String key : payment.keySet()) {
      jsonObject.writeStringField(key, payment.get(key));
    }

    jsonObject.writeEndObject();

    jsonObject.writeEndObject();
    return jsonObject.getAsString();
  }

  /**
   * Get the getOrder JSON to check order payment status on capture
   */
  public String mountCaptureRequest(Map<String, String> order) {
    JSONGenerator jsonObject = JSON.createGenerator(false);
    jsonObject.writeStartObject();

    Pagbrasil_Settings__c settings = Pagbrasil_Settings__c.getOrgDefaults();

    /**
     * Merchant object
     */
    jsonObject.writeFieldName('merchant');
    jsonObject.writeStartObject();
    jsonObject.writeStringField('pbtoken', settings.PB_Token__c);
    jsonObject.writeEndObject();

    /**
     * Order object
     */
    jsonObject.writeFieldName('order');
    jsonObject.writeStartObject();
    jsonObject.writeStringField('order', order.get('id'));
    jsonObject.writeStringField('order_token', order.get('token'));
    jsonObject.writeEndObject();

    jsonObject.writeEndObject();
    return jsonObject.getAsString();
  }
}