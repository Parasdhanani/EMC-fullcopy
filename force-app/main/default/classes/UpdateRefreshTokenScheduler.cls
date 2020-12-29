global  class UpdateRefreshTokenScheduler implements Schedulable{
    global void execute(SchedulableContext sc) {
        //getGoToWebinarDetail classObj = new getGoToWebinarDetail();
        getGoToWebinarDetail.refreshAcceToken();
    }
}