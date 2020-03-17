/**
 * @File Name          : CheckVehicleAccountTriggerHandler.cls
 * @Description        : 
 * @Author             : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Group              : 
 * @Last Modified By   : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Last Modified On   : 27/2/2020, 3:13:27 pm
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    27/2/2020   ChangeMeIn@UserSettingsUnder.SFDoc     Initial Version
**/
public with sharing class CheckVehicleAccountTriggerHandler {
    public  static void getvehiclename(List<Account> accsList){
        list<String> vehicleNamesset = new list<String>();
        Map<String,String> urlMap = new Map<String,String>();
        for(Account accObj : accsList){
            if(accObj.Vehicle_Types__c != null){
                vehicleNamesset.addAll(accObj.Vehicle_Types__c.replace(' ','').toUpperCase().split(';'));
            }
        }
        for(Vehicle_URL_Mapping__c u : [SELECT Id, Year__c, Vehicle__c, URL__c,Vehicle_Mapping__c FROM Vehicle_URL_Mapping__c where Vehicle_Mapping__c IN: vehicleNamesset]){
            if((u.URL__c != null || u.URL__c != '') &&(!urlMap.containsKey(u.Vehicle_Mapping__c))){
                urlMap.put(u.Vehicle_Mapping__c,u.URL__c);
            }
        }
        for(Account acc : accsList){
            if(String.isNotBlank(acc.Vehicle_Types__c))
            {
                list<String> updatedaccList = new List<String>();
                if(acc.Vehicle_Types__c.contains(';')){
                    updatedaccList.addAll(acc.Vehicle_Types__c.replace(' ','').toUpperCase().split(';'));
                }
                else{
                    updatedaccList.add(acc.Vehicle_Types__c.replace(' ','').toUpperCase());
                }
                //updatedaccList.addAll(acc.Vehicle_Types__c.replace(' ','').toUpperCase().split(';'));
                if(updatedaccList.size() > 0 ){
                    for(String accObj : updatedaccList){
                        if(!urlMap.containsKey(accObj))
                        {
                            acc.addError('Please Enter Valid Standard Vehicle Make Model and Year');
                        }
                    }
                }
            }
        }
    }
}