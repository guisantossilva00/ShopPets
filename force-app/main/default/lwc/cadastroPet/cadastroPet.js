import { LightningElement } from 'lwc';
import pesoPng from '@salesforce/resourceUrl/pesoIcon';
import setaBaixoPng from '@salesforce/resourceUrl/setaBaixoIcon';
import calendarioPng from '@salesforce/resourceUrl/calendarioIcon';

export default class CadastroPet extends LightningElement {
    pesoIcon = pesoPng;
    setaBaixoIcon = setaBaixoPng;
    calendarioIcon = calendarioPng;
    qualTipoPet = {
        Cachorro : '',
        Gato : '',
        Roedor : '',
        Pássaro : '',
    }

    nomeDoPet = '';
    generoDoPet = '';

    getNames(event) {
        const campoName = event.target.name;

        if (campoName == 'qualPet') {
            if(event.target.value == 'Cachorro') {
                this.qualTipoPet.Cachorro = event.target.value;
                
                this.qualTipoPet.Gato = false;   
                this.qualTipoPet.Roedor = false;
                this.qualTipoPet.Pássaro = false;
            }
            else if (event.target.value == 'Gato') {
                this.qualTipoPet.Gato = event.target.value;  

                this.qualTipoPet.Cachorro = false;
                this.qualTipoPet.Roedor = false;
                this.qualTipoPet.Pássaro = false;             
            }
            else if (event.target.value == 'Roedor') {
                this.qualTipoPet.Roedor = event.target.value;

                this.qualTipoPet.Cachorro = false;
                this.qualTipoPet.Gato = false;   
                this.qualTipoPet.Pássaro = false;
            }
            else if (event.target.value == 'Pássaro') {
                this.qualTipoPet.Pássaro = event.target.value;

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