public with sharing class IntegrationSAP {
    @testVisible
    public static void buildDataCommerce(Order sapOrder){
        HeaderSAP order = new HeaderSAP(sapOrder);
        Account customer = getCustomer(sapOrder);
        
        if(customer == null) return;
        
        List<OrderItem> orderItems = getItems(sapOrder);
        
        if(customer != null && orderItems != null){
            ParceirosSAP parceiros = new ParceirosSAP(customer);
            List<ItemSAP> items = new List<ItemSAP>();
            for(OrderItem orderItem : orderItems){
                if(orderItem.Product2.Name != 'Taxa de Entrega'){
                    ItemSAP item = new ItemSAP(orderItem);
                    items.add(item);
                } else {
                    order.FRETE = orderItem.UnitPrice;
                    if(orderItem.UnitPrice == 0){
                        order.INCOTERMS1 = 'FOB'; 
                        order.INCOTERMS2 = 'FOB';
                    } else {
                        order.INCOTERMS1 = 'CIF';
                        order.INCOTERMS2 = 'CIF';
                    }
                }
            }
            DataSAP data = new DataSAP(order, parceiros, items);
            String json = JSON.serialize(data);
            System.debug(json);
            sendJSON(json, sapOrder.Id);
        }
    }
    @testVisible
    public static void buildData(Order sapOrder){
        
        String SalesTeamLkp = '';
        String paymentCondition = '';
        
        if(!String.isBlank(sapOrder.paymentCondition__c)){
            paymentCondition = [SELECT SAPCodeTxt__c from paymentCondition__c WHERE id =: sapOrder.paymentCondition__c].SAPCodeTxt__c;
        }
        
        if(!String.isBlank(sapOrder.SalesTeamLkp__c)){
            SalesTeamLkp = [SELECT SAPCodeTxt__c from SalesTeam__c WHERE id =: sapOrder.SalesTeamLkp__c].SAPCodeTxt__c;
        }
        
        HeaderSAP order = new HeaderSAP(sapOrder, SalesTeamLkp, paymentCondition);
        
        Account customer = getCustomer(sapOrder);
        List<OrderItem> orderItems = getItems(sapOrder);
        Map<String, ProductsAvailable__c> mappedAvailables = getProductAvailables(orderItems);

        
        if(customer != null && orderItems != null && mappedAvailables != null){
            ParceirosSAP parceiro = new ParceirosSAP(customer);
            List<ItemSAP> items = new List<ItemSAP>();
            for(OrderItem orderItem : orderItems){
                ItemSAP item = new ItemSAP(orderItem, mappedAvailables.get(orderItem.Product2Id));
                items.add(item);
            }
            DataSAP data = new DataSAP(order, parceiro, items);
            String json = JSON.serialize(data);
            System.debug(json);
            sendJSON(json, sapOrder.Id);
        }
    }
    
    @testVisible
    private static List<OrderItem> getItems(Order sapOrder){
        return [SELECT Product2Id, Product2.Name, Product2.SAPCodeTxt__c, quantity, Unitprice 
                FROM OrderItem WHERE OrderId =: sapOrder.Id];
    }
    
    @testVisible
    private static Map<String, ProductsAvailable__c> getProductAvailables(List<OrderItem> items){
        Set<String> productsIds = new Set<String>();
        Map<String, ProductsAvailable__c> mappedAvailable = new Map<String, ProductsAvailable__c>();
        
        for(OrderItem item : items){
            productsIds.add(item.Product2Id);
        }
        
        List<ProductsAvailable__c> availables = [SELECT ProductLkp__c, SupplierCenterLkp__r.SapCodeTxt__c 
                                                 FROM ProductsAvailable__c WHERE ProductLkp__c IN : productsIds];
        if(availables.size() > 0){
            for(ProductsAvailable__c available : availables){
                mappedAvailable.put(available.ProductLkp__c, available);
            }
            return mappedAvailable;
        }
        return null;
    }
    
    @testVisible
    private static Account getCustomer(Order sapOrder){
        List<Account> customer = [SELECT SapCodeTxt__c FROM Account WHERE id =: sapOrder.AccountId 
                                  AND isActive__c = true];    
        if(customer.size() > 0){
            return customer.get(0);
        } 
        return null;
    }
    
    
    @future(callout=true)
    public static void sendJSON(String json, Id orderId){
        String endpoint = '';
        String username = '';
        String password = '';
        Boolean isSandbox = [SELECT isSandbox FROM Organization].isSandbox;
         if(isSandbox){
            endpoint = 'https://qasapsf.uisa.com.br:50001/RESTAdapter/SalesOrder';
            username = 'interfacepo';
            password = 'Uisa@2021';
        } else {
            endpoint = 'https://prdsapsf.uisa.com.br:50001/RESTAdapter/SalesOrder';
            username = 'interfacepo';
            password = 'Tnk@Ui2022PUP';
        }
        HttpRequest req = new HttpRequest();
        req.setEndpoint(endpoint);
        req.setBody(json);
        req.setMethod('POST');
        Blob headerValue = Blob.valueOf(username + ':' + password);
        String authorizationHeader = 'Basic ' +EncodingUtil.base64Encode(headerValue);
        req.setHeader('Authorization', authorizationHeader);
        req.setHeader('Content-Type', 'application/json');
        //Execute web service call here     
        Http http = new Http();
        HTTPResponse res = http.send(req);
        setNumberOrder(orderId, res.getBody());   
    }
    
    @future(callout=true)
    public static void sendOrderStatus(String json){
        HttpRequest req = new HttpRequest();
        String endpoint = '';
        String username = 'interfacepo';
        String password = 'Uisa@2021';
        Boolean isSandbox = [SELECT isSandbox FROM Organization].isSandbox;
        if(isSandbox){
            endpoint = 'https://qasapsf.uisa.com.br:50001/RESTAdapter/StatusOrder';
            username = 'interfacepo';
            password = 'Uisa@2021';
        } else {
            endpoint = 'https://prdsapsf.uisa.com.br:50001/RESTAdapter/SalesOrder';
            username = 'interfacepo';
            password = 'Tnk@Ui2022PUP';
        }
        req.setEndpoint(endpoint);
        req.setBody(json);
        req.setMethod('POST');
        
        
        Blob headerValue = Blob.valueOf(username + ':' + password);
        String authorizationHeader = 'Basic ' +EncodingUtil.base64Encode(headerValue);
        req.setHeader('Authorization', authorizationHeader);
        req.setHeader('Content-Type', 'application/json');
        Http http = new Http();
        HTTPResponse res = http.send(req);
    }

    public class SapResponse{
        public String VBELN {get;set;}
        public String MESSAGE {get;set;}
    }

    public static void setNumberOrder(Id orderId, String body){
        body = body.replace('{"return":', '');
        body = body.replace('}}', '}');
        SapResponse response = (SapResponse) JSON.deserialize(body, SapResponse.class);
        System.debug(response);
        Order salesOrder = [SELECT id, OrderNumberTxt__c from Order WHERE id =: orderId limit 1];
        salesOrder.OrderNumberTxt__c = response.VBELN;
        salesOrder.MessageSAPTxt__c = response.MESSAGE;
        System.debug(salesOrder);
        Update salesorder;
    }
}