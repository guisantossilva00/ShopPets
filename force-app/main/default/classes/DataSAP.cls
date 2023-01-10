global class DataSAP {

    public HeaderSAP HEADER {get;set;}
    public ParceirosSAP PARTNERS {get;set;}
    public List<ItemSAP> ITEM {get;set;}
        
    public dataSAP(HeaderSAP header, ParceirosSAP parceiros, List<ItemSAP> item){
        this.HEADER = header;
        this.PARTNERS = parceiros;
        this.ITEM = item;
    }
}