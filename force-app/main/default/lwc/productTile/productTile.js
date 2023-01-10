import { LightningElement, api, wire, track } from 'lwc';

// getImageId() method in ProductController Apex class
import getImageId from '@salesforce/apex/ProductController.getImageId';
import getCartIdController from '@salesforce/apex/miniCartCustomController.getCartIdController';
import updateCartController from '@salesforce/apex/miniCartCustomController.updateCartController';
import getFirstCartItem from '@salesforce/apex/ProductController.getFirstCartItem';
import createCart from '@salesforce/apex/ProductController.createCart';
import createCartItem from '@salesforce/apex/ProductController.createCartItem';
import getProductPrice from '@salesforce/apex/ProductController.getProductPrice';
import isSameType from '@salesforce/apex/CartTypeController.isSameType';

/**
 * A presentation component to display a Product2 sObject. The provided
 * Product2 data must contain all fields used by this component.
 */
export default class ProductTile extends LightningElement {
    /** Whether the tile is draggable. */
    @api draggable;
    quantity = 1;

    _product;
    qtyErrorValue;
    
    @api
    get product() {
        return this._product;
    }
    set product(value) {
        this._product = value;
        this.name = value.Name;
        this.description = value.Description;
        this.productLink = '/s/product/' + value.Id;
        this.productId = value.Id;
    }

    @wire(getImageId, { productId: '$productId'})
    imageURl({ error, data }) {
        if (data) {
            this.pictureUrl = data;
        } else if (error) {
            this.pictureUrl = '/s/sfsites/c/img/b2b/default-product-image.svg';
        }
    }

    @wire(getProductPrice, { productId: '$productId'})
    price({ error, data }) {
        if (data) {
            this.productPrice = data;
        } else if (error) {
            this.productPrice = '100';
        }
    }

    // Product2 field values to display
    name;
    pictureUrl;
    productPrice;
    valor = 100;
    
    changeHandler(event) {
        if (event.target.value < 1){
            this.quantity = 1;
            event.target.value = 1;
        }else if(event.target.value > 999) {
            this.quantity = 999;
            event.target.value = 999;
        }else{
            this.quantity = event.target.value;
        }
    }
    handleClickMore() {
        if (this.quantity < 999){
            this.quantity = parseInt(this.quantity) + 1;
        }else {
            this.qtyErrorValue = "A quantidade máxima é 999."
            setTimeout(() => {
                this.qtyErrorValue = "";                
            }, 2000);
        }
    }

    handleClickLess() {
        if (this.quantity > 1){
            this.quantity = parseInt(this.quantity) - 1;
        }else {
            this.qtyErrorValue = "A quantidade mínima é 1."
            setTimeout(() => {
                this.qtyErrorValue = "";                
            }, 2000);
        }
    }

    handleClickComprar() { 
        getCartIdController({})
        .then((result) => {
            this.cartId = result;

            if (this.cartId == null){

                createCart({}).then((result) => {
                    this.CartId = result;
                })
                .catch((error) => {
                    console.log(error);
                });
            }else{
                getFirstCartItem({cartId : this.cartId, productId : this.productId})
                .then((result) => {
                    this.cartItem = result;                   

                    if(this.cartItem){
                        isSameType({cartId : this.cartId,  productId : this.productId})
                        .then((result) => {
                            if(result) {
                                if(this.cartItem == this.productId) {
                                    updateCartController({ cartId : this.cartId, cartItem : this.cartItem, origin : 'carousel', quantity : this.quantity })
                                    .then((result) => {
                                        this.updateMiniCart = result;
                                        this.dispatchEvent(new CustomEvent('addtocartcustom', {'detail': 'add'}));
                                    })
                                    .catch((error) => {
                                        console.log(error);
                                    });
                                }else {
                                    createCartItem({ cartId : this.cartId,  productId : this.productId, quantity : this.quantity}).then((result) => {
                                        this.newCartItem = result;
                                        this.dispatchEvent(new CustomEvent('addtocartcustom', {'detail': 'add'}));
                                    })
                                    .catch((error) => {
                                        console.log(error);
                                    })
                                }
                            }else {
                                this.dispatchEvent(new CustomEvent('addtocartcustom', {'detail': 'error'}));
                            }
                        })
                    }else{
                        createCartItem({ cartId : this.cartId,  productId : this.productId, quantity : this.quantity}).then((result) => {
                            this.newCartItem = result;
                            this.dispatchEvent(new CustomEvent('addtocartcustom', {'detail': 'add'}));
                        })
                        .catch((error) => {
                            console.log(error);
                        });
                    }
                })
                .catch((error) => {
                    console.log(error);
                });
            }      
        })
        .catch((error) => {
            console.log(error);
        });
    }
}