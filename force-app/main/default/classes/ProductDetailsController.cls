public class ProductDetailsController {
    
	@AuraEnabled
    public static List<Product2> getProductDetails(String productId){
        List<Product2> product = [SELECT Id, Embalagem__c, Fabricante__c, Validade__c, QuantidadeLiquida__c, Conservacao__c, Ingredientes__c, Tipo__c, InformacaoNutricional__c, ValorEnergetico__c, PorcentagemValorEnergetico__c, Carboidratos__c, PorcentagemCarboidratos__c FROM Product2 where id = :productId];	
        return product;                
    }
    
    @AuraEnabled
    public static String getProductDescription(String productId){
        List<Product2> product = [SELECT Id, Description FROM Product2 where id = :productId];	
        return product[0].Description;                
    }
}