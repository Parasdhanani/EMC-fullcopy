global class G2WgetAttendQueAnsBatch implements Database.Batchable<sObject>,Database.AllowsCallouts {
    public String query;
    global G2WgetAttendQueAnsBatch() {
        query ='SELECT Id, Webinar_Key__c,Session_Key__c,Registrant_Key__c '+
                        'FROM GTW_Attendee__c '+
                        'WHERE Webinar_Key__c != null '+
                        'AND Session_Key__c != null '+
                        'AND Registrant_Key__c != null ';
    }

    //Start
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(query);
    }

    //Execute Logic
    global void execute(Database.BatchableContext BC, List<GTW_Attendee__c> scope) {
        for(GTW_Attendee__c g2wObj : scope ){
            getGoToWebinarDetail.getAttendeeQueAns(g2wObj.Webinar_Key__c, g2wObj.Session_Key__c, g2wObj.Registrant_Key__c);
        }
    }

    //Finish Logic
    global void finish(Database.BatchableContext BC) {
        system.debug('=====p====queAns batch finish===');   
    }
}