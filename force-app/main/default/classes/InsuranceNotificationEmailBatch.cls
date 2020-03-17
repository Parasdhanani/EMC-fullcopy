global class InsuranceNotificationEmailBatch implements Database.Batchable<sObject> {
    
    global List<Contact> start(Database.BatchableContext BC) {
        List<Contact> conQueryList = new List<Contact>();
        conQueryList = [Select id,
                               Name,
                               Email,
                               FirstName,
                               Account.Name 
                        From Contact Where Account.isUsingTriplog__c = true
                                           and Insurance_Attachment_Id__c = null 
                                           and Deactivated_Date__c = null 
                                           and (Role__c != 'admin' and Role__c != 'Manager')]; 
                                          
        return conQueryList;
    }
   
    global void execute(Database.BatchableContext BC, List<sObject> scope) {
         EmailTemplate emailTemplate = [SELECT Id,
                                               HtmlValue,
                                               Name,
                                               Subject 
                                        FROM EmailTemplate 
                                        WHERE DeveloperName = 'Car_Insurance_Attachment_Notification']; 
       
        List<Messaging.SingleEmailMessage> mailList = new List<Messaging.SingleEmailMessage>();        
        
        List<String> bccList = new List<String>();
        bccList = System.Label.Send_Email_Bcc_Address.split(',');

        SendEmail__c sendCustomSet = SendEmail__c.getValues('InsuranceNotificationEmailBatch');
        SendEmailToMe__c sendMeCustomSet = SendEmailToMe__c.getValues('InsuranceNotificationEmailBatch');


        for(Contact con :(List<Contact>) scope)
        {
            List<String> emailaddressofsending = new List<String>();
            String newBody = emailTemplate.HtmlValue;
            newBody = newBody.replace('{!$Label.Driver_Forword_Logo}', System.Label.Driver_Forword_Logo);
            newBody = newBody.replace('{!Contact.FirstName}', con.FirstName);
            messaging.singleEmailMessage mail = new messaging.singleEmailMessage();
            mail.setHtmlBody(newBody);
            if(!bccList.isEmpty() && bccList != null && sendMeCustomSet != null && sendMeCustomSet.Send_email_to_me__c == true){                
                mail.setBccAddresses(bccList);
            }            
            emailaddressofsending.add(con.Email);
            mail.setToAddresses(emailaddressofsending);
            mailList.add(mail);
        }
        if(!mailList.isEmpty() && !Test.isRunningTest() && sendCustomSet != null && sendCustomSet.Send_email_from_code__c == true) 
        {   
            Messaging.sendEmail(mailList);
        }
        
    }
     
    global void finish(Database.BatchableContext bc){
        
    }    
}