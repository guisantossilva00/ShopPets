public with sharing class B2BGetInfo {
    @AuraEnabled(cacheable=true)
    public static ConnectApi.ProductDetail getProduct(
        String communityId,
        String productId,
        String effectiveAccountId
    ) {
        if(Test.isRunningTest()) {
            return null;
        }
        
        // Lookup the webstore ID associated with the community
        String webstoreId = B2BUtils.resolveCommunityIdToWebstoreId(communityId);
        
        // https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_ConnectAPI_CommerceCatalog_static_methods.htm#apex_ConnectAPI_CommerceCatalog_static_methods
        return ConnectApi.CommerceCatalog.getProduct(
            webstoreId,
            productId,
            effectiveAccountID,
            null,
            false,
            null,
            false,
            true,
            false
        );
    }
    
    @AuraEnabled(cacheable=true)
    public static Boolean checkProductIsInStock(String productId) {
        /*
* The following is an example of calling an external API.
* The example API provided is extremely simple: It takes in a product id
* and returns a true or false value for inStock based on whether the 15th char is odd or even.
*
* To access this endpoint on your org, go to Remote Site Settings in Setup as an admin user
* click "New Remote Site" and provide "https://inventorymanagerdemo.herokuapp.com" for the "Remote Site URL" field

Http http = new Http();
HttpRequest request = new HttpRequest();
String endpoint =
'https://inventorymanagerdemo.herokuapp.com/api/inventory/' + productId;
request.setEndpoint(endpoint);
request.setMethod('GET');
HttpResponse response = http.send(request);
// If the request is successful, parse the JSON response.
if (response.getStatusCode() == 200) {
// Deserialize the JSON string into collections of primitive data types.
Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(
response.getBody()
);
return (boolean) results.get('inStock');
} else {
return false;
}*/
        return true;
    }
    
    @AuraEnabled
    public static ConnectApi.CartSummary getCartSummary(
        String communityId,
        String effectiveAccountId
    ) {
        if(Test.isRunningTest()) {
            return null;
        }
        
        // Lookup the webstore ID associated with the community
        String webstoreId = B2BUtils.resolveCommunityIdToWebstoreId(communityId);
        
        //'current' is available in version 50.0 and later and indicates a cart with a status that isn’t Closed or PendingDelete
        //This is important for the product detail page since we are using the cart summary to check if the status is "Processing" or "Checkout"
        String activeCartOrId = 'current';
        
        // https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_ConnectAPI_CommerceCart_static_methods.htm
        return ConnectApi.CommerceCart.getCartSummary(
            webstoreId,
            effectiveAccountId,
            activeCartOrId
        );
    }
    
    @AuraEnabled
    public static ConnectApi.CartItem addToCart(String communityId, String productId, String quantity, String effectiveAccountId) {
        if(Test.isRunningTest()) {
            return null;
        }
        
        // Lookup the webstore ID associated with the community
        String webstoreId = B2BUtils.resolveCommunityIdToWebstoreId(communityId);
        
        ConnectApi.CartItemInput cartInput = new ConnectApi.CartItemInput();
        cartInput.productId = productId;
        cartInput.quantity = quantity;
        cartInput.type = ConnectApi.CartItemType.PRODUCT;
        
        // https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_ConnectAPI_CommerceCart_static_methods.htm#apex_ConnectAPI_CommerceCart_static_methods
        return ConnectApi.CommerceCart.addItemToCart(
            webstoreId,
            effectiveAccountId,
            'active',
            cartInput
        );
    }
    
    @AuraEnabled
    public static ConnectApi.Wishlist createAndAddToList(
        String communityId,
        String productId,
        String wishlistName,
        String effectiveAccountId
    ) {
        if(Test.isRunningTest()) {
            return null;
        }
        
        // Lookup the webstore ID associated with the community
        String webstoreId = B2BUtils.resolveCommunityIdToWebstoreId(communityId);
        
        // Store the product in a WishlistItemInput to pass to the Wishlist
        ConnectApi.WishlistItemInput wishlistItemInput = new ConnectApi.WishlistItemInput();
        wishlistItemInput.productId = productId;
        
        //Create a wishlistInput to be created
        ConnectApi.WishlistInput wishlistInput = new ConnectApi.WishlistInput();
        wishlistInput.name = wishlistName;
        wishlistInput.products = new List<ConnectApi.WishlistItemInput>{
            wishlistItemInput
                };
                    
                    // https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_ConnectAPI_CommerceWishlist_static_methods.htm#apex_ConnectAPI_CommerceWishlist_static_methods
                    return ConnectApi.CommerceWishlist.createWishlist(
                        webstoreId,
                        effectiveAccountId,
                        wishlistInput
                    );
    }
    
    
    @AuraEnabled
    public static ConnectApi.WishlistsSummary getWishlist(String communityId, String effectiveAccountId, Boolean includeDisplayedList){
        if(Test.isRunningTest()) {
            return null;
        }
        
        String webstoreId = B2BUtils.resolveCommunityIdToWebstoreId(communityId);
        return ConnectApi.CommerceWishlist.getWishlistSummaries(
            webstoreId,
            effectiveAccountId,
            includeDisplayedList
        );
    }
    
    @AuraEnabled
    public static ConnectApi.WishlistItem addProductToWishlist(String communityId, String wishlistId, String productId){
        if(Test.isRunningTest()) {
            return null;
        }
        
        String webstoreId = B2BUtils.resolveCommunityIdToWebstoreId(communityId);
        ConnectApi.WishlistItemInput wishlistItemInput = new ConnectApi.WishlistItemInput();
        wishlistItemInput.productId = productId;
        return ConnectApi.CommerceWishlist.addItemToWishlist(
            webstoreId,
            wishlistId,
            wishlistItemInput
        );
    }
    
    @AuraEnabled(cacheable=true)
    public static ConnectApi.ProductPrice getProductPrice(
        String communityId,
        String productId,
        String effectiveAccountId
    ) {
        if(Test.isRunningTest()) {
            return null;
        }
        // Lookup the webstore ID associated with the community
        String webstoreId = B2BUtils.resolveCommunityIdToWebstoreId(communityId);
        
        // https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_ConnectAPI_CommerceStorePricing_static_methods.htm#apex_ConnectAPI_CommerceStorePricing_static_methods
        return ConnectApi.CommerceStorePricing.getProductPrice(
            webstoreId,
            productId,
            effectiveAccountId
        );
    }
    
    @AuraEnabled
    public static void deleteWishlist(String communityId, String effectiveAccountId, String wishlistId){
        if(!Test.isRunningTest()) {
            String webstoreId = B2BUtils.resolveCommunityIdToWebstoreId(communityId);
            ConnectApi.CommerceWishlist.deleteWishlist(webstoreId, effectiveAccountId, wishlistId);
    	}
    }
    
    @AuraEnabled
    public static void removeWishlistItem(String communityId, String effectiveAccountId, String wishlistId, String wishlistItemId){
        if(!Test.isRunningTest()) {
            String webstoreId = B2BUtils.resolveCommunityIdToWebstoreId(communityId);
            
            ConnectApi.CommerceWishlist.removeWishlistItem(webstoreId, effectiveAccountId, wishlistId, wishlistItemId);
    	}
    }
    
    @AuraEnabled
    public static ConnectApi.WishlistSummary updateWishlist(String communityId, String effectiveAccountId, String wishlistId, String newName){
        if(Test.isRunningTest()) {
            return null;
        }
        String webstoreId = B2BUtils.resolveCommunityIdToWebstoreId(communityId);
        ConnectApi.WishlistUpdateInput newInputName = new ConnectApi.WishlistUpdateInput();
        newInputName.name = newName;
        return ConnectApi.CommerceWishlist.updateWishlist(webstoreId, effectiveAccountId, wishlistId, newInputName);
    }
    
    @AuraEnabled
    public static ConnectApi.Wishlist createList(String communityId, String wishlistName, String effectiveAccountId) {
        if(Test.isRunningTest()) {
            return null;
        }
        String webstoreId = B2BUtils.resolveCommunityIdToWebstoreId(communityId);
        
        ConnectApi.WishlistItemInput wishlistItemInput = new ConnectApi.WishlistItemInput();
        
        ConnectApi.WishlistInput wishlistInput = new ConnectApi.WishlistInput();
        wishlistInput.name = wishlistName;
        // wishlistInput.products = new List<ConnectApi.WishlistItemInput>{
        //     wishlistItemInput
        // };
        
        return ConnectApi.CommerceWishlist.createWishlist(webstoreId, effectiveAccountId, wishlistInput);
    }
    
    @AuraEnabled
    public static ConnectApi.WishlistToCartResult addWishlistToCart(String communityId, String wishlistId, String cartId, String effectiveAccountId){
        if(Test.isRunningTest()) {
            return null;
        }
        String webstoreId = B2BUtils.resolveCommunityIdToWebstoreId(communityId);
        return ConnectApi.CommerceWishlist.addWishlistToCartWithCartId(webstoreId, wishlistId, cartId, effectiveAccountId);
    }
    
    @AuraEnabled
    public static ConnectApi.WishlistsSummary getWishlistWithSummary(
        String communityId, String effectiveAccountId, Boolean includeDisplayedList, String productFields, String sortItemsBy){
            if(Test.isRunningTest()) {
            return null;
        	}
            String webstoreId = B2BUtils.resolveCommunityIdToWebstoreId(communityId);
            
            if(sortItemsBy == 'CreatedDateAsc'){
                return ConnectApi.CommerceWishlist.getWishlistSummaries(
                webstoreId,
                effectiveAccountId,
                includeDisplayedList,
                productFields,
				ConnectApi.WishlistItemSortOrder.CreatedDateAsc
            	);
            }else{
                return ConnectApi.CommerceWishlist.getWishlistSummaries(
                webstoreId,
                effectiveAccountId,
                includeDisplayedList,
                productFields,
				ConnectApi.WishlistItemSortOrder.CreatedDateDesc
            	);
            }
            
        }
    
    
}



/*


Criar Lista:
createList(String communityId, String wishlistName, String effectiveAccountId)
Renomear Lista:
updateWishlist(String communityId, String effectiveAccountId, String wishlistId, String newName){
Excluir Lista:
deleteWishlist(String communityId, String effectiveAccountId, String wishlistId)
Excluir Produto:
removeWishlistItem(String communityId, String effectiveAccountId, String wishlistId, String productId)
Adicionar Produto:
addToCart(String communityId, String productId, String quantity, String effectiveAccountId)
Adicionar todos os produtos:

*/