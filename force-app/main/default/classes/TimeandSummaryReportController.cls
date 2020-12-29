/*
 * @Author:  GetonCRM Solutions LLP
 * @Description:  Apex class use to download a excel file for Time and Attendance Summary report.
 * ------------------------------------------------------------------------------------------------------------------------
 * @Modification Logs
 * ------------------------------------------------------------------------------------------------------------------------
 * @version 1.1   - @Author:  Sanket Goswami - 1 July 2020
 */
public with sharing class TimeandSummaryReportController {
    public List<mileageWrapper> mileageWrapperList{get;set;}
    public double totalMileges {get; set;}
    public string totalDriveTime {get; set;}
    public string totalStayTimeForMonth {get; set;}
    public string totalTimeForMonth {get; set;}
    public string contactName {get; set;}
    public integer totalMinute;
    public integer totalStay;
    public integer totalTimes;
    public String xlsHeader{
        get{
            String strHeader = '';
            strHeader += '<?xml version="1.0" encoding="UTF-8"?>';
            strHeader += '<?mso-application progid="Excel.Sheet"?>';
            return strHeader;
    
        }
    
    }
    public TimeandSummaryReportController() {
        drivingTime();
    }
    public void drivingTime(){
        String Id = ApexPages.currentPage().getParameters().get('id');
        String startDate = ApexPages.currentPage().getParameters().get('startDate');
        String endDate = ApexPages.currentPage().getParameters().get('endDate');
        system.debug('id'+id+'startDate'+startDate+'endDate'+endDate);
        mileageWrapperList = new List<mileageWrapper>();
        Map<Date,String> tripdateDayMap = new Map<Date,String>(); 
        Map<Date,Double> tripdateMileageMap = new Map<Date,Double>();
        Map<Date,Decimal> tripdateDrivingTimeMap = new Map<Date,Decimal>();
        Map<Date,Decimal> tripStayTimeMap = new Map<Date,Double>();
        Map<Date,Decimal> tripTotalTimeMap = new Map<Date,Double>();
        for(Employee_Mileage__c objMileages : [SELECT id,EmployeeReimbursement__r.Name,Trip_Date__c,Day_Of_Week__c, 
                                                        Mileage__c, Driving_Time__c,Origin_Name__c,
                                                        ConvertedStartTime__c, ConvertedEndTime__c, 
                                                        Stay_Time__c, EmployeeReimbursement__r.Contact_Id__c,
                                                        EmployeeReimbursement__r.Contact_Id__r.Name,Total_Time__c
                                                    FROM Employee_Mileage__c 
                                                    WHERE EmployeeReimbursement__r.Contact_Id__c =: Id
                                                    AND Trip_Date__c >= : Date.valueOf(startDate)
                                                    AND Trip_Date__c <= : Date.valueOf(endDate)
                                                    ]){
            contactName = objMileages.EmployeeReimbursement__r.Contact_Id__r.Name;
            tripdateDayMap.put(objMileages.Trip_Date__c, objMileages.Day_Of_Week__c);
            if(tripdateMileageMap.size() > 0 && tripdateMileageMap.containsKey(objMileages.Trip_Date__c)){
                double mileage = tripdateMileageMap.get(objMileages.Trip_Date__c);
                mileage = mileage + objMileages.Mileage__c ;
                tripdateMileageMap.put(objMileages.Trip_Date__c, mileage);
            }
            else {
                tripdateMileageMap.put(objMileages.Trip_Date__c, objMileages.Mileage__c);
            }

            if(tripdateDrivingTimeMap.size() > 0 && tripdateDrivingTimeMap.containsKey(objMileages.Trip_Date__c)){
                decimal driveTime = tripdateDrivingTimeMap.get(objMileages.Trip_Date__c);
                if(objMileages.Driving_Time__c != null){
                    driveTime = driveTime + objMileages.Driving_Time__c ;
                }
                
                tripdateDrivingTimeMap.put(objMileages.Trip_Date__c, driveTime);
            }
            else {
                tripdateDrivingTimeMap.put(objMileages.Trip_Date__c, objMileages.Driving_Time__c);
            }

            if(objMileages.Stay_Time__c != null){
                if(tripStayTimeMap.size() > 0 && tripStayTimeMap.containsKey(objMileages.Trip_Date__c)){
                    decimal stayTime = tripStayTimeMap.get(objMileages.Trip_Date__c);
                    stayTime = stayTime + objMileages.Stay_Time__c ;
                    tripStayTimeMap.put(objMileages.Trip_Date__c, stayTime);
                }
                else {
                    tripStayTimeMap.put(objMileages.Trip_Date__c, objMileages.Stay_Time__c);
                }
            }

            if(objMileages.Total_Time__c != null){
                if(tripTotalTimeMap.size() > 0 && tripTotalTimeMap.containsKey(objMileages.Trip_Date__c)){
                    decimal totalsTime = tripTotalTimeMap.get(objMileages.Trip_Date__c);
                    totalsTime = totalsTime + objMileages.Total_Time__c ;
                    tripTotalTimeMap.put(objMileages.Trip_Date__c, totalsTime);
                }
                else {
                    tripTotalTimeMap.put(objMileages.Trip_Date__c, objMileages.Total_Time__c);
                }
            }
            
        }
        
        for(Date currentDate : tripdateDayMap.keySet())
        {
            List<String> dateSplitted = new List<String>();
            if(String.valueOf(currentDate) != null && String.valueOf(currentDate).contains('-')){
                dateSplitted = String.valueOf(currentDate).split('-');
            }
         
            if(totalMinute > 0 ){
                totalMinute = totalMinute + Integer.valueOf(tripdateDrivingTimeMap.get(currentDate));
            } else {
                totalMinute = Integer.valueOf(tripdateDrivingTimeMap.get(currentDate));
            }
            
            if(totalStay > 0 && tripStayTimeMap.containsKey(currentDate)){
                totalStay = totalStay + Integer.valueOf(tripStayTimeMap.get(currentDate));
            } else {
                totalStay = Integer.valueOf(tripStayTimeMap.get(currentDate));
            }

            if(totalTimes > 0 && tripTotalTimeMap.containsKey(currentDate)){
                totalTimes = totalTimes + Integer.valueOf(tripTotalTimeMap.get(currentDate));
            } else {
                totalTimes = Integer.valueOf(tripTotalTimeMap.get(currentDate));
            }

            mileageWrapper objMileageWrap = new mileageWrapper();
            if(!dateSplitted.isEmpty()){
                objMileageWrap.tripDate = dateSplitted[1]+'/'+dateSplitted[2]+'/'+dateSplitted[0].substring(2,4);
            }
            objMileageWrap.tripDay = tripdateDayMap.get(currentDate);
            objMileageWrap.mileage = tripdateMileageMap.get(currentDate);
            objMileageWrap.totaldrivingTime = Utils.ConvertMinuteToHours(Integer.valueOf(tripdateDrivingTimeMap.get(currentDate)));
            objMileageWrap.totalStayTime = Utils.ConvertMinuteToHours(Integer.valueOf(tripStayTimeMap.get(currentDate)));
            objMileageWrap.totalTime = Utils.ConvertMinuteToHours(Integer.valueOf(tripTotalTimeMap.get(currentDate)));
            if(totalMileges > 0 ){
                totalMileges = totalMileges + objMileageWrap.mileage;
            } else {
                totalMileges = objMileageWrap.mileage;
            }
            
            mileageWrapperList.add(objMileageWrap);
        }
        System.debug('mileageWrapperList'+mileageWrapperList);
        totalTimeForMonth = Utils.ConvertMinuteToHours(totalTimes); 
        totalDriveTime = Utils.ConvertMinuteToHours(totalMinute);
        totalStayTimeForMonth = Utils.ConvertMinuteToHours(totalStay);
    }

    public class mileageWrapper{
        public string tripDate { get; set; }
        public string tripDay { get; set; }
        public decimal mileage { get; set; }
        public String totaldrivingTime { get; set; }
        public String totalStayTime { get; set; }
        public String totalTime { get; set; }
        public mileageWrapper(){
        }
    }
}