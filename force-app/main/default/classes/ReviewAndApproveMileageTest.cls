@istest
public class ReviewAndApproveMileageTest {
    
    public static testmethod void testMethod8(){
        Account acc = TestUtilityClass.getTestSingleAccount2();
        Contact con = TestUtilityClass.getTestSingleContact3(acc);
        Contact cont = TestUtilityClass.getTestSingleContact4(acc,con);
        //Employee_Reimbursement__c emp = TestUtilityClass.getTestEmployeeReimbursement3(con);
        
        IRS_Mileage_Rate__c obj_IRS_Mileage_Rate_3 = new IRS_Mileage_Rate__c();
        obj_IRS_Mileage_Rate_3.year__c='2020';
        obj_IRS_Mileage_Rate_3.IRS_Rate__c =0.567;
        insert obj_IRS_Mileage_Rate_3;
        
        Employee_Reimbursement__c empReim = new Employee_Reimbursement__c();
        RG_InsertLastMonthReimbursement ilmr = new RG_InsertLastMonthReimbursement();
        
        empReim.Contact_Id__c = con.id;
        empReim.Name = 'Test';
        empReim.Fuel_Price__c = 12;
        empReim.MPG__c = 45;
        empReim.Month__c =  ilmr.getLastMonthValue(-1);
        //empReim.Month__c =  '01-2020';
        empReim.Approved_Date__c = null;
        empReim.Monthly_Mileage__c = 50;
        empReim.IRS_Mileage_Rate__c =obj_IRS_Mileage_Rate_3.id;
        empReim.Maintenance_and_Tires__c =10;
        insert empReim;
        
        ReviewAndApproveMileage app = new ReviewAndApproveMileage();
        Database.executeBatch(app, 1);
    }
}