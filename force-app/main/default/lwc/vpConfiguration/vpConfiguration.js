import { LightningElement, api, wire, track} from 'lwc';
import getProductsByName from '@salesforce/apex/VPCController.getProductsByName';
import getRecords from '@salesforce/apex/VPCController.getRecords';
import getRecordsClone from '@salesforce/apex/VPCController.getRecordsClone';
import save from '@salesforce/apex/VPCController.save';
import getRows from '@salesforce/apex/VPCController.getRows';
import getRowsValues from '@salesforce/apex/VPCController.getRowsValues';
import getCreatedRowsNames from '@salesforce/apex/VPCController.getCreatedRowsNames';
import getConditions from '@salesforce/apex/VPCController.getConditions';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';


export default class vpConfiguration extends LightningElement {


    @wire(getProductsByName) productsByName;
    
    @track records = [];
    @track recordsClone = [];
    @track rows = [];
    @track rowsClone = [];

    @track productId = "Nenhum";
    @track cloneId = "Nenhum";
    
    @track isModalOpen = false;
    @track modalValue = "Nenhum";
 
    @track newLines = 0;
    @track newRows = 0;
    @track conditionType = [];

    @api rowsValues = [];
    @api loadRowsValues = [];
    @api rowNames = [];

    connectedCallback(){
        getConditions({})
        .then((result) => {
            this.conditionType = result;
        })
        .catch((error) => {
            this.showToastCatchError();
            console.log(error);
        });
    }

    renderedCallback(){
        if((this.rowsValues.length != (this.rows.length + this.records.length) && this.recordsClone.length == 0) && this.newLines == 0 && this.newRows == 0){
            this.assignConditionValues();
        }
        if(this.rowNames != null && this.rowNames != []){
            this.setReadOnlyMasterConditions();
        }
    }

    validation(){

        var elements = this.template.querySelectorAll('lightning-input');
        //Record Values
        var initial = "";
        var final = "";

        //Toast Error
        var message = "OK";

        for (let index = 0; index < elements.length; index++) {
            let isnum = /^\d+$/.test(elements[index].value);

            if(String(elements[index].value) === "" && (elements[index].name == 'mult')){
                message = "Preencha todos os valores multiplicadores das colunas!";
                break;
            }
           
            if(!isnum && elements[index].getAttribute("data-row") == 'data-row' && !String(elements[index].value).includes(".")){
                message = "Preencha todos os valores multiplicadores das colunas de condição de pagamento!";
                console.log("ELEMENT: "+elements[index].innerHTML);
                break;
            }
            
            if(Number(elements[index].value) != 1 && (elements[index].name == "initial" && elements[index].title == 0)){
                message = "Na primeira linha o valor inicial deve ser igual a 1 (um).";
                break;
            } 

            if(Number(elements[index].value) <= 0 && (elements[index].name == "initial" || elements[index].name == "final")){
                message = "Nenhum valor inicial ou final da tabela pode ser menor ou igual a zero.";
                break;
            }
            
            if(Number(elements[index].value) > 999999 && (elements[index].name == "initial" || elements[index].name == "final")){
                message = "Nenhum valor inicial ou final da tabela pode ser maior que 999999.";
                break;
            } 
            
            if(elements[index].name == "initial"){
                if(elements[index].value == null || elements[index].value == ""){
                    message = "Os valores iniciais de cada linha devem ser preenchidos.";
                    break;
                }else if(final != "" && final != null &&  Number(final) + 1 != Number(elements[index].value)){
                    message = "Os valores iniciais devem ser equivalentes ao valor final da linha anterior + 1.";
                    break;
                } else {
                    initial = elements[index].value;
                }
            }
            if(elements[index].name == "final"){
                if(elements[index].value == null || elements[index].value == ""){
                    message = "Os valores finais de cada linha devem ser preenchidos.";
                    break;
                }

                final = elements[index].value;

                if(Number(initial) >= Number(final)){
                    message = "Os valores finais devem ser maiores que os valores iniciais da mesma linha.";
                    break;
                }
            }
            
        }

        return message;

    }


