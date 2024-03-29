public with sharing class DynamicFieldsController {
    public  Id contactId {get;set;} 
    public Map<String, DataWrapper> dataWrapperMap {get;set;} 
       
    public DynamicFieldsController() {}
     
    public DynamicFieldsController (ApexPages.StandardController controller) {
        contactId = controller.getRecord().Id;    
        getContactData();    
    }
    
    
    private void getContactData(){
        List<FieldMetadata__c>  fieldsData = [Select ApiName__c, FieldType__c, FieldOptions__c from FieldMetadata__c];
        Map<String,FieldMetadata__c> fieldMap = new Map<String,FieldMetadata__c>(); 
        
        for(FieldMetadata__c theField : fieldsData){
            fieldMap.put(theField.ApiName__c, theField);
        }        
        Contact theContact = [Select Name, (Select Id, ApiName__c, Value__c from DynamicFieldTable__r order by Order__c asc)  from Contact where Id =: contactId ];
        dataWrapperMap = new Map<String, DataWrapper>();
        DataWrapper theDataWrapper;
        for(DynamicFieldTable__c dynamicData : theContact.DynamicFieldTable__r){
            theDataWrapper = new DataWrapper();
            theDataWrapper.dynamicField = dynamicData; 
            theDataWrapper.fieldType = fieldMap.get(dynamicData.ApiName__c).FieldType__c;
            if(theDataWrapper.fieldType =='Picklist'){
                List<String> options = (List<String>)JSON.deserialize(fieldMap.get(dynamicData.ApiName__c).FieldOptions__c,  List<String>.class );
                theDataWrapper.fieldOptions = new List<SelectOption>(); 
                for(String theOption : options){
                    theDataWrapper.fieldOptions.add(new SelectOption(theOption,theOption));
                }
            }
            
            dataWrapperMap.put(dynamicData.ApiName__c, theDataWrapper);
        }               
        //System.debug(dataWrappers[3].value);
        //System.debug(JSON.serialize(dataWrappers));
        //return JSON.serialize(dataWrappers) ;
    } 
       
    
    public Pagereference save(){
        List<DynamicFieldTable__c> theRecordList = new List<DynamicFieldTable__c>();
        DynamicFieldTable__c theRecord;
        for(String apiName: dataWrapperMap.keySet()){
            theRecord = dataWrapperMap.get(apiName).dynamicField; 
            theRecordList.add(theRecord);
        }       
        update theRecordList; 
        return null;
    }
        
    private class DataWrapper {
        public DynamicFieldTable__c dynamicField {get;set;}
        public String fieldType {get;set;}    
        public List<SelectOption> fieldOptions {get;set;} 
    }
}