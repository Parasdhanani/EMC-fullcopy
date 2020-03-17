global class AutoApprovedEmailClass implements Database.Batchable<sObject>, Database.Stateful{
    global List<OrgWideEmailAddress> owea;
    global EmailTemplate emailTemplate;
    global Map<Id, List<Employee_Reimbursement__c>> contactEmReimMap;
    global String lastMonth;

    /*
        Constructor
    */ 
    global AutoApprovedEmailClass(){
        owea = [ SELECT Id, 
                        address
                FROM OrgWideEmailAddress
                WHERE Address = 'driverservices@mburse.com' ];
        emailTemplate = [SELECT Id,HtmlValue,Name,Subject FROM EmailTemplate WHERE DeveloperName =:'Auto_Approval_Template'];

        String tempDate = date.today().addMonths(-1).Month() + '-' + date.today().addMonths(-1).Year();
        lastMonth = tempDate.left(2);
        if(lastMonth.contains('-')) {
            lastMonth = '0' + tempDate;
        } else {
            lastMonth = tempDate;
        }

        contactEmReimMap = new  Map<Id, List<Employee_Reimbursement__c>> ();

        for(Employee_Reimbursement__c reimb : [SELECT Id, Name, Month__c, Contact_Id__r.Account.Approval_Template_Message__c,  Total_Mileage__c, Status__c,Contact_Id__r.Role__c, Contact_Id__r.Manager__c, Contact_Id__r.Name, Contact_Id__r.Monthly_Mileage_Limit__c FROM Employee_Reimbursement__c WHERE Month__c =: lastMonth]){
            if(contactEmReimMap.containsKey(reimb.Contact_Id__c)){
                contactEmReimMap.get(reimb.Contact_Id__c).add(reimb);
            } else {
                contactEmReimMap.put(reimb.Contact_Id__c, new List<Employee_Reimbursement__c>{reimb});
            }
        }
    }

    /*
        Start Method
    */ 
    global Database.QueryLocator start(Database.BatchableContext BC){
        Set<Id> keys = contactEmReimMap.keyset();
        return Database.getQueryLocator('SELECT Id, Name, Account.Approval_Template_Message__c, role__c, Monthly_Mileage_Limit__c FROM Contact WHERE Id In: keys');
    }
    
    /*
        Execute Method
    */ 
    global void execute(Database.BatchableContext BC, list<contact> conlist){
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        
        string month = string.valueOf(Date.today().addMonths(-1).month());
        string m = (month == '1') ? 'January' : (month == '2') ? 'February' : (month == '3') ? 'March' : (month == '4') ? 'April' : (month == '5') ? 'May' : (month == '6') ? 'June' : (month == '7') ? 'July' : (month == '8') ? 'August' : (month == '9') ? 'September' : (month == '01') ? 'January' : (month == '02') ? 'February' : (month == '03') ? 'March' : (month == '04') ? 'April' : (month == '05') ? 'May' : (month == '06') ? 'June' : (month == '07') ? 'July' : (month == '08') ? 'August' : (month == '09') ? 'September' : (month == '10') ? 'October' : (month == '11') ? 'November' : (month == '12') ? 'December' : 'Invalid Month';

        for(Contact conObj : conlist) {
            string[] toAddresses = new string[]{'hiren.sharma@getoncrm.com'};
            messaging.singleEmailMessage mail = new  messaging.singleEmailMessage();
            String html = '';
            String newBody = emailTemplate.HtmlValue;
            
            for(Employee_Reimbursement__c empReimObj : contactEmReimMap.get(conObj.Id)) {
            
                if(!String.isBlank(conObj.Account.Approval_Template_Message__c)) {
                    String accountMessage = conObj.Account.Approval_Template_Message__c;
                    accountMessage = accountMessage.replace('{month}', m);
                    newBody = newBody.replace('{account.Approval_Template_Message__c}',accountMessage);
                } else {
                    newBody = newBody.replace('{account.Approval_Template_Message__c}','');
                }

                if(conObj.role__c == 'admin' ||  conObj.role__c == 'admin/driver') {
                    String reportTo = '<th style="border:2px solid black;" width="5%">Report To</th>';
                    newBody = newBody.replace('{reportToTR}',reportTo);
                } else {
                    newBody = newBody.replace('{reportToTR}','');
                }

                if(contactEmReimMap.containsKey(conObj.Id)){ 
                    if(empReimObj.Total_Mileage__c  != null) {
                        html = +'<tr align="center">' + '<td style="border:2px solid black;">' + conObj.Name + '</td>' + '<td style="border:2px solid black;">' + empReimObj.Month__c + '</td>' + '<td style="border:2px solid black;">' + conObj.Monthly_Mileage_Limit__c + '</td>' + '<td style="border:2px solid black;">' + empReimObj.Total_Mileage__c + '</td>' + '<td style="border:2px solid black;">' + empReimObj.status__c + '</td>';
                        if(conObj.role__c == 'admin' || conObj.role__c == 'admin/driver') {
                            html += +'<td style="border:2px solid black;" width="5%">' + conObj.Name + '</td>';
                        }
                        html += +'</tr>';
                    }
                } else {
                    if(empReimObj.Total_Mileage__c  != null) {
                        html += +'<tr align="center">' + '<td style="border:2px solid black;">' + conObj.Name + '</td>' + '<td style="border:2px solid black;">' + empReimObj.Month__c + '</td>' + '<td style="border:2px solid black;">' + conObj.Monthly_Mileage_Limit__c + '</td>' + '<td style="border:2px solid black;">' + empReimObj.Total_Mileage__c + '</td>' + '<td style="border:2px solid black;">' + empReimObj.status__c + '</td>';
                        if(conObj.role__c == 'admin' || conObj.role__c == 'admin/driver') {
                            html += +'<td style="border:2px solid black;" width="5%">' + conObj.Name + '</td>';
                        }
                        html += +'</tr>';
                    }
                }
                newBody = newBody.replace('{tableDynamicData}',html);
            } 

            if(newBody.contains('</td>')){
                mails.add(mail);    
            }

            if(!owea.isEmpty()) {
                mail.setOrgWideEmailAddressId(owea.get(0).Id);
            }
        
            mail.setToAddresses(toAddresses);
            mail.setSubject(emailTemplate.Subject);
            // mail.setBCCAddresses(new string[]{'minkesh.patel@getoncrm.com','natavar.goc@gmail.com'});
            mail.setHtmlBody(newBody);
        }

        if(!mails.isEmpty()) {
            Messaging.sendEmail(mails);
        }   
        

        // Map<Id, List<Employee_Reimbursement__c>> contactEmReimMap = new  Map<Id, List<Employee_Reimbursement__c>> ();
        // for(Employee_Reimbursement__c empReimObj : scope){
        //     string[] toAddresses = new string[]{'hiren.sharma@getoncrm.com'};
        //     messaging.singleEmailMessage mail = new  messaging.singleEmailMessage();

        //     String html = '';
        //     String newBody = emailTemplate.HtmlValue;

        //     if(empReimObj.Contact_Id__c != Null){
        //         if(contactEmReimMap.containsKey(empReimObj.Contact_Id__c)){
        //             contactEmReimMap.get(empReimObj.Contact_Id__c).add(empReimObj);
        //         } else {
        //             contactEmReimMap.put(empReimObj.Contact_Id__c, new List<Employee_Reimbursement__c>{empReimObj});
        //         }

        //         if(!String.isBlank(empReimObj.Contact_Id__r.Account.Approval_Template_Message__c)) {
        //             String accountMessage = empReimObj.Contact_Id__r.Account.Approval_Template_Message__c;
        //             accountMessage = accountMessage.replace('{month}', m);
        //             newBody = newBody.replace('{account.Approval_Template_Message__c}',accountMessage);
        //         }else {
        //             newBody = newBody.replace('{account.Approval_Template_Message__c}','');
        //         }

        //         if(empReimObj.Contact_Id__r.role__c == 'admin' || empReimObj.Contact_Id__r.role__c == 'admin/driver') {
        //             String reportTo = '<th style="border:2px solid black;" width="5%">Report To</th>';
        //             newBody = newBody.replace('{reportToTR}',reportTo);
        //         }else {
        //             newBody = newBody.replace('{reportToTR}','');
        //         }
                
        //         if(empReimObj.Total_Mileage__c  != null) {
        //             html += +'<tr align="center">' + '<td style="border:2px solid black;">' + empReimObj.Contact_Id__r.Name + '</td>' + '<td style="border:2px solid black;">' + empReimObj.Month__c + '</td>' + '<td style="border:2px solid black;">' + empReimObj.Contact_Id__r.Monthly_Mileage_Limit__c + '</td>' + '<td style="border:2px solid black;">' + empReimObj.Total_Mileage__c + '</td>' + '<td style="border:2px solid black;">' + empReimObj.status__c + '</td>';
        //             if(empReimObj.Contact_Id__r.role__c == 'admin' || empReimObj.Contact_Id__r.role__c == 'admin/driver') {
        //                 html += +'<td style="border:2px solid black;" width="5%">' + empReimObj.Contact_Id__r.Name + '</td>';
        //             }
        //             html += +'</tr>';
        //         }
        //         newBody = newBody.replace('{tableDynamicData}',html);
        //     }
            
            
        //     if(!owea.isEmpty()) {
        //         mail.setOrgWideEmailAddressId(owea.get(0).Id);
        //     }
            
        //     mail.setToAddresses(toAddresses);
        //     mail.setSubject(emailTemplate.Subject);
        //     // mail.setBCCAddresses(new string[]{'minkesh.patel@getoncrm.com','natavar.goc@gmail.com'});
        //     mail.setHtmlBody(newBody);
        //     if(newBody.contains('</td>')){
        //          //mails.add(mail);    
        //     }
        // }

        // for(Contact conObj : [SELECT Id,Name FROM Contact WHERE Id In: contactEmReimMap.Keyset()]){
        //     system.debug(conObj.Name);
        //     if(contactEmReimMap.containsKey(conObj.Id)){ 
        //         system.debug(contactEmReimMap.get(conObj.Id));
        //     } 
        // }

        // if(!mails.isEmpty()) {
        //     Messaging.sendEmail(mails);
        // }   

    }

    /*
        Finish Method
    */ 
    global void finish(Database.BatchableContext BC){

    }
}