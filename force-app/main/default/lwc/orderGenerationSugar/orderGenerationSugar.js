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
import getDeliveryOption  from '@salesforce/apex/ogSugarController.getDeliveryOption';
import getPaymentOption  from '@salesforce/apex/ogSugarController.getPaymentOption';
import getTeams from '@salesforce/apex/ogSugarController.getTeams';
import getAreas from '@salesforce/apex/ogSugarController.getAreas';

export default class orderGenerationSugar extends LightningElement {

    //New Order data
    @api order;  

    @api today;
    @api recordId; //by aura component
    @api conditions = [];
    @api incoterm = [];
    @api conditionId;
    @api teams = [];

    @track areas = [];
    @track orderName;

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
    @track block = false;

    connectedCallback(){
        this.init();
    }

    init(){
        this.getAccount();
        this.getAddresses();
        this.getContractValues();
        this.getDateToday();
        this.generateOrder();
        this.getDelivery();
        this.getCustomerTeams();
    }

    getCustomerTeams(){
        getTeams({customer : this.recordId}).then((result) => {
            this.teams = result;
        })
        .catch((error) => {
            this.showToastCatchError();
            console.log(error);
        });
    }

    getDelivery(){
        getDeliveryOption({})
        .then((result) => {
            this.incoterm = result;
        })
        .catch((error) => {
            this.showToastCatchError();
            console.log(error);
        });
    }

    getPayment(){
        getPaymentOption({team : this.order.SalesTeamLkp__c, customer : this.recordId})
        .then((result) => {
            this.conditions = result;
        })
        .catch((error) => {
            this.showToastCatchError();
            console.log(error);
        });
    }

