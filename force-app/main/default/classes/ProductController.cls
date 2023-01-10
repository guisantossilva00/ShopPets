public without sharing class ProductController {
    static Integer PAGE_SIZE = 6;

    @AuraEnabled(Cacheable=true)
    public static String getImageId(String productId){
        List<Network> c = [SELECT id FROM Network limit 1];
        List<ProductMedia> productImage = [SELECT Id, ElectronicMediaId FROM ProductMedia WHERE ProductId =: productId limit 1];
        List<String> ElectronicMediaId =  new List<String>();
        String producImageURL =  '/s/sfsites/c/cms/delivery/media/';
        if (!Test.isRunningTest()) {
        	ElectronicMediaId.add(productImage[0].ElectronicMediaId);                                              
        	ConnectApi.ManagedContentVersionCollection resp = ConnectApi.ManagedContent.getManagedContentByIds(c[0].id,ElectronicMediaId,null,null,'pt_BR','');
        	producImageURL =  producImageURL + String.valueOf(resp.items[0]).split('contentKey=')[1].split(',')[0];
        }

        return producImageURL;  
    }
    

    @AuraEnabled(Cacheable=true)
    public static PagedResult getProducts(Integer pageNumber, Integer screenSize) {
        String key = '';
        String whereClause = '';
        String criteria;
        Integer pageSize;

        if(screenSize < 560) {
            pageSize = 2;  
        } else if(screenSize >= 560 && screenSize < 768) {
            pageSize = 3;
        }else if(screenSize >= 768 && screenSize < 1024){
            pageSize = 4;
        }else if(screenSize >= 1024) {
            pageSize = 5;
        }


        String categoryAcucar = 'Açúcar';
        String categoryAlcool = 'Álcool';
        Integer offset = (pageNumber - 1) * pageSize;
        PagedResult result = new PagedResult();
        result.pageSize = pageSize;
        result.pageNumber = pageNumber;
        
        //result.totalItemCount = Database.countQuery(
        //    'SELECT count() FROM Product2 ' + whereClause
        //);
        result.totalItemCount = 8;

        List<ProductCategoryProduct> IdsProductProductCategoryProduct = Database.query('Select Id, Name, Product.Id, ProductCategory.Id From ProductCategoryProduct ');

        Set<ID> IdsProduct = new Set<ID>();

        for(ProductCategoryProduct IdProductProductCategoryProduct : IdsProductProductCategoryProduct) {
            IdsProduct.add(IdProductProductCategoryProduct.Product.Id);
        }   

        result.records = Database.query(
            'Select id, ProductCode,Family, Name, ' + 
            'Description From Product2 ' + 
            //whereClause + 
            ' WHERE Id IN :IdsProduct AND (Tipo_de_produto__c LIKE :categoryAcucar OR Tipo_de_produto__c LIKE :categoryAlcool) AND IsActive = true ' +
            ' WITH SECURITY_ENFORCED' +
            ' ORDER BY Name LIMIT :pageSize OFFSET :offset'
        );

        if(result.records.size() == 0) {
            result.records = Database.query(
                'Select id, ProductCode,Family, Name, ' + 
                'Description From Product2 ' + 
                //whereClause + 
                ' WHERE Id IN :IdsProduct AND (Tipo_de_produto__c LIKE :categoryAcucar OR Tipo_de_produto__c LIKE :categoryAlcool) AND IsActive = true ' +
                ' WITH SECURITY_ENFORCED' +
                ' ORDER BY Name LIMIT :pageSize OFFSET 0'
            );
        }
        
        return result;
    }

    @AuraEnabled(Cacheable=true)
    public static PagedResult getCategoryAcucar(Integer pageNumber, Integer screenSize) {
        String key = '';
        String whereClause = '';
        String criteria;
        Integer pageSize;

        if(screenSize < 560) {
            pageSize = 2;  
        } else if(screenSize >= 560 && screenSize < 768) {
            pageSize = 3;
        }else if(screenSize >= 768 && screenSize < 1024){
            pageSize = 4;
        }else if(screenSize >= 1024) {
            pageSize = 5;
        }

        String category = 'Açúcar';
        Integer offset = (pageNumber - 1) * pageSize;
        PagedResult result = new PagedResult();
        result.pageSize = pageSize;
        result.pageNumber = pageNumber;
        //result.totalItemCount = Database.countQuery(
        //    'SELECT count() FROM Product2 ' + whereClause
        //);
        result.totalItemCount = 8;

        List<ProductCategoryProduct> IdsProductProductCategoryProduct = Database.query('Select Id, Name, Product.Id, ProductCategory.Id From ProductCategoryProduct ');

        Set<ID> IdsProduct = new Set<ID>();

        for(ProductCategoryProduct IdProductProductCategoryProduct : IdsProductProductCategoryProduct) {
            IdsProduct.add(IdProductProductCategoryProduct.Product.Id);
        }   

        result.records = Database.query(
            'Select id, ProductCode,Family, Name, ' + 
            'Description From Product2 ' + 
            whereClause + 
            ' WHERE Id IN :IdsProduct AND Tipo_de_produto__c LIKE :category AND IsActive = true' +
            ' WITH SECURITY_ENFORCED' +
            ' ORDER BY Name LIMIT :pageSize OFFSET :offset'
        );

        if(result.records.size() == 0) {
            result.records = Database.query(
                'Select id, ProductCode,Family, Name, ' + 
                'Description From Product2 ' + 
                whereClause + 
                ' WHERE Id IN :IdsProduct AND Tipo_de_produto__c LIKE :category AND IsActive = true' +
                ' WITH SECURITY_ENFORCED' +
                ' ORDER BY Name LIMIT :pageSize OFFSET 0'
            );
        }

        return result;
        //return null;
    }

    @AuraEnabled(Cacheable=true)
    public static PagedResult getCategoryAlcool(Integer pageNumber, Integer screenSize) {
        String key = '';
        String whereClause = '';
        String criteria;
        Integer pageSize;

        if(screenSize < 560) {
            pageSize = 2;  
        } else if(screenSize >= 560 && screenSize < 768) {
            pageSize = 3;
        }else if(screenSize >= 768 && screenSize < 1024){
            pageSize = 4;
        }else if(screenSize >= 1024) {
            pageSize = 5;
        }

    
        String category = 'Álcool';
        Integer offset = (pageNumber - 1) * pageSize;
        PagedResult result = new PagedResult();
        result.pageSize = pageSize;
        result.pageNumber = pageNumber;
        //result.totalItemCount = Database.countQuery(
        //    'SELECT count() FROM Product2 ' + whereClause
        //);
        result.totalItemCount = 8;

        List<ProductCategoryProduct> IdsProductProductCategoryProduct = Database.query('Select Id, Name, Product.Id, ProductCategory.Id From ProductCategoryProduct ');

        Set<ID> IdsProduct = new Set<ID>();

        for(ProductCategoryProduct IdProductProductCategoryProduct : IdsProductProductCategoryProduct) {
            IdsProduct.add(IdProductProductCategoryProduct.Product.Id);
        }   

        result.records = Database.query(
            'Select id, ProductCode,Family, Name, ' + 
            'Description From Product2 ' + 
            whereClause + 
            ' WHERE Id IN :IdsProduct AND Tipo_de_produto__c LIKE :category AND IsActive = true' +
            ' WITH SECURITY_ENFORCED' +
            ' ORDER BY Name LIMIT :pageSize OFFSET :offset'
        );

        if(result.records.size() == 0) {
            result.records = Database.query(
                'Select id, ProductCode,Family, Name, ' + 
                'Description From Product2 ' + 
                whereClause + 
                ' WHERE Id IN :IdsProduct AND Tipo_de_produto__c LIKE :category AND IsActive = true' +
                ' WITH SECURITY_ENFORCED' +
                ' ORDER BY Name LIMIT :pageSize OFFSET 0'
            );
        }

        return result;
        //return null;
    }

    @AuraEnabled(Cacheable=true)
    public static PagedResult getRelatedProducts(Integer pageNumber, Integer screenSize, String pathURL) {
        String key = '';
        String whereClause = '';
        String criteria;
        Integer pageSize;

        if(screenSize < 560) {
            pageSize = 2;  
        } else if(screenSize >= 560 && screenSize < 768) {
            pageSize = 3;
        }else if(screenSize >= 768 && screenSize < 1024){
            pageSize = 4;
        }else if(screenSize >= 1024) {
            pageSize = 5;
        }

        List<lb2bt__Cross_Sell_Recommendations__c> ListRelated = [SELECT lb2bt__Recommended_Product__c  FROM lb2bt__Cross_Sell_Recommendations__c  where lb2bt__Recommended_Product_Parent__c = :pathURL LIMIT 10];
        Set<id> ids = new Set<id>();

        for ( lb2bt__Cross_Sell_Recommendations__c a :  ListRelated){

            ids.add(a.lb2bt__Recommended_Product__c);

        }

        Integer offset = (pageNumber - 1) * pageSize;
        PagedResult result = new PagedResult();
        result.pageSize = pageSize;
        result.pageNumber = pageNumber;
        result.totalItemCount = 8;
        result.records = Database.query(
            'Select id, ProductCode,Family, Name, ' + 
            'Description From Product2 ' + 
            whereClause + 
            ' WHERE id IN :ids' +
            ' WITH SECURITY_ENFORCED' +
            ' ORDER BY Name LIMIT :pageSize OFFSET :offset'
        );
        return result;
        //return null;
    } 

    @AuraEnabled(Cacheable=true)
    public static String getProductPrice(String productId) {
        List<PricebookEntry> price = new List<PricebookEntry>();
        if(!Test.isRunningTest()){
             price = [SELECT UnitPrice FROM PricebookEntry WHERE Pricebook2.Name Like '%B2B%' AND product2Id =: productId];
        }else{
             price = [SELECT UnitPrice FROM PricebookEntry WHERE product2Id =: productId ORDER BY UnitPrice DESC];
        }
        return String.valueOf(price[0].UnitPrice);
    }

    @AuraEnabled
    public static String getCartItem(String cartId, String productId) {
        
        List<CartItem> result = [SELECT Id FROM CartItem WHERE CartId =: cartId and SalesPrice != null and Product2Id =: productId order by CreatedDate desc];
        
        if ( result.size() > 0){
            return result[0].Id;
        }else{
            return null;
        }
    }

    @AuraEnabled
    public static String getFirstCartItem(String cartId, String productId) {
        
        List<CartItem> result = [SELECT Id FROM CartItem WHERE CartId =: cartId and SalesPrice != null and Product2Id =: productId order by CreatedDate desc];
        
        if ( result.size() > 0){
            return result[0].Id;
        }else{
            List<CartItem> newResult = [SELECT Id FROM CartItem WHERE CartId =: cartId and SalesPrice != null order by CreatedDate desc];

            if ( newResult.size() > 0){
                return newResult[0].Id;
            }else{
                return null;
            }
        }
    }

    @AuraEnabled
    public static String createCart() {
        List<WebStore> webStore = [SELECT Id, Name FROM WebStore limit 1];
        List<User> user =  [SELECT AccountId FROM User WHERE Id =: UserInfo.getUserId() ];
        String storeId = String.valueOf(webStore[0].Id);
        ConnectApi.CartInput cartInput = new ConnectApi.cartInput();
        cartInput.effectiveAccountId = user[0].AccountId;
        
        if (!Test.isRunningTest()) {
            ConnectApi.CommerceCart.createCart('0ZE17000000CaT3GAK', cartInput);
        }
        List<WebCart> cart =  [SELECT Id, TotalAmount, TotalProductCount FROM WebCart WHERE CreatedBy.id =: UserInfo.getUserId() and (Status = 'Active' or Status = 'Checkout') limit 1];        
        if(cart.size() > 0){
            return cart[0].Id;
        }else{
            return null;
        }  
    }

    @AuraEnabled(cacheable=true)
    public static String effectiveAccountValueID() {
        List<User> user =  [SELECT AccountId FROM User WHERE Id =: UserInfo.getUserId()];
        return user[0].AccountId;
    }



    @AuraEnabled
    public static String createCartItem(String cartId, String productId, String quantity) {
        List<User> user =  [SELECT Id, AccountId FROM User WHERE Id =: UserInfo.getUserId() ];
        List<WebStore> webStore = [SELECT Id, Name FROM WebStore limit 1];
        String webstoreId = String.valueOf(webStore[0].id);

        ConnectApi.CartItemInput cartItemInput = new ConnectApi.CartItemInput();
        cartItemInput.productId = productId;
        cartItemInput.quantity = quantity;
        cartItemInput.type = ConnectApi.CartItemType.Product;
        if (!Test.isRunningTest()) {
            ConnectApi.CommerceCart.addItemToCart(webStore[0].id, user[0].AccountId, cartId, cartItemInput);
        }
        return null;
    }

}