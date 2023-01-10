import { LightningElement, api, track, wire } from 'lwc';
import { registerListener, unregisterAllListeners } from 'c/pubsub';
import { CurrentPageReference  } from 'lightning/navigation';

export default class QuickAction extends LightningElement {
    @track 
    isQuickActionOpen = false;
    displayData;

    /**
     * Reference Page Data
     *
     * @type {string}
     */
    @wire (CurrentPageReference)
    pageRef;

    /**
    ** pubsub methods: method for transferring data between components
    ** get current product data
    **/
    connectedCallback() {
        registerListener('sendtoquickaction', this.handleCallback, this);
    }
    disconnectedCallback() {
        unregisterAllListeners(this);
    }

    handleCallback(prop) {
        console.log('prop', prop)
        console.log('prop.data', prop.categoriesData)
        // fetch product data from another component using the pubsub method
        this.displayData = prop;
    }

    changeCategory(evt) {
        this.dispatchEvent(
            new CustomEvent('quickactioncategory', {
                detail: evt.detail
            })
        );
        this.isQuickActionOpen = false;
    }
    changeFilters(evt) {
        this.dispatchEvent(
            new CustomEvent('quickactionfilters', {
                detail: evt.detail
            })
        );
        this.isQuickActionOpen = false;
    }


    @api
    openQuickAction() {
        // to open modal set isQuickActionOpen tarck value as true
        this.isQuickActionOpen = true;
    }
    closeQuickAction() {
        // to close modal set isQuickActionOpen tarck value as false
        this.isQuickActionOpen = false;
    }

    

    














    
}