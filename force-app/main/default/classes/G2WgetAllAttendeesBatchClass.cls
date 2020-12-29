global class G2WgetAllAttendeesBatchClass implements Database.Batchable<sObject>,Database.AllowsCallouts {
    public String query;
    global G2WgetAllAttendeesBatchClass() {
        
        query ='SELECT Id, GTW_webinar_key__c,GTW_session_key__c '+
                        'FROM GoToWebinar_Detail__c '+
                        'WHERE GTW_webinar_key__c != null '+
                        'AND GTW_session_key__c != null';
    }

    //Start
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(query);
    }

    //Execute Logic
    global void execute(Database.BatchableContext BC, List<GoToWebinar_Detail__c> scope) {
        for(GoToWebinar_Detail__c g2wObj : scope ){
            //getGoToWebinarDetail.getAllAttendees(g2wObj.GTW_webinar_key__c, g2wObj.GTW_session_key__c, g2wObj);
        }
    }

    //Finish Logic
    global void finish(Database.BatchableContext BC) {
        system.debug('=====p====attend batch finish===');
        Database.executeBatch(new G2WgetAttendQueAnsBatch(),1);    
    }
}