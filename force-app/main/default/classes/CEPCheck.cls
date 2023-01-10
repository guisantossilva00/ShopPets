global without sharing class CEPCheck {
    
    @InvocableMethod(label='Verificação de CEP')
    public static void fetchParams(List<String> params){
        
        List<String> splitted = params.toString().split(',');
        check(splitted[0], splitted[1]);
    }
    
    public static Boolean check(String cep, String estado) {      
        estado = estado.replaceAll('[^a-zA-Z0-9\\s+]', '');
        
        System.debug('estadoParam ' + estado);
        
        List<CEP__c> queryCep = [
            SELECT CepInicio__c, CepFim__c, Estado__c 
            FROM CEP__C 
            WHERE Estado__c =: estado
            LIMIT 1
        ];
        
        String cepInicio;
        String cepFim;
        
        cep = cep.replaceAll('\\D', '');
        System.debug('cep - ' + cep);
        
        if(!queryCep.isEmpty()){
            cepInicio = queryCep[0].CepInicio__c;
            cepInicio = cepInicio.replaceAll('\\D', '');
            System.debug('cepInicio - ' + cepInicio);
            
            cepFim = queryCep[0].CepFim__c;
            cepFim = cepFim.replaceAll('\\D', '');
            System.debug('cepFim - ' + cepFim);   
        }else{
            return false;
        }

        if(Integer.valueOf(cepInicio) < Integer.valueOf(cep) && Integer.valueOf(cepFim) > Integer.valueOf(cep)){
            return true;
        }else{
            return false;
        }
    }
    
}