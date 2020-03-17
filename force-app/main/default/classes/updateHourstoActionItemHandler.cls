/**
 * @File Name          : updateHourstoActionItemHandler.cls
 * @Description        : 
 * @Author             : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Group              : 
 * @Last Modified By   : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Last Modified On   : 27/2/2020, 5:43:40 pm
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    27/2/2020   ChangeMeIn@UserSettingsUnder.SFDoc     Initial Version
**/
public with sharing class updateHourstoActionItemHandler {
    
    public static void newDailyStUpdateAction(List<DailyStatus__c> newdailyStatusList){
        Map<String,Decimal> actionWorkHmap = new Map<String,Decimal>();
        system.debug('newdailyStatusList11=='+newdailyStatusList);
        for(DailyStatus__c dailyStObj : newdailyStatusList){
			system.debug('dailyStObj=='+dailyStObj);
            if(!actionWorkHmap.containsKey(dailyStObj.ActionItem__c)){
                // if not exist
                system.debug('dailyStObj =='+dailyStObj);
                if(dailyStObj.Working_Hours__c!=null){
                    actionWorkHmap.put(dailyStObj.ActionItem__c,dailyStObj.Working_Hours__c);
                }else{
                    actionWorkHmap.put(dailyStObj.ActionItem__c,0);
                }               
            }else{
                //if exist
                Decimal workinghours = actionWorkHmap.get(dailyStObj.ActionItem__c);
                if(dailyStObj.Working_Hours__c!=null){                     
                    workinghours = workinghours +dailyStObj.Working_Hours__c;                     
                }else{                     
                    workinghours = workinghours +0;                     
                }
                actionWorkHmap.put(dailyStObj.ActionItem__c,workinghours);
            }
        }
        List<ActionItem__c> actionItList = new List<ActionItem__c>();
        for(ActionItem__c obj:[Select id,Total_Working_Hours__c from ActionItem__c where id=:actionWorkHmap.keySet()]){
            obj.Total_Working_Hours__c = actionWorkHmap.get(obj.id); 
            actionItList.add(obj);     
        }
        if(actionItList.size()>0){
            update actionItList;
        }
    }

    public static void existDailyStUpdateAction(List<DailyStatus__c> existingdailyStatusList){
        Map<String,Decimal> actionWorkHmap = new Map<String,Decimal>();
        for(DailyStatus__c dailyStObj:existingdailyStatusList){
            if(!actionWorkHmap.containsKey(dailyStObj.ActionItem__c)){
                // if not exist
                if(dailyStObj.Working_Hours__c!=null){
                    actionWorkHmap.put(dailyStObj.ActionItem__c,dailyStObj.Working_Hours__c);
                }else{
                    actionWorkHmap.put(dailyStObj.ActionItem__c,0);
                }                   
            }else{
                //if exist
                Decimal workinghours = actionWorkHmap.get(dailyStObj.ActionItem__c);
                if(dailyStObj.Working_Hours__c!=null){                     
                        workinghours = workinghours +dailyStObj.Working_Hours__c;                     
                }else{                     
                        workinghours = workinghours +0;                     
                }
                actionWorkHmap.put(dailyStObj.ActionItem__c,workinghours);
            }
        }
        List<ActionItem__c> actionItList = new List<ActionItem__c>();
        for(ActionItem__c obj:[Select id,Total_Working_Hours__c from ActionItem__c where id=:actionWorkHmap.keySet()]){
            obj.Total_Working_Hours__c = obj.Total_Working_Hours__c + actionWorkHmap.get(obj.id); 
            actionItList.add(obj);     
        }
        if(actionItList.size()>0){
            update actionItList;
        }
    }
}