import { LightningElement, api, track} from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import suppliers  from '@salesforce/apex/saCreationController.suppliers';
import representatives from '@salesforce/apex/saCreationController.representatives';
import clients from '@salesforce/apex/saCreationController.clients';
import products from '@salesforce/apex/saCreationController.products';
import save from '@salesforce/apex/saCreationController.save';
import { getListUi } from 'lightning/uiListApi';

export default class SalesActionCreation extends LightningElement {

    //Tab Style
    @track detailStyle= "slds-tabs_default__item slds-is-active";
    @track clientStyle = "slds-tabs_default__item";
    @track productStyle = "slds-tabs_default__item";

    //Tabindex
    @track tabDetailInUse = 0;
    @track tabClientInUse = -1;
    @track tabProductInUse = -1;

    //Template Conditions
    @track detailOn = true;
    @track clientOn = false;
    @track productOn = false;

    //FIRST PAGE - DETAILS
    @api salesAction = { Id: null, SupplierCenterLkp__c: null, EndDateDte__c: null, StartDateDte__c: null, 
                        RepresentativeLkp__c: null, ObservationTxt__c: "", Name: "", Name__c: "",};
    @api supplierCenter = [];
    @api representative = [];
    @api today;

    //SECOND PAGE - CLIENTS
    @api clients = [];
    @api hasClientsAddeds = false;
    @api clientToAdd = null;
    @track clientsAddeds = [];
    @api clientsToRemove = [];

    //THIRD PAGE - PRODUCTS
    @api products = [];
    @api salesActionItensToInsert = [];
    @api positionActionItens = [];
    @track salesActionItens = [];
    @track hasProducts = false;
    @track finished = false;

    renderedCallback(){
        if(this.detailOn == true){
            this.putSelectedDetailValues();
        }
    }
    
    connectedCallback(){
        this.loadDetailsData(); 
        this.getDateToday();
        this.loadProductsData();
    }

    previousTab(){
        if(this.clientOn == true){
            this.showDetailTab();
        } else if(this.productOn == true){
            this.showClientTab();
        }
    }

    nextTab(event){
        if(this.detailOn == true){
            this.showClientTab();
        } else if(this.clientOn == true){
            this.showProductTab();
        }  else {
            this.save();
        }
    }

    detailValidation(){
        var success = true;
        if(this.salesAction.Name != null){
            this.salesAction.Name = this.salesAction.Name.trim();
        }

        if(this.salesAction.Name == null || this.salesAction.Name == ''){
            this.showToastValidation("Não é possível seguir para a próxima etapa.","O nome da ação de vendas deve ser preenchido.");
            success = false;
        } else if(this.salesAction.SupplierCenterLkp__c == null || this.salesAction.SupplierCenterLkp__c == ""){
            this.showToastValidation("Não é possível seguir para a próxima etapa.","O centro de distribuição deve ser selecionado.");
            success = false;
        } 
        else if(this.salesAction.RepresentativeLkp__c == null || this.salesAction.RepresentativeLkp__c == ""){
            this.showToastValidation("Não é possível seguir para a próxima etapa.","A equipe de Vendas deve ser selecionada.");
            success = false;
        }
        else if(this.salesAction.StartDateDte__c == null || this.salesAction.StartDateDte__c == ""){
            this.showToastValidation("Não é possível seguir para a próxima etapa.","A data de início deve ser selecionada.");
            success = false;
        }
        else if(this.salesAction.EndDateDte__c == null || this.salesAction.EndDateDte__c == ""){
            this.showToastValidation("Não é possível seguir para a próxima etapa.","A data de fim deve ser selecionada.");
            success = false;
        }
        else if(this.salesAction.EndDateDte__c < this.salesAction.StartDateDte__c){
            this.showToastValidation("Não é possível seguir para a próxima etapa.","A data de fim deve ser maior que a data de início.");
            success = false;
        }
        else if(this.salesAction.EndDateDte__c < this.today || this.salesAction.StartDateDte__c < this.today){
            this.showToastValidation("Não é possível seguir para a próxima etapa.","As datas de início e fim devem ser maiores ou iguais a data de hoje.");
            success = false;
        }
        return success;
    }

    clientNotSelected(){
        this.clientsAddeds = this.clients;
    }

