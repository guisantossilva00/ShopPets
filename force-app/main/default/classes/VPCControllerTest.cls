@isTest(seeAllData = true)
public class VPCControllerTest {
    
    @isTest
    public static void testMock(){
    	VPCController.testMock();    
    }
    
    private static void buildProduct(){
        Product2 first = new Product2();
        first.name = 'First Product in Test';
        first.SAPCodeTxt__c = '001';
        first.IsActive = true;
        
        Product2 second = new Product2();
        second.name = 'Second Product in Test';
        second.SAPCodeTxt__c = '001';
        second.IsActive = true;
    }
    
    private static void buildConditions(){
        PaymentCondition__c aVista = new PaymentCondition__c();
        aVista.name = 'A vista DDF - 0010';
        aVista.SAPCodeTxt__c = '1020';
        aVista.isActive__c = true;
        Insert aVista;
        
        PaymentCondition__c parcelado = new PaymentCondition__c();
        parcelado.name = 'Parcelado';
        Insert parcelado;
    }
    
    private static void buildVolumeConditions(String product, String payCondition){
        PaymentConditionVolume__c first = new PaymentConditionVolume__c();
        first.Name = 'A vista DDF - 0010';
        first.InitialVolumeNmb__c = 1;
        first.FinalVolumeNmb__c = 2;
        first.ListPriceBln__c = false; 
        first.LowPriceBln__c = false;
        first.MultiplierPriceNmb__c = 8;
        first.ProductLkp__c = product;
        first.PaymentConditionLkp__c = payCondition;
        
        PaymentConditionVolume__c second = new PaymentConditionVolume__c();
        second.Name = 'Payment Condition - 2';
        second.InitialVolumeNmb__c = 3;
        second.FinalVolumeNmb__c = 4;
        second.ListPriceBln__c = false; 
        second.LowPriceBln__c = false;
        second.MultiplierPriceNmb__c = 7;
        second.ProductLkp__c = product;
        second.PaymentConditionLkp__c = payCondition;
    }
    
    @isTest
    public static void getProductsByName(){
        Test.startTest();
        buildProduct();
        List<Product2> products = VPCController.getProductsByName();
        Test.stopTest();
    }
    
    @isTest
    public static void getRecords(){
        buildProduct();
        List<PaymentConditionVolume__c> payConditions = VPCController.getRecords('Nenhum');
        System.assertEquals(0, payConditions.size(), 'A instância da lista não pode conter elementos.');
        
        List<Product2> product = VPCController.getProductsByName();
        List<PaymentConditionVolume__c> payConVolumes = [SELECT name, PaymentConditionLkp__r.Name, MultiplierPriceNmb__c, 
                                                         TableLineNmb__c, TableColumnNmb__c 
                                                         FROM PaymentConditionVolume__c 
                                                         WHERE ProductLkp__c =: product 
                                                         AND PaymentConditionLkp__c != null 
                                                         AND TableColumnNmb__c != null
                                                         AND ActiveBln__c = true
                                                         ORDER BY InitialVolumeNmb__c ASC, TableLineNmb__c ASC, TableColumnNmb__c ASC];
    }
    
    @isTest
    public static void getRecordsSecondCheck(){
        //Check all the rest 
        Test.startTest();
        
        buildProduct();
        buildConditions();
        
        List<Product2> products = VPCController.getProductsByName();
        Product2 usedProduct = products.get(0);
        
        List<PaymentCondition__c> conditions = [SELECT id, name FROM PaymentCondition__c WHERE name = 'Parcelado'];
        PaymentCondition__c parcelado = conditions.get(0);
        
        conditions = [SELECT id, name FROM PaymentCondition__c WHERE name = 'A vista DDF - 0010'];
        PaymentCondition__c aVista = conditions.get(0);
        
        buildVolumeConditions(usedProduct.Id, parcelado.Id);
        buildVolumeConditions(usedProduct.Id, aVista.Id);
        
        List<PaymentConditionVolume__c> payConditionsVol = VPCController.getRecords(usedProduct.Id);
        System.debug('OBS: '+payConditionsVol);
        
        List<PaymentConditionVolume__c> updateToTest = [SELECT id, name, InitialVolumeNmb__c, FinalVolumeNmb__c
                                                        FROM PaymentConditionVolume__c WHERE PaymentConditionLkp__r.name = 'Parcelado'];
        
        for(PaymentConditionVolume__c record : updateToTest){
            record.InitialVolumeNmb__c = record.InitialVolumeNmb__c - 1;
            record.FinalVolumeNmb__c = record.FinalVolumeNmb__c - 1;
        }
        
        Update updateToTest;
        
        payConditionsVol = VPCController.getRecords(usedProduct.Id);
        
        for(PaymentConditionVolume__c record : updateToTest){
            record.InitialVolumeNmb__c = record.InitialVolumeNmb__c + 2;
            record.FinalVolumeNmb__c = record.FinalVolumeNmb__c + 2;
        }
        Update updateToTest;
        
        payConditionsVol = VPCController.getRecords(usedProduct.Id);
        
        Test.stopTest();
    }
    
