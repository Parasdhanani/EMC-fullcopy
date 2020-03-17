/**
 * @File Name          : CustomReportTrigger.trigger
 * @Description        : 
 * @Author             : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Group              : 
 * @Last Modified By   : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Last Modified On   : 27/2/2020, 4:05:59 pm
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    27/2/2020   ChangeMeIn@UserSettingsUnder.SFDoc     Initial Version
**/
trigger CustomReportTrigger on Custom_Report__c (before insert, before update) 
{
    if(Trigger.isInsert && Trigger.isBefore || Trigger.isUpdate && Trigger.isBefore){
        List<Custom_Report__c> currentReportList = new List<Custom_Report__c>();
        for(Custom_Report__c currentReportObj : Trigger.new){
            currentReportList.add(currentReportObj);
        }
        CustomReportTriggerHandler.updateCurrentReport(currentReportList);
    }
}