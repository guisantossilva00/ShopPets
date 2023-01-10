//Order generation sugar controller 
public class ogSugarController {
    
    //Lista de Opções de Entrega(Frete)
    @AuraEnabled(cacheable=true)
    public static List<String> getDeliveryOption(){
        Schema.DescribeFieldResult options = Order.DeliveryOption__c.getDescribe();
        List<Schema.PicklistEntry> optionValues = options.getPicklistValues();
        List<String> allOptions = new List<String>();
        for(Schema.PicklistEntry pick : optionValues){
            //Solicitado pela UISA para fixar apenas CIF e FOB
            if(pick.value.contains('CIF') || pick.value.contains('FOB')){
                allOptions.add(pick.value);
            }
        }
        return allOptions;
    }
    
    @AuraEnabled(cacheable=false)
    //Lista de opções de pagamento
    public static List<PaymentCondition__c> getPaymentOption(Id team, Id customer){
        List<PaymentCondition__c> lstpaymentSelect = [SELECT id, name, isActive__c, SAPCodeTxt__c FROM PaymentCondition__c WHERE isActive__c = true ORDER BY Name ASC];
        if(lstpaymentSelect.size() > 0){
            return lstpaymentSelect;               
        }
        return new List<PaymentCondition__c>();
        /*
        RepresentativeAccess representative = new RepresentativeAccess();
        return representative.getConditions(team, customer);
        */
    }
    
    @AuraEnabled(cacheable=false)
    public static List<SalesTeam__c> getTeams(Id customer){
        RepresentativeAccess representative = new RepresentativeAccess();
        return representative.getTeams(customer);
    }
    
    @AuraEnabled(cacheable=false)
    public static List<SalesArea__c> getAreas(Id customer, Id condition, Id team){
        RepresentativeAccess representative = new RepresentativeAccess();
        return representative.getAreas(customer, condition, team);
    }
    
    //Get records with user permissions/access
    private with sharing class RepresentativeAccess{
        
        public List<PaymentCondition__c> getConditions(Id team, Id customer){
            List<SalesArea__c> areas = [SELECT PaymentConditionLkp__c FROM SalesArea__c WHERE PaymentConditionLkp__c != null AND SalesTeamLkp__c =: team AND customerLkp__c =: customer];
            if(areas.size() > 0){
                Set<String> conditionsIds = new Set<String>();
                for(SalesArea__c area : areas){
                    conditionsIds.add(area.PaymentConditionLkp__c);
                }
                List<PaymentCondition__c> lstpaymentSelect = [SELECT id, name, isActive__c, SAPCodeTxt__c FROM PaymentCondition__c WHERE isActive__c=true 
                                                              AND id IN : conditionsIds ORDER BY Name ASC];
                if(lstpaymentSelect.size() > 0){
                    return lstpaymentSelect;               
                }
            }
            return new list <PaymentCondition__c>();
        }
        
        public List<SalesTeam__c> getTeams(Id customer){
            List<SalesArea__c> areas = [SELECT SalesTeamLkp__c FROM SalesArea__c WHERE customerLkp__c =: customer];
            if(areas.size() > 0){
                Set<String> teamsIds = new Set<String>();
                for(SalesArea__c area : areas){
                    teamsIds.add(area.SalesTeamLkp__c);
                }
                List<SalesTeam__c> teams = [SELECT Id, Name, SapCodeTxt__c FROM SalesTeam__c WHERE IsActive__c = true  
                                            AND Id IN : teamsIds ORDER BY Name ASC];
                if(teams.size() > 0){
                    return teams;
                }
            }
            return new List<SalesTeam__c>();
        } 
        
        public List<SalesArea__c> getAreas(Id customer, Id condition, Id team){
            List<SalesArea__c> areas = [SELECT Id, Name, SapCodeTxt__c FROM SalesArea__c WHERE CustomerLkp__c =: customer 
                                        AND SalesTeamLkp__c =: team 
                                        /*AND PaymentConditionLkp__c =:  condition*/ 
                                        AND IsActive__c = true 
                                        AND (ActivitySectorTxt__c = '10' 
                                             OR ActivitySectorTxt__c = '80'
                                             OR ActivitySectorTxt__c = '90')
                                        ORDER BY Name ASC];
            if(areas.size() > 0){
                System.debug(areas);
                return areas;
            }
            return new List<SalesArea__c>();        
        } 
    }
    
