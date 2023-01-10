import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getAccount from '@salesforce/apex/ogSugarController.getAccount';
import getAddresses from '@salesforce/apex/ogSugarController.getAddresses';
import getProduct from '@salesforce/apex/ogSugarController.getProduct';
import getAllContractValues from '@salesforce/apex/ogSugarController.getAllContractValues';
import getTableValue from '@salesforce/apex/ogSugarController.getTableValue';
import save from '@salesforce/apex/ogSugarController.save';
import saveOrderItens from '@salesforce/apex/ogSugarController.saveOrderItens';
import deleteOrderItem from '@salesforce/apex/ogSugarController.deleteOrderItem';
import deleteOrder from '@salesforce/apex/ogSugarController.deleteOrder';
import getOrderName from '@salesforce/apex/ogSugarController.getOrderName';
import hasSalesActions  from '@salesforce/apex/ogSugarController.hasSalesActions';

export default class orderGenerationSugar extends LightningElement {

    @api today;
    @api recordId; //by aura component
    @api conditions = ["A vista", "Parcelado", "Futuro", "05 dias","..."];
    @api incoterm = ["CFR", "CIF", "CIP", "CPT", "DAF", "DAP", "DAT", "DDP", "DDU", "DEQ", "DES", "EXW", "FAZ", "FCA", "FH", "FOB", "SEM", "TER", "UM"];
    @api conditionName;

    @track orderName;

    //New Order data
    @api order;  

    //Others
    @api products = [];
    @api removedProducts = [];
    @api markedProducts = [];
    @api loadedContractValues = [];
    @api linesInTotal = [];
    @api productsWithSalesAction = [];

    @track showTable = false;
    @track orderItens = [];
    @track account = "";
    @track totalValue = 0;
    @track addresses = [];
    @track isModalOpen = false;
    
    connectedCallback(){
        this.init();
    }

    init(){
        this.getAccount();
        this.getAddresses();
        this.getProducts();
        this.getContractValues();
        this.getDateToday();
        this.generateOrder();
    }

    getName(){
        getOrderName({id : this.order.Id})
        .then((name) => {
            console.log("NAME => "+name);
            this.orderName = name;
        })
        .catch((error) => {
            this.showToastCatchError();
            console.log(error);
        });
    }

    getContractValues(){
        getAllContractValues({id : this.recordId})        
        .then((result) => {
            this.loadedContractValues = result;
        })
        .catch((error) => {
            this.showToastCatchError();
            console.log(error);
        });
    }

    getProducts(){
        getProduct()        
        .then((result) => {
            this.products = result;
        })
        .catch((error) => {
            this.showToastCatchError();
            console.log(error);
        });
    }

    getDateToday(){
        console.log("START GET DATE");
        var date = new Date();
        var dd = String(date.getDate()).padStart(2, '0');
        var mm = String(date.getMonth() + 1).padStart(2, '0'); //January is 0!
        var yyyy = date.getFullYear();
        
        this.today = yyyy+'-'+mm+'-'+dd;

    }

    getAddresses(){
        getAddresses({ accountId : this.recordId})        
        .then((result) => {
            this.addresses = result;
        })
        .catch((error) => {
            this.showToastCatchError();
            console.log(error);
        });
    }

    getAccount(){
        getAccount({ id : this.recordId})        
        .then((result) => {
            this.account = result;
        })
        .catch((error) => {
            this.showToastCatchError();
            console.log(error);
        });
    }

    generateOrder(){
        this.order = {
            Id: null,
            Name__c: null,
            Name: "Pedido - Açucar",
            AccountLkp__c: this.recordId,
            DeliveryOption__c: null,
            DeliveryAdrressLkp__c: null,
            TotalNmb__c: 0,
            ObservationLtxt__c: null,
            StatusOption__c: "",
        }; 
    }

    setIncoterm(event){
        this.order.DeliveryOption__c = event.target.value;
    }

    setOrderObservation(event){
        this.order.ObservationLtxt__c = event.target.value;
    }

    setAddress(event){
        this.order.DeliveryAdrressLkp__c = event.target.value;
    }

    setCondition(event){
        if(event.target.value == "Nenhum" && this.orderItens.length > 0){
            event.target.value = this.conditionName;
            this.showToastValidation("Não foi possível remover a condição de pagamento.","É necessário que uma opção de pagamento esteja selecionada para gerenciar os itens do pedido.");
            return;
        }
        this.conditionName = event.target.value;
        this.queryTableValuesIfExists();
    }

