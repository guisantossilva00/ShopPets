import { LightningElement, api, wire } from 'lwc';

// getCategoryAcucar() method in ProductController Apex class
import getCategoryAcucar from '@salesforce/apex/ProductController.getCategoryAcucar';

export default class DisplayCategoryAcucar extends LightningElement {

    pageNumber = 1;
    totalItemCount = 0;
    screenSize = window.innerWidth;

    @wire(getCategoryAcucar, { pageNumber: '$pageNumber', screenSize: '$screenSize' })
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
                this.template.querySelector('c-modal-add-to-cart-custom[c-displaycategoryacucar_displaycategoryacucar]').openModal();
                break
            case 'error':
                this.template.querySelector('c-modal-error-custom[c-displaycategoryacucar_displaycategoryacucar]').openModal();
                break
        }
    } 
}