    save(){            
        var message = this.validation();
        if(message != 'OK'){
            const event = new ShowToastEvent({
                title: 'Não foi possível persistir os dados no sistema!',
                message: message,
                variant: 'error',
                mode: 'sticky'
            });
            this.dispatchEvent(event);
        } else {

            if(this.records == '[]' || this.records == null || this.records.length == 0){
                const event = new ShowToastEvent({
                    title: 'Não foi possível persistir os dados no sistema!',
                    message: 'Não existe nenhuma matriz, adicione linhas e colunas.',
                    variant: 'error',
                    mode: 'sticky'
                });
                this.dispatchEvent(event);
                return;
            }
            
            let payCon = {
                Id: null,
                Name: "A vista DDF - 0010",
                Value: null
            };

            let payConNames = [...this.rows, payCon];
            save({ payCon : payConNames, payConVolRecords : this.records, values : JSON.stringify(this.rowsValues)})
            .then((result) => {
                this.message = result;
                if(message != "OK"){
                    const event = new ShowToastEvent({
                        title: 'Não foi possível persistir os dados no sistema!',
                        message: message,
                        variant: 'error',
                        mode: 'sticky'
                    });
                    this.dispatchEvent(event);
                } else {
                    const event = new ShowToastEvent({
                        title: 'Operação realizada ✔',
                        message: 'Os registros foram salvos com sucesso!',
                        variant: 'success',
                        mode: 'dismissable'
                    });
                    this.dispatchEvent(event);
                    this.clearAll();
                    window.location.reload();
                }
            }).catch((error) => {
                this.showToastCatchError();
                console.log(error);
            });
        }
    }

   
    assignRowsValues(event){
        let data = Number(event.target.value);
        let dataString = String(data);
        console.log("VALUE: "+event.target.value);
        if(data < -9.9){
            data = -9.9;
            event.target.value = -9.9;
            this.showToastAdjust();
        }

        if(data > 9.9){
            data = 9.9;
            event.target.value = 9.9;
            this.showToastAdjust();
        }
        
        let column = Number(event.target.name);
        let line = Number(event.target.title);
        let index = column+""+line;
        let position = -1;

        if(data == null || data == ""){
            return;
        }
        position = this.rowsValues.map(function(item) { return item.key; }).indexOf(index);

        if(position == -1){
            this.rowsValues.push({key: index, value: data});
            console.log(index, data);
        } else {
            this.rowsValues.splice(position, 1);
            this.rowsValues.push({key: index, value: data});
        }
    }
    
    assignRowsFields(event){

        var inputValue = event.target.value;
        this.conditionType.splice(this.conditionType.indexOf(inputValue), 1);
        const nameChange =  this.rows.map(item => {
            if(this.rows.indexOf(item) == event.target.name){
                this.conditionType.push(item.Name);
                return {...item, Name:inputValue}
            } else {
                return item
            }        
        });
        this.rows = nameChange;
    }


    assignFields(event){

        var elements = this.template.querySelectorAll('lightning-input');
        let position = -1;
        let line = -1;
        for (let index = 0; index < elements.length - 1; index++) {
            if(elements[index].name == "initial"){
                ++line;
            }
            if(elements[index].id == event.target.id){
                position = line;
                break;
            }
        }
        if(position != -1){
            var inputValue = Number(event.target.value);
            var dataString = String(inputValue);

            if((inputValue < -9.9) && event.target.name == 'mult'){
                inputValue = -9.9;
                event.target.value = 9.9;
                this.showToastAdjust();
            }

            if(inputValue > 9.9 && event.target.name == 'mult'){
                inputValue = 9.9;
                event.target.value = 9.9;
                this.showToastAdjust();
            }

            switch (event.target.name) {
                case "initial":
                    const copyInit =  this.records.map(item => {
                        if(this.records.indexOf(item) == position){
                            return {...item, InitialVolumeNmb__c:inputValue}
                        } else {
                            return item
                        }        
                    });
                    this.records = copyInit;
                    break;
                    
                case "final":
                    const copyFinal =  this.records.map(item => {

                        if(this.records.indexOf(item) == position){
                            return {...item, FinalVolumeNmb__c:inputValue}
                        } else {
                            return item
                        }        
                    });
                    this.records = copyFinal;
                    break;
                case "cartCheckbox":
                    
                    const copyCart =  this.records.map(item => {

                        if(this.records.indexOf(item) == position){
                            inputValue = !(this.records[position].LowPriceBln__c);

                            return {...item, LowPriceBln__c:inputValue}
                        } else {
                            return item
                        }        
                    });
                    this.records = copyCart;
                    break;
                case "bookCheckbox":
                    const copyBook =  this.records.map(item => {

                        if(this.records.indexOf(item) == position){
                            

                            inputValue = !(this.records[position].ListPriceBln__c);

                            return {...item, ListPriceBln__c:inputValue}
                        } else {
                            return item
                        }        
                    });
                    this.records = copyBook;
                    break;
                case "mult":

                    const copyMultiplier =  this.records.map(item => {

                        if(this.records.indexOf(item) == position){
                            return {...item, MultiplierPriceNmb__c:inputValue}
                        } else {
                            return item
                        }        
                    });
                    this.records = copyMultiplier;
                    break;
                default:
                    break;
                }

            }
            
        }



