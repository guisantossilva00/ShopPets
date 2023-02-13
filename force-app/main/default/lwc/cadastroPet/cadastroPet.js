import { LightningElement, track } from 'lwc';
import pesoPng from '@salesforce/resourceUrl/pesoIcon';
import setaBaixoPng from '@salesforce/resourceUrl/setaBaixoIcon';
import calendarioPng from '@salesforce/resourceUrl/calendarioIcon';

export default class CadastroPet extends LightningElement {
    pesoIcon = pesoPng;
    setaBaixoIcon = setaBaixoPng;
    calendarioIcon = calendarioPng;

    nomeDoPet = '';
    generoDoPet = '';
    anoNascimentoPet;

    formulario;
    // elementoQualPet;

    @track qualTipoPet = {
        Cachorro : '',
        Gato : '',
        Roedor : '',
        Passaro : '',
    }

    renderedCallback() {
        this.formulario = this.template.querySelector('form');
            
        this.formulario.addEventListener('submit', (event) => {
            event.preventDefault();
            
            this.validaForm();
        })
    }
    
    getNames(event) {
        const campoName = event.target.name;
        
        if (campoName == 'qualPet') {            
            if(event.target.value == 'Cachorro') {
                this.qualTipoPet.Cachorro = true;

                this.qualTipoPet.Gato = false;   
                this.qualTipoPet.Roedor = false;
                this.qualTipoPet.Passaro = false;
            }
            else if (event.target.value == 'Gato') {
                this.qualTipoPet.Gato = event.target.value;  

                this.qualTipoPet.Cachorro = false;
                this.qualTipoPet.Roedor = false;
                this.qualTipoPet.Passaro = false;             
            }
            else if (event.target.value == 'Roedor') {
                this.qualTipoPet.Roedor = event.target.value;

                this.qualTipoPet.Cachorro = false;
                this.qualTipoPet.Gato = false;   
                this.qualTipoPet.Passaro = false;
            }
            else if (event.target.value == 'Passaro') {
                this.qualTipoPet.Passaro = event.target.value;

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
        else if(campoName == 'anoNascimentoPet') {
            const dataAtual = new Date();
            const anoAtual = parseInt(dataAtual.getFullYear());
            const idadePet = parseInt(event.target.value);

            const dataNascimento = anoAtual - idadePet + '-01-01';
            
            this.anoNascimentoPet = dataNascimento;
        }
    }

    validaForm() {
        const elementoQualPet = this.template.querySelector('[name="qualPet"]');
        const elementoNomePet = this.template.querySelector('[name="nomePet"]');
        const elementoGeneroPet = this.template.querySelector('[name="generoPet"]');
        const elementoRacaPet = this.template.querySelector('[name="racaPet"]');
        const elementoDataNascimentoPet = this.template.querySelector('[name="dataNascimentoPet"]');
        const elementoCastradoPet = this.template.querySelector('[name="castradoPet"]');
        const elementoPesoPet = this.template.querySelector('[name="pesoPet"]');
        const elementoTemperamentoPet = this.template.querySelector('[name="temperamentoPet"]');

        if (elementoQualPet.value == '') {
            this.setErro(elementoQualPet, 'O tipo do pet é obrigatório');
        } else {
            this.setSucesso(elementoQualPet);
        }
        
        if (elementoNomePet.value == '') {
            this.setErro(elementoNomePet, 'O nome do pet é obrigatório');
        } else {
            this.setSucesso(elementoNomePet);
        }

        if (elementoGeneroPet.value == '') {
            this.setErro(elementoGeneroPet, 'O gênero do pet é obrigatório');
        } else {
            this.setSucesso(elementoGeneroPet);
        }

        if (elementoRacaPet.value == '') {
            this.setErro(elementoRacaPet, 'A raça do pet é obrigatório');
        } else {
            this.setSucesso(elementoRacaPet);
        }

        if (elementoDataNascimentoPet.value == '') {
            this.setErro(elementoDataNascimentoPet, 'A data de nascimento do pet é obrigatório');
        } else {
            this.setSucesso(elementoDataNascimentoPet);
        }

        if (elementoCastradoPet.value == '') {
            this.setErro(elementoCastradoPet, 'O campo se o pet é castrado é obrigatório');
        } else {
            this.setSucesso(elementoCastradoPet);
        }

        if (elementoPesoPet.value == '') {
            this.setErro(elementoPesoPet, 'O peso do pet é obrigatório');
        } else {
            this.setSucesso(elementoPesoPet);
        }

        if (elementoTemperamentoPet.value == '') {
            this.setErro(elementoTemperamentoPet, 'O temperamento do pet é obrigatório');
        } else {
            this.setSucesso(elementoTemperamentoPet);
        }

    }

    setErro(input, mensagem) {
        const positionControl = input.parentElement;
        const small = positionControl.querySelector('small');

        small.innerText = mensagem;

        positionControl.classList.add('erro');
        positionControl.classList.remove('sucesso');
        input.focus();
    }

    setSucesso(input) {
        const positionControl = input.parentElement;

        positionControl.classList.add('sucesso');
        positionControl.classList.remove('erro');
    }
}