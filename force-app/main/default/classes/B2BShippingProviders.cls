global without sharing class B2BShippingProviders implements sfdc_checkout.CartShippingCharges {
    global sfdc_checkout.IntegrationStatus startCartProcessAsync(sfdc_checkout.IntegrationInfo jobInfo, Id cartId) {
        sfdc_checkout.IntegrationStatus integStatus = new sfdc_checkout.IntegrationStatus();
        
        try {

            // We need to get the ID of the cart delivery group in order to create the order delivery groups.
            Id cartDeliveryGroupId = [SELECT Id FROM CartDeliveryGroup WHERE CartId = :cartId][0].Id;

            // Get shipping options, including aspects like rates and carriers, from the external service. 
            TipoFrete__c[] shippingOptionsAndRatesFromExternalService = getTipoFrete(cartId);

            //G On re-entry of the checkout flow delete all previous CartDeliveryroupMethods for the given cartDeliveryGroupId
            delete [SELECT Id FROM CartDeliveryGroupMethod WHERE CartDeliveryGroupId = :cartDeliveryGroupId];

            // Create orderDeliveryMethods given your shipping options or fetch existing ones. 2 should be returned.
            List<Id> orderDeliveryMethodIds = getOrderDeliveryMethods(shippingOptionsAndRatesFromExternalService);

            // Create a CartDeliveryGroupMethod record for every shipping option returned from the external service
            Integer i = 0;
            Double value = 0;
            Decimal roundedValue = 0;
            for (Id orderDeliveryMethodId: orderDeliveryMethodIds) {
               value = getShippingRate(cartId, shippingOptionsAndRatesFromExternalService[i].Id);
               roundedValue = Decimal.valueOf(value).setScale(2, System.RoundingMode.HALF_UP);
              
               populateCartDeliveryGroupMethodWithShippingOptions(shippingOptionsAndRatesFromExternalService[i],
                                                                  cartDeliveryGroupId,
                                                                  orderDeliveryMethodId,
                                                                  cartId,
                                                                  roundedValue);
                i+=1;
            }
            
            // If everything works well, the charge is added to the cart and our integration has been successfully completed.
			integStatus.status = sfdc_checkout.IntegrationStatus.Status.SUCCESS;
        // For testing purposes, this example treats exceptions as user errors, which means they are displayed to the buyer user.
        // In production you probably want this to be an admin-type error. In that case, throw the exception here
        // and make sure that a notification system is in place to let the admin know that the error occurred.
        // See the readme section about error handling for details about how to create that notification.
        } catch (DmlException de) {
            // Catch any exceptions thrown when trying to insert the shipping charge to the CartItems
            Integer numErrors = de.getNumDml();
            String errorMessage = 'There were ' + numErrors + ' errors when trying to insert the charge in the CartItem: ';
            for(Integer errorIdx = 0; errorIdx < numErrors; errorIdx++) {
                errorMessage += 'Field Names = ' + de.getDmlFieldNames(errorIdx);
                errorMessage += 'Message = ' + de.getDmlMessage(errorIdx);
                errorMessage += ' , ';
            }

            return integrationStatusFailedWithCartValidationOutputError(
                integStatus,
                errorMessage,
                jobInfo,
                cartId
            );
        } catch(Exception e) {
            return integrationStatusFailedWithCartValidationOutputError(
                integStatus,
                'An exception of type ' + e.getTypeName() + ' has occurred: ' + e.getMessage(),
                jobInfo,
                cartId
            );
        }
        return integStatus;
    }
    
    private TipoFrete__c[] getTipoFrete(String cartId){

        List <TipoFrete__c> retornarListaFrete = new List <TipoFrete__c>();

        try{

            WebCart carrinho = [
                SELECT TipoCarrinho__c 
                FROM WebCart 
                WHERE ID =: cartId
                LIMIT 1
                ];

            Id accSelect = [
                SELECT Account.Id 
                FROM WebCart 
                WHERE ID =: cartId
            ][0].AccountId;

            ContactPointAddress cpa = [
                SELECT State, City 
                FROM ContactPointAddress 
                WHERE ParentId =: accSelect 
                AND IsDefault = TRUE 
                AND AddressType = 'Shipping'
                LIMIT 1
            ][0];
        
            String estado = cpa.State;
            String cidade = cpa.City;
            String tipoCarrinho = carrinho.TipoCarrinho__c;

            if (tipoCarrinho == 'Cosmético' || tipoCarrinho == 'Álcool'){

            retornarListaFrete = [
                SELECT Id, Name, Estado__c, Cidade__c, Custo__c, CustoMinimo__c, NomeOperadora__c, TipoFrete__c, Origem__c, DiasEntrega__c
                FROM TipoFrete__c
                WHERE ((Ativo__c = TRUE AND Estado__c =: estado AND Cidade__c =: cidade AND TipoFrete__c =: 'Álcool')
                OR (Ativo__c = TRUE AND Estado__c = 'Todos' AND Cidade__c =: 'Todas' AND TipoFrete__c =: 'Vazio'))
            ];

            }else{

                retornarListaFrete = [
                    SELECT Id, Name, Estado__c, Cidade__c, Custo__c, CustoMinimo__c, NomeOperadora__c, TipoFrete__c, Origem__c, DiasEntrega__c
                    FROM TipoFrete__c
                    WHERE ((Ativo__c = TRUE AND Estado__c =: estado AND Cidade__c =: cidade AND TipoFrete__c =: 'Açúcar')
                    OR (Ativo__c = TRUE AND Estado__c = 'Todos' AND Cidade__c =: 'Todas' AND TipoFrete__c =: 'Vazio'))
                ];

            }

            

        }catch(DmlException e) {
            System.debug('O seguinte erro ocorreu: ' + e.getMessage());
        }catch(Exception e) {
            System.debug('O seguinte erro ocorreu: ' + e.getMessage());
        }

        return retornarListaFrete;
        
    }

    // Create a CartDeliveryGroupMethod record for every shipping option returned from the external service
    private void populateCartDeliveryGroupMethodWithShippingOptions(TipoFrete__c shippingOption,
                                                                  Id cartDeliveryGroupId,
                                                                  Id deliveryMethodId,
                                                                  Id webCartId,
                                                                   Decimal value){
        // When inserting a new CartDeliveryGroupMethod, the following fields have to be populated:
        // CartDeliveryGroupId: Id of the delivery group of this shipping option
        // DeliveryMethodId: Id of the delivery method for this shipping option
        // ExternalProvider: Unique identifier of shipping provider
        // Name: Name of the CartDeliveryGroupMethod record
        // ShippingFee: The cost of shipping for the delivery group
        // WebCartId: Id if the cart that the delivery group belongs to
        CartDeliveryGroupMethod cartDeliveryGroupMethod = new CartDeliveryGroupMethod(
            CartDeliveryGroupId = cartDeliveryGroupId,
            DeliveryMethodId = deliveryMethodId,
            ExternalProvider = shippingOption.NomeOperadora__c,
            Name = shippingOption.Name + ' (' +  shippingOption.DiasEntrega__c + ' dias úteis) -' + ' ' + shippingOption.Origem__c,
            ShippingFee = value,
            WebCartId = webCartId
        );
        insert(cartDeliveryGroupMethod);
    }

    private sfdc_checkout.IntegrationStatus integrationStatusFailedWithCartValidationOutputError(
        sfdc_checkout.IntegrationStatus integrationStatus, String errorMessage, sfdc_checkout.IntegrationInfo jobInfo, Id cartId) {
            integrationStatus.status = sfdc_checkout.IntegrationStatus.Status.FAILED;
            // In order for the error to be propagated to the user, we need to add a new CartValidationOutput record.
            // The following fields must be populated:
            // BackgroundOperationId: Foreign Key to the BackgroundOperation
            // CartId: Foreign key to the WebCart that this validation line is for
            // Level (required): One of the following - Info, Error, or Warning
            // Message (optional): Message displayed to the user
            // Name (required): The name of this CartValidationOutput record. For example CartId:BackgroundOperationId
            // RelatedEntityId (required): Foreign key to WebCart, CartItem, CartDeliveryGroup
            // Type (required): One of the following - SystemError, Inventory, Taxes, Pricing, Shipping, Entitlement, Other
            CartValidationOutput cartValidationError = new CartValidationOutput(
                BackgroundOperationId = jobInfo.jobId,
                CartId = cartId,
                Level = 'Error',
                Message = errorMessage.left(255),
                Name = (String)cartId + ':' + jobInfo.jobId,
                RelatedEntityId = cartId,
                Type = 'Shipping'
            );
            insert(cartValidationError);
            return integrationStatus;
    }

    private Id getShippingChargeProduct2Id(Id orderDeliveryMethodId) {
        // The Order Delivery Method should have a Product2 associated with it, because we added that in getDefaultOrderDeliveryMethod if it didn't exist.
        List<OrderDeliveryMethod> orderDeliveryMethods = [SELECT ProductId FROM OrderDeliveryMethod WHERE Id = :orderDeliveryMethodId ];
        return orderDeliveryMethods[0].ProductId;
    }

    private List<Id> getOrderDeliveryMethods(List<TipoFrete__c> shippingOptions) {
        String defaultDeliveryMethodName = '';
        Id product2IdForThisDeliveryMethod = getDefaultShippingChargeProduct2Id();

        // Check to see if a default OrderDeliveryMethod already exists.
        // If it doesn't exist, create one.
        List<Id> orderDeliveryMethodIds = new List<Id>();
        List<OrderDeliveryMethod> orderDeliveryMethods = new List<OrderDeliveryMethod>();
        Integer i = 1;
        for (TipoFrete__c shippingOption: shippingOptions) {
            String shippingOptionNumber = String.valueOf(i);
            String name = shippingOption.Name + ' (' +  shippingOption.DiasEntrega__c + ' dias úteis)';
            List<OrderDeliveryMethod> odms = [SELECT Id, ProductId, Carrier, ClassOfService FROM OrderDeliveryMethod WHERE Name = :name];
            // This is the case in which an Order Delivery method does not exist.
            if (odms.isEmpty()) {
                OrderDeliveryMethod defaultOrderDeliveryMethod = new OrderDeliveryMethod(
                    Name = name,
                    Carrier = shippingOption.Name,
                    isActive = true,
                    ProductId = product2IdForThisDeliveryMethod,
                    ClassOfService = shippingOption.NomeOperadora__c
                );
                insert(defaultOrderDeliveryMethod);
                orderDeliveryMethodIds.add(defaultOrderDeliveryMethod.Id);
            }
            else {
                // This is the case in which an Order Delivery method exists.
                // If the OrderDeliveryMethod doesn't have a Product2 associated with it, assign one
                // We can always pick the 0th orderDeliveryMethod since we queried based off the name.
                OrderDeliveryMethod existingodm = odms[0];
                // This is for reference implementation purposes only.
                // This is the if statement that checks to make sure that there is a product carrier and class of service
                // associated to the order delivery method.
                if (existingodm.ProductId == null || existingodm.Carrier == null || existingodm.ClassOfService == null) {
                    existingodm.ProductId = product2IdForThisDeliveryMethod;
                    existingodm.Carrier = shippingOption.Name;
                    existingodm.ClassOfService = shippingOption.NomeOperadora__c;
                    update(existingodm);
                }
                orderDeliveryMethodIds.add(existingodm.Id);
            }
            i+=1;
        }
        return orderDeliveryMethodIds;
    }

    private Id getDefaultShippingChargeProduct2Id() {
        // In this example we will name the product representing shipping charges 'Shipping Charge for this delivery method'.
        // Check to see if a Product2 with that name already exists.
        // If it doesn't exist, create one.
        String shippingChargeProduct2Name = 'Taxa de Entrega';
        List<Product2> shippingChargeProducts = [SELECT Id FROM Product2 WHERE Name = :shippingChargeProduct2Name];
        if (shippingChargeProducts.isEmpty()) {
            Product2 shippingChargeProduct = new Product2(
                isActive = true,
                Name = shippingChargeProduct2Name
            );
            insert(shippingChargeProduct);
            return shippingChargeProduct.Id;
        }
        else {
            return shippingChargeProducts[0].Id;
        }
    }
    
    private static Double getShippingRate(Id cartId, Id selectedShippingMethod) {
        
        WebCart cart = [
            SELECT TipoCarrinho__c
			FROM WebCart 
            WHERE Id =: cartId 
            LIMIT 1
        ];

        List<CartItem> cartItem = [
            SELECT Product2.Id, Peso__c
            FROM CartItem 
            Where CartId =: cartId
        ]; 

        TipoFrete__c frete = [
            SELECT Custo__c, CustoMinimo__c
            FROM TipoFrete__c 
            WHERE ID =: selectedShippingMethod
            LIMIT 1
        ][0];

        double peso = 0;

        for(CartItem ca : cartItem){
            peso += ca.Peso__c;
        }
        
        if(cart.TipoCarrinho__c != 'Açúcar' && peso < 100.00){
            if(frete.CustoMinimo__c == Null){
                return 0;
            }else{
                return frete.CustoMinimo__c;
            }
        }else{
            return peso * frete.Custo__c;
        }
        
    }

    /*private static double convert(double peso){
        Double tonelada = 1000.000;
        return peso/tonelada;
    }*/
    
}