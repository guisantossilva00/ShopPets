public class ItemSAP {
    
    public String MATERIAL {get; set;}
    public String PLANT {get; set;}
    public Decimal TARGET_QTY {get; set;}
    public Decimal PRICE {get; set;}
    
    public ItemSAP(OrderItem orderItem, ProductsAvailable__c available){
        if(available != null){
            this.MATERIAL = orderItem.Product2.SAPCodeTxt__c;
        }
        this.PLANT = available.SupplierCenterLkp__r.SapCodeTxt__c;
        this.TARGET_QTY = orderItem.Quantity;
        this.PRICE = orderItem.Unitprice;
	}
    
     public ItemSAP(OrderItem orderItem){
        this.MATERIAL = orderItem.Product2.SAPCodeTxt__c;
        this.TARGET_QTY = orderItem.Quantity;
        this.PRICE = orderItem.Unitprice;
	}
}