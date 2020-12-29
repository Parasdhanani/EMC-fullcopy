/**
 * @Author: GetonCRM Solutions LLP
 * @Description: This class for post call in triplog and send total mileages.This class is called by Concer button on reimbursement object.
 * @Modification logs
 * ========================================================================================================================
 * @Date: 05 June 2020 | Sanket Goswami
 * @description: 
 * AI-000435
 */
global class UploadConcurQuickExpenseTriplog {
    Webservice static void postTotalReimbursement(String empReMonth,String contactEmail,String totalReimburement){
        String apiToken = System.label.Triplog_Concer_Expense_API;
        if(totalReimburement == null){
            totalReimburement = '0';
        }
        String todayDate = String.valueof(system.today().year()+'-'+date.today().addmonths(-1).month()+'-'+system.today().day());
        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartObject();
        gen.writeStringField('email', contactEmail);
        gen.writeStringField('date', todayDate);
        gen.writeStringField('amount', totalReimburement);
        gen.writeEndObject();
        String jsonstringconvert = gen.getAsString();

        /*HttpRequest postReq = new HttpRequest();
        Http postHTTP = new Http();
        HttpResponse postRes = new HttpResponse();
    
        postReq.setEndpoint(StaticValues.Concer_Quick_Expense);
        postReq.setMethod('POST');
        postReq.setTimeout(120000);
        postReq.setbody(jsonstringconvert);
        postReq.setHeader('Content-Type', 'application/json');
        postReq.setHeader('Authorization', 'apikey '+ apiToken);

        if(!Test.isRunningTest()){
            postRes = postHTTP.send(postReq);
                if(postRes.getStatusCode() == 200) {
                    System.debug('postRes.getStatusCode()'+postRes.getStatusCode());
                }
        }   else {
            ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.Severity.ERROR, 'Data is not send successfully.');
        }*/
        try {
            if(!Test.isRunningTest()) {
                HttpResponse res = ApiCalloutUtility.executeCallout(apiToken,'POST',StaticValues.Concer_Quick_Expense,'',jsonstringconvert);
                system.debug('res'+res);
            }
        } catch(System.CalloutException er) {
            ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.Severity.ERROR, 'Data is not send successfully.');
        }
    }

    Webservice static void postTotalReimbursementForAllUser(){
        String apiToken = System.label.Triplog_Concer_Expense_API;
        String lastMonth = Utils.fetchMonths(1, 0)[0]; 
        String todayDate = String.valueof(system.today().year()+'-'+date.today().addmonths(-1).month()+'-'+system.today().day());
        for(Employee_Reimbursement__c objReimbursemnt : [SELECT Id,Month__c,Total_Monthly_Reimbursement__c,Contact_Id__r.External_Email__c 
                                                            FROM Employee_Reimbursement__c 
                                                            WHERE Month__c =: lastMonth 
                                                            AND Contact_Id__r.Account.Name =: 'SPBS' limit 9999
                                                        ]){
            JSONGenerator gen = JSON.createGenerator(true);
            gen.writeStartObject();
            gen.writeStringField('email', objReimbursemnt.Contact_Id__r.External_Email__c );
            gen.writeStringField('date', todayDate);
            gen.writeStringField('amount', String.valueOf(objReimbursemnt.Total_Monthly_Reimbursement__c));
            gen.writeEndObject();
            String jsonstringconvert = gen.getAsString();
    
            /*HttpRequest postReq = new HttpRequest();
            Http postHTTP = new Http();
            HttpResponse postRes = new HttpResponse();
        
            postReq.setEndpoint(StaticValues.Concer_Quick_Expense);
            postReq.setMethod('POST');
            postReq.setTimeout(120000);
            postReq.setbody(jsonstringconvert);
            postReq.setHeader('Content-Type', 'application/json');
            postReq.setHeader('Authorization', 'apikey '+ apiToken);
            if(!Test.isRunningTest()){
                postRes = postHTTP.send(postReq);
                    if(postRes.getStatusCode() == 200) {
                        System.debug('postRes.getStatusCode()'+postRes.getStatusCode());
                    }
            }   else {
                ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.Severity.ERROR, 'Data is not send successfully.');
            }*/

            try {
                if(!Test.isRunningTest()) {
                    HttpResponse res = ApiCalloutUtility.executeCallout(apiToken,'POST',StaticValues.Concer_Quick_Expense,'',jsonstringconvert);
                    system.debug('res'+res);
                }
            } catch(System.CalloutException er) {
                ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.Severity.ERROR, 'Data is not send successfully.');
            }
        }
    }
    /*Webservice static void postTotalReimbursementForAllUser(){
        String apiToken = System.label.Triplog_Concer_Expense_API;
        String month = WrapperUtils.getLastMonthValue(-1);
        List<reimbursementWrapper> reimbursementWrapperList = new List<reimbursementWrapper>();
        for(Employee_Reimbursement__c reim : [SELECT id,Contact_Email__c, Month__c, Total_Monthly_Reimbursement__c FROM Employee_Reimbursement__c WHERE Month__c =: month]){
            reimbursementWrapper objReimbursementWrap = new reimbursementWrapper();
            objReimbursementWrap.email = reim.Contact_Email__c;
            objReimbursementWrap.month = reim.Month__c;
            objReimbursementWrap.amount = String.valueOf(reim.Total_Monthly_Reimbursement__c);
            reimbursementWrapperList.add(objReimbursementWrap);
        }
        String body = JSON.serialize(reimbursementWrapperList);
        
        Http postHTTP = new Http();
        HttpRequest postReq = new HttpRequest(); 
        HttpResponse postRes = new HttpResponse();
        postReq.setEndpoint(StaticValues.Concer_Quick_Expense);
        postReq.setMethod('POST');
        postReq.setTimeout(120000);
        postReq.setBody(body);
        postReq.setHeader('Content-Type', 'application/json');
        postReq.setHeader('Authorization', 'apikey '+ apiToken);

        if(!Test.isRunningTest()){
            postRes = postHTTP.send(postReq);
                if(postRes.getStatusCode() == 200) {
                    System.debug('postRes.getStatusCode()'+postRes.getStatusCode());
                }
        }   else {
            ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.Severity.ERROR, 'Data is not send successfully.');
        }
    }

    public class reimbursementWrapper{
        public string email { get; set; }
        public string month { get; set; }
        public string amount { get; set; }
    }*/
}