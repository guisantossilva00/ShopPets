global class B2BCheckTax implements sfdc_checkout.CartTaxCalculations {
    
    global sfdc_checkout.IntegrationStatus startCartProcessAsync(sfdc_checkout.IntegrationInfo jobInfo, Id cartId) {
        
        sfdc_checkout.IntegrationStatus integStatus = new sfdc_checkout.IntegrationStatus();        
        integStatus.status = sfdc_checkout.IntegrationStatus.Status.SUCCESS;
        return integStatus;
        
    }
    
}