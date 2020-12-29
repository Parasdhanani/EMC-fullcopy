/*
************************************************************************
@Author : Pruthviraj Israni 25-08-2020
@Description : For latest last Month, update fuel price field 
in Employee_Mileage__c object & Employee_Reimbursement__c object based on gas price
************************************************************************
*/


global class updateFuelPriceMonthlyBatch implements Database.Batchable<sObject>,Database.AllowsCallouts, Database.Stateful {
    //adding constructor so can call web service apex class- UpdateEmpReimFuelPrice
    global updateFuelPriceMonthlyBatch(){
        String lastMonth = Utils.fetchMonths(1, 0)[0]; //month in 'mm-yyyy' format.
        //update fuel price which are null/zero in Employee_Reimbursement object
        UpdateEmpReimFuelPrice.updateFuelPrice(lastMonth);  
    }
    global Database.QueryLocator start(Database.BatchableContext BC){
        //Trip_Date__c  (From_Previous_Months__c	Checkbox)
        Integer todayYear = System.today().year();
        Integer todayMonth = System.today().month();
        String startDateOflastMonth ;
        String endDateOflastMonth ;
        If(todayMonth == 1){
            startDateOflastMonth = (todayYear-1) + '-12-01';
            endDateOflastMonth = (todayYear-1) + '-12-31';   
        }else{
            If(todayMonth < 10){
                startDateOflastMonth = todayYear +'-0' + todayMonth + '-01';
                endDateOflastMonth = todayYear +'-0' + todayMonth + '-31';
            }else{
                startDateOflastMonth = todayYear +'-' + todayMonth + '-01';
                endDateOflastMonth = todayYear +'-' + todayMonth + '-31';    
            }
        }
        

        String query =  'SELECT Id, Fuel_price__c, EmployeeReimbursement__r.Fuel_price__c '+ 
                        ' FROM Employee_Mileage__c '+ 
                        ' WHERE Trip_Date__c >= : Date.valueOf(startDateOflastMonth) '+
                        ' AND Trip_Date__c <= : Date.valueOf(endDateOflastMonth) '+
                        ' AND EmployeeReimbursement__r.Fuel_Price__c != null '+
                        ' AND EmployeeReimbursement__r.Fuel_Price__c != 0.0 ';
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, List<Employee_Mileage__c> Scope){

        if(Scope.size()>0){
            try{
                List<Employee_Mileage__c> updateEmpMileageList = new List<Employee_Mileage__c>(); 
                for(Employee_Mileage__c empMilObj : Scope){
                
                    empMilObj.Fuel_price__c = empMilObj.EmployeeReimbursement__r.Fuel_Price__c;
                    updateEmpMileageList.add(empMilObj);           
                }
                if(!updateEmpMileageList.isEmpty()){
                    update updateEmpMileageList;
                }
            }catch(Exception e){
                System.Debug('updateFuelPriceDailyBatch-error'+ e);
            }
        }
    }
    global void finish(Database.BatchableContext BC){
    
    }
    // /* 
    //  * to get last month in mm-yyyy format pass param as '-1' as below
    //  * getLastMonthValue(-1)
    //  */
    // global String getLastMonthValue(Integer value) {
    //     String tempDate = date.today().addMonths(value).Month() + '-' + date.today().addMonths(value).Year();
    //     String lastMonth = tempDate.left(2);
    //     if(lastMonth.contains('-')) {
    //         lastMonth = '0' + tempDate;
    //     } else {
    //         lastMonth = tempDate;
    //     }
    //     return lastMonth;
    // }
}