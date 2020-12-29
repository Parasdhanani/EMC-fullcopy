global class scheduledGetTripfromTriplogBatchClass implements Schedulable{

    /*global static String scheduleMe() {
        scheduledGetTripfromTriplogBatchClass sc = new scheduledGetTripfromTriplogBatchClass();
        return System.schedule('batch Job', '0 00 00 * * ?', sc); //Every Day at Midnight 
    }*/

    global void execute(SchedulableContext sc) {

        GetTripfromTriplogBatchClass batchClass = new GetTripfromTriplogBatchClass();
        Database.executeBatch(batchClass,1);           
    }
}