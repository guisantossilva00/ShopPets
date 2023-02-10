import { LightningElement } from 'lwc';
import LogoShopPetz from '@salesforce/resourceUrl/logoShopPetz';
import { NavigationMixin } from 'lightning/navigation';


export default class HeaderLogin extends NavigationMixin(LightningElement) {
   logo = LogoShopPetz;
   urlHome;

   connectedCallback() {
      this[NavigationMixin.GenerateUrl]({
         type:'comm__namedPage',
         attributes: {
            name: 'Home'
            // actioName: 'Home'
         }
      }).then((url) => {
         this.urlHome = url;
         console.log('URL => '  + this.urlHome);
      });
   }
}