    clientValidation(){
        if(this.hasClientsAddeds){
            return true;
        } else {
            if(this.clients.length == 0 && this.clientsAddeds.length == 0){
                this.showToastValidation("Não é possível seguir para a próxima etapa.","Nenhum cliente existente na organização, entre em contato com o administrador.");
                return false;
            } else {
                return true;
            }
        }
    }

    productValidation(){

       if(this.salesActionItensToInsert.length < 1){
          this.showToastValidation("Não é possível salvar.","Deve existir ao menos um item da ação de vendas.");
          return true;
       } else {
            var error = false;
            this.salesActionItensToInsert.forEach(element => {

            if(element.InitialVolumeNmb__c == null || element.InitialVolumeNmb__c == ''){
                this.showToastValidation("Não é possível salvar.","Preencha todos os volumes iniciais dos itens da ação de venda marcados.");
                error = true;

            } else if(element.EndVolumeNmb__c == null || element.EndVolumeNmb__c == ''){
                this.showToastValidation("Não é possível salvar.","Preencha todos os volumes finais dos itens da ação de venda marcados.");
                error = true;

            } else if(element.DiscountNmb__c == null || element.DiscountNmb__c == ''){
                this.showToastValidation("Não é possível salvar.","Preencha todos os descontos dos itens da ação de venda marcados.");
                error = true;

            } else if(Number(element.InitialVolumeNmb__c) <= 0){
                this.showToastValidation("Não é possível salvar.","Os volumes iniciais devem ser maiores que zero (0).");
                error = true;

            } else if(Number(element.EndVolumeNmb__c) > 9999){
                this.showToastValidation("Não é possível salvar.","Os volumes finais devem ser menores que dez mil (10.000).");
                error = true;
            } else if(Number(element.InitialVolumeNmb__c) >= Number(element.EndVolumeNmb__c)){  
                this.showToastValidation("Não é possível salvar.","Os valores iniciais devem ser menores que os valores finais.");
                error = true;
    
            } else if(Number(element.DiscountNmb__c) < 1){
                this.showToastValidation("Não é possível salvar.","O desconto dos itens devem ser maiores que zero (0).");
                error = true;

            } else if(Number(element.DiscountNmb__c) > 99){
                this.showToastValidation("Não é possível salvar.","O desconto dos itens devem ser menores que cem porcento (100%).");
                error = true;
            }
           });
           if(error == false){
               error = this.invalidVolume(); //Maybe need to remove with the rest of the code after last comment.
           } 
           return error;
       }
    }

    invalidVolume(){

        this.salesActionItensToInsert.sort((a, b) => {
            return a.InitialVolumeNmb__c - b.InitialVolumeNmb__c;
        });

        var error = false;
        this.salesActionItensToInsert.forEach(element => {
            var position = this.salesActionItensToInsert.indexOf(element);

            this.salesActionItensToInsert.forEach(innerElement => {
                if(innerElement.ProductLkp__c == element.ProductLkp__c 
                    && this.salesActionItensToInsert.indexOf(innerElement) > position){
                        if(Number(element.InitialVolumeNmb__c) >= Number(innerElement.InitialVolumeNmb__c)
                        || Number(element.EndVolumeNmb__c) >= Number(innerElement.InitialVolumeNmb__c)){
                        this.showToastValidation("Não é possível salvar.","Faixas de volumes incorretas, não podem existir faixas com abrangências iguais para o mesmo produto. Preencha de forma crescente, como: 1 ~ 30, 31 ~ 41...");
                        error = true;
                    }
                }
            });
        });
        return error;
    }

    getDateToday(){
        var date = new Date();
        var dd = String(date.getDate()).padStart(2, '0');
        var mm = String(date.getMonth() + 1).padStart(2, '0'); //January is 0.
        var yyyy = date.getFullYear();
        
        this.today = yyyy+'-'+mm+'-'+dd;
    }

    setObservation(event){
        this.salesAction.ObservationTxt__c = event.target.value;
    }

    setStartDate(event){
        this.salesAction.StartDateDte__c = event.target.value;
    }

    setEndDate(event){
        this.salesAction.EndDateDte__c = event.target.value;
    }

    setRepresentative(event){
        this.salesAction.RepresentativeLkp__c = event.target.value;
        this.setClients();
    }