    validation(){
        if(this.order.Id != null && this.order.StatusOption__c == "Finalizado"){
            this.showToastValidation("O pedido não pode ser alterado.", "O pedido foi finalizado anteriormente, e não pode ser alterado.");
            return false;
        }
        if(this.order.DeliveryAdrressLkp__c == "Nenhum" || this.order.DeliveryAdrressLkp__c == null){
            this.showToastValidation("Preencha o endereço.", "O endereço de entrega deve ser preenchido para que o pedido seja finalizado.");
            return false;
        }
        if(this.order.DeliveryOption__c == "Nenhum" || this.order.DeliveryOption__c == null){
            this.showToastValidation("Preencha o Incoterm.", "A opção de entrega (Incoterm) deve ser preenchida para que o pedido seja finalizado.");
            return false;
        }
        if(this.conditionName == "Nenhum" || this.conditionName == null){
            this.showToastValidation("Preencha a Condição de pagamento.", "A condição de pagamento deve ser preenchida para que o pedido seja finalizado.");
            return false;
        }
        if(this.orderItens == null || this.orderItens.length == 0){
            this.showToastValidation("Deve existir ao menos um item do pedido.", "Ao menos um item do pedido deve ser adicionado para que o pedido seja finalizado.");
            return false;
        } else {
            let forResult = true;
            this.orderItens.forEach(element => {
                if(element.QuantityNmb__c == null || element.QuantityNmb__c <= 0){
                    this.showToastValidation("Preencha a quantidade dos itens.", "Preencha ou remova os itens do pedido que não possuem quantidade.");
                    forResult = false;
                    
                } else if(element.DateShipmentDte__c == null || element.DateShipmentDte__c < this.today){
                    this.showToastValidation("Preencha a data da remessa dos itens.", "Preencha ou remova os itens do pedido que não possuem data da remessa.");
                    forResult = false;
                    
                } else if(element.UnitaryValeuNmb__c == null || element.UnitaryValeuNmb__c <= 0){
                    this.showToastValidation("Preencha o valor unitário dos itens.", "Preencha ou remova os itens do pedido que não possuem valor unitário.");
                    forResult = false;
                } 
            });
            return forResult;
        }
    }

    saveHasDraft(event){
        let status = event.target.value;
        if(this.order.Id != null && this.order.StatusOption__c == "Finalizado"){
            this.showToastValidation("O pedido não pode ser alterado.", "O pedido foi finalizado anteriormente, e não pode ser alterado.");
            return false;
        } else if(status == "Em aberto"){
            this.saveOrder(status);
        } 
    }

    saveHasFinished(event){
        let status = event.target.value;
        if(status == "Finalizado" && this.validation()){
            this.saveOrder(status);
        } 
    }

    blockAll(){
        let elements = this.template.querySelectorAll("lightning-input");
        for(let index = 0; index < elements.length; index++){
            elements[index].disabled = true;
        }

        elements = this.template.querySelectorAll("lightning-textarea");
        for(let index = 0; index < elements.length; index++){
            elements[index].disabled = true;
        }

        elements = this.template.querySelectorAll("select");
        for(let index = 0; index < elements.length; index++){
            elements[index].disabled = true;
        }
    }

    saveOrder(status){
        this.order.StatusOption__c = status;
        this.order.TotalNmb__c = this.totalValue;
        save({ conditionName : this.conditionName, order : this.order})        
        .then((result) => {
           if(result != null){
             this.order = result;
             if(this.order.StatusOption__c == "Finalizado"){
                this.showToastSucessOrderData("Pedido enviado e finalizado com sucesso.");
             } else {
                if(this.order.Id != null){
                    this.showToastSucessOrderData("O pedido em aberto foi atualizado com sucesso.");
                } else {
                    this.showToastSucessOrderData("Um novo pedido em aberto foi criado com sucesso.");
                }
             }
             if(this.order.Id != null){
                this.saveAllOrderItens(this.order.Id);     
                this.getName();       
             }
             if(this.order.StatusOption__c == "Finalizado"){
                this.blockAll();
             }
           }
        })
        .catch((error) => {
            this.showToastCatchError();
            console.log(error);
        });
    }


    saveAllOrderItens(orderId){
        saveOrderItens({id : orderId, orderItens : this.orderItens})        
        .then((result) => {
           if(result != null){
              this.orderItens = result;
              this.showToastSucessOrderItensData();
           }
        })
        .catch((error) => {
            this.showToastCatchError();
            console.log(error);
        });
    }

