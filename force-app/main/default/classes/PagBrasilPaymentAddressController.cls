/**
 * PagBrasilPaymentAddressController class
 */
public with sharing class PagBrasilPaymentAddressController {
  /**
   * Request external service to find address details searching for postal code
   */
  @AuraEnabled
  public static String findAddressPostalCode(String postalCode) {
    postalCode = postalCode.replaceAll('[^0-9]', '');

    HttpRequest request = new HttpRequest();

    String endpoint = String.format(
      'callout:ViaCep/ws/{0}/json/',
      new List<String>{ postalCode }
    );

    request.setEndpoint(endpoint);
    request.setMethod('GET');

    Http http = new Http();
    HTTPResponse response = http.send(request);

    return response.getBody();
  }

  /**
   * Find account saved addresses
   */
  @AuraEnabled
  public static List<ContactPointAddress> getAccountAddresses() {
    return new PagBrasilQueryUtils().getCurrentAccountBillingAddressList();
  }
}