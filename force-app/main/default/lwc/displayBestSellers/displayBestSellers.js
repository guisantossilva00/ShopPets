import { LightningElement, wire } from 'lwc';

// getCategoryAcucar() method in ProductController Apex class
import getProducts from '@salesforce/apex/ProductController.getProducts';
// import getPageSize from '@salesforce/apex/ProductController.getPageSize';

export default class DisplayBestSellers extends LightningElement {
    pageNumber = 1;
    totalItemCount = 0;
    screenSize = window.innerWidth;

    
    @wire(getProducts, { pageNumber: '$pageNumber', screenSize: '$screenSize' })
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
                this.template.querySelector('c-modal-add-to-cart-custom[c-displaybestsellers_displaybestsellers]').openModal();
                break
            case 'error':
                this.template.querySelector('c-modal-error-custom[c-displaybestsellers_displaybestsellers]').openModal();
                break
        }
    } 
}