    queryTableValuesIfExists(){
        if(this.conditionName != null && this.orderItens != null){
            var reg = /\D/g;
            this.orderItens.forEach(element => {
       
                if(String(value).match(reg)){
                    element.QuantityNmb__c = 0;
                }

                if(element.QuantityNmb__c != null){
                    getTableValue({productId : element.ProductLkp__c, quantity : element.QuantityNmb__c, conditionName : this.conditionName})        
                    .then((result) => {
                        let elements = this.template.querySelectorAll('span[title="Preço de tabela"]');
                        for(let index = 0; index < elements.length; index++){
                            if(elements[index].getAttribute("data-id") == element.ProductLkp__c){
                                elements[index].innerHTML= result;
                            }
                        }
                    })
                    .catch((error) => {
                        this.showToastCatchError();
                        console.log(error);
                    });
                }
            });
        }
    }

    todayDateAdjust(event){
        if(event.target.value < this.today){
            event.target.value = this.today;
            this.showToastAdjustData();
        } 
        this.orderItens.forEach(element => {
            if(element.ProductLkp__c == event.target.name){
                element.DateShipmentDte__c = event.target.value;
            }
        });
    }


    markedProduct(event){
        console.log(event.target.checked);
        let productPosition = event.target.name;
        if(event.target.checked == true){
            this.selectProduct(productPosition);
        } else {
            this.unselectProduct(productPosition);
        }
    }
    
    selectProduct(position){
        this.markedProducts.push(this.products[position]);
        console.log("SELECT: "+position+" // "+this.markedProducts.length);
    }

    unselectProduct(position){
        this.markedProducts.splice(position, 1);
        console.log("UNSELECT: "+position+" // "+this.markedProducts.length);
    }

    addItens(event){

        console.log("LIST SIZE: "+this.loadedContractValues.length);

        this.markedProducts.forEach(element => {
            let valueInContract = null;
            this.loadedContractValues.forEach(contract => {
                console.log("example");
                console.log("CONTRACT: "+contract.ProductLkp__c);
                console.log("CONTRACT: "+contract.ContractValeuNmb__c);
                if(contract.ProductLkp__c == element.Id && contract.ContractValeuNmb__c != null){
                    valueInContract = contract.ContractValeuNmb__c;
                }
            });
            console.log("value: "+valueInContract);

            let orderItem = {
                Id: null,
                Name: element.Name,
                Account__c: this.recordId,
                DateShipmentDte__c: this.today,
                ProductLkp__c: element.Id,
                QuantityNmb__c: null,
                FinalVolumeNmb__c: null,
                TotalNmb__c: 0,
                UnitaryValeuNmb__c: valueInContract,
                DiscountNmb__c: null,
                SalesContractNmb__c: valueInContract,
            }; 
            this.orderItens.push(orderItem);
            this.removedProducts.push(element);
            this.products = this.products.filter(x => x !== element);

        });
        this.showTable = true;
        this.markedProducts = [];
        this.productsWithSalesAction = [];
        this.closeModal();
        this.queryTableValuesIfExists();
    }

    valueCalculationWithTable(event){
        let id = event.target.name;
        this.valueCalculation(event);
        let value = event.target.value;
        var reg = /\D/g;
       
        if(String(value).match(reg)){
            event.target.value = null;
            return;
        }
        if(value == null || value == ""){
            event.target.value = null;
            return;
        }

        getTableValue({productId : id, quantity : value, conditionName : this.conditionName})        
        .then((result) => {
            let elements = this.template.querySelectorAll('span[title="Preço de tabela"]');
            for(let index = 0; index < elements.length; index++){
                if(elements[index].getAttribute("data-id") == id){
                    elements[index].innerHTML= result;
                }
            }
        })
        .catch((error) => {
            this.showToastCatchError();
            console.log(error);
        });
    }
    

    valueCalculation(event){
        console.log("Enter v.c");
        let value = event.target.value;
        //Adjust
        if(value != null){
            if(value < 0){
                event.target.value = 0;
                this.showToastAdjustData();
            }
            if(event.target.title == "Quantidade" && value > 9999){
                event.target.value = 9999;
                this.showToastAdjustData();
            }
            if(event.target.title == "Valor unitário" && value > 99.99){
                event.target.value = 99.99;
                this.showToastAdjustData();
            }
            if(event.target.title == "Desconto" && value > 5.00){
                event.target.value = 5.0;
                this.showToastAdjustData();
            } 
            
            value = event.target.value;
        }    

        this.orderItens.forEach(element => {

            if(element.ProductLkp__c == event.target.name){
                
                //Remove old value from main total
                let positionInTotal = this.linesInTotal.indexOf(event.target.name)
                if(positionInTotal != -1 && element.TotalNmb__c != null){
                    this.totalValue = this.totalValue - element.TotalNmb__c;
                    this.linesInTotal.splice(positionInTotal, 1);
                }

                if(event.target.title == "Quantidade"){
                    element.QuantityNmb__c = value;
                } else if(event.target.title == "Valor unitário") {
                    element.UnitaryValeuNmb__c = value;
                } else {
                    element.DiscountNmb__c = value;
                }
              
                element.TotalNmb__c = element.QuantityNmb__c * element.UnitaryValeuNmb__c;     
                if(element.DiscountNmb__c != null && element.DiscountNmb__c > 0){
                    element.TotalNmb__c = element.TotalNmb__c - (element.TotalNmb__c * element.DiscountNmb__c / 100);
                } 

                //Add new value to main total
                if(element.TotalNmb__c != null){
                    this.totalValue = this.totalValue + element.TotalNmb__c;
                    this.linesInTotal.push(event.target.name);
                }
            }
        });
    }

