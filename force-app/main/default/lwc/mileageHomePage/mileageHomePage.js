import {
    LightningElement,
    track,
    api,
    wire
} from 'lwc';
import getMilegesData from '@salesforce/apex/GetDriverData.getMilegesData';

export default class MileageHomePage extends LightningElement {
    ready = false;
    @api vfurl;
    @track driverId;
    @api accountId;
    @api adminId;
    @api Id;
    @api showTeam;
    @api ProfileId;
    @api admindriver
    @track dashboardurl;
    @track mileageurl;
    @track driverurl;
    @track reporturl;
    @track myDetailurl;
    @api searchList = [];
    @track drivername;
    @track loadingSpinner = false;
    @track isSelectedChecked = false;
    @track optionSelected = false;
    @track isActive = false;
    @track fromlocation;
    @track tolocation;
    @track field;
    @track idfield;
    @track object;
    @track getstartDate;
    @track getendDate;
    @track startMileage;
    @track endMileage;
    @track trip_status;
    @track track_method;
    @track tags;
    @track notes='';
    @track key;
    @track searchkeyvalue;
    @track wherefieldvalue;
    @track accfield;
    @track emailaddressvalue;
    @track approveRejectData;
    @api filterStartDate;
    @api filterEndDate;
    @api idOfDriver;
    @api StartDate;
    @api EndDate;
    @api OriginName;
    @api DestinationName;
    @api ActiveDriver;
    @api StartMileage;
    @api EndMileage;
    @api TripStatus;
    @api TrackingMethod;
    @api Tag;
    @api Notes;
    drivermanagerLoggedIn = false;
    adminLoggedIn = false;
    admindriverLoggedIn = false;

    // Get fields for ValidateDataList component
    handleClickEvent(event) {

        // eslint-disable-next-line no-console
        this.driverId = event.detail;
        this.idfield = 'Id';
        this.field = 'Trip_Origin__c';
        this.object = 'Employee_Mileage__c';
        this.searchkeyvalue = 'Trip_Origin__c';
        this.key = 'Destination_Name__c';
        this.wherefieldvalue = 'EmployeeReimbursement__r.Contact_Id__c';
        this.accfield = 'EmployeeReimbursement__r.Contact_Id__r.AccountId';

    }
     // To clear component data
    handleClearEvent(event) {
        event.preventDefault();
        this.template.querySelectorAll('c-validate-data-list-component').forEach(element => {
            element.clearAll();
        });;

        this.template.querySelector('c-l-w-c-mileages-component').clearAll();
    }
    // Hide show advance search 
    handleButtonClick() {
        this.template.querySelector('.tripDiv')
            .classList.toggle('slds-hide');
    }
    // Cancel Button Click Event
    handleCancelEvent() {
        this.template.querySelector('.tripDiv')
            .classList.add('slds-hide')
        this.template.querySelector('.advSearch')
            .classList.remove('slds-hide');
        this.template.querySelector('.closeModalBtn')
            .classList.add('slds-hide');
    }

    // To Get Selected Start Date
    handleStartDateClickEvent(event) {
        this.getstartDate = event.detail;

    }

    // To Get Selected End Date
    handleEndDateClickEvent(event) {
        this.getendDate = event.detail;
    }


    // To Get Selected From Location
    handleFromLocation(event) {
        if(event.detail === 'All Locations'){
            this.fromlocation = null;
        }else{
            this.fromlocation = event.detail;
        }
    }

    // To Get Selected To Location
    handleToLocation(event) {
        if(event.detail === 'All Locations'){
           this.tolocation = null;
        }else{
          this.tolocation = event.detail;
        }
    }

    // To Get Selected Mileage
    handleMileageChangeEvent(event) {
        this.startMileage = event.detail;
    }

    // To Get Selected Mileage
    handleMileageChangeEnd(event) {
        this.endMileage = event.detail;
    }

    // To Get Selected Trip Status
    handleTripStatus(event) {
        if(event.detail === 'All Status'){
            this.trip_status = null;
        }else{
            this.trip_status = event.detail;
        }
        console.log("trip", this.trip_status);
    }