    @isTest
    public static void getRecordsClone(){
        Test.startTest();
        
        List<PaymentConditionVolume__c> payConditionsVol = VPCController.getRecordsClone('Nenhum', 'Nenhum');
        System.assertEquals(0, payConditionsVol.size(), 'A instância da lista não pode conter elementos.');
        
        buildProduct();
        
        List<Product2> products = VPCController.getProductsByName();
        Product2 cloneProduct = products.get(0);
        Product2 toProduct = products.get(1);
        
        payConditionsVol = VPCController.getRecordsClone(cloneProduct.Id, toProduct.Id);
        
        buildConditions();
        
        List<PaymentCondition__c> payConditions = [SELECT id, name FROM PaymentCondition__c WHERE name = 'Parcelado'];
        PaymentCondition__c parcelado = payConditions.get(0);
        
        payConditions = [SELECT id, name FROM PaymentCondition__c WHERE name = 'A vista DDF - 0010'];
        PaymentCondition__c aVista = payConditions.get(0);
        
        buildVolumeConditions(cloneProduct.Id, parcelado.Id);
        buildVolumeConditions(cloneProduct.Id, aVista.Id);
        payConditionsVol = VPCController.getRecordsClone(cloneProduct.Id, toProduct.Id);
        
        buildProduct();
        
        Test.stopTest();
    }
    
    @isTest
    public static void getCreatedRowsNames(){
        Test.startTest();
        
        List<String> conditionNames = VPCController.getCreatedRowsNames('Nenhum');
        System.assertEquals(0, conditionNames.size(), 'A instância da lista de nomes de condições não pode conter registros.');
        
        buildProduct();
        
        List<Product2> products = VPCController.getProductsByName();
        Product2 product = products.get(0);
        
        buildConditions();
        
        List<PaymentCondition__c> payConditions = [SELECT id, name FROM PaymentCondition__c WHERE name = 'Parcelado'];
        PaymentCondition__c parcelado = payConditions.get(0);
        
        conditionNames = VPCController.getCreatedRowsNames(product.Id);
        
        payConditions = [SELECT id, name FROM PaymentCondition__c WHERE name = 'A vista DDF - 0010'];
        PaymentCondition__c aVista = payConditions.get(0);
        
        buildVolumeConditions(product.Id, parcelado.Id);
        buildVolumeConditions(product.Id, aVista.Id);
        
        conditionNames = VPCController.getCreatedRowsNames(product.Id);
        
        Test.stopTest();
    }
    
    @isTest
    public static void getRows(){
        Test.startTest();
        List<PaymentCondition__c> conditionNames = VPCController.getRows('Nenhum');
        System.assertEquals(0, conditionNames.size(), 'A instância da lista de condições não pode conter registros.');
        
        buildProduct();
        
        List<Product2> products = VPCController.getProductsByName();
        Product2 product = products.get(0);
        
        buildConditions();
        
        List<PaymentCondition__c> payConditions = [SELECT id, name FROM PaymentCondition__c WHERE name = 'Parcelado'];
        PaymentCondition__c parcelado = payConditions.get(0);
        
        conditionNames = VPCController.getRows(product.Id);
        
        buildVolumeConditions(product.Id, parcelado.Id);
        
        conditionNames = VPCController.getRows(product.Id);
        
        List<Decimal> values = new List<Decimal>();
        Decimal count = 0;
        Test.stopTest();
    }
    
