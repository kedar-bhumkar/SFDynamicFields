global with sharing class DynamicFieldsControllerMustacheBased {
   
    @RemoteAction
    global static String getContactData(Id contactId){
        
        System.debug('contactId = ' + contactId);
        List<FieldMetadata__c>  fieldsData = [Select ApiName__c, FieldType__c, FieldOptions__c from FieldMetadata__c];
        Map<String,FieldMetadata__c> fieldMap = new Map<String,FieldMetadata__c>(); 
        
        for(FieldMetadata__c theField : fieldsData){
            fieldMap.put(theField.ApiName__c, theField);
        }        
        Contact theContact = [Select Name, (Select Id, ApiName__c, Value__c from DynamicFieldTable__r order by Order__c asc)  from Contact where Id =: contactId ];
        
        Map<String, DataWrapper> dataWrapperMap = new Map<String, DataWrapper>();
        List<DataWrapper> dataWrapperList = new List<DataWrapper>(); 
        DataWrapper theDataWrapper;
        for(DynamicFieldTable__c dynamicData : theContact.DynamicFieldTable__r){
            theDataWrapper = new DataWrapper();
            theDataWrapper.apiName    = dynamicData.ApiName__c; 
            theDataWrapper.fieldType  = fieldMap.get(dynamicData.ApiName__c).FieldType__c;
            theDataWrapper.value      = dynamicData.value__c;
            theDataWrapper.id         = dynamicData.id;
            dataWrapperList.add(theDataWrapper);
        }               
        System.debug(JSON.serialize(dataWrapperList));
        return JSON.serialize(dataWrapperList) ;
    } 
 
    @RemoteAction
    public static void save(List<DataWrapper> wrapperList){
        System.debug('Inside save - ' + wrapperList);
        List<DynamicFieldTable__c> fieldValueList = new List<DynamicFieldTable__c>(); 
        DynamicFieldTable__c fieldValue;
        Contact ct = [Select Id from Contact where Id = '0031U000005sVZL' LIMIT 1];
        for(DataWrapper wrapper: wrapperList){
            fieldValue = new DynamicFieldTable__c(); 
            fieldValue.value__c = wrapper.value; 
            fieldValue.id = wrapper.id;
            fieldValue.Contact__c = ct.Id;
            System.debug('Id = ' + wrapper.id);
            fieldValueList.add(fieldValue);
        }       
        update fieldValueList; 
        
    }
          
    private class DataWrapper {
        public String id {get;set;}
        public String apiName {get;set;}
        public String value {get;set;}
        public String fieldType {get;set;}    
   }
}