    hasSalesAction(){
        hasSalesActions({products : this.products})
        .then((result) => {
            this.productsWithSalesAction = result
        })
        .catch((error) => {
            this.showToastCatchError();
            console.log(error);
        });
    }

    openModal(event){

        let status = this.order.StatusOption__c;
        if(status == "Finalizado"){
            this.showToastValidation("Ação bloqueada", "O pedido foi finalizado anteriormente e não pode ser alterado.");
            return;
        } 
        if(this.conditionName == "Nenhum" || this.conditionName == null){
            this.showToastValidation("Selecione uma condição de pagamento", "Para adicionar itens do produto é necessário selecionar a condição de pagamento.");
            return;
        }
        this.isModalOpen = true;
        this.hasSalesAction();

    }

    closeModal(event){
        this.isModalOpen = false;
    }   

    deleteSelectedItem(event){
        
        let value = this.orderItens[event.target.name].TotalNmb__c;
        let id = this.orderItens[event.target.name].Id;
        let status = this.order.StatusOption__c;
        var deleteItem = true;

        if(status == "Finalizado"){
            this.showToastValidation("Ação bloqueada", "O pedido foi finalizado anteriormente e não pode ser alterado.");
            return;
        } 
        
        if(id != null){
            console.log("Enter");
            deleteOrderItem({orderItemId : id})
            .then(() => {})
            .catch((error) => {
                deleteItem = false;
                this.showToastCatchError();
                console.log(error);
            });
        }
            
        if(deleteItem == true){
        
            this.totalValue = this.totalValue - value;
            if(this.totalValue <= 0){
                this.totalValue = 0;
            } 
            
            this.orderItens.splice(event.target.name, 1);
            this.products.push(this.removedProducts[event.target.name]);
            this.removedProducts.splice(event.target.name, 1);
            this.queryTableValuesIfExists();

            if(this.orderItens != null && this.orderItens.length == 0){
                this.showTable = false;
            }
        }
    }

    componentExit(){
        const close = new CustomEvent('close');
        this.dispatchEvent(close);
    }

    deleteOrder(){
        if(this.order.Id != null && this.order.StatusOption__c != "Finalizado"){
            deleteOrder({orderId : this.order.Id})
            .then(() => {
                //DELETE MESSAGE HERE
                this.orderName = "";
                this.order.Id = null;
                if(this.orderItens != null && this.orderItens)
                this.orderItens.forEach(element => {
                    element.Id = null;
                });
            })
            .catch((error) => {
                this.showToastCatchError();
                console.log(error);
            });
        } else {
            if(this.order.Id == null){
                this.showToastValidation("Não foi possível deletar o pedido", "O pedido não foi salvo/enviado anteriormente.");
            } else {
                this.showToastValidation("Não foi possível deletar o pedido", "O pedido foi finalizado anteriormente, e não pode ser excluído.");
            }
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

    showToastAdjustData(){
        const sucess = new ShowToastEvent({
            title: 'Valor ajustado.',
            message: 'O valor inserido foi ajustado dentro dos limites predefinidos.',
            variant: 'default',
            mode: 'dismissable'
        });
        this.dispatchEvent(sucess);
    }

    showToastSucessOrderData(message){
        const sucess = new ShowToastEvent({
            title:  message,
            message: '',
            variant: 'success',
            mode: 'dismissable'
        });
        this.dispatchEvent(sucess);
    }

    showToastSucessOrderItensData(){
        const sucess = new ShowToastEvent({
            title: 'Os itens do pedido foram criados/atualizados com sucesso.',
            message: '',
            variant: 'success',
            mode: 'dismissable'
        });
        this.dispatchEvent(sucess);
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
}