    @isTest
    public static void getRowsClone(){
        Test.startTest();
        
        List<PaymentCondition__c> conditions = VPCController.getRowsClone('Nenhum');
        System.assertEquals(0, conditions.size(), 'A instância da lista de condições não pode conter registros.');
        
        buildProduct();
        
        List<Product2> products = VPCController.getProductsByName();
        Product2 product = products.get(0);
        
        buildConditions();
        
        List<PaymentCondition__c> payConditions = [SELECT id, name FROM PaymentCondition__c WHERE name = 'Parcelado'];
        PaymentCondition__c parcelado = payConditions.get(0);
        buildVolumeConditions(product.Id, parcelado.Id);
        
        conditions = VPCController.getRowsClone(product.Id);
        for(PaymentCondition__c record : conditions){
            System.assertEquals(null, record.Id, 'O Id das condições clones deve ser nulo para não implicar no registro original.');
        }
        Test.stopTest();
    }
    
    @isTest
    public static void getRowsValues(){
        Test.startTest();
        
        List<Decimal> values = VPCController.getRowsValues('Nenhum');
        System.assertEquals(0, values.size(), 'A instância da lista de condições não pode conter registros.');
        
        buildProduct();
        
        List<Product2> products = VPCController.getProductsByName();
        Product2 product = products.get(0);
        
        buildConditions();
        
        List<PaymentCondition__c> payConditions = [SELECT id, name FROM PaymentCondition__c WHERE name = 'Parcelado'];
        PaymentCondition__c parcelado = payConditions.get(0);
        buildVolumeConditions(product.Id, parcelado.Id);
        
        values = VPCController.getRowsValues(product.Id);
        boolean first = true;
        for(Decimal value : values){
            if(first == true){
                first = false;
            } else {}
        }
        Test.stopTest();
    }
    
