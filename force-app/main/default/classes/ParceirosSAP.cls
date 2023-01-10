public class ParceirosSAP {
    public String SOLD { get; set; }
    public String BILL { get; set; }
    public String PAYER { get; set; }
    public String SHIP_TO { get; set; }

    public ParceirosSAP(Account customer){
       	this.SOLD = customer.SAPCodeTxt__c;
       	this.BILL = customer.SAPCodeTxt__c;
       	this.PAYER = customer.SAPCodeTxt__c;
        this.SHIP_TO = customer.SAPCodeTxt__c;
    }

}