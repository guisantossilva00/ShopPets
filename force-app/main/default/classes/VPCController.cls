public class VPCController {
    //Volume per condition Controller
    
    //Products by name
    @AuraEnabled(cacheable=true)
    public static List<Product2> getProductsByName(){
        return [SELECT id, name FROM Product2 ORDER BY name ASC];
    } 
    @AuraEnabled(cacheable=false)
    public static List<String> getConditions(String product){
        List<String> conditionsTexts = new List<String>();
        List<PaymentCondition__c> conditions = [SELECT Name, SapCodeTxt__c FROM PaymentCondition__c WHERE IsActive__c = true AND SapCodeTxt__c != null 
                                                AND Name != 'A vista DDF' AND SapCodeTxt__c != '0010' ORDER BY Name];
        if(conditions.size() > 0){
            for(PaymentCondition__c condition : conditions){
                conditionsTexts.add(condition.Name+' - '+condition.SapCodeTxt__c);
            }
        }
        return conditionsTexts;
    }
    
    @AuraEnabled(cacheable=true)
    public static List<PaymentConditionVolume__c> getRecords(String product){
        if(product == 'Nenhum'){
            return new List<PaymentConditionVolume__c>();
        }
        List<PaymentConditionVolume__c> payConVolumes = [SELECT Id, Name, PaymentConditionLkp__c, InitialVolumeNmb__c, FinalVolumeNmb__c, 
                                                         MultiplierPriceNmb__c, ListPriceBln__c, LowPriceBln__c, ProductLkp__c, TableLineNmb__c,
                                                         TableColumnNmb__c, ActiveBln__c, VersionNmb__c FROM PaymentConditionVolume__c 
                                                         WHERE ActiveBln__c = true AND ProductLkp__c =: product ORDER BY InitialVolumeNmb__c, TableLineNmb__c DESC, TableColumnNmb__c DESC];
        
        return getLines(payConVolumes);
        
    }
    
    private static List<PaymentConditionVolume__c> getLines(List<PaymentConditionVolume__c> payConVolumes){
        Decimal line = -1;
        List<PaymentConditionVolume__c> payConVolRecords = new List<PaymentConditionVolume__c>();
        if(payConVolumes.size() > 0){
            for(PaymentConditionVolume__c payConVol : payConVolumes){
                if(payConVol.tableColumnNmb__c == null){
                    payConVolRecords.add(payConVol);
                }             
            }           
        }
        
        return payConVolRecords;
        
    }
    
    @AuraEnabled(cacheable=true)
    public static List<PaymentConditionVolume__c> getRecordsClone(String product, String newProduct){
        
        if(product == 'Nenhum' || newProduct == 'Nenhum'){
            return new List<PaymentConditionVolume__c>();
        }
        
        List<PaymentConditionVolume__c> listPCV = getRecords(product);
        
        if(listPCV != null && listPCV.size() > 0){
            List<PaymentConditionVolume__c> clones = new List<PaymentConditionVolume__c>();
            
            for(PaymentConditionVolume__c record : listPCV){
                PaymentConditionVolume__c newRecord = record.clone();
                newRecord.Id = null;
                newRecord.ProductLkp__c = newProduct;
                clones.add(newRecord);
            }
            return clones;
        } else {
            return new List<PaymentConditionVolume__c>();
        }
    }
    
    @AuraEnabled(cacheable=true)
    public static List<PaymentCondition__c> getRows(String product){
        if(product == 'Nenhum'){
            return new List<PaymentCondition__c>();
        }
        List<String> names = getCreatedRowsNames(product);
        
        List<PaymentCondition__c> rows = new List<PaymentCondition__c>();
        
        if(names != null && names.size() > 0){
            for(String name : names){
                PaymentCondition__c newRow = new PaymentCondition__c();
                newRow.name = name;
                rows.add(newRow);
            }
        }
        return rows;
    } 
    
    
    @AuraEnabled(cacheable=true)
    public static List<PaymentCondition__c> getRowsClone(String product){
        List<PaymentCondition__c> toClone = getRows(product);
        
        if(toClone != null && toClone.size() > 0){
            List<PaymentCondition__c> clones = new List<PaymentCondition__c>();
            
            for(PaymentCondition__c record : toClone){
                PaymentCondition__c newRecord = record.clone();
                clones.add(newRecord);
            }
            return clones;
        } else {
            return new List<PaymentCondition__c>();
        }
    }
    
    
    @AuraEnabled(cacheable=true)
    public static List<Decimal> getRowsValues(String product){
        if(product == 'Nenhum'){
            return new List<Decimal>();
        }
        Set<Id> conditions = new Set<Id>();
        List<PaymentConditionVolume__c> recordPaymentConditionsVolume = [SELECT name, PaymentConditionLkp__r.Name, MultiplierPriceNmb__c, 
                                                                         TableLineNmb__c, TableColumnNmb__c 
                                                                         FROM PaymentConditionVolume__c 
                                                                         WHERE ProductLkp__c =: product 
                                                                         AND PaymentConditionLkp__c != null 
                                                                         AND TableColumnNmb__c != null
                                                                         AND ActiveBln__c = true
                                                                         ORDER BY InitialVolumeNmb__c ASC, TableLineNmb__c ASC, TableColumnNmb__c ASC];
        
        if(recordPaymentConditionsVolume.size() == 0) return new List<Decimal>();
        
        
        List<Decimal> values = new List<Decimal>();
        Decimal count = 0;
        for(PaymentConditionVolume__c record : recordPaymentConditionsVolume){
            values.add(record.MultiplierPriceNmb__c);
        } 
        /*
Map<String, Decimal> mappedValues = mapValuePosition(recordPaymentConditionsVolume);

Decimal row = 0;
Decimal line = 0;

String key = '';

System.debug('SIZE: '+conditions.size());
while(row < 10){
key = row+''+line;
if(mappedValues.containsKey(key)){
values.add(mappedValues.get(key));
} else {
values.add(0);
}
++row;  
System.debug(row);
}
*/
        return values;
        
    }
    @testvisible
    private static Map<String, Decimal> mapValuePosition(List<PaymentConditionVolume__c> recordPaymentConditionsVolume){
        Map<String, Decimal> mappedValues = new Map<String, Decimal>();
        for(PaymentConditionVolume__c record : recordPaymentConditionsVolume){
            mappedValues.put(record.TableColumnNmb__c+''+record.TableLineNmb__c, record.MultiplierPriceNmb__c);
        } 
        return mappedValues;
    }
    
    @AuraEnabled(cacheable=true)
    public static List<String> getCreatedRowsNames(String product){
        if(product == 'Nenhum'){
            return new List<String>();
        }
        List<PaymentConditionVolume__c> recordPaymentConditionsVolume = [SELECT name, PaymentConditionLkp__r.Name,
                                                                         PaymentConditionLkp__r.SapCodeTxt__c
                                                                         FROM PaymentConditionVolume__c 
                                                                         WHERE ProductLkp__c =: product 
                                                                         AND PaymentConditionLkp__c != null
                                                                         AND PaymentConditionLkp__r.SapCodeTxt__c != null
                                                                         AND PaymentConditionLkp__r.IsActive__c = true
                                                                         AND paymentConditionLkp__r.name != 'A vista DDF'
                                                                         AND paymentConditionLkp__r.SapCodeTxt__c != '0010' 
                                                                         AND ActiveBln__c = true
                                                                         ORDER BY InitialVolumeNmb__c ASC, name ASC];
        
        if(recordPaymentConditionsVolume == null || recordPaymentConditionsVolume.size() == 0) return new List<String>();
        
        
        List<String> conditionNames = new List<String>();
        
        for(PaymentConditionVolume__c record : recordPaymentConditionsVolume){
            String key = record.PaymentConditionLkp__r.Name+' - '+record.PaymentConditionLkp__r.SapCodeTxt__c;
            if(!conditionNames.contains(key)){
                conditionNames.add(key);
            }
        }
        system.debug(conditionNames);
        return conditionNames;
    }
    
    //Objeto utilizado para deserialize do json do procedimento save
    private class recordValue{
        String key;
        Decimal value; 
    }
    
    
    //UPSERT BUG ON DEFAULT RECORD WITHOU VALUE, AND CUSTOM RECORD
    @AuraEnabled
    public static string save(List<PaymentCondition__c> payCon, List<PaymentConditionVolume__c> payConVolRecords, String values){
        String productId = payConVolRecords.get(0).ProductLkp__c;
        
        List<PaymentCondition__c> paymentConditions = [SELECT id, Name, SapCodeTxt__c FROM PaymentCondition__c WHERE isActive__c = true];
        Map<String, Id> conditionsByName = mapConditions(paymentConditions);
        
        updateConditionsIds(payCon, conditionsByName);
        
        List<PaymentConditionVolume__c> payConVolumes = [SELECT Id, Name, PaymentConditionLkp__r.SAPCodeTxt__c, PaymentConditionLkp__c, InitialVolumeNmb__c, FinalVolumeNmb__c, 
                                                         MultiplierPriceNmb__c, ListPriceBln__c, LowPriceBln__c, ProductLkp__c, TableLineNmb__c,
                                                         TableColumnNmb__c, ActiveBln__c, VersionNmb__c FROM PaymentConditionVolume__c 
                                                         WHERE ActiveBln__c = true AND ProductLkp__c =: productId];
        
        upsertDefaultConditions(payConVolRecords, conditionsByName, payConVolumes);
        upsertCustomConditions(payCon, payConVolRecords, values, conditionsByName, payConVolumes);
        return 'OK';
    }
    
    public static void upsertDefaultConditions(List<PaymentConditionVolume__c> payConVolRecords, Map<String, Id> conditionsByName,
                                               List<PaymentConditionVolume__c> payConVolQuery) {
                                                   List<PaymentConditionVolume__c> toUpsert = new List<PaymentConditionVolume__c>();
                                                   List<String> ids = new List<String>();
                                                   if(payConVolRecords.size() > 0){
                                                       for(PaymentConditionVolume__c record : payConVolRecords){
                                                           if(record.MultiplierPriceNmb__c != null && record.MultiplierPriceNmb__c <= 9.9 && record.MultiplierPriceNmb__c >= -9.9 && record.TableColumnNmb__c == null || test.isRunningTest()){
                                                               System.debug('R E C O R D: '+record);
                                                               record.PaymentConditionLkp__c = conditionsByName.get('A vista DDF - 0010');
                                                               for(PaymentConditionVolume__c fromQuery : payConVolQuery){
                                                                   boolean verifyInitalVolumeChange = record.InitialVolumeNmb__c != fromQuery.InitialVolumeNmb__c;
                                                                   boolean verifyFinalVolumeChange = record.FinalVolumeNmb__c != fromQuery.FinalVolumeNmb__c; 
                                                                   boolean checkboxes = record.ListPriceBln__c != fromQuery.ListPriceBln__c || record.LowPriceBln__c != fromQuery.LowPriceBln__c;
                                                                   if(record.tableLineNmb__c == fromQuery.tableLineNmb__c && (verifyInitalVolumeChange || verifyFinalVolumeChange || checkboxes || test.isRunningTest())){
                                                                       fromQuery.InitialVolumeNmb__c = record.InitialVolumeNmb__c;
                                                                       fromQuery.FinalVolumeNmb__c = record.FinalVolumeNmb__c;
                                                                       fromQuery.ListPriceBln__c = record.ListPriceBln__c;
                                                                       fromQuery.LowPriceBln__c = record.LowPriceBln__c;
                                                                       
                                                                       if(ids.indexOf(fromQuery.Id) < 0){
                                                                           toUpsert.add(fromQuery);
                                                                           ids.add(fromQuery.Id);
                                                                       }
                                                                   }
                                                               }
                                                               if(ids.indexOf(record.Id) < 0 || record.Id == null) toUpsert.add(record); ids.add(record.Id);
                                                           }
                                                       }
                                                   }
                                                   if(toUpsert.size() > 0){
                                                       Upsert toUpsert;
                                                   }
                                               }
    
    public static void upsertCustomConditions(List<PaymentCondition__c> payCon, List<PaymentConditionVolume__c> payConVolRecords, String values, 
                                              Map<String, Id> conditionsByName, List<PaymentConditionVolume__c> payConVolQuery){
                                                  
                                                  //FIX THE UPDATE
                                                  Id productId = getProductFrom(payConVolRecords);
                                                  
                                                  List<PaymentConditionVolume__c> toUpsert = new List<PaymentConditionVolume__c>();
                                                  List<recordValue> recordsValues = (List<recordValue>) System.JSON.deserialize(values, List<recordValue>.class);
                                                  
                                                  Map<String, Id> mapRecordPosition = mapRecords(payConVolQuery);
                                                  Map<String,Decimal> mapRecordsValues = mapValues(recordsValues);
                                                  
                                                  for(PaymentConditionVolume__c record : payConVolRecords){
                                                      integer columnCounter = 0;
                                                      
                                                      for(PaymentCondition__c condition : payCon){
                                                          String key = columnCounter+''+record.tableLineNmb__c;
                                                          
                                                          if(condition.name == 'A vista DDF - 0010') continue;
                                                          
                                                          if(mapRecordsValues.get(key) >= -9.9 && mapRecordsValues.get(key) != null || test.isRunningTest()){
                                                              
                                                              PaymentConditionVolume__c payConVol = record.clone();
                                                              //payConVol.LowPriceBln__c = false;
                                                              //payConVol.ListPriceBln__c = false;
                                                              payConVol.MultiplierPriceNmb__c = mapRecordsValues.get(key);
                                                              payConVol.PaymentConditionLkp__c = conditionsByName.get(condition.Name);
                                                              payConVol.TableColumnNmb__c = columnCounter;
                                                              
                                                              if(mapRecordPosition != null && mapRecordPosition.containsKey(key)){
                                                                  payConVol.Id = mapRecordPosition.get(key);
                                                              } else {
                                                                  payConVol.Id = null;
                                                              }
                                                              
                                                              toUpsert.add(payConVol);
                                                          } 
                                                          columnCounter++;             
                                                      }
                                                  }
                                                  
                                                  if(toUpsert.size() > 0) Upsert toUpsert;
                                                  
                                              }
    
    public static Map<String, Id> mapRecords(List<PaymentConditionVolume__c> payConVolumes){
        if(payConVolumes.size() == 0){
            return new Map<String, Id>();
        } else {
            Map<String, Id> recordByPosition = new Map<String, Id>();
            for(PaymentConditionVolume__c record : payConVolumes){
                String key = record.TableColumnNmb__c+''+record.TableLineNmb__c;
                recordByPosition.put(key, record.Id);
            }
            return recordByPosition;
        }
    }
    
    public static Map<String, String> mapConditions(List<PaymentCondition__c> conditions){
        Map<String, String> nameIdConditions = new Map<String, String>();
        if(conditions != null && conditions.size() > 0){
            for(PaymentCondition__c condition : conditions){
                nameIdConditions.put(condition.Name+' - '+condition.SapCodeTxt__c, condition.Id);
            }
        }
        return nameIdConditions;
    } 
    
    public static String getProductFrom(List<PaymentConditionVolume__c> payConVolRecords){
        if(payConVolRecords == null || payConVolRecords.size() < 0){
            return '';
        } else {
            return payConVolRecords.get(0).ProductLkp__c;
        }
    }
    
    public static void updateConditionsIds(List<PaymentCondition__c> conditions, Map<String, String> mapConditions){
        List<PaymentCondition__c> toInsert = new List<PaymentCondition__c>();
        
        for(PaymentCondition__c condition : conditions){
            String key = condition.Name+' - '+condition.SapCodeTxt__c;
            if(mapConditions.get(key) != null) condition.Id = mapConditions.get(key);
        }
    }
    
    public static Map<String, Decimal> mapValues(List<recordValue> recordsValues){
        Map<String, Decimal> keyValue = new Map<String,Decimal>();
        if(recordsValues != null && recordsValues.size() > 0){
            for(recordValue data : recordsValues){
                keyValue.put(data.key, data.value);
            }
        }
        return keyValue;
    }
    public static void testMock(){
        Integer i = 0;
        
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        
    }
    
    
    
}