public with sharing class LoginRedirection 
{
    
    public LoginRedirection() 
    {
     System.debug('in LoginRedirection class----');   

    }
    public PageReference redirectOnPage()
    {
        User u = new User();

        u = [select id,Profile.Name,contactid,contact.showTeamRecord__c,contact.Accountid,Contact.Insurance_Attachment_Id__c from user where id=:userinfo.getuserid()];
        System.debug('in LoginRedirection class---user-----'+u);
        
        if(u!=null)
        {   
            if(u.Profile.Name == 'Customer Community Login User - Manager')
            {
                PageReference pageRef = new PageReference('/app/managerdashboard?accid='+u.contact.Accountid+'&id='+u.contactid+'&showteam='+String.valueOf(u.contact.showTeamRecord__c));
                System.debug('in LoginRedirection class1----'+pageRef);
                return pageRef;
            } 
            else if(u.Profile.Name == 'Customer Community Login User - Super Manager')
            {
                PageReference pageRef = new PageReference('/app/admindashboard?accid='+u.contact.Accountid+'&id='+u.contactid+'&showteam='+String.valueOf(u.contact.showTeamRecord__c));
                System.debug('in LoginRedirection class2----'+pageRef);
                return pageRef;
            }
            else if(u.Profile.Name == 'Customer Community Login User - Driver')
            {
                //AI-000414
                PageReference pageRef;
                if(u.Contact.Insurance_Attachment_Id__c != null ){
                    pageRef = new PageReference('/app/driverDashboardClone?accid='+u.contact.Accountid+'&id='+u.contactid);
                }
                else{
                    pageRef = new PageReference('/app/driverDashboardInsuranceClone?accid='+u.contact.Accountid+'&id='+u.contactid);
                }
                System.debug('in LoginRedirection class3----'+pageRef);
                return pageRef;
            }
            else if(u.Profile.Name == 'Customer Community Login User - Manager/Driver')
            {
                PageReference pageRef = new PageReference('/app/drivermanagerdashboard?accid='+u.contact.Accountid+'&id='+u.contactid+'&showteam='+String.valueOf(u.contact.showTeamRecord__c));
                System.debug('in LoginRedirection class4----'+pageRef);
                return pageRef;
            }
            else if(u.Profile.Name == 'Customer Community Login User - Super Manager/Driver')
            {
                PageReference pageRef = new PageReference('/app/admindriverdashboard?accid='+u.contact.Accountid+'&id='+u.contactid+'&showteam='+String.valueOf(u.contact.showTeamRecord__c)+'&admindriver=true');
                System.debug('in LoginRedirection class5----'+pageRef);
                return pageRef;
            }
            
        }
        System.debug('in LoginRedirection class return null----');
    //  PageReference pageRef = new PageReference();
        return null;
    }
}