    productSelected(event) {

        
        this.productId = event.target.value

        if(this.productId == "Nenhum"){
            this.clearAll();
            this.clearRowInputs();
            return;
        } else {
            this.clearRowInputs();
            this.rowsValues = [];
            this.rowNames = [];
            this.records = [];
            this.recordsClone = [];
            var elements = this.template.querySelectorAll('select');
            for(let index = 0; index < elements.length - 1; index++){
                if(elements[index].name == "optionSelectClone"){
                    elements[index].value = "Nenhum";
                }
            }
        }

        this.clearConditionSelect();
        this.loadMasterConditions();
        this.removeItensInModal();
        this.loadConditionsValues();
        this.loadRecords();
        if(this.records != [] && this.records != null){
            this.showToastLoadData();
        }
    }

    setReadOnlyMasterConditions(){

        var elements = this.template.querySelectorAll('select[data-select]');
        for(let index = 0; index < elements.length; index++){
            if(index < this.rows.length - this.newRows){         
                elements[index].disabled = true;
            }
        }
        this.disablePicklist = true;
    }
    
    removeItensInModal(){
        getCreatedRowsNames({ product : this.productId})        
        .then((result) => {
            this.rowNames = result;
            for(let index = 0; index < this.rowNames.length; index++){
                let position = this.conditionType.indexOf(this.rowNames[index]);
                if(index != -1){
                    this.conditionType.splice(position,1);
                }
            }
        })
        .catch((error) => {
            this.showToastCatchError();
            console.log(error);
        });
    }

    loadRecords(){
        getRecords({ product :  this.productId })
        .then((result) => {
            this.records = result;
            this.newLines = 0; 
        })
        .catch((error) => {
            this.showToastCatchError();
            console.log(error);
        });
    }

    
    assignConditionValues(){
        var elements = this.template.querySelectorAll('lightning-input[data-row]');

        if(this.loadRowsValues != [] && this.loadRowsValues != null){

            let lines = 0;
            for(let index = 0 ; index < elements.length; index++){
                if(elements[index].name == "0"){
                    ++lines;
                }
            }

            let perLine;

            if(lines == 0){
                perLine = 0;
            } else {
                perLine = elements.length / lines;
            }

            for(let index = 0 ; index < elements.length; index++){
                let line = elements[index].title;
                let row = elements[index].name;
                let position = -1; 
                
                if(elements[index].title == 0){
                    position = row+""+line;
                    let valueToPush = this.loadRowsValues[index];

                    if(valueToPush == undefined || valueToPush == null){
                        valueToPush = 0;
                    } else {
                        elements[index].value = valueToPush;
                    }
                     
                    let inListPosition = this.rowsValues.map(function(item) { return item.key; }).indexOf(position);

                    if(inListPosition == -1 && elements[index].value != undefined && elements[index].value != null){
                        this.rowsValues.push({key: position, value: ''+valueToPush});
                    }

                } else {
                    //3 * 1 + 0 <=> (perLIne * line + row)
                    let valuePosition = this.loadRowsValues[perLine * line + row];

                    if(valuePosition == undefined || valuePosition == null){
                        valuePosition = 0;
                    } else {
                        elements[index].value = valuePosition;
                    }
                    

                    position = row+""+line;

                    let inListPosition = this.rowsValues.map(function(item) { return item.key; }).indexOf(position);

                    if(inListPosition == -1 && elements[index].value != undefined &&  elements[index].value != null){
                        this.rowsValues.push({key: position, value: ''+valuePosition});
                    }
                }

            }
        }
    }

    
    loadConditionsValues(){
        getRowsValues({ product : this.productId})        
        .then((result) => {
            this.loadRowsValues = result;
            this.assignConditionValues();
        })
        .catch((error) => {
            this.showToastCatchError();
            console.log(error);
        });
    }