    // Verificar se faz parte da ação de vendas
    @AuraEnabled(cacheable=false)
    public static List<boolean> hasSalesActions(List<Product2> products){
        if(products == null || products.size() == 0){
            return new List<boolean>{false};
                }   
        
        List<boolean> marked = new List<boolean>();
        List<String> productsIds = new List<String>();
        
        for(Product2 product : products){
            productsIds.add(product.Id);    
        }
        
        List<SalesActionItems__c> itens = [SELECT id, ProductLkp__c FROM SalesActionItems__c WHERE ProductLkp__c IN : productsIds 
                                           AND SalesAction__c != null AND SalesAction__r.EndDateDte__c != null AND SalesAction__r.EndDateDte__c >= TODAY];
        
        if(itens != null && itens.size() > 0){
            for(Product2 product : products){
                boolean mark = false;
                for(SalesActionItems__c item : itens){
                    if(item.ProductLkp__c == product.Id){
                        mark = true;
                        break;
                    }
                }
                marked.add(mark);
            }
            return marked;
        }
        return new List<boolean>{false};
            }
    
    //Salvar o Pedido
    @AuraEnabled(cacheable=false)
    public static String save(Order order){
        
        String recordTypeId = Schema.SObjectType.Order.getRecordTypeInfosByName().get('Sales').getRecordTypeId();
        System.debug('Order:' + order);
        if(order != null){
            
            order.Pricebook2Id = [SELECT Id FROM Pricebook2 WHERE IsStandard = true].Id;
            order.Status = 'Rascunho';
            order.EffectiveDate = System.Today();
            if(order.RecordTypeId != recordTypeId){
                order.RecordTypeId = recordTypeId;
            }
            if(order.Id != null){
                Update order;
            } else {
                Insert order;
            }
            return order.Id;
        }
        return order.Id;
    }
    
    //Salvar os itens do Pedido
    @AuraEnabled(cacheable=false)
    public static List<String> saveOrderItens(Order salesOrder, List<OrderItem> orderItens, String orderStatus){
        System.debug('ok');
        List<String> orderItemsIds = new List<String>();
        Set<String> productsIds = new Set<String>();
        String orderName = '';
        String orderPricebook = '';
        if(salesOrder != null && salesOrder.Id != null){
            if(salesOrder.Pricebook2Id != null){
                orderPricebook = salesOrder.Pricebook2Id;
            } else {
                orderPricebook = [SELECT Id FROM Pricebook2 WHERE IsStandard = true].Id;
            }
            System.debug('ITENS: '+orderItens);
            if(orderItens != null){
                for(OrderItem item : orderItens){
                    productsIds.add(item.Product2Id);
                    System.debug('ORDER ID: '+salesOrder.Id);
                }
                Map<String, String> mappedEntries = mapPricebookEntry(productsIds, orderPricebook);
                List<OrderItem> toInsert = new List<OrderItem>();
                List<OrderItem> toUpdate = new List<OrderItem>();
                
                for(OrderItem item : orderItens){
                    if(item.Id != null && item.OrderId != null){
                        toUpdate.add(item);
                    } else {
                        if(mappedEntries.containsKey(item.Product2Id)){
                            OrderItem newItem = new OrderItem(OrderId = salesOrder.Id, PricebookEntryId = mappedEntries.get(item.Product2Id));
                            newItem.Account__c = item.Account__c;
                            newItem.DateShipmentDte__c = item.DateShipmentDte__c;
                            newItem.Product2Id = item.Product2Id;
                            newItem.Quantity = item.Quantity;
                            newItem.TotalNmb__c = item.TotalNmb__c;
                            newItem.UnitPrice = item.UnitPrice;
                            newItem.DiscountNmb__c = item.DiscountNmb__c;
                            newItem.SalesContractNmb__c = item.SalesContractNmb__c;
                            item = newItem;
                            toInsert.add(item);
                        } else {
                            throw new CustomException('Para criar um pedido é necessário que todos os produtos dos itens do pedido estejam no catálogo padrão de preço.');
                        }
                    }
                }
                Insert toInsert;
                Update toUpdate;
                for(OrderItem item : toUpdate){
                    orderItemsIds.add(item.Id);
                }
                for(OrderItem item : toInsert){
                    orderItemsIds.add(item.Id);
                }
                if(orderStatus == 'Finalizado'){
                    salesOrder.status = 'Finalizado';
                    salesOrder.isActive__c = true;
                    Update salesOrder;
                }
                System.debug('ALL ITENS: '+orderItemsIds);
                return orderItemsIds;
            }
            System.debug('ORDER ID: '+salesOrder.Id);
        }
        return orderItemsIds;
    }
    
    private class CustomException extends Exception{}
    
    @testVisible
    private static Map<String, String> mapPricebookEntry(Set<String> productsIds, String pricebook){
        System.debug('IDS MAP: '+productsIds);
        System.debug(pricebook);
        List<PricebookEntry> entries = [SELECT id, Product2Id FROM PricebookEntry WHERE Product2Id IN : productsIds AND Pricebook2Id =: pricebook];
        System.debug('ENTRIES: '+entries);
        Map<String, String> mappedEntries = new Map<String, String>();
        for(PricebookEntry entry : entries){
            mappedEntries.put(entry.Product2Id, entry.Id);
        }
        return mappedEntries;
    }
    
