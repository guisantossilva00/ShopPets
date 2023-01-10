import { LightningElement, api } from 'lwc';

export default class CommerceDefaultFooter extends LightningElement {

    @api stripeColor;

    @api logo1;
    @api logo2;

    @api logoFb;
    @api logoIg;
    @api logoIn;

    @api texto1;
    @api link1;
    @api texto2;
    @api link2;
    @api texto3;
    @api link3;
    @api texto4;
    @api link4;
    @api texto5;
    @api link5;

    @api tabela1Titulo;
    @api tabela1Link1;
    @api tabela1Texto1;
    @api tabela1Link2;
    @api tabela1Texto2;
    @api tabela1Link3;
    @api tabela1Texto3;

    @api tabela2Titulo;
    @api tabela2Link1;
    @api tabela2Texto1;
    @api tabela2Link2;
    @api tabela2Texto2;
    @api tabela2Link3;
    @api tabela2Texto3;
    @api tabela2Link4;
    @api tabela2Texto4;
    @api tabela2Link5;
    @api tabela2Texto5;
    
    @api tabela3Titulo;
    @api tabela3Link1;
    @api tabela3Texto1;
    @api tabela3Link2;
    @api tabela3Texto2;
    @api tabela3Link3;
    @api tabela3Texto3;
    @api tabela3Link4;
    @api tabela3Texto4;
    @api tabela3Link5;
    @api tabela3Texto5;

    @api frase;
    @api endereco;

    activeSections = ['A', 'C'];
}