    loadMasterConditions(){
        getRows({ product :   this.productId  })
        .then((result) => {
            this.rows = result;
            this.newRows = 0;
        })
        .catch((error) => {
            this.showToastCatchError();
            console.log(error);
        });
    }


    clearRowInputs(){
        var elements = this.template.querySelectorAll('lightning-input[data-row]');

        if(this.loadRowsValues != [] && this.loadRowsValues != null){
            for(let index = 0 ; index < elements.length; index++){
                    elements[index].value = 0;
            }
        }    
    }

    clearConditionSelect(){

        getConditions({})
        .then((result) => {
            this.conditionType = result;
        })
        .catch((error) => {
            this.showToastCatchError();
            console.log(error);
        });
        this.rowNames = []
    }
    
    clearAll(){
        this.disablePicklist = false;
        this.rowNames = [];
        this.records = [];
        this.newLines = 0;
        this.newRows = 0;
        this.rows = [];
        this.rowsValues = [];
        this.rowsClone = [];
        this.modalValue = "Nenhum";
        this.recordsClone = [];
        this.cloneId = "Nenhum";
        this.productId = "Nenhum";  

        var elements = this.template.querySelectorAll('select');
        for(let index = 0; index < elements.length - 1; index++){
            if(elements[index].name == "optionSelect" || elements[index].name == "optionSelectClone"){
                elements[index].value = "Nenhum";
            }
        }
    }

    cloneSelected(event) {
        this.cloneId = event.target.value;
        this.loadRowsValues = [];

        getRows({ product :   this.cloneId  })
        .then((result) => {
            this.rowsClone = result;
        })
        .catch((error) => {
            this.showToastCatchError();
            console.log(error);
        });

        getRecordsClone({ product : this.cloneId, newProduct : this.productId})
            .then((result) => {
                this.recordsClone = result;
            })
            .catch((error) => {
            this.showToastCatchError();
            console.log(error);
        });

        
    }

    clone(){    
        if(this.productId == "Nenhum" || this.cloneId == "Nenhum" || this.productId == this.cloneId){
            this.showToastClone();
        } else {

            if(this.records.length > 0){
                this.showToastCloneTable();
                return;
            }
            getRowsValues({ product : this.cloneId})        
            .then((result) => {
                this.loadRowsValues = result;
                this.assignConditionValues();
            })
            .catch((error) => {
                this.showToastCatchError();
                console.log(error);
            });
            this.rows = this.rowsClone;
            this.records = this.recordsClone;
            this.newLines = 0;
            this.newRows = 0;
            this.showToastLoadData();
            
            this.clearConditionSelect();

            getCreatedRowsNames({ product : this.cloneId})        
            .then((result) => {
                this.rowNames = result;
                for(let index = 0; index < this.rowNames.length; index++){
                    let position = this.conditionType.indexOf(this.rowNames[index]);
                    if(index != -1){
                        this.conditionType.splice(position,1);
                    }
                }
            })
            .catch((error) => {
                this.showToastCatchError();
                console.log(error);
            });
        }
    }

    cancelButton(){
        this.clearAll();
        window.location.reload();
    }

    openModal() {
        if(this.productId == "Nenhum"){
            this.showToastSelectProduct();
        } else if(this.records.length < 1){ 
            this.showToastAddRowLines();
        } else {
            this.isModalOpen = true;
        }
    }

    closeModal() {
        this.isModalOpen = false;
        this.modalValue = "Nenhum";
    }

    selectedModal(event){
        this.modalValue = event.target.value;
    }
   
    addRow(){

        if(this.modalValue == "Nenhum"){
            this.showToastAddRow();
        } else {
            let payCon = {
                Id: null,
                Name: this.modalValue,
                Value: null,
            };

            this.loadRowsValues = [];
            this.newRows++;
            this.rows = [...this.rows, payCon];
            this.isModalOpen = false;
            this.conditionType.splice(this.conditionType.indexOf(this.modalValue),1);
            this.modalValue = "Nenhum";
        }
    }

