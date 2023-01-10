// This component is very similar to the productTilelist LWC in the E-Bikes Sample app
// https://github.com/trailheadapps/ebikes-lwc

import { LightningElement, api, wire, track } from 'lwc';

//Ligthning Message Service and message channels
//import { publish, MessageContext } from 'lightning/messageService';
//import PRODUCT_SELECTED_MESSAGE from '@salesforce/messageChannel/ProductSelected__c';


// getProducts() method in ProductController Apex class
import getProducts from '@salesforce/apex/ProductController.getProducts';
import getCategoryAcucar from '@salesforce/apex/ProductController.getCategoryAcucar';

export default class DisplayProducts extends LightningElement {
    
    @api searchBarIsVisible = false;
    @api tilesAreDraggable = false;
    @api categoriaAcucar = false;
    @api categoriaAlcool = false;
    @api maisVendidos = false;
    @track categoriaA;

    connectedCallback() {
        this.categoriaA = this.categoriaAcucar;
    }

    pageNumber = 1;
    totalItemCount = 0;
    pageSize;

    // Load context for Ligthning Messaging Service 
    //@wire(MessageContext) messageContext;
   
     // Load the list of available products.
    @wire(getProducts, { pageNumber: '$pageNumber' })
    products;

    @wire(getCategoryAcucar, { pageNumber: '$pageNumber' })
    productsAcucar;

    //products = productsSellers.;

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

}