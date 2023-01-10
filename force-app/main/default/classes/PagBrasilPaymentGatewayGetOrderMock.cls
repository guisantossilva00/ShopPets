global class PagBrasilPaymentGatewayGetOrderMock implements HttpCalloutMock {
  global HttpResponse respond(HttpRequest request) {
    HttpResponse response = new HttpResponse();

    response.setStatusCode(200);
    response.setBody(
      '<request><order>101001</order><order_status>PF</order_status><payment_method>B</payment_method><submission_date>10/12/2021</submission_date><url_boleto>https://pagbrasil.com/b?b3b4cj7rf</url_boleto><order_status>PC</order_status><payment_date>10/15/2021</payment_date><product_name>Product Test (1 license)</product_name><customer_name>PagBrasil</customer_name><customer_taxid>19100000000</customer_taxid><customer_email>support@pagbrasil.com</customer_email><customer_phone>5135000718</customer_phone><address_street>Av. Dr Nilo Pecanha 1221</address_street><address_zip>91330000</address_zip><address_city>Porto Alegre</address_city><address_state>RS</address_state><amount_brl>100.00</amount_brl><amount_paid>100.00</amount_paid><signature>0c0372d38364f2a6d31ec61b0054ff32</signature></request>'
    );

    return response;
  }
}