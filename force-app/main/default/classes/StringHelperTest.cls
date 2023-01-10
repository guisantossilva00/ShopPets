@istest
Public class StringHelperTest {
    @isTest static void splitPath(){
        String pay = 'ZECV - Testando a Integração';
        System.assertEquals('ZECV', StringHelper.splitPath(pay));   
        pay = '';
        System.assertEquals('', StringHelper.splitPath(pay));   
    }   
    
    @isTest static void fixSapText(){
        String sapText = 'ACUCAR, acucar, Acucar, ALCOOL, alcool, Alcool, Antisseptico, antisseptico, ANTISSEPTICO, COSMETICO, Cosmetico, cosmetico, etilico, Etilico, ETILICO';
    	String match = 'AÇÚCAR, açúcar, Açúcar, ÁLCOOL, álcool, Álcool, Antisséptico, antisséptico, ANTISSÉPTICO, COSMÉTICO, Cosmético, cosmético, etílico, Etílico, ETÍLICO';
        System.assertEquals(match, StringHelper.fixSapText(sapText), 'As palavras devem possuir acentuação e cedilha.');    
    }
}