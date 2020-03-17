public with sharing class SingleEmailUtil 
{
    public SingleEmailUtil() 
    {
        
    }
    public static string htmlReplaceText(string htmlvalue,string toReplace,string actualValue)
    {
        if(htmlvalue.contains(toReplace) && (String.isNotBlank(actualValue)))
        {
            htmlvalue = htmlvalue.replace(toReplace,actualValue);
        }
        return htmlvalue;   
    }
    public static void sendSingleEmail(List<Messaging.singleEmailMessage> singleEmailList)
    {
        if(singleEmailList!=null && singleEmailList.size()>0 && !Test.isRunningTest())
        {
            try
            {
                Messaging.sendEmail(singleEmailList);
            }
            catch(EmcException e)
            {
                
            }
        }
    }
    public static Messaging.singleEmailMessage buildEmail(List<String> toAddresses,String subject,String html)
    {
        OrgWideEmailAddress[] owea = [SELECT Id ,Address from OrgWideEmailAddress where Address =:System.Label.DriverServicesEmail];
        messaging.singleEmailMessage mail = new messaging.singleEmailMessage();
        mail.setOrgWideEmailAddressId(owea.get(0).Id);
        if(toAddresses.size()==0)
        {
            toAddresses = getListOfEmailAddress(Label.Email_To_Address);
        }
        else
        {   
            List<String> bccAddress = new List<String>();
            bccAddress = getListOfEmailAddress(Label.Email_To_Address);       
            mail.setBccAddresses(bccAddress);  
        }              
        mail.setToAddresses(toAddresses);        
        mail.setSubject(subject);
        mail.setHtmlBody(html);
        return mail;
    }
    public static List<String> getListOfEmailAddress(String emailAddresses)
    {
        List<String> toAddresses = new List<String>();
        if(emailAddresses.contains(','))
        {
            for(String currentEmailAddress : emailAddresses.split(','))
            {
                if(currentEmailAddress.contains(','))
                {
                    currentEmailAddress = currentEmailAddress.remove(',');
                }
                toAddresses.add(currentEmailAddress.trim());
            }
        }
        else
        {
            toAddresses.add('minkesh.patel@getoncrm.com');
        }
        return toAddresses;
    }
    public static string chooseWhometoSendEmail(String nameOfSetting)
    {
        if(String.isNotBlank(nameOfSetting))
        {
            SendEmailonDeactivation__c currentSetting = SendEmailonDeactivation__c.getValues(nameOfSetting);
            String result ='';
            if(currentSetting.Send_to_Admin__c ==true)
            {
                result = 'admin';
            }
            return result;
        }
        else
        {
            return 'none';
        }
    }
}