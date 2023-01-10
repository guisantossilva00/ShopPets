@isTest
private class PagBrasilPaymentAddressControllerTest {
  @isTest
  static void findPostalCodeTest() {
    Test.startTest();
    Test.setMock(HttpCalloutMock.class, new PagBrasilPostalCodeServiceMock());

    String responseBody = PagBrasilPaymentAddressController.findAddressPostalCode(
      '91330-000'
    );

    Map<String, String> responseJson = (Map<String, String>) JSON.deserialize(
      responseBody,
      Map<String, String>.class
    );

    System.assertEquals(
      'Avenida Doutor Nilo Peçanha',
      responseJson.get('logradouro')
    );

    System.assertEquals('Três Figueiras', responseJson.get('bairro'));
    System.assertEquals('Porto Alegre', responseJson.get('localidade'));
    System.assertEquals('RS', responseJson.get('uf'));

    Test.stopTest();
  }

  @isTest
  static void getAccountAddressesTest() {
    Id profileId = [
      SELECT Id
      FROM Profile
      WHERE Name = 'UISA Customer Community Plus Login User'
    ]
    .Id;

    Account account = createAccount('Test Account');
    insert (account);

    Contact contact = createContact(
      'test',
      'Contact',
      'support@pagbrasil.com',
      account.Id
    );
    insert (contact);

    User user = createCommunityUser(contact.Id, profileId, 'Carlos', 'Knebel');

    ContactPointAddress contactPointAddress = new ContactPointAddress(
      Name = 'Endereço de faturamento',
      AddressType = 'Billing',
      ParentId = account.Id
    );
    insert (contactPointAddress);

    Test.startTest();

    System.runAs(user) {
      List<ContactPointAddress> addresses = PagBrasilPaymentAddressController.getAccountAddresses();
      System.assertEquals(1, addresses.size());
    }

    Test.stopTest();
  }

  private static Account createAccount(String Name) {
    Account portalAccount = new Account(name = Name);
    return portalAccount;
  }

  private static Contact createContact(
    String firstName,
    String lastName,
    String email,
    String accountId
  ) {
    Contact portalContact = new contact(
      FirstName = firstName,
      LastName = lastName,
      Email = email,
      AccountId = accountId
    );
    return portalContact;
  }

  private static User prepareUser(
    String roleId,
    String profId,
    String firstName,
    String lastName
  ) {
    String orgId = UserInfo.getOrganizationId();
    String dateString = String.valueof(Datetime.now())
      .replace(' ', '')
      .replace(':', '')
      .replace('-', '');

    Integer randomInt = Integer.valueOf(math.rint(math.random() * 1000000));
    String uniqueName = orgId + dateString + randomInt;

    User tempUser = new User(
      FirstName = firstName,
      LastName = lastName,
      email = uniqueName + '@sfdc' + orgId + '.org',
      Username = uniqueName + '@sfdc' + orgId + '.org',
      EmailEncodingKey = 'ISO-8859-1',
      Alias = uniqueName.substring(18, 23),
      TimeZoneSidKey = 'America/Los_Angeles',
      LocaleSidKey = 'en_US',
      LanguageLocaleKey = 'en_US',
      ProfileId = profId
    );

    if (String.isBlank(roleId) == false) {
      tempUser.UserRoleId = roleId;
    }

    return tempUser;
  }

  private static User createCommunityUser(
    String contactId,
    String profId,
    String firstName,
    String lastName
  ) {
    User tempUser = prepareUser('', profId, firstName, lastName);
    tempUser.ContactId = contactId;

    return tempUser;
  }
}