    @isTest
    public static void saveFirstCheck(){
        
        Test.startTest();
        
        buildProduct();
        
        List<Product2> products = VPCController.getProductsByName();
        Product2 product = products.get(0);
        
        buildConditions();
        
        List<PaymentCondition__c> payConditions = [SELECT id, name FROM PaymentCondition__c WHERE name = 'Parcelado'];
        PaymentCondition__c parcelado = payConditions.get(0);
        
        payConditions = [SELECT id, name FROM PaymentCondition__c WHERE name = 'A vista DDF - 0010'];
        PaymentCondition__c aVista = payConditions.get(0);
        
        PaymentConditionVolume__c first = new PaymentConditionVolume__c();
        first.Name = 'Payment Condition [0]';
        first.InitialVolumeNmb__c = 1;
        first.FinalVolumeNmb__c = 2;
        first.ListPriceBln__c = true; 
        first.LowPriceBln__c = false;
        first.MultiplierPriceNmb__c = 7;
        first.ProductLkp__c = product.Id;
        first.PaymentConditionLkp__c = aVista.Id;
        Insert first;
        
        List<PaymentCondition__c> conditions = [SELECT id, name FROM PaymentCondition__c WHERE name = 'Parcelado'];
        
        PaymentCondition__c futuro = new PaymentCondition__c();
        parcelado.name = 'Futuro';
        
        PaymentConditionVolume__c second = new PaymentConditionVolume__c();
        second.Name = 'Payment Condition [1]';
        second.InitialVolumeNmb__c = 3;
        second.FinalVolumeNmb__c = 4;
        second.ListPriceBln__c = true; 
        second.LowPriceBln__c = true;
        second.MultiplierPriceNmb__c = 8;
        second.ProductLkp__c = product.Id;
        second.PaymentConditionLkp__c = aVista.Id;
        Insert second;
        
        conditions.add(parcelado);
        conditions.add(aVista);
        conditions.add(futuro);
        
        
        List<PaymentConditionVolume__c> records = new List<PaymentConditionVolume__c> {first, second};
            
            //Insert
            List<PaymentConditionVolume__c> all = [SELECT name, InitialVolumeNmb__c, FinalVolumeNmb__c, ListPriceBln__c, 
                                                   LowPriceBln__c, MultiplierPriceNmb__c, ProductLkp__c, PaymentConditionLkp__c
                                                   FROM PaymentConditionVolume__c WHERE ProductLkp__c =: product.Id];
        
        
        for(PaymentConditionVolume__c record : all){
            System.debug('RECORD: '+record);
            if(record.name == 'Payment Condition [0]'){
                System.assertEquals(7, record.MultiplierPriceNmb__c, 'O valor do registro  '+aVista.name+':   '+record.name+' deve ser o mesmo da fonte de dados.');
                System.assertEquals(1, record.InitialVolumeNmb__c, 'O volume inicial do registro  '+aVista.name+': '+record.name+' deve ser o mesmo da fonte de dados.');
                System.assertEquals(2, record.FinalVolumeNmb__c, 'O volume Final do registro  '+aVista.name+': '+record.name+' deve ser o mesmo da fonte de dados.');
                System.assertEquals(true, record.ListPriceBln__c, 'O valor de lista do registro  '+aVista.name+': '+record.name+' deve ser o mesmo da fonte de dados.');
                System.assertEquals(false, record.LowPriceBln__c, 'O menor preço do registro  '+aVista.name+': '+record.name+' deve ser o mesmo da fonte de dados.');
                System.assertEquals(aVista.Id, record.PaymentConditionLkp__c, 'A condição de pagamento '+aVista.name+' deve ser igual para o registro '+record.name);
            }
            
            if(record.name == 'Payment Condition [1]'){
                System.assertEquals(8, record.MultiplierPriceNmb__c, 'O valor do registro  '+aVista.name+':   '+record.name+' deve ser o mesmo da fonte de dados.');
                System.assertEquals(3, record.InitialVolumeNmb__c, 'O volume inicial do registro  '+aVista.name+': '+record.name+' deve ser o mesmo da fonte de dados.');
                System.assertEquals(4, record.FinalVolumeNmb__c, 'O volume Final do registro  '+aVista.name+': '+record.name+' deve ser o mesmo da fonte de dados.');
                System.assertEquals(true, record.ListPriceBln__c, 'O valor de lista do registro  '+aVista.name+': '+record.name+' deve ser o mesmo da fonte de dados.');
                System.assertEquals(true, record.LowPriceBln__c, 'O menor preço do registro  '+aVista.name+': '+record.name+' deve ser o mesmo da fonte de dados.');
                System.assertEquals(aVista.Id, record.PaymentConditionLkp__c, 'A condição de pagamento '+aVista.name+' deve ser igual para o registro '+record.name);
                
            }
            
            if(record.name == 'Payment Condition [0] [0]' || record.name == 'Payment Condition [1] [0]'){
                System.assertEquals(50.99, record.MultiplierPriceNmb__c, 'O valor do registro '+record.name+' deve ser o mesmo da fonte de dados.');
                System.assertEquals(1, record.InitialVolumeNmb__c, 'O volume inicial do registro '+record.name+' deve ser o mesmo da fonte de dados.');
                System.assertEquals(2, record.FinalVolumeNmb__c, 'O volume Final do registro '+record.name+' deve ser o mesmo da fonte de dados.');
                System.assertEquals(false, record.ListPriceBln__c, 'O valor de lista do registro '+record.name+' deve ser falso.');
                System.assertEquals(false, record.LowPriceBln__c, 'O menor preço do registro '+record.name+' deve ser falso.');
                System.assertEquals(true, (record.PaymentConditionLkp__c == parcelado.Id || futuro.Id == record.PaymentConditionLkp__c), 'A condição de pagamento deve ser igual a fonte de dados para o registro '+record.name);
            }
            
            if(record.name == 'Payment Condition [1] [1]' || record.name == 'Payment Condition [0] [1]'){
                System.assertEquals(69.99, record.MultiplierPriceNmb__c, 'O valor do registro '+record.name+' deve ser o mesmo da fonte de dados.');
                System.assertEquals(3, record.InitialVolumeNmb__c, 'O volume inicial do registro '+record.name+' deve ser o mesmo da fonte de dados.');
                System.assertEquals(4, record.FinalVolumeNmb__c, 'O volume Final do registro '+record.name+' deve ser o mesmo da fonte de dados.');
                System.assertEquals(false, record.ListPriceBln__c, 'O valor de lista do registro '+record.name+' deve ser falso.');
                System.assertEquals(false, record.LowPriceBln__c, 'O menor preço do registro '+record.name+' deve ser falso.');
                System.assertEquals(true, (record.PaymentConditionLkp__c == parcelado.Id || futuro.Id == record.PaymentConditionLkp__c), 'A condição de pagamento deve ser igual a fonte de dados para o registro '+record.name);
            }
        } 
        all = [SELECT name, InitialVolumeNmb__c, FinalVolumeNmb__c, ListPriceBln__c, 
               LowPriceBln__c, MultiplierPriceNmb__c, ProductLkp__c, PaymentConditionLkp__c
               FROM PaymentConditionVolume__c WHERE ProductLkp__c =: product.Id];
        for(PaymentConditionVolume__c record : all){
            
            if(record.name == 'Payment Condition [0]'){
                System.assertEquals(7, record.MultiplierPriceNmb__c, 'O valor do registro  '+aVista.name+':   '+record.name+' deve ser o mesmo da fonte de dados.');
                System.assertEquals(1, record.InitialVolumeNmb__c, 'O volume inicial do registro  '+aVista.name+': '+record.name+' deve ser o mesmo da fonte de dados.');
                System.assertEquals(2, record.FinalVolumeNmb__c, 'O volume Final do registro  '+aVista.name+': '+record.name+' deve ser o mesmo da fonte de dados.');
                System.assertEquals(true, record.ListPriceBln__c, 'O valor de lista do registro  '+aVista.name+': '+record.name+' deve ser o mesmo da fonte de dados.');
                System.assertEquals(false, record.LowPriceBln__c, 'O menor preço do registro  '+aVista.name+': '+record.name+' deve ser o mesmo da fonte de dados.');
                System.assertEquals(aVista.Id, record.PaymentConditionLkp__c, 'A condição de pagamento '+aVista.name+' deve ser igual para o registro '+record.name);
            }
            
            if(record.name == 'Payment Condition [1]'){
                System.assertEquals(8, record.MultiplierPriceNmb__c, 'O valor do registro  '+aVista.name+':   '+record.name+' deve ser o mesmo da fonte de dados.');
                System.assertEquals(3, record.InitialVolumeNmb__c, 'O volume inicial do registro  '+aVista.name+': '+record.name+' deve ser o mesmo da fonte de dados.');
                System.assertEquals(4, record.FinalVolumeNmb__c, 'O volume Final do registro  '+aVista.name+': '+record.name+' deve ser o mesmo da fonte de dados.');
                System.assertEquals(true, record.ListPriceBln__c, 'O valor de lista do registro  '+aVista.name+': '+record.name+' deve ser o mesmo da fonte de dados.');
                System.assertEquals(true, record.LowPriceBln__c, 'O menor preço do registro  '+aVista.name+': '+record.name+' deve ser o mesmo da fonte de dados.');
                System.assertEquals(aVista.Id, record.PaymentConditionLkp__c, 'A condição de pagamento '+aVista.name+' deve ser igual para o registro '+record.name);
                
            }
            
            if(record.name == 'Payment Condition [0] [0]' || record.name == 'Payment Condition [1] [0]'){
                System.assertEquals(50.99, record.MultiplierPriceNmb__c, 'O valor do registro '+record.name+' deve ser o mesmo da fonte de dados.');
                System.assertEquals(1, record.InitialVolumeNmb__c, 'O volume inicial do registro '+record.name+' deve ser o mesmo da fonte de dados.');
                System.assertEquals(2, record.FinalVolumeNmb__c, 'O volume Final do registro '+record.name+' deve ser o mesmo da fonte de dados.');
                System.assertEquals(false, record.ListPriceBln__c, 'O valor de lista do registro '+record.name+' deve ser falso.');
                System.assertEquals(false, record.LowPriceBln__c, 'O menor preço do registro '+record.name+' deve ser falso.');
                System.assertEquals(true, (record.PaymentConditionLkp__c == parcelado.Id || futuro.Id == record.PaymentConditionLkp__c), 'A condição de pagamento deve ser igual a fonte de dados para o registro '+record.name);
            }
            
            if(record.name == 'Payment Condition [1] [1]' || record.name == 'Payment Condition [0] [1]'){
                System.assertEquals(69.99, record.MultiplierPriceNmb__c, 'O valor do registro '+record.name+' deve ser o mesmo da fonte de dados.');
                System.assertEquals(3, record.InitialVolumeNmb__c, 'O volume inicial do registro '+record.name+' deve ser o mesmo da fonte de dados.');
                System.assertEquals(4, record.FinalVolumeNmb__c, 'O volume Final do registro '+record.name+' deve ser o mesmo da fonte de dados.');
                System.assertEquals(false, record.ListPriceBln__c, 'O valor de lista do registro '+record.name+' deve ser falso.');
                System.assertEquals(false, record.LowPriceBln__c, 'O menor preço do registro '+record.name+' deve ser falso.');
                System.assertEquals(true, (record.PaymentConditionLkp__c == parcelado.Id || futuro.Id == record.PaymentConditionLkp__c), 'A condição de pagamento deve ser igual a fonte de dados para o registro '+record.name);
            }
        }
        Test.stopTest();
    }
    