    removeRow(){
        if(this.rows != [] && this.rows.length > 0 && this.rows != null && this.newRows > 0){
            this.newRows--;
            this.conditionType.push(this.rows[this.rows.length - 1].Name);
            this.rows.pop();

            for(let iterator = 0; iterator < this.rowsValues.length; iterator++){
                let index = this.rows.length+""+iterator;
                let position = -1;
                position = this.rowsValues.map(function(item) { return item.key; }).indexOf(index);
    
                if(position != -1){
                    this.rowsValues.splice(position, 1);
                } 
            }
        }
    }

    removeLine(){
        if(this.records != [] && this.records.length > 0 && this.records != null && this.newLines > 0){
            this.newLines--;
            this.records.pop();

            for(let iterator = 0; iterator < this.rowsValues.length; iterator++){
                let index = iterator+""+this.records.length;
                let position = -1;
                position = this.rowsValues.map(function(item) { return item.key; }).indexOf(index);
    
                if(position != -1){
                    this.rowsValues.splice(position, 1);
                } 
            }
        }

    }
    
    addLine(event){  
        if(this.productId == "Nenhum"){
            this.showToastSelectProduct();
        } else {
            let payConVol = {
                FinalVolumeNmb__c: null,
                InitialVolumeNmb__c: null,
                ListPriceBln__c: false,
                LowPriceBln__c: false,
                MultiplierPriceNmb__c: null,
                Name: "Volume x Condição",
                PaymentConditionLkp__c: null,
                ProductLkp__c: this.productId,
                VersionNmb__c: 0,
                TableColumnNmb__c: null,
                TableLineNmb__c: this.records.length,
                ActiveBln__c: true,
            };

            this.newLines++;
            this.records = [...this.records, payConVol];
        }
    }

    /*

     TOASTS

    */

    showToastCatchError(){
        const event = new ShowToastEvent({
            title: 'Ocorreu um erro durante o processamento!',
            message: 'Um erro inesperado ocorreu, tente novamente mais tarde ou entre em contato com um administrador.',
            variant: 'error',
            mode: 'sticky'
        });
        this.dispatchEvent(event);
    }
    showToastClone() {
        const event = new ShowToastEvent({
            title: 'A copia dos dados não foi efetuada!',
            message: 'Selecione o produto principal e um diferente para realizar a cópia.',
            variant: 'warning',
            mode: 'dismissable'
        });
        this.dispatchEvent(event);
    }

    showToastCloneTable() {
        const event = new ShowToastEvent({
            title: 'A copia dos dados não foi efetuada!',
            message: 'Não é possível sobrescrever uma tabela existente.',
            variant: 'warning',
            mode: 'dismissable'
        });
        this.dispatchEvent(event);
    }

    showToastAddRow() {
        const event = new ShowToastEvent({
            title: 'Operação de adição de coluna não realizada!',
            message: 'Selecione um valor na lista de opções.',
            variant: 'warning',
            mode: 'dismissable'
        });
        this.dispatchEvent(event);
    }

    showToastAddRowLines() {
        const event = new ShowToastEvent({
            title: 'Operação de adição de coluna não realizada!',
            message: 'Adicione linhas na tabela antes de adicionar colunas.',
            variant: 'warning',
            mode: 'dismissable'
        });
        this.dispatchEvent(event);
    }

    showToastSelectProduct() {
        const event = new ShowToastEvent({
            title: 'Não é possível continuar!',
            message: 'Selecione o produto na lista de valores.',
            variant: 'warning',
            mode: 'dismissable'
        });
        this.dispatchEvent(event);
    }

    showToastLoadData(){
        const sucess = new ShowToastEvent({
            title: 'Operação de atualização realizada.',
            message: '',
            variant: 'default',
            mode: 'dismissable'
        });
        this.dispatchEvent(sucess);
    }
    showToastAdjust(){
        const ajust = new ShowToastEvent({
            title: 'Valor ajustado.',
            message: 'O valor inserido foi redefinido de acordo com as regras predefinidas.',
            variant: 'default',
            mode: 'dismissable'
        });
        this.dispatchEvent(ajust);
    }
}