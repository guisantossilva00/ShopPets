public class OrderTriggerHandler {
    
    public static void setStatus(){
        String recordTypeB2B = Schema.SObjectType.Order.getRecordTypeInfosByName().get('B2B').getRecordTypeId();
        for (Order order : (List<Order>) Trigger.new) {
            boolean sameRecordType = order.RecordTypeId == recordTypeB2B;
            if(order.Status == 'WP' && sameRecordType){
                order.Status = 'Pagamento pendente';
            } else if(order.Status == 'PC' && sameRecordType){
                order.Status = 'Pagamento aprovado';
            }
        }
    }
    
    public static void orderSAP(){
        List<Order> ordersNew = (List<Order>) trigger.new; 
        Map<id, Order> oldMapOrders = (Map<id, Order>) trigger.oldMap;
        String recordTypeSales = Schema.SObjectType.Order.getRecordTypeInfosByName().get('Sales').getRecordTypeId();
        String recordTypeB2B = Schema.SObjectType.Order.getRecordTypeInfosByName().get('B2B').getRecordTypeId();
        
        for (Order orderRecord : ordersNew) {
            if(orderRecord.TotalAmount == 0) continue;
            
            boolean diff = oldMapOrders.get(orderRecord.id).Status != orderRecord.Status;			
            if(orderRecord.Status == 'Finalizado' && diff && orderRecord.RecordTypeId == recordTypeSales){
                IntegrationSAP.buildData(orderRecord);
            }
            if(orderRecord.Status == 'Pagamento aprovado' && diff && orderRecord.RecordTypeId == recordTypeB2B) IntegrationSAP.buildDataCommerce(orderRecord);
        }
    }
    
    public static void orderStatusUpdateSAP(){
        List<Order> ordersNew = (List<Order>) trigger.new; 
        //String recordTypeCommerce = Schema.SObjectType.Order.getRecordTypeInfosByName().get('B2B').getRecordTypeId();
        //String recordTypeSales = Schema.SObjectType.Order.getRecordTypeInfosByName().get('Sales').getRecordTypeId();
        
        Map<id, Order> oldMapOrders = (Map<id, Order>) trigger.oldMap;
        for (Order orderRecord : ordersNew) {
            boolean IsStatusChange = oldMapOrders.get(orderRecord.id).Status != orderRecord.Status;
            system.debug('OrderNumberTXT: ' + orderRecord.OrderNumberTxt__c);
            if(!String.isBlank(orderRecord.OrderNumberTxt__c)){
                if(orderRecord.Status == 'Cancelado' && IsStatusChange) IntegrationSAP.sendOrderStatus('{"OrderNumberTxt" : "'+orderRecord.OrderNumberTxt__c+'" , "Status" : "CANCELADO"}');
            }
        }
    }
}