    // To Get Selected Track Method
    handleTrackMethod(event) {
        if(event.detail === 'All Tracking Methods'){
            this.track_method = null
        }else{
            this.track_method = event.detail;
        }
      
    }

    // To Get Selected Track Method
    handleTagSelect(event) {
        if(event.detail === 'All Tags'){
            this.tags = null;
        }else{
            this.tags = event.detail;
        }
     
    }
    // To Get Active Driver True/false
    handleActiveDriver(event) {
        this.isActive = event.target.checked;
        this.template.querySelector('c-validate-data-list-component').getActiveDriver(this.isActive);
        this.template.querySelector('c-multiple-dropdown-component').getActiveDriver(this.isActive);
    }

    // Get Data based on advance search filter
    handleSearchEvent() {
        var getTable = this.template.querySelector('c-data-table-component').getTableElement();
        this.loadingSpinner = true;
        getTable.style.opacity = "0.5";
        this.searchFlag = true;
        this.StartDate = this.getstartDate;
        this.EndDate = this.getendDate;
        this.OriginName = this.fromlocation;
        this.DestinationName = this.tolocation;
        this.ActiveDriver = this.isActive;
        this.StartMileage = this.startMileage;
        this.EndMileage = this.endMileage;
        this.TripStatus = this.trip_status;
        this.TrackingMethod = this.track_method;
        this.Tag = this.tags;
        this.Notes = this.notes;
        console.log(this.tags,this.notes);
        getMilegesData({
                accountId: this.accountId,
                idOfDriver: this.driverId,
                StartDate: this.StartDate,
                EndDate: this.EndDate,
                OriginName: this.OriginName,
                DestinationName: this.DestinationName,
                ActiveDriver: this.ActiveDriver,
                StartMileage: this.StartMileage,
                EndMileage: this.EndMileage,
                TripStatus: this.TripStatus,
                TrackingMethod: this.TrackingMethod,
                Tag: this.tags,
                Notes: this.notes
            })
            .then((result) => {
                this.loadingSpinner = false;
                getTable.style.opacity = "1";
                this.searchList = result;
                this.template.querySelector('c-data-table-component').getSearchData(this.searchList);

            })
            .catch((error) => {
                console.log(error);
            });

    }

    // Quick Search Button Click Event
    handleQuickSearchEvent() {
        var i;
        var txtValue;
        var tr = this.template.querySelector('c-data-table-component').getElement();
        let input = this.template.querySelector('.quickSearchInput');
        let filter = input.value.toUpperCase();
        for (i = 0; i < tr.length; i++) {
            txtValue = tr[i].textContent;
            if (txtValue.toUpperCase().indexOf(filter) > -1) {
                tr[i].style.display = "";
            } else {
                tr[i].style.display = "none";
            }
        }
    }

    
    handleApproveRejectEvent(event) {
        this.approveRejectData = event.detail;

    }
    handleApproveRejectSearchEvent(event) {
        this.approveRejectData = event.detail;
    }

    // Approve Button Clicked 
    handleApproveClick() {
        var modalShow = this.template.querySelector('c-modal-popup').ModalClassList();
        var modalbackdrop = this.template.querySelector('c-modal-popup').ModalBackdrop();
        modalShow.classList.remove("slds-hide");
        modalbackdrop.classList.remove("slds-hide");
        this.emailaddressvalue = JSON.stringify(this.approveRejectData);
        this.isSelectedChecked = true;

    }
    // Reject Button Clicked 
    handleRejectClick() {
        var modalShow = this.template.querySelector('c-modal-popup').ModalClassList();
        var modalbackdrop = this.template.querySelector('c-modal-popup').ModalBackdrop();
        modalShow.classList.remove("slds-hide");
        modalbackdrop.classList.remove("slds-hide");
        this.emailaddressvalue = JSON.stringify(this.approveRejectData);
        this.isSelectedChecked = false;
    }

