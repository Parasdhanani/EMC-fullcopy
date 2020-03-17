/**
 * @File Name          : CheckVehicleAccountTrigger.trigger
 * @Description        : Verify the availablity of vehicle based on vehicle value entered in Account records.
 * @Author             : Minkesh Patel
 * @Modification Log   : 

**/
trigger CheckVehicleAccountTrigger on Account(before insert,before update) {
    if(Trigger.isInsert && Trigger.isBefore || Trigger.isUpdate && Trigger.isBefore){
        CheckVehicleAccountTriggerHandler.getvehiclename(Trigger.new);
    }
}