({
    qsToEventMap: {
        'startURL'  : 'e.c:setStartUrl'
    },
    
    qsToEventMap2: {
        'expid'  : 'e.c:setExpId'
    },
    
    handleSelfRegister: function (component, event, helpler) {
        var accountId = component.get("v.accountId");
        var regConfirmUrl = component.get("v.regConfirmUrl");        
        var CompanyName = component.find("CompanyName").get("v.value");
        var CNPJ = component.find("CNPJ").get("v.value");
        var InscricaoEM = component.find("InscricaoEstadualMunicipal").get("v.value");
        var Phone = component.find("Phone").get("v.value");        
        var lastname = component.find("lastname").get("v.value");                        
        var CEP_entrega = component.find("CEP_entrega").get("v.value");
        var Endereco_entrega = component.find("Endereco_entrega").get("v.value");
        var Numero_entrega = component.find("Numero_entrega").get("v.value");
        var Bairro_entrega = component.find("Bairro_entrega").get("v.value");
        var Cidade_entrega = component.find("Cidade_entrega").get("v.value");
        var Estado_entrega = component.find("Estado_entrega").get("v.value");
        var email = component.find("email").get("v.value");
        var includePassword = component.get("v.includePasswordField");
        var password = component.find("password").get("v.value");
        var confirmPassword = component.find("confirmPassword").get("v.value");
        var validRegexEmail = "^[a-zA-Z0-9._|\\\\%#~`=?&/$^*!}{+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,4}$";
        var endereco_entrega = component.find("checkbox_entrega").get("v.value");
        
        if(endereco_entrega == true){
            var CEP = CEP_entrega;
            var Endereco = Endereco_entrega;
            var Numero = Numero_entrega;
            var Bairro = Bairro_entrega;
            var Cidade = Cidade_entrega;
            var Estado = Estado_entrega;
        }else{
            var CEP = component.find("CEP").get("v.value");
            var Endereco = component.find("Endereco").get("v.value");
            var Numero = component.find("Numero").get("v.value");
            var Bairro = component.find("Bairro").get("v.value");
            var Cidade = component.find("Cidade").get("v.value");
            var Estado = component.find("Estado").get("v.value");
        }
        
        if(!CompanyName){
            component.set("v.errorMessage",'Razão Social é obrigatório.');
            component.set("v.showError",true);
            $A.enqueueAction(CompanyName);
        }else if(CompanyName.length > 80){
            component.set("v.errorMessage",'O campo Razão Social é limitado em até 80 caractéres.');
            component.set("v.showError",CompanyName);
            $A.enqueueAction(CompanyName);
        }else if(!CNPJ){
            component.set("v.errorMessage",'CNPJ é obrigatório.');
            component.set("v.showError",true);
            $A.enqueueAction(CNPJ);
        }else if(CNPJ.length < 18){
            component.set("v.errorMessage",'O campo CNPJ é inválido.');
            component.set("v.showError",true);
            $A.enqueueAction(CNPJ);
        }else if(!InscricaoEM){
            component.set("v.errorMessage",'Inscrição estadual ou municipal é obrigatório.');
            component.set("v.showError",true);
            $A.enqueueAction(InscricaoEM);
        }else if(InscricaoEM.length > 18){
            component.set("v.errorMessage",'O campo Inscrição estadual ou municipal é inválido.');
            component.set("v.showError",true);
            $A.enqueueAction(InscricaoEM);
        }else if(!Phone){
            component.set("v.errorMessage",'Telefone é obrigatório.');
            component.set("v.showError",true);
            $A.enqueueAction(Phone);
        }else if(Phone.length < 14){
            component.set("v.errorMessage",'O campo Telefone é inválido.');
            component.set("v.showError",true);
            $A.enqueueAction(Phone);
        }else if(!lastname){
            component.set("v.errorMessage",'Responsável é obrigatório.');
            component.set("v.showError",true);
            $A.enqueueAction(lastname);
        }else if(!CEP_entrega){
            component.set("v.errorMessage",'CEP de entrega é obrigatório.');
            component.set("v.showError",true);
            $A.enqueueAction(CEP_entrega);
        }else if(CEP_entrega.length != 9){
            component.set("v.errorMessage",'O campo CEP de entrega é inválido.');
            component.set("v.showError",true);
            $A.enqueueAction(CEP_entrega);
        }else if(!Endereco_entrega){
            component.set("v.errorMessage",'Endereço de entrega é obrigatório.');
            component.set("v.showError",true);
            $A.enqueueAction(Endereco_entrega);
        }else if(!Numero_entrega){
            component.set("v.errorMessage",'Número de entrega é obrigatório.');
            component.set("v.showError",true);
            $A.enqueueAction(Numero_entrega);
        }else if(!Bairro_entrega){
            component.set("v.errorMessage",'Bairro de entrega é obrigatório.');
            component.set("v.showError",true);
            $A.enqueueAction(Bairro_entrega);
        }else if(!Cidade_entrega){
            component.set("v.errorMessage",'Cidade de entrega é obrigatório.');
            component.set("v.showError",true);
            $A.enqueueAction(Cidade_entrega);
        }else if(!Estado_entrega){
            component.set("v.errorMessage",'Estado de entrega é obrigatório.');
            component.set("v.showError",true);
            $A.enqueueAction(Estado_entrega);
        }else if(Estado_entrega.length < 2){
            component.set("v.errorMessage",'O campo Estado de entrega é inválido.');
            component.set("v.showError",true);
            $A.enqueueAction(Estado_entrega);
        }else if(!CEP){
            component.set("v.errorMessage",'CEP é obrigatório.');
            component.set("v.showError",true);
            $A.enqueueAction(CEP);
        }else if(CEP.length != 9){
            component.set("v.errorMessage",'O campo CEP é inválido.');
            component.set("v.showError",true);
            $A.enqueueAction(CEP);
        }else if(!Endereco){
            component.set("v.errorMessage",'Endereço é obrigatório.');
            component.set("v.showError",true);
            $A.enqueueAction(Endereco);
        }else if(!Numero){
            component.set("v.errorMessage",'Número é obrigatório.');
            component.set("v.showError",true);
            $A.enqueueAction(Numero);
        }else if(!Bairro){
            component.set("v.errorMessage",'Bairro é obrigatório.');
            component.set("v.showError",true);
            $A.enqueueAction(Bairro);
        }else if(!Cidade){
            component.set("v.errorMessage",'Cidade é obrigatório.');
            component.set("v.showError",true);
            $A.enqueueAction(Cidade);
        }else if(!Estado){
            component.set("v.errorMessage",'Estado é obrigatório.');
            component.set("v.showError",true);
            $A.enqueueAction(Estado);
        }else if(Estado.length < 2){
            component.set("v.errorMessage",'O campo Estado é inválido.');
            component.set("v.showError",true);
            $A.enqueueAction(Estado);
        }else if(!email){
            component.set("v.errorMessage",'E-mail é obrigatório.');
            component.set("v.showError",true);
            $A.enqueueAction(email);
        }else if (!email.match(validRegexEmail)) {
        	component.set("v.errorMessage",'O campo E-mail é inválido.');
            component.set("v.showError",true);
            $A.enqueueAction(email);
        }else{            
            var action = component.get("c.selfRegister");            
            var startUrl = component.get("v.startUrl");            
            startUrl = decodeURIComponent(startUrl);            
            action.setParams({CompanyName: CompanyName, CNPJ: CNPJ, InscricaoEM: InscricaoEM, Phone: Phone, lastname:lastname, Endereco: Endereco, CEP: CEP, Numero: Numero, Bairro: Bairro, Cidade: Cidade, Estado: Estado, 
                              EnderecoEntrega: Endereco_entrega , CEPEntrega: CEP_entrega, NumeroEntrega: Numero_entrega, BairroEntrega: Bairro_entrega, CidadeEntrega: Cidade_entrega, EstadoEntrega: Estado_entrega, email:email,
                    password:password, confirmPassword:confirmPassword, accountId:accountId, regConfirmUrl:regConfirmUrl, startUrl:startUrl, includePassword:includePassword});
              action.setCallback(this, function(a){
              var rtnValue = a.getReturnValue();
              if (rtnValue !== null) {
                 component.set("v.errorMessage",rtnValue);
                 component.set("v.showError",true);
              }else{
                  	var actionSetAssignment = component.get("c.setPermissionSetAssignment");                    
                    actionSetAssignment.setParams({CNPJ: CNPJ});
                    actionSetAssignment.setCallback(this, function(a){
                        console.log(rtnValue);
                      var rtnValue = a.getReturnValue();
                      if (rtnValue !== null) {
                         component.set("v.errorMessage",rtnValue);
                         component.set("v.showError",true);
                      }
                   });
                   $A.enqueueAction(actionSetAssignment); 
              }
           });
   		   $A.enqueueAction(action);                       
        }                
        
    },
    
    verificaCep : function (component, event, helper) {
        var CEP = component.find("CEP-f1").get("v.value");
        var Estado = component.find("Estado-f1").get("v.value");

        if(!CEP){
            component.set("v.errorMessage",'CEP é obrigatório.');
            component.set("v.showError",true);
            $A.enqueueAction(CEP);
        }else if(CEP.length != 9){
            component.set("v.errorMessage",'O campo CEP é inválido.');
            component.set("v.showError",true);
            $A.enqueueAction(CEP);
        }else if(!Estado){
            component.set("v.errorMessage",'Estado é obrigatório.');
            component.set("v.showError",true);
            $A.enqueueAction(Estado);    
            
        }else{  
        	var action = component.get("c.cepcheck");
            action.setParams({cep : CEP, Estado : Estado});                
            action.setCallback(this, function(a){
            var rtnValue = a.getReturnValue(); 
                component.set("v.showError",false);
                if (rtnValue == false) {                    
                    var form1 = document.getElementById("form-1");
                    $A.util.addClass(form1, "hide");
                    $A.util.removeClass(form1, "show");
                    var form2 = document.getElementById("form-2");
                    $A.util.addClass(form2, "show");
                    $A.util.removeClass(form2, "hide");
                    component.set('v.cepCadastrado',CEP);
                }else{
					var form1 = document.getElementById("form-1");
                    $A.util.addClass(form1, "hide");
                    $A.util.removeClass(form1, "show"); 
                    var form3 = document.getElementById("form-3");
                    $A.util.addClass(form3, "show");
                    $A.util.removeClass(form3, "hide");
                    helper.getAddress(component, event, helper);
                }
            });
            $A.enqueueAction(action);
        }
    },
    
    getExtraFields : function (component, event, helpler) {
        var action = component.get("c.getExtraFields");
        action.setParam("extraFieldsFieldSet", component.get("v.extraFieldsFieldSet"));
        action.setCallback(this, function(a){
        var rtnValue = a.getReturnValue();
            if (rtnValue !== null) {
                component.set('v.extraFields',rtnValue);
            }
        });
        $A.enqueueAction(action);
    },

    setBrandingCookie: function (component, event, helpler) {        
        var expId = component.get("v.expid");
        if (expId) {
            var action = component.get("c.setExperienceId");
            action.setParams({expId:expId});
            action.setCallback(this, function(a){ });
            $A.enqueueAction(action);
        }
    },

	handleMascaraCEP: function (component, event, helpler) {  
        var cep = component.find("CEP-f1").get("v.value");
        cep=cep.replace(/\D/g,'');                
        cep=cep.replace(/^(\d{5})(\d)/,'$1-$2');
        component.find("CEP-f1").set("v.value",cep);        
    },
    
    handleMascaraCEP2: function (component, event, helpler) {  
        var cep = component.find("CEP").get("v.value");
        cep=cep.replace(/\D/g,'');                
        cep=cep.replace(/^(\d{5})(\d)/,'$1-$2');
        component.find("CEP").set("v.value",cep);        
    },
    
    handleMascaraCNPJ: function (component, event, helpler) {  
        var cnpj = component.find("CNPJ").get("v.value");
        cnpj=cnpj.replace(/\D/g,'');                   
        cnpj=cnpj.replace(/^(\d{2})(\d)/,'$1.$2');     
        cnpj=cnpj.replace(/^(\d{2})\.(\d{3})(\d)/,'$1.$2.$3'); 
        cnpj=cnpj.replace(/\.(\d{3})(\d)/,'.$1/$2');       
        cnpj=cnpj.replace(/(\d{4})(\d)/,'$1-$2');
        component.find("CNPJ").set("v.value",cnpj);        
    },
    
    handleMascaraTel: function (component, event, helpler) {  
        var tel = component.find("Phone").get("v.value");
        tel=tel.replace(/\D/g,'');                 
        tel=tel.replace(/^(\d\d)(\d)/g,'($1) $2'); 
        tel=tel.replace(/(\d{4})(\d)/,'$1-$2');    
        component.find("Phone").set("v.value",tel);        
    },
    
    mascaraUF: function (component, event, helpler) {  
        var comp = component.find("Estado").get("v.value");
        comp=comp.replace(/[0-9]/g,'');                    
        component.find("Estado").set("v.value",comp);        
    },
    
    mascaraNumero: function (component, event, helpler) {  
        var comp = component.find("Numero").get("v.value");
        comp=comp.replace(/\D/g,'');                    
        component.find("Numero").set("v.value",comp);        
    },
    
    mascaraInscricao: function (component, event, helpler) {  
        var comp = component.find("InscricaoEstadualMunicipal").get("v.value");
        comp=comp.replace(/\D/g,'');                    
        component.find("InscricaoEstadualMunicipal").set("v.value",comp);        
    },

	getAddress: function (component, event, helpler) {
        var action = component.get("c.getAddressData");
        var cep = component.find("CEP-f1").get("v.value");
        component.find("CEP_entrega").set("v.value", cep);
        component.find("CEP_entrega").set("v.disabled", true);
        action.setParams({ cep: cep });
        action.setCallback(this, function (a) {
            var rtnValue = a.getReturnValue();
            if (rtnValue != "Não encontrado") {
                const address = JSON.parse(rtnValue);
                component.find("Endereco_entrega").set("v.value", address[0].logradouro);
                component.find("Bairro_entrega").set("v.value", address[0].bairro);
                component.find("Cidade_entrega").set("v.value", address[0].localidade);
                component.find("Estado_entrega").set("v.value", address[0].uf);
                component.find("Endereco_entrega").set("v.disabled", true);
                component.find("Bairro_entrega").set("v.disabled", true);
                component.find("Cidade_entrega").set("v.disabled", true);
                component.find("Estado_entrega").set("v.disabled", true);
            }
        });
        $A.enqueueAction(action);
    },

	backSelfRegister: function (component, event, helpler) {
        var form1 = document.getElementById("form-1");
        $A.util.addClass(form1, "show");
        $A.util.removeClass(form1, "hide"); 
        var form2 = document.getElementById("form-2");
        $A.util.addClass(form2, "hide");
        $A.util.removeClass(form2, "show");
        var form3 = document.getElementById("form-3");
        $A.util.addClass(form3, "hide");
        $A.util.removeClass(form3, "show");        
    }, 
    
    createLead: function (component, event, helpler) {        
        component.set("v.showError",false);
        var cep = component.find("CEP-f1").get("v.value");
        var CompanyName = component.find("CompanyName-f2").get("v.value");
        var email = component.find("email-f2").get("v.value");
        var validRegexEmail = "^[a-zA-Z0-9._|\\\\%#~`=?&/$^*!}{+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,4}$";
        
        if(!CompanyName){
            component.set("v.errorMessage",'Razão Social é obrigatório.');
            component.set("v.showError",true);
            $A.enqueueAction(CompanyName);
        }else if(!email){
            component.set("v.errorMessage",'E-mail é obrigatório.');
            component.set("v.showError",true);
            $A.enqueueAction(email);
        }else if (!email.match(validRegexEmail)) {
        	component.set("v.errorMessage",'O campo E-mail é inválido.');
            component.set("v.showError",true);
            $A.enqueueAction(email);
        }else if(cep.length != 9){
            component.set("v.errorMessage",'O campo CEP é inválido.');
            component.set("v.showError",true);
            $A.enqueueAction(cep);
        }else{
            var action = component.get("c.createLeadAlert");
            action.setParams({ cep: cep, CompanyName:CompanyName, email:email });
            action.setCallback(this, function (a) {
                var rtnValue = a.getReturnValue();
                if (rtnValue !== null) {                    
                    var msg = document.getElementById("form-2-msg");
                    $A.util.addClass(msg, "show");
                    $A.util.removeClass(msg, "hide"); 
                    var form = document.getElementById("form-2-data");
                    $A.util.addClass(form, "hide");
                    $A.util.removeClass(form, "show");
                }else{
                    component.set("v.errorMessage",'Ocorreu um erro. Por favor, tente novamente mais tarde.');
                    component.set("v.showError",true);
                }
            });
            $A.enqueueAction(action);
        }
    },
})