    getName(){
        getOrderName({id : this.order.Id})
        .then((name) => {
            this.orderName = 'Pedido - '+name;
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

    getProducts(areaId){
        getProduct({area : areaId})        
        .then((result) => {
            this.products = result;
            console.log(this.products);
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
            Name: "Pedido - Açucar",
            AccountId: this.recordId,
            DeliveryOption__c: null,
            paymentCondition__c: null,
            ContactPointAddressLkp__c: null,
            TotalNmb__c: 0,
            ObservationLtxt__c: null,
            Status: 'Rascunho',
            SalesTeamLkp__c: null,
            SalesAreaLkp__c: null,
        }; 
    }

    setTeam(event){
        if(this.orderItens.length > 0){
            event.target.value = this.order.SalesTeamLkp__c;
            this.showToastValidation("Não foi possível alterar a equipe de venda.","A equipe não pode ser alterada se já existir itens do pedido.");
            return;
        }
        if(event.target.value != "Nenhum"){
            this.order.SalesTeamLkp__c = event.target.value;        
            this.getPayment(event.target.value);
        } else {
            this.order.SalesTeamLkp__c = null;
        }
        this.getArea();
    }
    
    getArea(){
        if(this.order.paymentCondition__c != null && this.order.SalesTeamLkp__c != null && this.order.DeliveryOption__c != null ){
            getAreas({ customer : this.order.AccountId, condition : this.order.paymentCondition__c, team : this.order.SalesTeamLkp__c, incotermPickList : this.order.DeliveryOption__c})        
            .then((result) => {
                this.areas = result;
            })
            .catch((error) => {
                this.showToastCatchError();
                console.log(error);
            });
        } 
        this.order.SalesAreaLkp__c = null;
    }

    setArea(event){
        if(this.orderItens.length > 0){
            event.target.value = this.order.SalesAreaLkp__c;
            this.showToastValidation("Não foi possível alterar a area de vendas.","A área de vendas não pode ser alterada se já existir itens do pedido.");
            return;
        }
        if(event.target.value != "Nenhum"){
            this.order.SalesAreaLkp__c = event.target.value;
            this.getProducts(event.target.value);
        } else {
            this.order.SalesAreaLkp__c = null;
        }
    }

    setIncoterm(event){
        if(event.target.value != "Nenhum"){
            this.order.DeliveryOption__c = event.target.value;
        } else {
            this.order.DeliveryOption__c = null;
        }
    }

    setOrderObservation(event){
        this.order.ObservationLtxt__c = event.target.value;
    }

    setAddress(event){
        if(event.target.value != "Nenhum"){
            this.order.ContactPointAddressLkp__c = event.target.value;
        } else {
            this.order.ContactPointAddressLkp__c = null;
        }
    }

    setCondition(event){
        if(this.orderItens.length > 0){
            event.target.value = this.order.paymentCondition__c;
            this.showToastValidation("Não foi possível alterar a condição de pagamento.","A condição de pagamento não pode ser alterada se já existir itens do pedido.");
            return;
        }
        if(event.target.value != "Nenhum"){
            this.order.paymentCondition__c = event.target.value;
        } else {
            this.order.paymentCondition__c = null;
        }
        this.getArea();
    }

    validation(){
        if(this.account.isActive__c == false){
            this.showToastValidation("Cliente inativo.", "O pedido não foi criado, o cliente não possui cadastro ativo.");
            return false;
        }
        if(this.block){
            this.showToastValidation("O pedido não pode ser alterado.", "O pedido foi finalizado anteriormente, e não pode ser alterado.");
            return false;
        }
        if(this.order.ContactPointAddressLkp__c == "Nenhum" || this.order.ContactPointAddressLkp__c == null){
            this.showToastValidation("Preencha o endereço.", "O endereço de entrega deve ser preenchido para que o pedido seja salvo.");
            return false;
        }
        if(this.order.SalesTeamLkp__c == "Nenhum" || this.order.SalesTeamLkp__c == null){
            this.showToastValidation("Preencha a equipe de venda.", "A equipe de vendas deve ser preenchida para que o pedido seja salvo.");
            return false;
        }
        if(this.order.DeliveryOption__c == "Nenhum" || this.order.DeliveryOption__c == null){
            this.showToastValidation("Preencha o Incoterm.", "A opção de entrega (Incoterm) deve ser preenchida para que o pedido seja salvo.");
            return false;
        }
        if(this.order.paymentCondition__c  == "Nenhum" || this.order.paymentCondition__c  == null){
            this.showToastValidation("Preencha a Condição de pagamento.", "A condição de pagamento deve ser preenchida para que o pedido seja salvo.");
            return false;
        }
        if(this.order.SalesAreaLkp__c == "Nenhum" || this.order.SalesAreaLkp__c == null){
            this.showToastValidation("Preencha o área de venda.", "A área de venda deve ser preenchida para que o pedido seja salvo.");
            return false;
        }
        if(this.orderItens == null || this.orderItens.length == 0){
            this.showToastValidation("Deve existir ao menos um item do pedido.", "Ao menos um item do pedido deve ser adicionado para que o pedido seja salvo.");
            return false;
        } else {
            let forResult = true;
            this.orderItens.forEach(element => {
                if(element.Quantity == null || element.Quantity <= 0){
                    this.showToastValidation("Preencha a quantidade dos itens.", "Preencha ou remova os itens do pedido que não possuem quantidade.");
                    forResult = false;
                } else if(element.Quantity > 9999){
                    this.showToastValidation("A quantidade de cada item deve ser inferior a 9999.", "Altere os itens do pedido que não possuem quantidade válida.");
                    forResult = false;
                } else if(element.DateShipmentDte__c == null || element.DateShipmentDte__c < this.today){
                    this.showToastValidation("Preencha a data da remessa dos itens.", "Preencha ou remova os itens do pedido que não possuem data da remessa.");
                    forResult = false;
                } else if(element.UnitPrice == null || element.UnitPrice <= 0){
                    this.showToastValidation("Preencha o valor unitário dos itens.", "Preencha ou remova os itens do pedido que não possuem valor unitário.");
                    forResult = false;
                } 
            });
            return forResult;
        }
    }

    blockAll(){
        this.block = true;
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

    saveAll(event){
        var status = event.target.value;
        if(this.block){
            this.showToastValidation("O pedido não pode ser alterado.", "O pedido foi finalizado anteriormente, e não pode ser alterado.");
        } else if(status == "Rascunho" || status == "Finalizado"){
            this.saveOrder(status);
        }
    }

    saveOrder(status){
        this.order.AccountId = this.account.Id;
        this.order.TotalNmb__c = this.totalValue;
        this.order.DateShipmentDte__c = this.DateShipmentDte__c;
        if(this.validation() == true){
            this.upsertOrder(status);
        }
    }

    upsertOrder(status){
        save({order : this.order})        
        .then((result) => {
            this.order.Id = result;
            this.showToastSucessOrderData("Operação realizada com sucesso!");
             if(this.order.Id != null){
                this.getName(); 
             }
            this.upsertOrderItens(status);
        })
        .catch((error) => {
            this.showToastCatchError();
            console.log(error);
        });
    }   

    upsertOrderItens(status){
        saveOrderItens({salesOrder : this.order, orderItens : this.orderItens, orderStatus : status}).
        then((items) => {
            this.orderItens.forEach(element => {
                let position = this.orderItens.indexOf(element);
                element.Id = items[position];
                element.OrderId = this.order.Id;
            });   
            if(status == "Finalizado"){
                this.order.status = "Finalizado";
                this.blockAll();
            }   
        }).catch((error) => {
            this.showToastCatchError();
            console.log(error);
        });
    }
        
     todayDateAdjust(event){
        if(event.target.value < this.today){
            event.target.value = this.today;
            this.showToastAdjustData();
        } 
        this.orderItens.forEach(element => {
            if(element.Product2Id == event.target.name){
                element.DateShipmentDte__c = event.target.value;
            }
        });
    }


    markedProduct(event){
        let productPosition = event.target.name;
        if(event.target.checked == true){
            this.selectProduct(productPosition);
        } else {
            this.unselectProduct(productPosition);
        }
    }
    
    selectProduct(position){
        this.markedProducts.push(this.products[position]);
    }

    unselectProduct(position){
        this.markedProducts.splice(position, 1);
    }

    addItens(event){

        if(this.markedProducts.length == 0){
            this.showToastValidation("Selecione um produto.","Selecione pelo menos um produto para inserir na lista.");
            return;
        }


        this.markedProducts.forEach(element => {
            /*
            this.loadedContractValues.forEach(contract => {
                console.log("example");
                console.log("CONTRACT: "+contract.ProductLkp__c);
                console.log("CONTRACT: "+contract.ContractValeuNmb__c);
                if(contract.ProductLkp__c == element.Id && contract.ContractValeuNmb__c != null){
                    valueInContract = contract.ContractValeuNmb__c;
                }
            });
            console.log("value: "+valueInContract);
            */
            let orderItem = {
                Id: null,
                Name: element.Name,
                Account__c: this.recordId,
                DateShipmentDte__c: this.today,
                Product2Id: element.Id,
                BasicUnitTxt__c: element.BasicUnitTxt__c,
                Quantity: null,
                OrderId: null,
                TotalNmb__c: 0,
                UnitPrice: 0,
                DiscountNmb__c: null,
                SalesContractNmb__c: null,
                valueTable: 0,
                oldValue: 0,
            }; 
            /*
            if(valueInContract != null){
                orderItem.valueTable = valueInContract;
            }
            */
            this.orderItens.push(orderItem);
            this.removedProducts.push(element);
            this.products = this.products.filter(x => x !== element);

        });
        this.showTable = true;
        this.markedProducts = [];
        this.productsWithSalesAction = [];
        this.closeModal();
    }

    valueCalculation(event){

        let value = event.target.value;

        //Adjust
        if(value != null){
            if(value < 0){
                event.target.value = 0;
                this.showToastAdjustData();
            }

            if(event.target.title == "Desconto" && value > 5.00){
                event.target.value = 5.0;
                this.showToastAdjustData();
            }

            if(event.target.title == "Valor unitário" && value > 999){
                event.target.value = 999;
                this.showToastAdjustData();
            }

            if(event.target.title == "Quantidade"){
                this.orderItens.forEach(item => {
                    if(item.Product2Id == event.target.name){
                        if(event.target.value > 0){ 
                            getTableValue({customerDomicile : this.account.TaxDomicileTxt__c, productId : event.target.name, salesAreaId : this.order.SalesAreaLkp__c, paymentConditionId : this.order.paymentCondition__c, quantity : event.target.value})
                            .then((result) => {
                                item.valueTable = result;
                            })
                            .catch((error) => {
                                this.showToastCatchError();
                                console.log(error);
                            });
                        } else {
                            item.valueTable = 0;
                        }
                    }
                });
            }
            
            if(event.target.title == "Valor unitário"){ 
                this.orderItens.forEach(item => {
                    if(item.Product2Id == event.target.name){
                        if(Number(event.target.value) < Number(item.valueTable)){
                            event.target.value = item.valueTable;
                            item.DiscountNmb__c = null;
                            this.showToastAdjustData();
                        } else if(Number(item.valueTable) == 0){
                            event.target.value = item.valueTable;
                            item.DiscountNmb__c = null;
                            this.showToastValidation("Não foi possível definir um valor", "É necessário que o valor para o volume indicado seja configurado pelos administradores.");
                        }
                    }
                });
            }

            value = event.target.value;
        }

        this.orderItens.forEach(element => {

            if(element.Product2Id == event.target.name){
                
                //Remove old value from main total
                let positionInTotal = this.linesInTotal.indexOf(event.target.name)
                if(positionInTotal != -1 && element.TotalNmb__c != null){
                    this.totalValue = this.totalValue - element.TotalNmb__c;
                    this.linesInTotal.splice(positionInTotal, 1);
                }

                if(event.target.title == "Quantidade"){
                    element.Quantity = Number(value);
                } else if(event.target.title == "Valor unitário") {
                    element.UnitPrice = Number(value);
                    element.oldValue = Number(value);
                } else if(event.target.title == "Desconto") {
                    element.DiscountNmb__c = Number(value);
                }
              
                if(element.DiscountNmb__c != null && element.DiscountNmb__c > 0){
                    var calculation = (element.oldValue - (element.oldValue * element.DiscountNmb__c / 100));
                    element.UnitPrice = calculation.toPrecision(2);
                    element.TotalNmb__c = element.Quantity * element.UnitPrice;  
                    //element.TotalNmb__c = (element.TotalNmb__c - (element.TotalNmb__c * element.DiscountNmb__c / 100));
                } else if((element.DiscountNmb__c == 0 || element.DiscountNmb__c == null)){
                    element.UnitPrice = element.oldValue;
                    element.TotalNmb__c = element.Quantity * element.UnitPrice;  
                }

                //Add new value to main total
                if(element.TotalNmb__c != null){
                    this.totalValue = this.totalValue + element.TotalNmb__c;
                    this.totalValue.toPrecision(2);
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

        if(this.block){
            this.showToastValidation("Ação bloqueada", "O pedido foi finalizado anteriormente e não pode ser alterado.");
            return;
        } 
        if(this.order.SalesAreaLkp__c  == "Nenhum" || this.order.SalesAreaLkp__c  == null){
            this.showToastValidation("Selecione uma área de vendas.", "Para adicionar itens do produto é necessário selecionar uma área de vendas.");
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
        var deleteItem = true;

        if(this.block){
            this.showToastValidation("Ação bloqueada", "O pedido foi finalizado anteriormente e não pode ser alterado.");
            return;
        }

        if(id != null){
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
        if(this.order.Id != null && !this.block){
            deleteOrder({orderId : this.order.Id})
            .then(() => {
                this.showToastSucessOrderData("Operação realizada com sucesso!");
                this.orderName = "";
                this.order.Id = null;
                if(this.orderItens != null && this.orderItens){
                    this.orderItens.forEach(element => {
                        element.Id = null;
                    });
                }
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