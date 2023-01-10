// Classe utilizada para o tratamento e formatação das Strings
Public class StringHelper {
    public static String splitPath(String pay){
        if(pay == '' || pay == null){
            return '';
        }
        return (pay.split('-')[0]).trim();
    }
    
    public static String fixSapText(String sapText){
        sapText = (sapText.replace('ACUCAR', 'AÇÚCAR')).replace('ALCOOL', 'ÁLCOOL');
        sapText = (sapText.replace('acucar', 'açúcar')).replace('alcool', 'álcool');
        sapText = (sapText.replace('Acucar', 'Açúcar')).replace('Alcool', 'Álcool');
        sapText = (sapText.replace('Antisseptico', 'Antisséptico')).replace('ANTISSEPTICO', 'ANTISSÉPTICO');
        sapText = (sapText.replace('antisseptico', 'antisséptico')).replace('cosmetico', 'cosmético');
        sapText = (sapText.replace('COSMETICO', 'COSMÉTICO')).replace('Cosmetico', 'Cosmético');
        sapText = (sapText.replace('etilico', 'etílico')).replace('Etilico', 'Etílico');
        sapText = (sapText.replace('ETILICO', 'ETÍLICO'));
		return sapText;
    }
}