@isTest
public class PricebookEntryRESTTest {
    
    @isTest(seeAllData = true) public static void doPatch(){
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        
        req.requestURI = '/UISA/PricebookEntry/';  //Request URL
        req.httpMethod = 'Patch';//HTTP Request Type
        RestContext.request = req;
        RestContext.response= res;
        
        Pricebook2 pricebook = new Pricebook2();
        pricebook.name = 'Test - PricebookEntryRESTTest';
        Insert pricebook;
        
        Product2 productA = new Product2();
        productA.name = 'Test - Product';
        Insert productA;
        
        Product2 productB = new Product2();
        productB.name = 'Test - Product 2';
        Insert productB;
        
        String standardPrice = Test.getStandardPricebookId();
        PricebookEntry standardA = new PricebookEntry(pricebook2Id = standardPrice, UnitPrice = 1);
        standardA.product2Id = productA.Id;
        standardA.SAPCodeTxt__c = '01010101010';
        Insert standardA;
        
        PricebookEntry standardB = new PricebookEntry(pricebook2Id = standardPrice, UnitPrice = 1);
        standardB.product2Id = productB.Id;
        standardB.SAPCodeTxt__c = '01020102030';
        standardB.IsActive = true;
        Insert standardB;
        
        Test.startTest();
        PricebookEntry pbeA = new PricebookEntry(pricebook2Id = pricebook.Id, UnitPrice = 1);
        pbeA.product2Id = productA.Id;
        pbeA.SAPCodeTxt__c = '0101010101';
        Insert pbeA;
        
        PricebookEntry pbeB = new PricebookEntry(pricebook2Id = pricebook.Id, UnitPrice = 1);
        pbeB.product2Id = productB.Id;
        pbeB.SAPCodeTxt__c = '0102010203';
        pbeB.IsActive = true;

        PricebookEntryREST.doPatch(false, new List<PricebookEntry>{pbeA, pbeB});
        System.assertEquals(1, [SELECT COUNT() FROM PricebookEntry WHERE Pricebook2Id =: pricebook.Id AND product2Id =: productA.Id], 'Pricebook Entry A já deve constar no sistema.');
        System.assertEquals(1, [SELECT COUNT() FROM PricebookEntry WHERE Pricebook2Id =: pricebook.Id AND product2Id =: productB.Id], 'Pricebook Entry B deve ser inserido no sistema.');
        System.assertEquals(true, [SELECT IsActive FROM PricebookEntry WHERE SapCodeTxt__c = '0102010203'].IsActive, 'O Pricebook Entry B deve estar com o campo ativo devido a atualização do REST.');
        Try{
            PricebookEntryREST.doPatch(false, null);
            System.assert(true); 
        } catch(Exception e){
            System.assert(false, 'O erro precisa ser tratado pela classe REST.');
        }
        Test.stopTest();
    }
}