    @AuraEnabled(cacheable=false)
    public static void deleteOrderItem(String orderItemId){
        List<OrderItem> itens = [SELECT id FROM OrderItem WHERE id =: orderItemId];
        if(itens != null && itens.size() > 0){
            Delete itens; 
        }
    }
    
    @AuraEnabled(cacheable=false)
    public static void deleteOrder(String orderId){
        List<Order> item = [SELECT id from Order WHERE id =: orderId];
        if(item != null && item.size() > 0){
            List<OrderItem> itens = [SELECT Id FROM OrderItem WHERE OrderId =: orderId];
            if(itens != null && itens.size() > 0){
                Delete itens; 
            }
            Delete item;
        }
    }
    
    @AuraEnabled(cacheable=false)
    public static String getOrderName(String id){
        System.debug('ENTER GETORDERNAME');
        List<Order> orderRecord = [SELECT id, OrderNumber FROM Order WHERE id =: id];
        
        System.debug('ORDER: '+orderRecord);
        if(orderRecord != null && orderRecord.size() > 0){
            return orderRecord.get(0).OrderNumber;
        } else {
            return '';
        }
    }
    
    @AuraEnabled(cacheable=false)
    public static Decimal getTableValue(String customerDomicile, Id productId, Id salesAreaId, Id paymentConditionId, Decimal quantity){
        return PriceCalculationHelperREST.doPost(customerDomicile, productId, salesAreaId, paymentConditionId, quantity);
    } 
    
    @AuraEnabled(cacheable=true)
    public static List<Contract> getAllContractValues(String id){
        return [SELECT id, ProductLkp__c /*,ContractValeuNmb__c*/ FROM Contract 
                WHERE AccountId =: id AND status = 'Activated' AND EndDate >= TODAY];
    } 
    
    
    @AuraEnabled(cacheable=false)
    public static List<Product2> getProduct(String area){
        System.debug(area);
        List<SalesArea__c> areas = [SELECT ActivitySectorTxt__c FROM SalesArea__c WHERE id =: area];
        String sector = 'NA';
        if(areas.size() > 0){
            sector = areas.get(0).ActivitySectorTxt__c;
        }
        List<ProductsAvailable__c> products = [SELECT Id, ProductLkp__c, ProductLkp__r.SapCodeTxt__c, ActivitySectorTxt__c, ProductLkp__r.Name, 
                                               ProductLkp__r.ProductCode, ProductLkp__r.BasicUnitTxt__c FROM ProductsAvailable__c 
                                               WHERE IsActive__c = TRUE AND ProductLkp__r.IsActive = TRUE 
                                               AND ActivitySectorTxt__c =: sector 
                                               AND ProductLkp__r.SapCodeTxt__c != null 
                                               AND customIdTxt__c != null Order by ProductLkp__c ASC];
        if(products.size() == 0){
            return new List<Product2>();
        }
        List<Product2> allproducts = new List<Product2>();
        Set<String> sapCodes = new Set<String>();
        for(ProductsAvailable__c available : products){
            if(!sapCodes.contains(available.ProductLkp__r.SapCodeTxt__c)){
                Product2 product = new Product2();
                product.Name = available.ProductLkp__r.Name;
                product.SapCodeTxt__c = available.ProductLkp__r.SapCodeTxt__c;
                product.Id = available.ProductLkp__c;
                product.BasicUnitTxt__c = getBasicUnitLabel(available.ProductLkp__r.BasicUnitTxt__c);
                allproducts.add(product);
                sapCodes.add(available.ProductLkp__r.SapCodeTxt__c);
            }
        }
        
        return allproducts;
    } 
    
    private static String getBasicUnitLabel(String basicUnit){
        if(!String.isBlank(basicUnit)){
            Schema.DescribeFieldResult options = Product2.BasicUnitTxt__c.getDescribe();
            List<Schema.PicklistEntry> optionValues = options.getPicklistValues();
            for(Schema.PicklistEntry pick : optionValues){
                if(pick.value == basicUnit){
                    return pick.label;
                }
            }
        }
        return '';
    }
    
    @AuraEnabled(cacheable=false)
    public static Account getAccount(String id){
        return [SELECT id, Name__c, isActive__c, SAPCodeTxt__c, TaxDomicileTxt__c FROM Account WHERE id =: id];
    } 
    
    
    @AuraEnabled(cacheable=false)
    public static List<ContactPointAddress> getAddresses(String accountId){
        List<ContactPointAddress> addresses = [SELECT id, State, City, Country, Name FROM ContactPointAddress 
                                               WHERE ParentId =: accountId AND AddressType = 'Shipping' AND IsPrimary = true AND IsDefault = true ORDER BY State ASC];
        
        if(addresses == null || addresses.size() == 0){
            return new List<ContactPointAddress>();
        }
        return addresses;
    } 
    
}