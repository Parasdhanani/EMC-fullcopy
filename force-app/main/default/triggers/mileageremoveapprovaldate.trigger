trigger mileageremoveapprovaldate on Employee_Mileage__c (before insert , before update) {
    
    MileageTriggerHandler.MileageRemoveApprovalDateHandler(Trigger.new);
}