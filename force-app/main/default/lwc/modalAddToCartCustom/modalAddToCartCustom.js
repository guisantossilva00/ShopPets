import { LightningElement,track, api } from 'lwc';
export default class ModalPopupLWC extends LightningElement {
    //Boolean tracked variable to indicate if modal is open or not default value is false as modal is closed when page is loaded 
    @track isModalOpen = false;
    @track link = '';

    @api
    openModal() {

        //async function check element
        const checkElement = async selector => {
            while (document.querySelector(selector) === null) {
                await new Promise(resolve => requestAnimationFrame(resolve))
            }
            return document.querySelector(selector);
        };

        //trigger update cart
        checkElement('.updateCart')
            .then((selector) => {
                selector.click();
            });


        //get attribute href and add link to modal button
        checkElement('.close__order')
        .then((selector) => {
           let linkToCart = selector.getAttribute('href');

           this.link = linkToCart;
        });

        // to open modal set isModalOpen tarck value as true
        this.isModalOpen = true;
    }
    closeModal() {
        // to close modal set isModalOpen tarck value as false
        this.isModalOpen = false;
    }
}