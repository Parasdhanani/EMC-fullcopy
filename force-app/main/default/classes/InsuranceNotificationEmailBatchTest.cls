@isTest
public class InsuranceNotificationEmailBatchTest {
    static testMethod void InsuranceTest() {

         //Insert Custom setting data

         SendEmail__c sendCustomSet = new SendEmail__c();
         sendCustomSet.Name = 'InsuranceNotificationEmailBatch';
         sendCustomSet.Send_email_from_code__c = true;
         insert sendCustomSet;

         SendEmailToMe__c sendMeCustomSet = new SendEmailToMe__c();
         sendMeCustomSet.Name = 'InsuranceNotificationEmailBatch';
         sendMeCustomSet.Send_email_to_me__c = true;
         insert sendMeCustomSet;

         Address__c obj_Address = new Address__c();
         obj_Address.State__c ='Alabama';
         obj_Address.City__c ='Abbeville';
         obj_Address.Abbreviation__c ='AL';
         obj_Address.ZIP_Code__c ='36310'; 
         obj_Address.Time_Zone__c = 'America/Anchorage';

         List<Address__c> obj_list_Address = new List<Address__c>();
         obj_list_Address.add(obj_Address);
         insert obj_list_Address;
 
         Vehicle_URL_Mapping__c veh = new Vehicle_URL_Mapping__c();
         veh.URL__c = 'https://cdn2.hubspot.net/hubfs/2511299/iStock-494093356.jpg';
         veh.vehicle__c = 'Full-Size Sedan';
         veh.Year__c = '2019';
         insert veh;
 
         Vehicle_URL_Mapping__c veh2 = new Vehicle_URL_Mapping__c();
         veh2.URL__c = 'https://cdn3.hubspot.net/hubfs/2511299/iStock-494093356.jpg';
         veh2.vehicle__c = 'Dodge Charger';
         veh2.Year__c = '2020';
         insert veh2;
         
         SendEmail__c customSetting =  new SendEmail__c();
         customSetting.Name = 'Send Email For Compliance';
         customSetting.Send_email_from_code__c= true;
         insert customSetting;
          
         //Insert Account data Using Utility class
         Account acc = TestUtilityClass.getTestSingleAccount();
         acc.isUsingTriplog__c = true;
         update acc;

         //Insert Contact data 
         Contact con = new Contact();
         con.FirstName = 'Test';
         con.LastName = 'Contact';
         con.AccountId = acc.Id;
         con.Fixed_Amount__c = 10;
         con.MailingStreet = 'Test Street';
         con.MailingCity = 'Test City';
         con.MailingState = 'AL';
         con.MailingPostalCode = '36310';
         con.MailingCountry = 'CA';
         con.Phone = '1232434445';
         con.External_Email__c = 'minkesh.patel14232378@gmail.com';
         con.Deactivated_Date__c = null;
         con.isCommunityUser__c = True;
         con.Role__c = 'Driver';
         con.Monthly_Mileage_Limit__c = 0;
         con.IsCreatedFromCommunity__c = true; 
         con.Vehicle_Type__c  = '2019 Full-Size Sedan';
         con.compliancestatus__c = 'Yes';
         insert con;
 
         Contact con2 = new Contact();
         con2.FirstName = 'Test2';
         con2.LastName = 'Contact';
         con2.AccountId = acc.Id;
         con2.MailingStreet = 'Test Street';
         con2.MailingCity = 'Abbeville';
         con2.MailingState = 'AL';
         con2.Manager__c = con.Id;
         con2.MailingPostalCode = '123';
         con2.MailingCountry = 'CA';
         con2.Phone = '1232434445';
         con2.External_Email__c = 'minkesh.patel14@gmail.com';
         con2.Deactivated_Date__c = null;
         con2.isCommunityUser__c = True;
         con2.Role__c = 'Manager';
         con2.Monthly_Mileage_Limit__c = 0;
         con2.IsCreatedFromCommunity__c = true; 
         insert con2;

        InsuranceNotificationEmailBatch b = new InsuranceNotificationEmailBatch();
		    Database.executeBatch(b,1);
         
    }
}