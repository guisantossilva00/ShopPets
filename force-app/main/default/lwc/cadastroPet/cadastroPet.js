import { LightningElement, track } from 'lwc';
import pesoPng from '@salesforce/resourceUrl/pesoIcon';
import setaBaixoPng from '@salesforce/resourceUrl/setaBaixoIcon';
import calendarioPng from '@salesforce/resourceUrl/calendarioIcon';

export default class CadastroPet extends LightningElement {
    pesoIcon = pesoPng;
    setaBaixoIcon = setaBaixoPng;
    calendarioIcon = calendarioPng;

    @track qualTipoPet = {
        Cachorro : '',
        Gato : '',
        Roedor : '',
        Passaro : '',
    }

    nomeDoPet = '';
    generoDoPet = '';
    renderedCallback() {
        
    }

    getNames(event) {
        const campoName = event.target.name;
        
        if (campoName == 'qualPet') {            
            if(event.target.value == 'Cachorro') {
                this.qualTipoPet.Cachorro = true;

                console.log('this.qualTipoPet.Cachorro => ' + this.qualTipoPet.Cachorro);
                this.qualTipoPet.Gato = false;   
                this.qualTipoPet.Roedor = false;
                this.qualTipoPet.Passaro = false;
            }
            else if (event.target.value == 'Gato') {
                this.qualTipoPet.Gato = event.target.value;  
                console.log('this.qualTipoPet.Gato => ' + this.qualTipoPet.Gato);

                this.qualTipoPet.Cachorro = false;
                this.qualTipoPet.Roedor = false;
                this.qualTipoPet.Passaro = false;             
            }
            else if (event.target.value == 'Roedor') {
                this.qualTipoPet.Roedor = event.target.value;
                console.log('this.qualTipoPet.Roedor => ' + this.qualTipoPet.Roedor);

                this.qualTipoPet.Cachorro = false;
                this.qualTipoPet.Gato = false;   
                this.qualTipoPet.Passaro = false;
            }
            else if (event.target.value == 'Passaro') {
                this.qualTipoPet.Passaro = event.target.value;
                console.log('this.qualTipoPet.Passaro => ' + this.qualTipoPet.Passaro);

                this.qualTipoPet.Cachorro = false;
                this.qualTipoPet.Gato = false;   
                this.qualTipoPet.Roedor = false;
            }
        }
        else if (campoName == 'nomePet') {
            this.nomeDoPet = event.target.value;
        }
        else if (campoName == 'generoPet') {
            if(event.target.value == 'Fêmea') this.generoDoPet = event.target.value;
            else this.generoDoPet = false;
        }
    }
}