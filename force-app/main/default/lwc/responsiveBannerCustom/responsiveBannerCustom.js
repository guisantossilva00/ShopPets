import { LightningElement, api } from 'lwc';

export default class ResponsiveBannerCustom extends LightningElement {
    @api
    smallImageUrl

    @api
    largeImageUrl

    @api
    linkToCategory
    

    get isMobile() {
        return window.screen.width < 768 ? true : false;
    }
}