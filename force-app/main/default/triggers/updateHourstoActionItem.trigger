/**
 * @File Name          : updateHourstoActionItem.trigger
 * @Description        : 
 * @Author             : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Group              : 
 * @Last Modified By   : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Last Modified On   : 28/2/2020, 12:39:24 pm
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    27/2/2020   ChangeMeIn@UserSettingsUnder.SFDoc     Initial Version
**/
trigger updateHourstoActionItem on DailyStatus__c (After Insert, After Update) 
{
    Map<String,Decimal> actionWorkHmap = new Map<String,Decimal>();
    List<DailyStatus__c> newdailyStatusList =new List<DailyStatus__c>();
    List<DailyStatus__c> existingdailyStatusList =new List<DailyStatus__c>();
    if(Trigger.IsInsert && Trigger.IsAfter){
        for(DailyStatus__c dailyStObj:Trigger.New){
            newdailyStatusList.add(dailyStObj);
        }
        updateHourstoActionItemHandler.newDailyStUpdateAction(newdailyStatusList);
    }
    if(Trigger.IsUpdate && Trigger.IsAfter){
        for(DailyStatus__c dailyStObj:Trigger.New){
            if((Trigger.OldMap.get(dailyStObj.id).ActionItem__c==Trigger.NewMap.get(dailyStObj.id).ActionItem__c)&&(Trigger.OldMap.get(dailyStObj.id).Working_Hours__c!=Trigger.NewMap.get(dailyStObj.id).Working_Hours__c)){
                existingdailyStatusList.add(dailyStObj);
            }
        }
        updateHourstoActionItemHandler.existDailyStUpdateAction(existingdailyStatusList);
    }
    /* if(Trigger.IsDelete)
    {
        for(ActionItem__c obj:[Select id,Total_Working_Hours__c from ActionItem__c where id=:actionWorkHmap.keySet()])
        {
             obj.Total_Working_Hours__c = actionWorkHmap.get(obj.id); 
             actionItList.add(obj);     
        }   
    }
    if(actionItList.size()>0)
    {
        update actionItList;
    }*/    
}