    //Just to run in another road of code if's.
    @isTest
    public static void saveSecondCheck(){
        Test.startTest();
        buildProduct();
        
        List<Product2> products = VPCController.getProductsByName();
        Product2 product = products.get(0);
        
        PaymentConditionVolume__c first = new PaymentConditionVolume__c();
        first.Name = '';
        first.InitialVolumeNmb__c = 1;
        first.FinalVolumeNmb__c = 2;
        first.ListPriceBln__c = true; 
        first.LowPriceBln__c = false;
        first.MultiplierPriceNmb__c = 33.33;
        first.ProductLkp__c = product.Id;
        first.PaymentConditionLkp__c = null;
        Insert first;
        
        List<PaymentConditionVolume__c> records = new List<PaymentConditionVolume__c> {first};
            
            PaymentCondition__c futuro = new PaymentCondition__c();
        futuro.name = 'Futuro';
        Insert futuro;
        
        buildConditions();
        
        PaymentCondition__c parcelado = new PaymentCondition__c();
        parcelado.name = 'Parcelado';
        
        //Insert
        VPCController.save(new List<PaymentCondition__c>{parcelado}, records, '[]');
        
        Test.stopTest();
        
    }
    
    @isTest
    public static void mapValuePosition(){
        List<PaymentConditionVolume__c> recordPaymentConditionsVolume = new List <PaymentConditionVolume__c>();
        PaymentCondition__c aVista = new PaymentCondition__c();
        aVista.name = 'A vista';
        Insert aVista;
        
        PaymentCondition__c parcelado = new PaymentCondition__c();
        parcelado.name = 'Parcelado';
        Insert parcelado;
        
        VPCController.mapValuePosition(recordPaymentConditionsVolume);
    }
    
