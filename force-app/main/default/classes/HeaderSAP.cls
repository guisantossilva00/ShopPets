//Reffers to Order
public class HeaderSAP {
    public String DOC_TYPE { get; set;}
    public String SALES_ORG { get; set;}
    public String DISTR_CHAN { get; set;}
    public String SALES_OFF { get; set;}
    public String SALES_GRP { get; set;}
    public String REQ_DATE_H { get; set;}
    public String PURCH_NO_C { get; set;}
    public String PURCH_DATE { get; set;}
    public String PRICE_DATE { get; set;}
    public String PYMT_METH { get; set;}
    public String ZTERM { get; set;}
    public String DIVISION {get; set;}
    public Decimal FRETE {get; public set;}
    public String INCOTERMS1 {get; public set;}
    public String INCOTERMS2 {get; public set;}
    
    
    public HeaderSAP(Order salesOrder, String SalesTeamLkp, String paymentCondition){
        Datetime d = salesOrder.EffectiveDate;
        String OrderDate = DateTime.newInstance(d.year(),d.month(),d.day()+1).format('yyyy-MM-dd').replace('-', '');
       
        if (salesOrder.RecordTypeId == '0124x000000QigqAAC'){
            this.DOC_TYPE = 'ZVEC';}
        if (salesOrder.RecordTypeId == '0124x000000QigrAAC'){
            this.DOC_TYPE = 'ZVPE';}

        this.SALES_ORG = salesOrder.SalesOrganizationFml__c;
        this.DISTR_CHAN = salesOrder.DistributionChannelFml__c;
        this.DIVISION = salesOrder.ActivitySectorFml__c;
        this.SALES_OFF= salesOrder.SalesOfficeFml__c;
        this.SALES_GRP= SalesTeamLkp;
        this.REQ_DATE_H = OrderDate;
        this.PURCH_NO_C = salesOrder.OrderNumber;
        
    if (salesOrder.PaymentFormTxt__c == 'A - Duplicata Registrada - Cliente'){
        this.PYMT_METH = 'A';
}   if (salesOrder.PaymentFormTxt__c == 'C - Cheque - Pagto Fornecedor'){
        this.PYMT_METH = 'C';
}   if (salesOrder.PaymentFormTxt__c == 'B - Boleto/Duplicata - Fornecedor'){
        this.PYMT_METH = 'B';
}   if (salesOrder.PaymentFormTxt__c == 'D - Boleto/Duplicata - Clientes'){
        this.PYMT_METH = 'D';
}   if (salesOrder.PaymentFormTxt__c == 'E - Pagto Dinheiro/Cheque -Cliente'){
        this.PYMT_METH = 'E';
}   if (salesOrder.PaymentFormTxt__c == 'F - Borderô - Fornecedor'){
        this.PYMT_METH = 'F';
}   if (salesOrder.PaymentFormTxt__c == 'G - Pagamento a concessionárias'){
        this.PYMT_METH = 'G';
}   if (salesOrder.PaymentFormTxt__c == 'H - Pagamento a vista - fornecedor'){
        this.PYMT_METH = 'H';
}   if (salesOrder.PaymentFormTxt__c == 'J - Pagamento Juridico TED'){
        this.PYMT_METH = 'J';
}   if (salesOrder.PaymentFormTxt__c == 'K - BR_FEBRABAN_P Nota de crédito'){
        this.PYMT_METH = 'K';
}   if (salesOrder.PaymentFormTxt__c == 'L - Pagamento externo'){
        this.PYMT_METH = 'L';
}   if (salesOrder.PaymentFormTxt__c == 'M - Nota de débito'){
        this.PYMT_METH = 'M';
}   if (salesOrder.PaymentFormTxt__c == 'N - Pagamento de cartão'){
        this.PYMT_METH = 'N';
}   if (salesOrder.PaymentFormTxt__c == 'P - BR_FEBRABAN_A ordem pagamento'){
        this.PYMT_METH = 'P';
}   if (salesOrder.PaymentFormTxt__c == 'R - TED'){
        this.PYMT_METH = 'R';
}   if (salesOrder.PaymentFormTxt__c == 'S - DOC'){
        this.PYMT_METH = 'S';
}   if (salesOrder.PaymentFormTxt__c == 'T - Trib com código de barras'){
        this.PYMT_METH = 'T';
}   if (salesOrder.PaymentFormTxt__c == 'U - Transfêrencia'){
        this.PYMT_METH = 'U';
}   if (salesOrder.PaymentFormTxt__c == 'V - Vendor Operation payment'){
        this.PYMT_METH = 'V';
}
        //this.PYMT_METH = StringHelper.splitPath(salesOrder.PaymentFormTxt__c);
        //this.PYMT_METH = 'A';
        this.PURCH_DATE = OrderDate;
        this.PRICE_DATE = OrderDate;
        this.ZTERM = paymentCondition;
        this.FRETE = 0;
        this.INCOTERMS1 = StringHelper.splitPath(salesOrder.DeliveryOption__c);
        this.INCOTERMS2 = salesOrder.Cidade__c; //INCOTERMS1;
    }
    
    public HeaderSAP(Order salesOrder){
        Datetime d = salesOrder.EffectiveDate;
        String OrderDate = DateTime.newInstance(d.year(),d.month(),d.day()+1).format('yyyy-MM-dd').replace('-', '');
        this.DISTR_CHAN = salesOrder.DistributionChannelFml__c;
        this.DIVISION = salesOrder.ActivitySectorFml__c;
        this.SALES_OFF= salesOrder.SalesOfficeFml__c;
        
        if (salesOrder.RecordTypeId == '0124x000000QigqAAC'){
            this.DOC_TYPE = 'ZVEC';}
        if (salesOrder.RecordTypeId == '0124x000000QigrAAC'){
            this.DOC_TYPE = 'ZVPE';}

        this.ZTERM = 'ZEC1';
        this.PYMT_METH = 'M';
        this.SALES_ORG = salesOrder.SalesOrganizationFml__c;
        this.REQ_DATE_H = OrderDate;
        this.PURCH_NO_C = salesOrder.OrderNumber;
        this.PURCH_DATE = OrderDate;
        this.PRICE_DATE = OrderDate;
    }
}