    setSalesActionName(event){
        let name = event.target.value;
        this.salesAction.Name = name;
        this.salesAction.Name__c = name;
    }

    setSupplierCenter(event){
        this.salesAction.SupplierCenterLkp__c = event.target.value;
    }
    
    selectedClient(event){
        var id = event.target.value;
        if(id != "Todos"){
            for(let index = 0; index < this.clients.length; index++){
                if(id == this.clients[index].Id){
                    this.clientToAdd = this.clients[index];
                    
                    return;
                 }
            }
        } 
    }
 
    addClient(){
        if(this.clientToAdd != null && this.clientsAddeds.indexOf(this.clientToAdd) < 0){
            this.clientsAddeds.push(this.clientToAdd);
            this.clients.splice(this.clients.indexOf(this.clientToAdd), 1);
            this.hasClientsAddeds = true;
            this.clientToAdd = null;
        }
    }
    
    markToRemove(event){
        let checked = event.target.checked;
        if(checked){
            let index = this.clientsToRemove.indexOf(event.target.name);
            if(index == -1){
                this.clientsToRemove.push(event.target.name);
            } 
        } else {
            let index = this.clientsToRemove.indexOf(event.target.name);
            if(index != -1){
                this.clientsToRemove.splice(index, 1);
            } 
        }
    }

    removeClient(){
       this.clientsToRemove.forEach( id => {
            this.clientsAddeds.forEach( element => {
                let index = this.clientsAddeds.indexOf(element);
                if(this.clientsToRemove.indexOf(element.Id) != -1){
                    this.clients.push(element);
                    this.clientsAddeds.splice(index, 1);
                    return;
                }
            });
       });
       this.clientsToRemove = [];
       if(this.clientsAddeds.length == 0){
           this.hasClientsAddeds = false;
       }
    }

    setClients(){
        clients({representativeId : this.salesAction.RepresentativeLkp__c}).then((result) => {
            this.clients = result;
        })
        .catch((error) => {
            this.showToastCatchError();
            console.log(error);
        });
    }

    loadProductsData(){
        products({}).then((result) => {
            this.products = result;
            if(this.products != null && this.products.length > 0){
                this.hasProducts = true;
            }
            this.createActionItens();
        })
        .catch((error) => {
            this.showToastCatchError();
        });
    } 

    createActionItens(){
        this.products.forEach(element => {
            var actionItem = {
                Id: null,
                Name: element.Name,
                ProductLkp__c: element.Id,
                InitialVolumeNmb__c: null,
                EndVolumeNmb__c: null,
                DeliveryOption__c: null,
                DiscountNmb__c: null,
                SalesAction__c: null,
            }; 
            this.salesActionItens.push(actionItem);
        });
    }

    setInitialVolume(event){
        this.salesActionItens[event.target.name].InitialVolumeNmb__c = event.target.value;
    }

    setEndVolume(event){
        this.salesActionItens[event.target.name].EndVolumeNmb__c = event.target.value;
    }

    setDiscount(event){
        this.salesActionItens[event.target.name].DiscountNmb__c = event.target.value;
    }

    loadDetailsData(){

        suppliers({}).then((result) => {
            this.supplierCenter = result;
        })
        .catch((error) => {
            this.showToastCatchError();
            console.log(error);
        });

        representatives({}).then((result) => {
            this.representative = result;
        })
        .catch((error) => {
            this.showToastCatchError();
            console.log(error);
        });
    }

    putSelectedDetailValues(){
        var elements = this.template.querySelectorAll('option[data-supp]');
        if(elements != null){
            for(let index = 0; index < elements.length; index++){
                if(elements[index].value == this.salesAction.SupplierCenterLkp__c){
                    elements[index].selected = true;
                    break;
                }
            }
        }

        elements = this.template.querySelectorAll('option[data-rep]');
        if(elements != null){
            for(let index = 0; index < elements.length; index++){
                if(elements[index].value == this.salesAction.RepresentativeLkp__c){
                    elements[index].selected = true;
                    break;
                }
            }
        }
    }

    clearClientTab(){
        this.clientToAdd = null;
    }
    