    // Get Excel For Selected Trips
    exportSelectedTrips() {
        this.template.querySelector('c-data-table-component').exportSelectedTrip();
    }
    // Get Excel For Trips By Date
    exportTripsByDate() {
        this.template.querySelector('c-data-table-component').showFilterModal();

    }
    connectedCallback() {
            this.ready = true;
            if (this.ProfileId === '00e31000001FRDYAA4') {
                this.drivermanagerLoggedIn = false;
                this.adminLoggedIn = true;
                this.admindriverLoggedIn = false;
                this.dashboardurl = "/app/admindashboard?accid=" + this.accountId + "&id=" + this.Id + "&showteam=" + this.showTeam;
                this.mileageurl = "/app/MileageDashboard?accid=" + this.accountId + "&id=" + this.Id + "&showteam=" + this.showTeam;
                this.driverurl = "/app/roster?accid=" + this.accountId + "&id=" + this.Id + "&showteam=" + this.showTeam;
                this.reporturl = "/app/reportlist?accid=" + this.accountId + "&id=" + this.Id + "&showteam=" + this.showTeam;
            } else if (this.ProfileId === '00e31000001FRDWAA4') {
                this.drivermanagerLoggedIn = false;
                this.admindriverLoggedIn = false;
                this.adminLoggedIn = false;
                this.dashboardurl = "/app/managerdashboard?accid=" + this.accountId + "&id=" + this.Id + "&showteam=" + this.showTeam;
                this.mileageurl = "/app/MileageDashboard?accid=" + this.accountId + "&id=" + this.Id + "&showteam=" + this.showTeam;
                this.driverurl = "/app/roster?accid=" + this.accountId + "&id=" + this.Id + "&showteam=" + this.showTeam;
                this.reporturl = "/app/reportlist?accid=" + this.accountId + "&id=" + this.Id + "&showteam=" + this.showTeam;
            } else if (this.ProfileId === '00e31000001FRDXAA4') {
                this.drivermanagerLoggedIn = true;
                this.admindriverLoggedIn = false;
                this.adminLoggedIn = false;
                this.dashboardurl = "/app/drivermanagerdashboard?accid=" + this.accountId + "&id=" + this.Id + "&showteam=" + this.showTeam;
                this.mileageurl = "/app/MileageDashboard?accid=" + this.accountId + "&id=" + this.Id + "&showteam=" + this.showTeam;
                this.driverurl = "/app/roster?accid=" + this.accountId + "&id=" + this.Id + "&showteam=" + this.showTeam;
                this.reporturl = "/app/reportlist?accid=" + this.accountId + "&id=" + this.Id + "&showteam=" + this.showTeam;
                this.myDetailurl = "/app/driveradminmanagermydetail?accid=" + this.accountId + "&id=" + this.Id + "&showteam=" + this.showTeam;
            } else if (this.ProfileId === '00e31000001FRDZAA4') {
                this.admindriverLoggedIn = true;
                this.drivermanagerLoggedIn = false;
                this.adminLoggedIn = false;
                this.dashboardurl = "/app/admindriverdashboard?accid=" + this.accountId + "&id=" + this.Id + "&showteam=" + this.showTeam + "&admindriver=" + this.admindriver
                this.mileageurl = "/app/MileageDashboard?accid=" + this.accountId + "&id=" + this.Id + "&showteam=" + this.showTeam + "&admindriver=" + this.admindriver;
                this.driverurl = "/app/roster?accid=" + this.accountId + "&id=" + this.Id + "&showteam=" + this.showTeam + "&admindriver=" + this.admindriver;
                this.reporturl = "/app/reportlist?accid=" + this.accountId + "&id=" + this.Id + "&showteam=" + this.showTeam + "&admindriver=" + this.admindriver;
                this.myDetailurl = "/app/driveradminmanagermydetail?accid=" + this.accountId + "&id=" + this.Id + "&showteam=" + this.showTeam + "&admindriver=" + this.admindriver;
            }
    }

    renderedCallback() {
        if (!this.ready) {
            this.ready = true;
        }
        console.log('From homePage->' , this.template.querySelector('.tagList'))
    }
    
}