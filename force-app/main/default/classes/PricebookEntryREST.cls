@RestResource(urlMapping='/UISA/PricebookEntry/')
global with sharing class PricebookEntryREST {
    
    @HttpPatch
    global static void doPatch(Boolean allOrNone, List<PricebookEntry> records){
        RestRequest restReq = RestContext.request;
        RestResponse restRes = RestContext.response;
        RestContext.response.addHeader('Content-Type', 'application/json');
		
        Map<String, String> mappedSapIds = new Map<String, String>();
        List<PricebookEntry> toInsert = new List<PricebookEntry>();
        List<PricebookEntry> toUpdate = new List<PricebookEntry>();
        String json;
        try{
            List<PricebookEntry> inserteds = getInserteds(records);
            if(inserteds.size() > 0){
                mappedSapIds = mapIds(inserteds);
            }
            for(PricebookEntry record : records){
                if(mappedSapIds.containsKey(record.SAPCodeTxt__c)){
                    record.Id = mappedSapIds.get(record.SAPCodeTxt__c);
                    toUpdate.add(record);
                } else {
					toInsert.add(record);
                }   
            }
            Database.SaveResult [] databaseResult = Database.insert(toInsert, allOrNone);
            databaseResult.addAll(Database.update(toUpdate, allOrNone));
            json = System.JSON.serialize(databaseResult);
        } catch(exception e){
            json = System.JSON.serialize(e.getMessage());
        }            
        restRes.responseBody = Blob.valueOf(json);
    }
    
    @TestVisible
    private static List<PricebookEntry> getInserteds(List<PricebookEntry> records){
        Set<String> sapCodes = new Set<String>();
        for(PricebookEntry record : records){
            sapCodes.add(record.SAPCodeTxt__c);
        }
        return [SELECT id, SapCodeTxt__c 
                FROM PricebookEntry 
                WHERE SapCodeTxt__c IN : sapCodes AND SapCodeTxt__c != null AND SapCodeTxt__c != ''];
    }
    
    @TestVisible
    private static Map<String, String> mapIds(List<PricebookEntry> entries){
        Map<String, String> mappedSapIds = new Map<String, String>();
        for(PricebookEntry entry : entries){
            mappedSapIds.put(entry.SapCodeTxt__c, entry.Id);
        }
        return mappedSapIds;
    }
}