    showDetailTab(){
        this.clearClientTab();
        this.detailStyle= "slds-tabs_default__item slds-is-active";
        this.clientStyle = "slds-tabs_default__item";
        this.productStyle = "slds-tabs_default__item";
        this.tabDetailInUse = 0;
        this.tabClientInUsetab = -1;
        this.tabProductInUse = -1;
        this.detailOn = true;
        this.clientOn = false;
        this.productOn = false;
    }

    showClientTab(){
        if(this.detailValidation()){
            this.detailStyle= "slds-tabs_default__item";
            this.clientStyle = "slds-tabs_default__item slds-is-active";
            this.productStyle = "slds-tabs_default__item";
            this.tabDetailInUse = -1;
            this.tabClientInUsetab = 0;
            this.tabProductInUse = -1;
            this.detailOn = false;
            this.clientOn = true;
            this.productOn = false;
        } else {
            this.showDetailTab();
        }
    }

    showProductTab(){
        this.clearClientTab();
        if(this.detailValidation()){
            if(this.clientValidation()){
                this.detailStyle= "slds-tabs_default__item";
                this.clientStyle = "slds-tabs_default__item";
                this.productStyle = "slds-tabs_default__item slds-is-active";
                this.tabDetailInUse = -1;
                this.tabClientInUsetab = -1;
                this.tabProductInUse = 0;
                this.detailOn = false;
                this.clientOn = false;
                this.productOn = true;
            } else {
                this.showClientTab();
            }
        } else {
            this.showDetailTab();
        }
      
    }

    save(){
        var hasError = this.productValidation();
        if(!hasError && this.finished == false){
            if(this.clientsAddeds.length == 0){
                if(this.clients.length > 0){
                    this.clientNotSelected();
                } else {
                    this.showToastValidation("Não é possível finalizar o processo de criação da ação de vendas.","Nenhum cliente existente na organização, entre em contato com o administrador.");
                    return;
                }
            } 
            this.finished = true;
            save({salesAction: this.salesAction, clients: this.clientsAddeds, salesActionItens: this.salesActionItensToInsert}).then(() => {
                const sucess = new ShowToastEvent({
                    title: 'Ação de vendas criada com sucesso!',
                    message: '',
                    variant: 'success',
                    mode: 'dismissable'
                });
                this.dispatchEvent(sucess);
                window.location.reload();
            })
            .catch((error) => {
                this.showToastCatchError();
                console.log(error);
            });
        } 
    }
    showToastCatchError(){
        const event = new ShowToastEvent({
            title: 'Ocorreu um erro durante o processamento!',
            message: 'Um erro inesperado ocorreu, tente novamente mais tarde ou entre em contato com um administrador.',
            variant: 'error',
            mode: 'sticky'
        });
        this.dispatchEvent(event);
    }

    showToastValidation(textTitle, textMessage){
        const event = new ShowToastEvent({
            title: textTitle,
            message: textMessage,
            variant: 'warning',
            mode: 'sticky'
        });
        this.dispatchEvent(event);
    }

    productCheckbox(event){
        var index = event.target.name;
        if(event.target.checked == true){
            if(this.positionActionItens.indexOf(index) == -1){
                this.salesActionItensToInsert.push(this.salesActionItens[index]);
                this.positionActionItens.push(index);
            }
        } else {
            var position = this.positionActionItens.indexOf(index);
            if(position != -1){
                this.salesActionItensToInsert.splice(position, 1);
                this.positionActionItens.splice(position, 1);
            }
        }
    }
    
    //PROCEDURES, DATA, AND FUNCTIONS THAT CAN BE REMOVED IN FUTURE - NOT DOCUMENTED
    @api productSelected; 
    
    productSelectedModal(event){
       this.productSelected = null;

       this.products.forEach(element => {
           if(event.target.value != "" && element.Id == event.target.value){
               this.productSelected = element;
               return;
           } 
       });
    }

    addProduct(){
        if(this.productSelected == null){
            return;
        }
        var actionItem = {
            Id: null,
            Name: this.productSelected.Name,
            ProductLkp__c: this.productSelected.Id,
            InitialVolumeNmb__c: null,
            EndVolumeNmb__c: null,
            DiscountNmb__c: null,
            SalesAction__c: null,
        }; 
        this.salesActionItens.push(actionItem);
    }
}