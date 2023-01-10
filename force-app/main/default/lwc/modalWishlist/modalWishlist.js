import { LightningElement, track, api, wire } from 'lwc';
import { NavigationMixin, CurrentPageReference } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import communityId from '@salesforce/community/Id';

import getWishlist from '@salesforce/apex/B2BGetInfo.getWishlist';
import addProductToWishlist from '@salesforce/apex/B2BGetInfo.addProductToWishlist';
import createAndAddToList from '@salesforce/apex/B2BGetInfo.createAndAddToList';
import effectiveAccountValueID from '@salesforce/apex/ProductController.effectiveAccountValueID';

import { registerListener, unregisterAllListeners } from 'c/pubsub';

export default class ModalWishlist extends NavigationMixin(LightningElement) {
    @track isModalOpen = false;

    // All existing favorite lists
    @track wishlistData;
    
    _includeDisplayedList = true;

    /**
     * Current List Name
     * 
     * @type {string}
     */
    @track
    _currentListName;

    /**
     * Current radio button value
     * 
     * @type {string}
     */
    _radioButton;

    /**
     * Product Data
     *
     * @type {string}
     */
    @api 
    _productData;


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
        registerListener('sendtomodal', this.handleCallback, this);
    }
    disconnectedCallback() {
        unregisterAllListeners(this);
    }

    handleCallback(prop) {
        // fetch product data from another component using the pubsub method
        this._productData = prop.data;
        this._currentListName = prop.data.fields.Name;
    }

    /**
    * Radio Button: add new list option
    **/ 
    optionsCreate = [
        { label: 'Criar uma lista', value: 'createList' }
    ];

    /**
    * Radio button: all existing list options 
    **/ 
    optionsList = [
        { label: 'Adicionar a uma lista existente', value: 'getList' }
    ];
        
    /**
    * Handle change input radio
    * Default value of the radio buttons
    **/ 
    _selectedRadioButtonOption = 'createList';
    _wishlistNameInputDisabled = false;
    _buttonDisabledValue = false;
    _comboboxDisabledValue = true;

    handleRadioChange(event) {
        const selectedOption = event.detail.value;

        //toggle buttton enable/disabled
        switch (selectedOption) {
            case "createList":
                this._buttonDisabledValue = false;
                this._wishlistNameInputDisabled = false;
                this._selectedRadioButtonOption = selectedOption;
                break;

            case "getList":
                this._buttonDisabledValue = true;
                this._comboboxDisabledValue = false;
                this._wishlistNameInputDisabled = true;
                this._selectedRadioButtonOption = selectedOption;
                break;
        }
    }

   
    @api
    async openModal() {
        getWishlist ({
            communityId: communityId,
            effectiveAccountId: await effectiveAccountValueID(),
            includeDisplayedList: this._includeDisplayedList,
        })
        .then((result) => {
            this.wishlistData = result.summaries;
            
            // to open modal set isModalOpen tarck value as true
            this.isModalOpen = true;
        })
        .catch((err) => {
            console.log(err)
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message:
                        '{0} could not be added to a new list. Please make sure you have fewer than 10 lists or try again later',
                    messageData: [this.displayableProduct.name],
                    variant: 'error',
                    mode: 'dismissable'
                })
            );
        });
    }

    /**
    * Listen to change event in wishlist input
    * */
    changeHandler(event) {
        this._currentListName = event.target.value;
        
        this._targetWishlistId = event.target.options.filter((el)=> {
            return this._currentListName == el.value
        })[0].description;
        
        if(this._selectedRadioButtonOption == "getList") {
            addProductToWishlist({
                communityId: communityId,
                wishlistId: this._targetWishlistId,
                productId: this._productData.id
            })
            .then((result) => {
                this.isModalOpen = false;
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: `${this._productData.fields.Name} adicionado à lista ${this._currentListName}`,
                        variant: 'success',
                        mode: 'dismissable'
                    })
                );
            })
            .catch((error) => {
                console.log(error)
            })
        }
    }

    async handleCreateAndAddToList(event) {
        createAndAddToList({
            communityId: communityId,
            productId: this._productData.id,
            wishlistName: this._currentListName,
            effectiveAccountId: await effectiveAccountValueID()
        })
        .then((result) => {
            this.isModalOpen = false;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: `Criada a lista ${this._currentListName} e produto ${this._productData.fields.Name} foi adicionado`,
                    variant: 'success',
                    mode: 'dismissable'
                })
            );

        })
        .catch((error) => {
            console.log('error', error);
        })
    }

    /**
    ** Gets wishlist options
    ** montando o select de minhas listas
    **/
    get options() {
        var returnOptions = [];
        if(this.wishlistData){
            this.wishlistData.forEach(wishitem =>{
                returnOptions.push({label:wishitem.name , value:wishitem.name, description: wishitem.id });
            }); 
        }

        return returnOptions;
    }

    closeModal() {
        // to close modal set isModalOpen track value as false
        this.isModalOpen = false;
    }
}