    @isTest
    public static void getConditions(){
        Test.startTest();
        buildProduct();
        buildConditions();
        VPCController.getConditions('Nenhum');
        List<String> conditionsTexts = new List<String>();
        Test.stopTest();
    }
    
    @isTest
    public static void upsertDefaultConditions(){
        Product2 prod = new Product2();
        prod.name = 'First Product in Test';
        prod.SAPCodeTxt__c = '001';
        prod.IsActive = true;
        insert prod;
        
        PaymentCondition__c aVista = new PaymentCondition__c();
        aVista.name = 'A vista DDF - 0010';
        aVista.SAPCodeTxt__c = '1020';
        aVista.isActive__c = true;
        Insert aVista;
        
        List<PaymentConditionVolume__c> payConVolRecords = new List<PaymentConditionVolume__c>();
        PaymentConditionVolume__c first = new PaymentConditionVolume__c();
        first.Name = 'A vista DDF - 0010';
        first.InitialVolumeNmb__c = 1;
        first.FinalVolumeNmb__c = 2;
        first.ListPriceBln__c = false; 
        first.LowPriceBln__c = false;
        first.MultiplierPriceNmb__c = 7;
        first.ProductLkp__c = prod.id;
        first.PaymentConditionLkp__c = aVista.id;
        
        payConVolRecords.add(first);
        insert payConVolRecords;
        
        List<PaymentCondition__c> conditions = [SELECT id, name FROM PaymentCondition__c WHERE name = 'A vista DDF - 0010'];
        List<PaymentConditionVolume__c> records = new List<PaymentConditionVolume__c> {first};
        
        //VPCController.upsertDefaultConditions(payConVolRecords, conditions, records);
        
        
        
    }
}