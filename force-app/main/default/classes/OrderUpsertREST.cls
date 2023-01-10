@RestResource(urlMapping='/Order')
global class OrderUpsertREST {
    
    @HttpPatch
    global static void doPatch(Boolean allOrNone, List<Order> records){
        RestRequest restReq = RestContext.request;
        RestResponse restRes = RestContext.response;
        RestContext.response.addHeader('Content-Type', 'application/json');

        Database.UpsertResult [] upsertResults = Database.upsert(records, Order.CustomIdTxt__c, allOrNone);
        restRes.responseBody = Blob.valueOf(System.JSON.serialize(upsertResults));
    }
}