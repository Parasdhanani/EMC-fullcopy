Trigger MappingGasPriceTrigger on Employee_Mileage__c (before insert, before update, after insert,after update) {
    
    TriggerConfig__c customSetting = TriggerConfig__c.getInstance('Defaulttrigger');
    system.debug('inside trigger');
   
    if( Trigger.isInsert && Trigger.isBefore && customSetting.MappingGasPriceTrigger__c)
    {
        Set<String> reimIds = new Set<String>();
        Map<String,Decimal> reimbursementWiseFuelMap = new Map<String,Decimal>();
        Map<String,Decimal> gasPriceFuelMap = new Map<String,Decimal>();
        Map<String,String> reimbursementWiseMonthMap = new Map<String,String>();
        Map<String,String> reimWiseStateCityMap = new Map<String,String>();
        for(Employee_Mileage__c mil : Trigger.New)
        {
            reimIds.add(mil.EmployeeReimbursement__c);                    
        }
        
        if(!reimIds.isEmpty()) {
            for(Employee_Reimbursement__c reim : [Select Id,
                                                                    Month__c,
                                                                    Fuel_Price__c,
                                                                    Contact_Id__r.MailingState,
                                                                    Contact_Id__r.MailingCity 
                                                                FROM Employee_Reimbursement__c 
                                                                WHERE Id In: reimIds]) {
               
                if( reim.Month__c.contains('-') 
                    && ( String.isNotBlank(reim.Contact_Id__r.MailingCity) || String.isNotBlank(reim.Contact_Id__r.MailingState) ) ) 
                {
                    reimWiseStateCityMap.put( reim.id, reim.Contact_Id__r.MailingCity + '' + reim.Contact_Id__r.MailingState.toUpperCase() );    
                }  
                if(reim.Fuel_Price__c != null && reim.Fuel_Price__c > 0 )
                    reimbursementWiseFuelMap.put(reim.id, reim.Fuel_Price__c);
                
                if(String.isNotBlank(reim.Month__c))
                    reimbursementWiseMonthMap.put(reim.Id, reim.Month__c );
                
            }

            Set<String> cityStateDate = new Set<String>();
            for(Employee_Mileage__c mil : Trigger.New) {
    
                if( mil.Trip_Date__c != null ) {
                    String month = ( mil.Trip_Date__c.month() < 10 ? '0' : '') + mil.Trip_Date__c.month() + '-' + mil.Trip_Date__c.Year();

                    if( reimbursementWiseMonthMap.containsKey(mil.EmployeeReimbursement__c) 
                    && ( month == reimbursementWiseMonthMap.get(mil.EmployeeReimbursement__c)) 
                    && reimbursementWiseFuelMap.containsKey(mil.EmployeeReimbursement__c))
                    {
                        System.debug('It have same reimbursmeent and it is setting fuel price here for Month ' + month);
                        mil.Fuel_Price__c = reimbursementWiseFuelMap.get(mil.EmployeeReimbursement__c);
                    }
                    else if(reimWiseStateCityMap.containsKey(mil.EmployeeReimbursement__c) )
                    {
                        String stateCity = reimWiseStateCityMap.get(mil.EmployeeReimbursement__c);
                        stateCity += mil.Trip_Date__c.Month() + '' + mil.Trip_Date__c.Year();
                        cityStateDate.add(stateCity);
                    } 
                }                 
                
                
            }

            System.debug('cityStateDate has no of records ' + cityStateDate);
            if(!cityStateDate.isEmpty())
            {
                for(Gas_Prices__c gs : [Select Id,
                                                Fuel_Price__c,
                                                Month_State_City__c 
                                            FROM Gas_Prices__c 
                                                WHERE Month_State_City__c IN: cityStateDate])
                {
                    gasPriceFuelMap.put( gs.Month_State_City__c, gs.Fuel_Price__c);
                }

                if(!gasPriceFuelMap.isEmpty()) {
                    for(Employee_Mileage__c mil : Trigger.New) {
                        if( mil.Trip_Date__c != null && reimWiseStateCityMap.containsKey(mil.EmployeeReimbursement__c)) {
                            String statecity = reimWiseStateCityMap.get(mil.EmployeeReimbursement__c);
                            System.debug('Finally Settinig Fuel price with a part of a key having state and City :- ' + statecity);
                            statecity += mil.Trip_Date__c.Month() + '' + mil.Trip_Date__c.Year();
                            System.debug('Added dates in to it :- ' + statecity);
                            if( gasPriceFuelMap.containsKey(statecity) ) {
                                System.debug('Finally it is Setting here the fuel price.');
                                mil.Fuel_Price__c = gasPriceFuelMap.get(statecity);
                            }
                        } 
                    }
                }
                
            }
        }
        
    }

    if(customSetting.MappingGasPriceTriggerUpdateConvertedDat__c){
        if(Trigger.isInsert && Trigger.isBefore) {
            MappingGasPriceTriggerHelper.updateConvertedDates(Trigger.new);
        }
        else if(Trigger.isBefore && Trigger.isUpdate){
            List<Employee_Mileage__c> updateMileagesList = new List<Employee_Mileage__c>();
            for(Employee_Mileage__c mil : Trigger.New)
            {
                if(mil.TimeZone__c != Trigger.oldMap.get(mil.id).TimeZone__c 
                    || mil.StartTime__c != Trigger.oldMap.get(mil.id).StartTime__c 
                    || mil.EndTime__c != Trigger.oldMap.get(mil.id).EndTime__c)
                {
                    updateMileagesList.add(mil);
                }

                if( (mil.Mileage__c == Trigger.oldMap.get(mil.id).Mileage__c) && (mil.Name.contains('EMP')) ) {
                    System.debug('mil.Mileage__c'+mil.Mileage__c);
                    System.debug('Trigger.oldMap.get(mil.id).Mileage__c'+Trigger.oldMap.get(mil.id).Mileage__c);
                    mil.Trip_Status__c = Trigger.oldMap.get(mil.id).Trip_Status__c;
                    mil.Approved_Date__c = Trigger.oldMap.get(mil.Id).Approved_Date__c;
                }

            }
            if(!updateMileagesList.isEmpty())
                MappingGasPriceTriggerHelper.updateConvertedDates(updateMileagesList);
            
        }
    }

    if(Trigger.isAfter && Trigger.isInsert && customSetting.MappingGasStayTime__c){
        set<Id> reimbursementIdsSet = new set<Id>();
        List<datetime> tripList = new List<datetime>();
        List<Employee_Mileage__c> mileageList = new List<Employee_Mileage__c>();
        for(Employee_Mileage__c empmilege : Trigger.new) {
            reimbursementIdsSet.add(empmilege.EmployeeReimbursement__c); 
        }
        System.debug('reimbursementIdsSet'+reimbursementIdsSet);
        System.debug('StaticValues.isFirstTime===='+StaticValues.isFirstTime);
        if(!reimbursementIdsSet.isEmpty() && StaticValues.isFirstTime){
            StaticValues.isFirstTime = false; 
            System.debug('StaticValues.isFirstTime'+StaticValues.isFirstTime);
            for(AggregateResult objMileage : [SELECT MIN(ConvertedStartTime__c) 
                                            FROM Employee_Mileage__c 
                                            WHERE EmployeeReimbursement__c In : reimbursementIdsSet 
                                            Group By Trip_Date__c ]){
            tripList.add((Datetime)objMileage.get('expr0'));
            }
            System.debug('tripList===='+tripList);
            for(Employee_Mileage__c objMil : [SELECT id,ConvertedStartTime__c,Stay_Time__c 
                                                FROM Employee_Mileage__c 
                                                WHERE (ConvertedStartTime__c In :tripList OR Mileage__c = 0)
                                                AND EmployeeReimbursement__c In : reimbursementIdsSet
                                                Order By Stay_Time__c]){
                objMil.Stay_Time__c = 0;
                mileageList.add(objMil);
            }
            System.debug('mileageList===='+mileageList);
            If(!mileageList.isEmpty()){
                update mileageList;
            }
        }
    }

    if(Trigger.isUpdate && Trigger.isAfter && checkRecursive.runOnce()) {
        System.debug('inside after update');
        System.debug('inside old update'+Trigger.oldMap);
        System.debug('inside new update'+Trigger.new);
        MappingGasPriceTriggerHelper.TrackHistory(Trigger.oldMap,Trigger.new);
    }
}