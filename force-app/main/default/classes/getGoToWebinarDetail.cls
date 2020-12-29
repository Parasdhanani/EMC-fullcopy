global class getGoToWebinarDetail {

    public static String authCode;
    public static String MsgToDisplay { get; set; }
    public static Boolean gotAuthCode;
    public static Map<String,String> sessKeyTimeZoneMap {get; set;}

    
    // redirect url after having auth code(oAuth step 1)
    public Pagereference getAuthCode(){
        system.debug('in authcode method==@p');
        String ClientId = system.Label.G2W_Client_Id;
        String redirectUri = EncodingUtil.urlEncode(URL.getSalesforceBaseUrl().toExternalForm() + '/apex/G2Wauthorization', 'UTF-8');
        String endPoint = 'https://api.getgo.com/oauth/v2/authorize?client_id='
                            + ClientId +'&response_type=code&redirect_uri='
                            + redirectUri ;

        Pagereference url4AuthCode = new Pagereference(endPoint);
        return url4AuthCode.setRedirect(True);
    }

    /*{
        "access_token": "eyJraWQiOiJvYXV0aHYyLmxt666...",
        "token_type": "Bearer",
        "refresh_token": "eyJraWQiOiJvYXV0aHYyLmxt999...",
        "expires_in": 3600,
        "account_key": "9999982253621659654",
        "account_type": "",
        "email": "mister.jones@fakemail.com",
        "firstName": "Moon",
        "lastName": "Beam",
        "organizer_key": "8439885694023999999",
        "version": "3"
       }
    */
    public static void getAccessToken(){
        System.debug('in acctoken method 1==@p==');
        if(!ApexPages.currentPage().getParameters().containskey('code')){
            gotAuthCode = false;
            return;
        }else{
            gotAuthCode = true;
            authCode = ApexPages.currentPage().getParameters().get('code');
        }
        System.debug('in acctoken method (not return)==@p==');
        String base64encodedString = EncodingUtil.base64Encode(Blob.valueOf(system.Label.G2W_Client_Id +':'+ system.Label.G2W_Client_secret));
        //String redirectUri = system.Label.G2W_Redirect_URL;
        String redirectUri = EncodingUtil.urlEncode(URL.getSalesforceBaseUrl().toExternalForm() + '/apex/G2Wauthorization', 'UTF-8');
        system.debug('authcode==@p=='+authCode);
        String endPoint = 'https://api.getgo.com/oauth/v2/token?grant_type=authorization_code&code='+ 
                            authCode+'&redirect_uri='+ redirectUri ;
        HttpRequest httpReq = new HttpRequest();
        HttpResponse httpRes = new HttpResponse();
        Http http = new Http();
        httpReq.setMethod('POST');
        httpReq.setEndPoint(endPoint);
        httpReq.setHeader('Authorization' , 'Basic '+ base64encodedString);
        httpReq.setHeader('Accept' , 'application/json');
        httpReq.setHeader('Content-Type' , 'application/x-www-form-urlencoded');
        System.debug('httpReq==@p=='+httpReq);
        try{
            httpRes = http.send(httpReq);
            System.debug('Status code==@p=='+httpRes.getStatusCode());
            System.debug('httpRes.getBody()==@p=='+httpRes.getBody());
            if(httpRes.getStatusCode() == 200){
                Map<String, Object> result = (Map<String, Object>)JSON.deserializeUntyped(httpRes.getBody());
                Map<String,Object> cMDfieldMap = new Map<String,Object>();
                system.debug('result==@p='+result);
                cMDfieldMap.put('access_Token__c',string.valueof(result.get('access_token')));
                cMDfieldMap.put('Account_Key__c', string.valueof(result.get('account_key')));
                cMDfieldMap.put('Organizer_Key__c', string.valueof(result.get('organizer_key')));
                cMDfieldMap.put('refresh_Token__c', string.valueof(result.get('refresh_token')));
                cMDfieldMap.put('Token_created_time__c', system.now());
                cMDfieldMap.put('Expire_In_Time__c', system.now().addSeconds(Integer.valueof(result.get('expires_in'))));
                cMDfieldMap.put('First_Name__c', string.valueof(result.get('firstName')));
                cMDfieldMap.put('Last_Name__c', string.valueof(result.get('lastName')));
                cMDfieldMap.put('Email__c', string.valueof(result.get('email')));
                system.debug('cMDfieldMap==@p=='+cMDfieldMap);
                customMetaDataUtils.updateCustomMetadata('G2W_oAuth__mdt','G2W_oAuth','G2W oAuth',cMDfieldMap);
                system.debug('refresh token ==@p=='+ string.valueof(result.get('refresh_token')));
                MsgToDisplay = system.label.G2W_Auth_page_Msg;
            } else{
                MsgToDisplay = 'Try again !! Error = '+ httpRes.getBody();
            }
        }catch(System.Exception e){
            MsgToDisplay = 'Some error occur during Authorization :( ======'+e.getMessage();
            System.debug('sys error--'+e.getMessage());
        }
    }

    /*{
        "access_token": "eyJraWQiOiJvYXV0aHYyLmxt666...",
        "token_type": "Bearer",
        "refresh_token": "eyJraWQiOiJvYXV0aHYyLmxt999...",
        "expires_in": 3600,
        "account_key": "9999982253621659654",
        "account_type": "",
        "email": "mahar.singh@company.com",
        "firstName": "Mahar",
        "lastName": "Singh",
        "organizer_key": "8439885694023999999",
        "version": "3"
        }
    */
    //@future(callout=true)
    webservice static void refreshAcceToken(){
         
        String base64encodedString = EncodingUtil.base64Encode(Blob.valueOf(system.Label.G2W_Client_Id +':'+ system.Label.G2W_Client_secret));
        String endPoint = 'https://api.getgo.com/oauth/v2/token?grant_type=refresh_token&refresh_token='+ getGoToWebinarDetail.getRefreToken();
        HttpRequest httpReq = new HttpRequest();
        HttpResponse httpRes = new HttpResponse();
        Http http = new Http();
        httpReq.setMethod('POST');
        httpReq.setEndPoint(endPoint);
        httpReq.setHeader('Authorization' , 'Basic '+ base64encodedString);
        httpReq.setHeader('Content-Type' , 'application/x-www-form-urlencoded');
        try{
            httpRes = http.send(httpReq);
            if(httpRes.getStatusCode() == 200){
                Map<String, Object> result = (Map<String, Object>)JSON.deserializeUntyped(httpRes.getBody());
                Map<String,Object> cMDfieldMap = new Map<String,Object>();
                //system.debug('result==@p='+result);
                cMDfieldMap.put('access_Token__c',string.valueof(result.get('access_token')));
                cMDfieldMap.put('Account_Key__c', string.valueof(result.get('account_key')));
                cMDfieldMap.put('Organizer_Key__c', string.valueof(result.get('organizer_key')));
                cMDfieldMap.put('refresh_Token__c', string.valueof(result.get('refresh_token')));
                cMDfieldMap.put('Token_created_time__c', system.now());
                cMDfieldMap.put('Expire_In_Time__c', system.now().addSeconds(Integer.valueof(result.get('expires_in'))));
                cMDfieldMap.put('First_Name__c', string.valueof(result.get('firstName')));
                cMDfieldMap.put('Last_Name__c', string.valueof(result.get('lastName')));
                cMDfieldMap.put('Email__c', string.valueof(result.get('email')));
                //system.debug('cMDfieldMap==@p=='+cMDfieldMap);
                customMetaDataUtils.updateCustomMetadata('G2W_oAuth__mdt','G2W_oAuth','G2W oAuth',cMDfieldMap);
                MsgToDisplay = system.label.G2W_Auth_page_Msg;
            } else{
                System.debug(' error--');
            }
        }catch(System.Exception e){
            System.debug('sys error--'+e.getMessage());
        }
    }

    //https://api.getgo.com/G2W/rest/v2/organizers/{organizerKey}/webinars
    /*{
        "_embedded": {
          "webinars": [
            {
              "webinarKey": "string",
              "webinarID": "string",
              "organizerKey": "string",
              "accountKey": "string",
              "subject": "string",
              "description": "string",
              "times": [
                {
                  "startTime": "2020-09-22T11:49:29Z",
                  "endTime": "2020-09-22T11:49:29Z"
                }
              ],
              "timeZone": "string",
              "locale": "en_US",
              "approvalType": "string",
              "registrationUrl": "string",
              "impromptu": true,
              "isPasswordProtected": true,
              "recurrenceType": "string",
              "experienceType": "string"
            }
          ]
        },
        "page": {
          "size": 0,
          "totalElements": 0,
          "totalPages": 0,
          "number": 0
        }
      }
    */
    //@future(callout=true)
    webservice static void getAllwebinars() {
        //getGoToWebinarDetail.getAllwebinars();
        HttpRequest httpReq = new HttpRequest();
        HttpResponse httpRes = new HttpResponse();
        Http http = new Http();
        String fromTime = '2013-03-13T10:00:00Z';
        String toTime = '2021-10-13T22:00:00Z';
        String page = '0';
        String size = '200';
        String endpoint = system.label.G2W_Base_URL +'/organizers/'+ getGoToWebinarDetail.getOrganiKey() +
                            '/webinars?fromTime='+ fromTime +
                            '&toTime='+ toTime +
                            '&page='+ page +'&size='+ size;
        
        httpReq.setMethod('GET');
        httpReq.setEndPoint(endpoint);
        httpReq.setHeader('Accept' , 'application/json');
        httpReq.setHeader('Content-Type' , 'application/x-www-form-urlencoded' );
        httpReq.setHeader('Authorization','Bearer '+ getGoToWebinarDetail.getAcceToken());

        try{
            httpRes = http.send(httpReq);
            if(httpRes.getStatusCode() == 200){
                // Deserialize the JSON string into collections of primitive data types.
                Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(httpRes.getBody());
                Map<String, Object> embedded = (Map<String, Object>) results.get('_embedded');
                List<Object> webinarsObjList = (List<Object>) embedded.get('webinars');
                List<GoToWebinar_Detail__c> g2wObjUpsertList = new List<GoToWebinar_Detail__c>();
                for(Object wObj : webinarsObjList){
                    GoToWebinar_Detail__c g2wObj = new GoToWebinar_Detail__c();
                    Map<String, Object> webinarsInfoMap = (Map<String, Object>) wObj;
                    
                    g2wObj.Registration_URL__c = String.valueOf(webinarsInfoMap.get('registrationUrl'));
                    g2wObj.GTW_webinar_key__c = String.valueOf(webinarsInfoMap.get('webinarKey'));
                    g2wObj.GTW_organizer_key__c = String.valueOf(webinarsInfoMap.get('organizerKey'));
                    String webiName = String.valueOf(webinarsInfoMap.get('subject'));
                    g2wObj.Webinar_Name__c = webiName;
                    //system.debug('---------webiName----'+webiName);
                    if(webiName.contains('Driver Meeting')){
                        //g2wObj.Account__c = getGoToWebinarDetail.fillAccLookupForG2W(webiName);
                    }
                    g2wObj.Registered__c = Integer.valueOf(webinarsInfoMap.get('registrantCount'));
                    g2wObj.Attended__c = Integer.valueOf(webinarsInfoMap.get('registrantsAttended'));
                    g2wObj.GTW_account_key__c = String.valueOf(webinarsInfoMap.get('accountKey'));
                    g2wObj.Name = String.valueOf(webinarsInfoMap.get('subject')) +'-ID:-' + String.valueOf(webinarsInfoMap.get('webinarID'));
                    g2wObj.Webinar_ID__c = String.valueOf(webinarsInfoMap.get('webinarID'));
                    String TZ = String.valueOf(webinarsInfoMap.get('timeZone'));
                    g2wObj.Time_Zone__c = TZ.substringAfter('/');
                    g2wObj.GTW_Status__c = 'Not Started';

                    List<Object> timesObj = (List<Object>) webinarsInfoMap.get('times');
                    Map<String,Object> timesObjMap = (Map<String, Object>) timesObj[0];
                    String startDT = String.valueOf(timesObjMap.get('startTime'));
                    String endDT = String.valueOf(timesObjMap.get('endTime'));
                    
                    g2wObj.Scheduled_Start_Time__c = getGoToWebinarDetail.convertDatetimeInAMPMformat(startDT, TZ);
                    g2wObj.Scheduled_Start_Date__c = date.valueOf(startDT.substringBefore('T'));
                    g2wObj.Scheduled_End_Time__c = getGoToWebinarDetail.convertDatetimeInAMPMformat(endDT, TZ);

                    
                    
                    g2wObjUpsertList.add(g2wObj);
                }
                Database.UpsertResult[] g2wUpsertResult = Database.upsert(g2wObjUpsertList, GoToWebinar_Detail__c.GTW_webinar_key__c,false);
                system.debug('-------p---'+g2wUpsertResult);
                getGoToWebinarDetail.getAllSessions();
                MsgToDisplay = system.label.G2W_Auth_page_Msg3;
            }else{
                System.debug('error---');
                MsgToDisplay = 'Try again !! Error = '+ httpRes.getBody();
            }
        }catch(System.Exception e){
            System.debug('sys error--'+e.getMessage());
            MsgToDisplay = 'Try again !! Error = '+ e.getMessage();
        }      
    }


    //https://api.getgo.com/G2W/rest/v2/organizers/{organizerKey}/sessions
    /*{
        "_embedded": {
            "sessionInfoResources": [
            {
                "sessionKey": "string",
                "webinarKey": "string",
                "webinarName": "string",
                "startTime": "2020-09-22T11:49:29Z",
                "endTime": "2020-09-22T11:49:29Z",
                "registrantsAttended": 0,
                "registrantCount": 0,
                "accountKey": "string",
                "creatingOrganizerKey": "string",
                "creatingOrganizerName": "string",
                "startingOrganizerKey": "string",
                "startingOrganizerName": "string",
                "totalPollCount": 0,
                "timeZone": "string",
                "experienceType": "string",
                "webinarID": "string"
            }
            ]
        },
        "page": {
            "size": 0,
            "totalElements": 0,
            "totalPages": 0,
            "number": 0
        }
       }
    */
    @future(callout=true)
    webservice static void getAllSessions(){
        //getGoToWebinarDetail.getAllSessions();
        HttpRequest httpReq = new HttpRequest();
        HttpResponse httpRes = new HttpResponse();
        Http http = new Http();
        String fromTime = '2013-03-13T10:00:00Z';
        String toTime = '2021-10-13T22:00:00Z';
        String page = '0';
        String size = '200';
        String organizerKey = getGoToWebinarDetail.getOrganiKey();
        String endpoint = system.label.G2W_Base_URL+'/organizers/'+ organizerKey +
                            '/sessions?fromTime='+ fromTime +
                            '&toTime='+ toTime +
                            '&page='+ page +'&size='+ size;
        
        httpReq.setMethod('GET');
        httpReq.setEndPoint(endpoint);
        httpReq.setHeader('Accept' , 'application/json');
        httpReq.setHeader('Content-Type' , 'application/x-www-form-urlencoded' );
        httpReq.setHeader('Authorization','Bearer '+ getGoToWebinarDetail.getAcceToken());

        try{
            httpRes = http.send(httpReq);
            if(httpRes.getStatusCode() == 200){
                // Deserialize the JSON string into collections of primitive data types.
                Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(httpRes.getBody());
                Map<String, Object> embedded = (Map<String, Object>) results.get('_embedded');
                List<Object> sessionsObjList = (List<Object>) embedded.get('sessionInfoResources');
                List<GoToWebinar_Detail__c> g2wObjUpsertList = new List<GoToWebinar_Detail__c>();
                for(Object se:sessionsObjList){
                    GoToWebinar_Detail__c g2wObj = new GoToWebinar_Detail__c();
                    Map<String, Object> sessionsInfoMap = (Map<String, Object>) se;
                    
                    g2wObj.Name = String.valueOf(sessionsInfoMap.get('webinarName')) +'-ID:-' + String.valueOf(sessionsInfoMap.get('webinarID'));
                    g2wObj.Webinar_ID__c = String.valueOf(sessionsInfoMap.get('webinarID'));
                    g2wObj.GTW_session_key__c = String.valueOf(sessionsInfoMap.get('sessionKey'));
                    g2wObj.GTW_webinar_key__c = String.valueOf(sessionsInfoMap.get('webinarKey'));
                    g2wObj.GTW_organizer_key__c = String.valueOf(sessionsInfoMap.get('creatingOrganizerKey'));
                    String webiName = String.valueOf(sessionsInfoMap.get('webinarName'));
                    g2wObj.Webinar_Name__c = webiName;
                    if(webiName.contains('Driver Meeting')){
                        //g2wObj.Account__c = getGoToWebinarDetail.fillAccLookupForG2W(webiName);
                    }
                    g2wObj.Registered__c = Integer.valueOf(sessionsInfoMap.get('registrantCount'));
                    g2wObj.Attended__c = Integer.valueOf(sessionsInfoMap.get('registrantsAttended'));
                    g2wObj.GTW_account_key__c = String.valueOf(sessionsInfoMap.get('accountKey'));

                    String startDT = String.valueOf(sessionsInfoMap.get('startTime'));
                    String endDT = String.valueOf(sessionsInfoMap.get('endTime'));
                    String TZ = String.valueOf(sessionsInfoMap.get('timeZone'));
                    g2wObj.Actual_Start_Time__c = getGoToWebinarDetail.convertDatetimeInAMPMformat(startDT, TZ);
                    g2wObj.Actual_End_Time__c = getGoToWebinarDetail.convertDatetimeInAMPMformat(endDT, TZ);
                    g2wObj.GTW_Status__c = 'Completed';
                    //g2wObj.Scheduled_Start_Date__c = date.valueOf((startDateTime).substringBefore('T'));
                    //g2wObj.Time_Zone__c = String.valueOf(sessionsInfoMap.get('timeZone'));
                    
                    //sessKeyTimeZoneMap.put(String.valueOf(sessionsInfoMap.get('sessionKey')), TZ);
                    g2wObjUpsertList.add(g2wObj);
                }
                Database.UpsertResult[] g2wUpsertResult = Database.upsert(g2wObjUpsertList, GoToWebinar_Detail__c.GTW_webinar_key__c,false);
                //ID batchprocessid =  Database.executeBatch(new G2WgetAllregistrantsBatch(),1);
                // AsyncApexJob aaj = [SELECT Id, Status, 
                //                         JobItemsProcessed, TotalJobItems, NumberOfErrors 
                //                     FROM AsyncApexJob 
                //                     WHERE ID =: batchprocessid ];
                system.debug('=g2wUpsertResult===p====='+ g2wUpsertResult);
                MsgToDisplay = system.label.G2W_Auth_page_Msg3;
            }else{
                MsgToDisplay = 'Try again !! Error = '+ httpRes.getBody();
            }
        }catch(System.Exception e){
            MsgToDisplay = 'Try again !! Error = '+ e.getMessage();
        }      
    }

    //https://api.getgo.com/G2W/rest/v2/organizers/{organizerKey}/webinars/{webinarKey}/registrants
    /*  [
            {
                "lastName": "string",
                "email": "string",
                "firstName": "string",
                "registrantKey": 0,
                "registrationDate": "2020-09-29T03:58:46Z",
                "status": "APPROVED",
                "joinUrl": "string",
                "timeZone": "string"
            }
        ]
    */
    webservice static void getAllregistrants(String g2wObjId){
        //getGoToWebinarDetail.getAllregistrants();
        GoToWebinar_Detail__c g2wObj =[SELECT id,GTW_webinar_key__c,GTW_session_key__c,
                                            Actual_Start_Time__c,Scheduled_Start_Date__c 
                                        FROM GoToWebinar_Detail__c
                                        WHERE id =:g2wObjId
                                        LIMIT 1 ];
        String webinarKey = g2wObj.GTW_webinar_key__c;
        HttpRequest httpReq = new HttpRequest();
        HttpResponse httpRes = new HttpResponse();
        Http http = new Http();
        
        String endpoint = system.label.G2W_Base_URL+'/organizers/'+ getGoToWebinarDetail.getOrganiKey() +
                            '/webinars/'+ webinarKey +'/registrants';
        
        httpReq.setMethod('GET');
        httpReq.setEndPoint(endpoint);
        httpReq.setHeader('Accept' , 'application/json');
        httpReq.setHeader('Content-Type' , 'application/x-www-form-urlencoded' );
        httpReq.setHeader('Authorization','Bearer '+ getGoToWebinarDetail.getAcceToken());

        try{
            httpRes = http.send(httpReq);
            if(httpRes.getStatusCode() == 200){
                // Deserialize the JSON string into collections of primitive data types.
                List<Object> results = (List<Object>) JSON.deserializeUntyped(httpRes.getBody());
                List<GTW_Attendee__c> g2wAttenObjUpsertList = new List<GTW_Attendee__c>();
                for(Object obj : results ){
                    GTW_Attendee__c g2wAttenObj = new GTW_Attendee__c();
                    Map<String,Object> objMap = (Map<String, Object>) obj;

                    String email = String.valueOf(objMap.get('email'));
                    g2wAttenObj.Email_Address__c = email;
                    //if(getGoToWebinarDetail.emailContactExistOrNot(email)){
                    //g2wAttenObj.Contact__c = getGoToWebinarDetail.fillContactLookupForG2W(email);
                    //}
                    g2wAttenObj.Name = String.valueOf(objMap.get('firstName')) +
                                     ' ' + String.valueOf(objMap.get('lastName'))+
                                     '-ID:-'+String.valueOf(objMap.get('registrantKey'));
                    g2wAttenObj.Registrant_Key__c = String.valueOf(objMap.get('registrantKey'));
                    g2wAttenObj.First_Name__c = String.valueOf(objMap.get('firstName'));
                    g2wAttenObj.Last_Name__c = String.valueOf(objMap.get('lastName'));

                    string regDateTime = String.valueOf(objMap.get('registrationDate'));
                    string regTimeZone = String.valueOf(objMap.get('timeZone'));
                    g2wAttenObj.Registration_Time__c = getGoToWebinarDetail.convertDatetimeInAMPMformat(regDateTime,regTimeZone);
                    g2wAttenObj.Registration_Date__c = Date.valueOf(regDateTime.substringBefore('T'));
                    g2wAttenObj.Time_Zone__c = regTimeZone.substringAfter('/');
                    
                    g2wAttenObj.Join_Url__c = String.valueOf(objMap.get('joinUrl'));
                    g2wAttenObj.Attended__c = false;
                    g2wAttenObj.GoToWebinar_Detail__c = g2wObj.Id;
                    g2wAttenObj.Webinar_Key__c = g2wObj.GTW_webinar_key__c;
                    g2wAttenObj.Actual_Start_Time__c = g2wObj.Actual_Start_Time__c;
                    g2wAttenObj.Webinar_Date__c = g2wObj.Scheduled_Start_Date__c; 
                    
                    
                    g2wAttenObjUpsertList.add(g2wAttenObj);
                }
                Database.UpsertResult[] g2wAttUpsertResult = Database.upsert(g2wAttenObjUpsertList, GTW_Attendee__c.Registrant_Key__c,false);
                //System.debug('upsertresult=================@p=='+g2wAttUpsertResult);
                getGoToWebinarDetail.getAllAttendees(g2wObj.id);
                MsgToDisplay = 'You got all Attendees successfully :)';
            }else{
                MsgToDisplay = 'Try again !! Error = '+ httpRes.getBody();
            }
        }catch(System.Exception e){
            MsgToDisplay = 'Try again !! Error = '+ e.getMessage();
        }    
    }

    //https://api.getgo.com/G2W/rest/v2/organizers/{organizerKey}/webinars/{webinarKey}/sessions/{sessionKey}/performance
    /*  {
            "sessionInfo": {
                "webinarName": "Anton Paar Driver Meeting",
                "recurrencePeriod": "intermittent",
                "webinarId": "829138115",
                "sessionKey": "18116241",
                "registrationLinkClickedCount": 90,
                "timeZone": "America/Denver",
                "startTime": "2020-01-17T18:47:06Z",
                "endTime": "2020-01-17T21:07:47Z",
                "experienceType": "classic",
                "registrationEmailOpenedCount": 0
            },
            "pollsAndSurveys": {
                "surveyCount": 0,
                "questionsAsked": 60,
                "pollCount": 0,
                "percentagePollsCompleted": 0,
                "percentageSurveysCompleted": 0
            },
            "attendance": {
                "percentageAttendance": 88.63636,
                "registrantCount": 44,
                "averageInterestRating": 70.84615,
                "averageAttendanceTimeSeconds": 6531.20513,
                "averageAttentiveness": 55.28205
            }
        }
    */
    // @future(callout=true)
    webservice static void getSessionPerformance(String g2wObjId){
        GoToWebinar_Detail__c g2wObj =[SELECT id,GTW_webinar_key__c,GTW_session_key__c 
                                        FROM GoToWebinar_Detail__c
                                        WHERE id =:g2wObjId
                                        LIMIT 1 ]; 
        String webinarKey = g2wObj.GTW_webinar_key__c;
        String sessionKey = g2wObj.GTW_session_key__c;
        HttpRequest httpReq = new HttpRequest();
        HttpResponse httpRes = new HttpResponse();
        Http http = new Http();

        String endpoint = system.label.G2W_Base_URL+'/organizers/'+ getGoToWebinarDetail.getOrganiKey() +
                            '/webinars/'+ webinarKey + '/sessions/'+ sessionKey +'/performance';
        httpReq.setMethod('GET');
        httpReq.setEndPoint(endpoint);
        httpReq.setHeader('Accept' , 'application/json');
        httpReq.setHeader('Content-Type' , 'application/x-www-form-urlencoded' );
        httpReq.setHeader('Authorization','Bearer '+ getGoToWebinarDetail.getAcceToken());

        try{
            system.debug('httpReq--------'+httpReq);
            httpRes = http.send(httpReq);
            system.debug('httpRes.getBody()--------'+httpRes.getBody());
            if(httpRes.getStatusCode() == 200){
                // Deserialize the JSON string into collections of primitive data types.
                Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(httpRes.getBody());
                Map<String, Object> attendance = (Map<String, Object>) results.get('attendance');//List<GTW_Attendee__c> g2wAttenObjUpsertList = new List<GTW_Attendee__c>();
                
                
                MsgToDisplay = 'You got all Attendees successfully :)';
            }else{
                MsgToDisplay = 'Try again !! Error = '+ httpRes.getBody();
            }
        }catch(System.Exception e){
            MsgToDisplay = 'Try again !! Error = '+ e.getMessage();
        }                   
    }

    //https://api.getgo.com/G2W/rest/v2/organizers/{organizerKey}/webinars/{webinarKey}/sessions/{sessionKey}/attendees
    /*  [
            {
                "registrantKey": 0,
                "firstName": "string",
                "lastName": "string",
                "email": "string",
                "attendanceTimeInSeconds": 0,
                "sessionKey": 0,
                "attendance": [
                {
                    "joinTime": "2020-09-22T11:49:29Z",
                    "leaveTime": "2020-09-22T11:49:29Z"
                }
                ]
            }
        ]
    */
    @future(callout = true)
    webservice static void getAllAttendees(String g2wObjId){
        GoToWebinar_Detail__c g2wObj =[SELECT id,GTW_webinar_key__c,GTW_session_key__c 
                                        FROM GoToWebinar_Detail__c
                                        WHERE id =:g2wObjId
                                        LIMIT 1 ]; 
        String webinarKey = g2wObj.GTW_webinar_key__c;
        String sessionKey = g2wObj.GTW_session_key__c;
        HttpRequest httpReq = new HttpRequest();
        HttpResponse httpRes = new HttpResponse();
        Http http = new Http();

        String endpoint = system.label.G2W_Base_URL+'/organizers/'+ getGoToWebinarDetail.getOrganiKey() +
                            '/webinars/'+ webinarKey + '/sessions/'+ sessionKey +'/attendees';
        httpReq.setMethod('GET');
        httpReq.setEndPoint(endpoint);
        httpReq.setHeader('Accept' , 'application/json');
        httpReq.setHeader('Content-Type' , 'application/x-www-form-urlencoded' );
        httpReq.setHeader('Authorization','Bearer '+ getGoToWebinarDetail.getAcceToken());

        try{
            httpRes = http.send(httpReq);
            system.debug('httpRes.getBody()--------'+httpRes.getBody());
            if(httpRes.getStatusCode() == 200){
                // Deserialize the JSON string into collections of primitive data types.
                List<Object> results = (List<Object>) JSON.deserializeUntyped(httpRes.getBody());
                List<GTW_Attendee__c> g2wAttenObjUpsertList = new List<GTW_Attendee__c>();
                for(Object obj : results ){
                    GTW_Attendee__c g2wAttenObj = new GTW_Attendee__c();
                    Map<String,Object> objMap = (Map<String, Object>) obj;

                    String email = String.valueOf(objMap.get('email'));
                    g2wAttenObj.Email_Address__c = email;
                    //g2wAttenObj.Contact__c = getGoToWebinarDetail.fillContactLookupForG2W(email);
                    
                    g2wAttenObj.Name = String.valueOf(objMap.get('firstName')) +
                                     ' ' + String.valueOf(objMap.get('lastName'))+
                                     '-ID:-'+String.valueOf(objMap.get('registrantKey'));
                    g2wAttenObj.Registrant_Key__c = String.valueOf(objMap.get('registrantKey'));
                    g2wAttenObj.First_Name__c = String.valueOf(objMap.get('firstName'));
                    g2wAttenObj.Last_Name__c = String.valueOf(objMap.get('lastName'));

                    Integer seconds = Integer.valueOf(objMap.get('attendanceTimeInSeconds'));
                    g2wAttenObj.Time_In_Session__c = String.valueOf(DateTime.valueOf(seconds*1000).formatGMT('HH:mm:ss'));
                    g2wAttenObj.Session_Key__c = String.valueOf(objMap.get('sessionKey'));
                    g2wAttenObj.GoToWebinar_Detail__c = g2wObj.id;
                    g2wAttenObj.Attended__c = true;
                    g2wAttenObj.Webinar_Key__c = g2wObj.GTW_webinar_key__c;
                    
                    List<Object> attenObj = (List<Object>) objMap.get('attendance');
                    Map<String,Object> attenObjMap = (Map<String, Object>) attenObj[0];
                    string joinTime = String.valueOf(attenObjMap.get('joinTime'));
                    string leaveTime = String.valueOf(attenObjMap.get('leaveTime'));
                    string regTimeZone = 'America/Denver'; //sessKeyTimeZoneMap.get(String.valueOf(objMap.get('sessionKey')));
                    g2wAttenObj.Join_Time__c = getGoToWebinarDetail.convertDatetimeInAMPMformat(joinTime,regTimeZone);
                    g2wAttenObj.Leave_Time__c = getGoToWebinarDetail.convertDatetimeInAMPMformat(leaveTime,regTimeZone);
                   
                    g2wAttenObjUpsertList.add(g2wAttenObj);
                }
                Database.UpsertResult[] g2wAttUpsertResult = Database.upsert(g2wAttenObjUpsertList, GTW_Attendee__c.Registrant_Key__c,false);
                //System.debug('upsertresult=================@p=='+g2wAttUpsertResult);
                
                MsgToDisplay = 'You got all Attendees successfully :)';
            }else{
                MsgToDisplay = 'Try again !! Error = '+ httpRes.getBody();
            }
        }catch(System.Exception e){
            MsgToDisplay = 'Try again !! Error = '+ e.getMessage();
        }                   
    }

    //https://api.getgo.com/G2W/rest/v2/organizers/{organizerKey}/webinars/{webinarKey}/sessions/{sessionKey}/attendees/{registrantKey}/questions
    /*
        [
            {
                "question": "Do we actually have to log EVERY trip (even personal) or do we just log business trips?",
                "askedBy": "jason.smith@us.panasonic.com",
                "askerKey": "5269363703315419404",
                "dateAsked": "2020-05-08T19:30:54Z",
                "answers": []
            },
            {
                "question": "So right now were getting a Fixed amount, is this going to stay the same and the variable milleage will be added? And what happens f you dont meet the 400+ miles per month?",
                "askedBy": "timberley.loth@us.panasonic.com",
                "askerKey": "7959009937939523598",
                "dateAsked": "2020-05-08T19:43:58Z",
                "answers": []
            },
            {
                "question": "Thank you Will! Great job.",
                "askedBy": "hannah.brauer@us.panasonic.com",
                "askerKey": "3565762795052939535",
                "dateAsked": "2020-05-08T19:50:51Z",
                "answers": [
                    {
                        "answer": "Thanks!",
                        "answeredBy": "1150664589213251590",
                        "answererRole": "INTERNAL_ORGANIZER",
                        "answerTime": "2020-05-08T19:51:12Z",
                        "answererEmail": "willh@mburse.com"
                    }
                ]
            }
        ]
    */
    //@future(callout = true)
    webservice static void getAttendeeQueAns(string webinarKey, string sessionKey){
        //getGoToWebinarDetail.getAttendeeQueAns();
        HttpRequest httpReq = new HttpRequest();
        HttpResponse httpRes = new HttpResponse();
        Http http = new Http();
        //string webinarKey;
        //string sessionKey;
        String endpoint = system.label.G2W_Base_URL+'/organizers/'+ getGoToWebinarDetail.getOrganiKey() +
                            '/webinars/'+ webinarKey + '/sessions/'+ sessionKey +
                            '/questions';
        httpReq.setMethod('GET');
        httpReq.setEndPoint(endpoint);
        httpReq.setHeader('Accept' , 'application/json');
        httpReq.setHeader('Content-Type' , 'application/x-www-form-urlencoded' );
        httpReq.setHeader('Authorization','Bearer '+ getGoToWebinarDetail.getAcceToken());

        try{
            httpRes = http.send(httpReq);
            System.debug('httpRes.getBody()---'+httpRes.getBody());
            if(httpRes.getStatusCode() == 200){
                // Deserialize the JSON string into collections of primitive data types.
                //Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(httpRes.getBody());
                //system.debug('results---'+results);
            }else{
                system.debug('error---');
            }
        }catch(System.Exception e){
            system.debug('sys error--'+e.getMessage());
        }              
    } 

    public static string getAcceToken(){
        G2W_OAuth__mdt oAuthMetaDataObject = [SELECT access_Token__c
                                                FROM G2W_OAuth__mdt
                                                WHERE MasterLabel = 'G2W oAuth'
                                                LIMIT 1];
        return oAuthMetaDataObject.access_Token__c;
    }

    public static string getRefreToken(){
        G2W_OAuth__mdt oAuthMetaDataObject = [SELECT refresh_Token__c
                                                FROM G2W_OAuth__mdt
                                                WHERE MasterLabel = 'G2W oAuth'
                                                LIMIT 1];
        return oAuthMetaDataObject.refresh_Token__c;
    }

    public static string getOrganiKey(){
        G2W_OAuth__mdt oAuthMetaDataObject = [SELECT Organizer_Key__c
                                                FROM G2W_OAuth__mdt
                                                WHERE MasterLabel = 'G2W oAuth'
                                                LIMIT 1];
        return oAuthMetaDataObject.Organizer_Key__c;
    }

    public static string fillAccLookupForG2W(String webinarName){
        system.debug('======================@p=='+webinarName);
        String AccountName = webinarName.substringBefore(' ') + '%';
        if(webinarName.contains('Saverino')){
            AccountName = '%Saverino & Associates%';
        }
        if( AccountName == 'TDE%' || AccountName == 'The%'){
            AccountName = 'commu%';
        }
        if( AccountName == 'CNCA%'){
            AccountName = '%CNCA%';
        }
        system.debug('====================@p=='+AccountName);
        if(AccountName != '%'){
            Account accObj =[SELECT  Id, Name
                            FROM Account
                            WHERE Name LIKE :AccountName LIMIT 1];
            if(accObj != null){
                system.debug('============================p=='+accObj);
                return String.valueOf(accObj.Id);
            }else{
                system.debug('=========================p=null1=');
                return null;
            }
        }else{
            system.debug('=================================p=null2=');
            return null;
        }
    }

    public static string fillContactLookupForG2W(String email){
        Contact conObj =[SELECT Id
                            FROM Contact
                            WHERE Email = :email LIMIT 1];
        return String.valueOf(conObj.Id);
    }
    
    public static string convertDatetimeInAMPMformat(String datetimejson, String timezone){
            
        Datetime inDateTime = (Datetime)(json.deserialize('"'+datetimejson+'"', datetime.class));
        //system.debug('---inDateTime--'+inDateTime);
        String dtString = inDateTime.format('MM/dd/yyyy HH:mm:ss a zz', timezone);
        Integer hour = Integer.valueOf(dtString.subString(11,13));

        if(hour>12){
            String hournew = (hour-12)<10?'0'+String.valueOf(hour-12):String.valueOf(hour-12);
            //system.debug('---hournew---'+hournew);
            dtString = dtString.substringBefore(' ')+' '+hournew+':'+dtString.substringAfter(':');
            //system.debug('---new---'+dtString);
        }
        //system.debug('---dateTimeStr'+dtString);
        return dtString;
    }
}