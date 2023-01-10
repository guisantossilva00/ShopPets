import { LightningElement, api, wire } from 'lwc';

// getCategoryAcucar() method in ProductController Apex class
import getCategoryAlcool from '@salesforce/apex/ProductController.getCategoryAlcool';

export default class DisplayCategoryAlcool extends LightningElement {

    pageNumber = 1;
    totalItemCount = 0;
    filters = {};
    screenSize = window.innerWidth;

    @wire(getCategoryAlcool, { filters: '$filters', pageNumber: '$pageNumber', screenSize: '$screenSize' })
    products;


    //Publish ProductSelected message
    handleProductSelected(event) {  
        publish(this.messageContext, PRODUCT_SELECTED_MESSAGE, {
            productId: event.detail
        });
    }

    handleSearchKeyChange(event) {
        this.filters = { searchKey: event.target.value.toLowerCase()};
        this.pageNumber = 1;
    }
    handlePreviousPage() {
        this.pageNumber = this.pageNumber - 1;
    }

    handleNextPage() {
        this.pageNumber = this.pageNumber + 1;
    }
    handleAddToCartCustom(ev) {
        switch (ev.detail) {
            case 'add':
                this.template.querySelector('c-modal-add-to-cart-custom[c-displaycategoryalcool_displaycategoryalcool]').openModal();
                break
            case 'error':
                this.template.querySelector('c-modal-error-custom[c-displaycategoryalcool_displaycategoryalcool]').openModal();
                break
        }
    }
}