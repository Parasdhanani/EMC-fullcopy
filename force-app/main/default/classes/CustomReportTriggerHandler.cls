/**
 * @File Name          : CustomReportTriggerHandler.cls
 * @Description        : 
 * @Author             : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Group              : 
 * @Last Modified By   : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Last Modified On   : 27/2/2020, 4:07:00 pm
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    27/2/2020   ChangeMeIn@UserSettingsUnder.SFDoc     Initial Version
**/
public with sharing class CustomReportTriggerHandler{
    
    public static void updateCurrentReport(List<Custom_Report__c> currentReportsList){
        for(Custom_Report__c currentReport : currentReportsList){
            if(String.isNotBlank(currentReport.Report_Soql__c) && currentReport.Report_Soql__c.containsIgnoreCase('select') && currentReport.Report_Soql__c.containsIgnoreCase(',') && currentReport.Report_Soql__c.containsIgnoreCase('from'))
            {
                List<String> fieldsList = new List<String>();
                String query =  currentReport.Report_Soql__c.removeStartIgnoreCase('select');
                
                query = query.toLowerCase();            
                for(String currentFieldValue : String.valueOf((query.split('from'))[0]).split(',')){
                    fieldsList.add(currentFieldValue.trim());
                }
                if(String.isNotBlank(currentReport.Date_Fields__c))
                {
                    if(currentReport.Date_Fields__c.contains(','))
                    {
                        for(String currentField : currentReport.Date_Fields__c.split(','))
                        {
                            CustomReportTriggerHandler.checkField(fieldsList,currentField,Label.Custom_Report_Err_Message.replace('***', 'Date'),currentReport);
                        }
                    }
                    else 
                    {
                        CustomReportTriggerHandler.checkField(fieldsList,currentReport.Date_Fields__c,Label.Custom_Report_Err_Message.replace('***', 'Date'),currentReport);                    
                    }                
                }
                if(String.isNotBlank(currentReport.Date_Time_Fields__c))
                {
                    if(currentReport.Date_Time_Fields__c.contains(','))
                    {
                        for(String currentField : currentReport.Date_Time_Fields__c.split(','))
                        {
                            CustomReportTriggerHandler.checkField(fieldsList,currentField,Label.Custom_Report_Err_Message.replace('***', 'Date Time'),currentReport);
                        }
                    }
                    else 
                    {
                        CustomReportTriggerHandler.checkField(fieldsList,currentReport.Date_Time_Fields__c,Label.Custom_Report_Err_Message.replace('***', 'Date Time'),currentReport);     
                    }                
                }
                if(String.isNotBlank(currentReport.Numeric_Fields__c))
                {
                    if(currentReport.Numeric_Fields__c.contains(','))
                    {
                        for(String currentField : currentReport.Numeric_Fields__c.split(','))
                        {
                            CustomReportTriggerHandler.checkField(fieldsList,currentField,Label.Custom_Report_Err_Message.replace('***', 'Numeric'),currentReport);
                        }
                    }
                    else 
                    {
                        CustomReportTriggerHandler.checkField(fieldsList,currentReport.Numeric_Fields__c,Label.Custom_Report_Err_Message.replace('***', 'Numeric'),currentReport); 
                    }                
                }            
            }
            else if((!String.isNotBlank(currentReport.Report_Soql__c))||(!currentReport.Report_Soql__c.containsIgnoreCase('select'))||(!currentReport.Report_Soql__c.containsIgnoreCase('from')))
            {
                currentReport.addError(Label.Custom_Report_Err_Message.replace('*** Field', 'valid query'));
            }
            if(currentReport.Use_Driver_List__c!=true && currentReport.Use_Manager_List__c!=true)
            {
                currentReport.addError('Please Select 1 of the Filters');
            }
        }
    }
    public static void checkField(List<String> fieldsList, String currentField,String message,Custom_Report__c currentReport)
    {
        System.debug(currentField.toLowerCase().trim());
        
        System.debug(fieldsList.contains(currentField.toLowerCase().trim()));
        System.debug(fieldsList);
        if(!fieldsList.contains(currentField.toLowerCase().trim()))
        {
            currentReport.addError(message);
        }
    }
}