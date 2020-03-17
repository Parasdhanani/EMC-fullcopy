/**
 * @File Name          : ActionItemCreateTrigger.trigger
 * @Description        : 
 * @Author             : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Group              : 
 * @Last Modified By   : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Last Modified On   : 27/2/2020, 6:21:12 pm
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    27/2/2020   ChangeMeIn@UserSettingsUnder.SFDoc     Initial Version
**/
trigger ActionItemCreateTrigger on ActionItem__c (after insert,after update) { 
    ActionItemCreateCustom__c objCustomSet = ActionItemCreateCustom__c.getValues('CustomData'); 
    if (trigger.isAfter ){
               

        if(trigger.isInsert && objCustomSet.IsInsertExecution__c == true)
        {            
            ActionItemCreateTriggerHandler.sendEmail(trigger.new,objCustomSet.InsertEmailTemplate__c);            
        }

        if(trigger.isUpdate && objCustomSet.IsUpdateExecution__c == true)
        {  
            List<ActionItem__c> actList = new List<ActionItem__c>();
            Set<ActionItem__c> actSet = new Set<ActionItem__c>();
            for(ActionItem__c act : Trigger.new) 
            {                
                ActionItem__c oldAct = Trigger.oldMap.get(act.Id);
                List<string> compareFieldsList = objCustomSet.Compare_Fields__c.split(','); 
                for(string comp:compareFieldsList)
                {                     
                    if(act.get(comp) != oldAct.get(comp))
                    {                        
                        actSet.add(Trigger.newmap.get(act.Id));                        
                    }
                }
            }               
            actList.addAll(actSet);
            
            if(actList != null && actList.size() > 0 )
            {   
                ActionItemCreateTriggerHandler.sendEmail(actList,objCustomSet.UpdateEmailTemplate__c);
            }
        }
    }
}