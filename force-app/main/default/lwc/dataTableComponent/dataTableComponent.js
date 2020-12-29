/* eslint-disable no-console */
import {
  LightningElement,
  wire,
  track,
  api
} from "lwc";
import fetchMileages from "@salesforce/apex/GetDriverData.fetchMileages";
import LwcDesignImage from "@salesforce/resourceUrl/LwcDesignImage";
const recordsPerPage = [25, 50, 100, 250, 500];
export default class DataTableComponent extends LightningElement {
  ready = false;
  isRenderCallbackActionExecuted = true;
  isRowSplitterExcecuted = false;
  isPerPageActionExecuted = false;
  selectBool = false;
  @track statusAppImg;
  @track statusRejImg;
  @track columns = [{
      label: "Date & Time",
      fieldName: "Date",
      type: "datetime",
    },
    {
      label: "Driver",
      fieldName: "Name",
    },
    {
      label: "Vehicle",
      fieldName: "VehicleType",
    },
    {
      label: "Mileage",
      fieldName: "Mileage",
    },
    {
      label: "From",
      fieldName: "TripOrigin",
    },
    {
      label: "To",
      fieldName: "TripDestination",
    },
    {
      label: "Notes",
      fieldName: "notes",
    },
  ];
  @api accountID;
  @api contactID;
  @track iconProp = true;
  @track record = {};
  @track wiredData = [];
  @track currentPage = 1;
  @track loadingSpinner = true;
  @track pageClick = false;
  @track searchallList = [];
  @track allowSorting = false;
  @track recordpepagecheck = false;
  @track reverse = false;
  @track totalrows;
  @track currentData = [];
  @track csvExportData = [];
  @track exportData = [];
  @track searchData = [];
  @track option;
  @track mileagevalue;
  @track totalmileage;
  @track driverId;
  @track field;
  @track object;
  @track key;
  @track searchkeyvalue;
  @track wherefieldvalue;
  @track pageSize;
  @track xlsHeader = [];
  @track xlsData = [];
  @track csvData = [];
  @track filename;
  @track xlsSheetContent = [];
  @track workSheetNameList = [];
  @track filterStartDate;
  @track filterEndDate;
  @api approveRejectCheck = [];
  @api approveRejectCheckSearch = [];
  @api pageSizeOptions = recordsPerPage;

  searchFlag = false;
  searchDataLength = false;
  currentDataLength = false;
  // Advance Search Based on lookups such as Date,Driver,Mileage etc
  @api getSearchData(value) {
    if (!this.loadingSpinner) {
      this.loadingSpinner = true;
    }
    this.isRowSplitterExcecuted = false;
    this.searchallList = [];
    this.searchFlag = true;
    this.searchallList = value;
    if (this.searchallList.length < 25) {
      this.template.querySelector("c-paginator").classList.add("slds-hide");
    } else {
      this.template.querySelector("c-paginator").classList.remove("slds-hide");
      this.template.querySelector("c-paginator").pageData(value, this.pageSize);
    }

    this.searchallList = this.defaultSortingByDate(
      this.searchallList,
      "ConvertedStartTime__c"
    );


    if (this.searchallList.length != 0) {
      this.searchDataLength = true;
      this.loadingSpinner = false;
    } else {
      this.searchDataLength = false;
    }

    this.setSearchRecordsToDisplay();
  }

  // Get all <tr> of accordion(table)
  @api
  getElement() {
    const table_tr = this.template.querySelectorAll(".collapsible");
    if (table_tr) {
      return table_tr;
    }
  }

  //Get tripRoute Icon
  @api
  getIcon;

  //Get <table> element
  @api
  getTableElement() {
    const table = this.template.querySelector(".accordion_table");
    if (table) {
      return table;
    }
  }

  //Download Excel based selected trips
  @api exportSelectedTrip() {
    this.exportSelectedData = [];
    var checkbox = this.template.querySelectorAll(
      ".checkboxCheckUncheckSearch"
    );

    var checkbox2 = this.template.querySelectorAll(
      ".checkboxCheckUncheck"
    );
    if (this.searchData.length != 0) {
      var i,
        exportTripData = [],
        j = checkbox.length;
      for (i = 0; i < j; i++) {
        if (checkbox[i].checked === true) {
          if (this.searchData[i].id === checkbox[i].dataset.id) {
            exportTripData.push({
              Driver: this.searchData[i].Name,
              Email: this.searchData[i].emailID,
              Status: this.searchData[i].TripStatus,
              Date: this.searchData[i].userdate,
              Day: this.searchData[i].Day,
              StartTime: this.searchData[i].StartTime,
              EndTime: this.searchData[i].EndTime,
              StayTime: this.searchData[i].StayTime,
              DriveTime: this.searchData[i].DriveTime,
              TotalTime: this.searchData[i].TotalTime,
              Activity: "Business",
              Mileage: this.searchData[i].Mileage,
              FromLocationName: this.searchData[i].FromLocation,
              FromLocationAddress: this.searchData[i].TripOrigin,
              ToLocationName: this.searchData[i].ToLocation,
              ToLocationAddress: this.searchData[i].TripDestination,
              State: this.searchData[i].State,
              Tags: this.searchData[i].Tags,
              Notes: this.searchData[i].notes,
              TrackingMethod: this.searchData[i].TrackingMethod,
            });
          }
        }

        //formatted data for excel download
        this.exportSelectedData = exportTripData;
      }
    } else {
      var i,
        exportTripData = [],


        j = checkbox2.length;

      for (i = 0; i < j; i++) {
        if (checkbox2[i].checked === true) {
          if (this.currentData[i].id === checkbox2[i].dataset.id) {
            exportTripData.push({
              Driver: this.currentData[i].Name,
              Email: this.currentData[i].emailID,
              Status: this.currentData[i].TripStatus,
              Date: this.currentData[i].userdate,
              Day: this.currentData[i].Day,
              StartTime: this.currentData[i].StartTime,
              EndTime: this.currentData[i].EndTime,
              StayTime: this.currentData[i].StayTime,
              DriveTime: this.currentData[i].DriveTime,
              TotalTime: this.currentData[i].TotalTime,
              Activity: "Business",
              Mileage: this.currentData[i].Mileage,
              FromLocationName: this.currentData[i].FromLocation,
              FromLocationAddress: this.currentData[i].TripOrigin,
              ToLocationName: this.currentData[i].ToLocation,
              ToLocationAddress: this.currentData[i].TripDestination,
              State: this.currentData[i].State,
              Tags: this.currentData[i].Tags,
              Notes: this.currentData[i].notes,
              TrackingMethod: this.currentData[i].TrackingMethod,
            });
          }
        }

        //formatted data for excel download
        this.exportSelectedData = exportTripData;
      }
    }

    this.xlsFormatter(this.exportSelectedData);
  }

  // Filter Modal For CSV Download
  @api showFilterModal() {
    // Calls function from child component (c-filter-modal-popup)
    let filtermodalShow = this.template
      .querySelector("c-filter-modal-popup")
      .ModalClassList();
    var filtermodalbackdrop = this.template
      .querySelector("c-filter-modal-popup")
      .ModalBackdrop();
    filtermodalShow.classList.remove("slds-hide");
    filtermodalbackdrop.classList.remove("slds-hide");
  }

  // Apex Method Call For Default Data To Display in table
  apexMethodCall() {
    //  setTimeout(() => {
    fetchMileages({
        accID: this.accountID,
        AdminId: this.contactID
      })
      .then((data) => {
        console.log('From fetch mileage', data);
        this.wiredData = data;
        this.template.querySelector("c-paginator").pageData(data, this.pageSize);
        this.setRecordsToDisplay();
      })
      .catch((error) => {
        console.log(error);
      });
    // }, 10);
  }
  //Date format for csv content Starts --->
  handleFilterDateEvent(event) {
    this.filterStartDate = event.detail;
    let newdate = new Date(this.filterStartDate);
    let dd = newdate.getDate();
    let mm = newdate.getMonth() + 1;
    let yy = newdate.getFullYear();
    let filter_Startdate = mm + "/" + dd + "/" + yy;
    this.filterStartDate = filter_Startdate;
  }
  handleFilterToDateEvent(event) {
    this.filterEndDate = event.detail;
    let newdate = new Date(this.filterEndDate);
    let dd = newdate.getDate();
    let mm = newdate.getMonth() + 1;
    let yy = newdate.getFullYear();
    let filter_Enddate = mm + "/" + dd + "/" + yy;
    this.filterEndDate = filter_Enddate;
    this.formatToCSV();
  }

  //Date format for csv content Ends --->

  //CSV Download Based On Filter By Date
  formatToCSV() {
    var i,
      filterCSVData = [],
      formatCSVData = [],
      mappedCSVData = [];
    this.csvData = [];
    if (this.csvExportData.length != 0) {
      var j = this.csvExportData.length;
      for (i = 0; i < j; i++) {
        filterCSVData.push({
          Driver: this.csvExportData[i].Name,
          Email: this.csvExportData[i].emailID,
          Status: this.csvExportData[i].TripStatus,
          Date: this.csvExportData[i].userdate,
          Day: this.csvExportData[i].Day,
          StartTime: this.csvExportData[i].StartTime,
          EndTime: this.csvExportData[i].EndTime,
          StayTime: this.csvExportData[i].StayTime,
          DriveTime: this.csvExportData[i].DriveTime,
          TotalTime: this.csvExportData[i].TotalTime,
          Activity: "Business",
          Mileage: this.csvExportData[i].Mileage,
          FromLocationName: this.csvExportData[i].FromLocation,
          FromLocationAddress: this.csvExportData[i].TripOrigin,
          ToLocationName: this.csvExportData[i].ToLocation,
          ToLocationAddress: this.csvExportData[i].TripDestination,
          State: this.csvExportData[i].State,
          Tags: this.csvExportData[i].Tags,
          Notes: this.csvExportData[i].notes,
          TrackingMethod: this.csvExportData[i].TrackingMethod,
        });
      }

      //  console.log("filterCSV",filterCSVData);
      // mapping of excel headers based on content for csv
      mappedCSVData = filterCSVData.map(function (obj) {
        obj["Start Time"] = obj["StartTime"];
        delete obj["StartTime"];
        obj["End Time"] = obj["EndTime"];
        delete obj["EndTime"];
        obj["Mileage (mi)"] = obj["Mileage"];
        delete obj["Mileage"];
        obj["From Location Name"] = obj["FromLocationName"];
        delete obj["FromLocationName"];
        obj["From Location Address"] = obj["FromLocationAddress"];
        delete obj["FromLocationAddress"];
        obj["To Location Name"] = obj["ToLocationName"];
        delete obj["ToLocationName"];
        obj["To Location Address"] = obj["ToLocationAddress"];
        delete obj["ToLocationAddress"];
        obj["Tracking Method"] = obj["TrackingMethod"];
        delete obj["TrackingMethod"];
        obj["Stay Time"] = obj["StayTime"];
        delete obj["StayTime"];
        obj["Drive Time"] = obj["DriveTime"];
        delete obj["DriveTime"];
        obj["Total Time"] = obj["TotalTime"];
        delete obj["TotalTime"];
        return obj;
      });

      // filter csvData based on StartDate and EndDate
      formatCSVData = mappedCSVData.filter((item) => {
        return (
          item.Date >= this.filterStartDate && item.Date <= this.filterEndDate
        );
      });

      this.csvData = formatCSVData;
      //  console.log("filterAfterCSV",this.csvData);
    }
  }

  // On click event of child (c-validate-data-list-component) component
  handleDriverSelect(event) {
    // eslint-disable-next-line no-console
    event.preventDefault();

    this.driverId = event.detail; // stores id of driver

    // options to be displayed in dropdown based on field,object,key,wherefieldvalue,searchkeyvalue
    this.field = "Trip_Origin__c";
    this.object = "Employee_Mileage__c";
    this.searchkeyvalue = "Trip_Origin__c";
    this.key = "Destination_Name__c";
    this.wherefieldvalue = "EmployeeReimbursement__r.Contact_Id__c";

    //Call function from child component
    this.template
      .querySelector(".fromdatalistcomponent")
      .deleteSelectedOption();
    this.template.querySelector(".todatalistcomponent").deleteSelectedOption();
  }

  // On click event of each row in table
  clickHandler(event) {
    // console.log('inside click handler',event);
    // process.exit(0);
    var i;
    var checkbox;
    var to = event.target ? event.target : event.toElement;
    if (to.parentElement != null || to.parentElement != undefined) {
      checkbox = to.parentElement.previousElementSibling;
      //To prevent checkbox click starts -->
      if (event.target !== event.currentTarget) {
        if (checkbox.checked) {
          checkbox.checked = false;
          if (to.className === "slds-checkbox_faux") {
            return (
              this.CheckUncheckForApprove(), this.CheckUncheckForSearchApprove()
            );
          }
        } else {
          if (to.className === "slds-checkbox_faux") {
            checkbox.checked = true;
            return (
              this.CheckUncheckForApprove(), this.CheckUncheckForSearchApprove()
            );
          }
        }
      }
    }

    var insideTr = to.localName;

    if (insideTr === "input") {
      return;
    }

    //To prevent checkbox click Ends -->

    // data-id of row <tr> -- >
    let targetId = event.currentTarget.dataset.id;

    // Display list of rows with class name 'content'
    let rowList = this.template.querySelectorAll(
      `[data-id="${targetId}"],.content`
    );

    var j = rowList.length;
    //Hide show accordion on each row click Starts -->
    for (i = 0; i < j; i++) {
      let row = rowList[i];
      if (
        row.className === "collapsible even" ||
        row.className === "collapsible odd"
      ) {
        if (targetId === row.dataset.id) {
          if (row.style.display === "table-row" || row.style.display === "")
            row.style.display = "none";
          else row.style.display = "table-row";
        }
      } else if (row.className === "content") {
        if (targetId === row.dataset.id) {
          if (row.style.display === "table-row") row.style.display = "none";
          else row.style.display = "table-row";
        }
      }
    }
    //Hide show accordion on each row click Ends -->

    // To get data inside each row based on targetRow Starts -->
    let targetRow = event.currentTarget.cells;
    this.datetime = targetRow[3].textContent;
    if (this.datetime != '') {
      this.date = this.datetime.slice(0, 10);

      this.date = new Date(this.date);
      this.date =
        this.date.getFullYear() +
        "-" +
        (this.date.getMonth() + 1) +
        "-" +
        this.date.getDate();
    } else {
      this.date = '';
    }

    //get data for 'From' Dropdown list as selected option
    this.fromlocation = targetRow[6].textContent;

    //get data for 'To' Dropdown list as selected option
    this.tolocation = targetRow[7].textContent;
    // Show map component on click of each row in table

    // Pass 'from' and 'to' location to child component (c-map-creation-component) based on target row
    this.template
      .querySelector(`c-map-creation-component[data-id="${targetId}"]`)
      .mapAccess();

    // Pass Stored Data to child component functions Starts -->

    let datetimeComponent = this.template.querySelectorAll(
      `[data-id="${targetId}"],.datetimecomponent`
    );
    var datetimelen = datetimeComponent.length;
    for (i = 0; i < datetimelen; i++) {
      let datelist = datetimeComponent[i];
      if (datelist.className === "datetimecomponent") {
        if (targetId === datelist.dataset.id) {
          datelist.getTime(this.date);
        }
      }
    }

    // Pass Stored Data to child component functions Ends -->

    // To get data inside each row based on targetRow Ends -->
  }

  // Click event to close opened row
  handlecloselookUp(event) {
    var i, j;
    let targetId = event.currentTarget.dataset.id;
    let closerowList = this.template.querySelectorAll(
      `[data-id="${targetId}"],.content`
    );

    j = closerowList.length;
    //Hide show accordion on each row click
    for (i = 0; i < j; i++) {
      let closerow = closerowList[i];
      if (
        closerow.className === "collapsible even" ||
        closerow.className === "collapsible odd"
      ) {
        if (targetId === closerow.dataset.id) {
          if (
            closerow.style.display === "table-row" ||
            closerow.style.display === ""
          )
            closerow.style.display = "none";
          else closerow.style.display = "table-row";
        }
      } else if (closerow.className === "content") {
        if (targetId === closerow.dataset.id) {
          if (closerow.style.display === "table-row")
            closerow.style.display = "none";
          else closerow.style.display = "table-row";
        }
      }
    }
  }

  // Default Sorting By Date
  defaultSortingByDate(sortArr, keyName) {

    if (!this.reverse) {
      this.reverse = true;
    }
    if (keyName === "ConvertedStartTime__c") {
      sortArr.sort(function (a, b) {
        var dateA =
          a[keyName] == null || undefined ?
          "" :
          new Date(a[keyName].toLowerCase()),
          dateB =
          b[keyName] == null || undefined ?
          "" :
          new Date(b[keyName].toLowerCase());
        //sort string ascending
        if (dateA < dateB) {
          return -1;
        } else if (dateA > dateB) {
          return 1;
        } else {
          return 0;
        }
      });

    }

    return sortArr;

  }
  // Sorting based on header click 'chevronup' and 'chevrondown' icons in table
  updateColumnSorting(event) {
    this.deleteRow();
    this.loadingSpinner = true;
    var header, keyName;
    this.allowSorting = true;
    var targetelem = event.currentTarget;
    setTimeout(() => {
      this.loadingSpinner = false;
      if (targetelem) {
        header = targetelem.parentElement.parentNode.textContent;
        if (header === "Driver") {
          keyName = "Name";
        } else if (header === "From") {
          keyName = "TripOrigin";
        } else if (header === "To") {
          keyName = "TripDestination";
        } else if (header === "Mileage") {
          keyName = "Mileage";
        } else if (header === "Date & Time") {
          keyName = "Date";
        }
      }
      if (!this.reverse) {
        this.reverse = true;
        if (
          keyName === "Name" ||
          keyName === "TripOrigin" ||
          keyName === "TripDestination"
        ) {
          if (this.searchData.length != 0) {
            this.searchData.sort(function (a, b) {
              var nameA = a[keyName] == null || undefined ?
                "" : a[keyName].toLowerCase(),
                nameB = b[keyName] == null || undefined ?
                "" : b[keyName].toLowerCase();
              //sort string ascending
              if (nameA < nameB) {
                return -1;
              } else if (nameA > nameB) {
                return 1;
              } else {
                return 0;
              }
            });
          } else {
            this.currentData.sort(function (a, b) {
              var nameA = a[keyName] == null || undefined ?
                "" : a[keyName].toLowerCase(),
                nameB = b[keyName] == null || undefined ?
                "" : b[keyName].toLowerCase();
              //sort string ascending
              if (nameA < nameB) {
                return -1;
              } else if (nameA > nameB) {
                return 1;
              } else {
                return 0;
              }
            });
          }
        } else if (keyName === "Mileage") {
          if (this.searchData.length != 0) {
            this.searchData.sort(function (a, b) {
              var floatA = a[keyName] == null || undefined ?
                "" : parseFloat(a[keyName]),
                floatB = b[keyName] == null || undefined ?
                "" : parseFloat(b[keyName]);

              //sort string ascending
              if (floatA < floatB) {
                return -1;
              } else if (floatA > floatB) {
                return 1;
              } else {
                return 0;
              }
            });
          } else {
            this.currentData.sort(function (a, b) {
              var floatA = a[keyName] == null || undefined ?
                "" : parseFloat(a[keyName]),
                floatB = b[keyName] == null || undefined ?
                "" : parseFloat(b[keyName]);

              //sort string ascending
              if (floatA < floatB) {
                return -1;
              } else if (floatA > floatB) {
                return 1;
              } else {
                return 0;
              }
            });
          }
        } else if (keyName === "Date") {
          if (this.searchData.length != 0) {
            this.searchData.sort(function (a, b) {
              var formatDateA = a[keyName] == null || undefined ?
                "" : a[keyName].slice(0, 9),
                formatDateB = b[keyName] == null || undefined ?
                "" : b[keyName].slice(0, 9);
              var dateA = formatDateA == "" ? "" : new Date(formatDateA.toLowerCase()),
                dateB = formatDateB == "" ? "" : new Date(formatDateB.toLowerCase());
              //sort string ascending
              const searchTime12to24 = (time12h, cdate) => {
                const [time, modifier] = time12h.split(' ');

                let [hours, minutes] = time.split(':');

                if (hours === '12') {
                  hours = '00';
                }

                if (modifier === 'PM') {
                  hours = parseInt(hours, 10) + 12;
                }
                let seconds = '00'
                cdate.setHours(hours, minutes, seconds);
                return cdate
                //return `${hours}:${minutes}`;
              }

              let timeA = searchTime12to24(a.StartTime, dateA),
                time = searchTime12to24(b.StartTime, dateB);
              if (dateA < dateB) {
                return -1;
              } else if (dateA > dateB) {
                return 1;
              } else {
                return 0;
              }
            });
          } else {
            this.currentData.sort(function (a, b) {
              var formatDateA = a[keyName] == null || undefined ?
                "" : a[keyName].slice(0, 9),
                formatDateB = b[keyName] == null || undefined ?
                "" : b[keyName].slice(0, 9);

              var dateA = formatDateA == "" ? "" : new Date(formatDateA.toLowerCase()),
                dateB = formatDateB == "" ? "" : new Date(formatDateB.toLowerCase());

              const Time12to24 = (time12h, cdate) => {
                const [time, modifier] = time12h.split(' ');

                let [hours, minutes] = time.split(':');

                if (hours === '12') {
                  hours = '00';
                }

                if (modifier === 'PM') {
                  hours = parseInt(hours, 10) + 12;
                }
                let seconds = '00'
                cdate.setHours(hours, minutes, seconds);
                return cdate
                //return `${hours}:${minutes}`;
              }

              let timeA = Time12to24(a.StartTime, dateA),
                time = Time12to24(b.StartTime, dateB);
              //sort string ascending
              if (dateA < dateB) {
                return -1;
              } else if (dateA > dateB) {
                return 1;
              } else {
                return 0;
              }
            });
          }
        }
      } else {
        this.reverse = false;
        if (
          keyName === "Name" ||
          keyName === "TripOrigin" ||
          keyName === "TripDestination"
        ) {
          if (this.searchData.length != 0) {
            this.searchData.sort(function (a, b) {
              var nameA = a[keyName] == null || undefined ?
                "" : a[keyName].toLowerCase(),
                nameB = b[keyName] == null || undefined ?
                "" : b[keyName].toLowerCase();
              //sort string descending
              if (nameA < nameB) {
                return 1;
              } else if (nameA > nameB) {
                return -1;
              } else {
                return 0;
              }
            });
          } else {
            this.currentData.sort(function (a, b) {
              var nameA = a[keyName] == null || undefined ?
                "" : a[keyName].toLowerCase(),
                nameB = b[keyName] == null || undefined ?
                "" : b[keyName].toLowerCase();
              //sort string descending
              if (nameA < nameB) {
                return 1;
              } else if (nameA > nameB) {
                return -1;
              } else {
                return 0;
              }
            });
          }
        } else if (keyName === "Mileage") {
          if (this.searchData.length != 0) {
            this.searchData.sort(function (a, b) {
              var floatA = a[keyName] == null || undefined ?
                "" : parseFloat(a[keyName]),
                floatB = b[keyName] == null || undefined ?
                "" : parseFloat(b[keyName]);

              //sort string descending
              if (floatA < floatB) {
                return 1;
              } else if (floatA > floatB) {
                return -1;
              } else {
                return 0;
              }
            });
          } else {
            this.currentData.sort(function (a, b) {
              var floatA = a[keyName] == null || undefined ?
                "" : parseFloat(a[keyName]),
                floatB = b[keyName] == null || undefined ?
                "" : parseFloat(b[keyName]);

              //sort string descending
              if (floatA < floatB) {
                return 1;
              } else if (floatA > floatB) {
                return -1;
              } else {
                return 0;
              }
            });
          }
        } else if (keyName === "Date") {
          if (this.searchData.length != 0) {
            this.searchData.sort(function (a, b) {
              var formatDateA = a[keyName] == null || undefined ?
                "" : a[keyName].slice(0, 9),
                formatDateB = b[keyName] == null || undefined ?
                "" : b[keyName].slice(0, 9);

              var dateA = formatDateA == "" ? "" : new Date(formatDateA.toLowerCase()),
                dateB = formatDateB == "" ? "" : new Date(formatDateB.toLowerCase());

              const searchconvertTime12to24 = (time12h, cdate) => {
                const [time, modifier] = time12h.split(' ');

                let [hours, minutes] = time.split(':');

                if (hours === '12') {
                  hours = '00';
                }

                if (modifier === 'PM') {
                  hours = parseInt(hours, 10) + 12;
                }
                let seconds = '00'
                cdate.setHours(hours, minutes, seconds);
                return cdate
                //return `${hours}:${minutes}`;
              }

              var time12 = searchconvertTime12to24(a.StartTime, dateA),
                timeB12 = searchconvertTime12to24(b.StartTime, dateB);
              //sort string descending
              if (dateA < dateB) {
                return 1;
              } else if (dateA > dateB) {
                return -1;
              } else {
                return 0;
              }
            });
          } else {
            this.currentData.sort(function (a, b) {
              var formatDateA = a[keyName] == null || undefined ?
                "" : a[keyName].slice(0, 9),
                formatDateB = b[keyName] == null || undefined ?
                "" : b[keyName].slice(0, 9);

              var dateA = formatDateA == "" ? "" : new Date(formatDateA.toLowerCase()),
                dateB = formatDateB == "" ? "" : new Date(formatDateB.toLowerCase());

              const convertTime12to24 = (time12h, cdate) => {
                const [time, modifier] = time12h.split(' ');

                let [hours, minutes] = time.split(':');

                if (hours === '12') {
                  hours = '00';
                }

                if (modifier === 'PM') {
                  hours = parseInt(hours, 10) + 12;
                }
                let seconds = '00'
                cdate.setHours(hours, minutes, seconds);
                return cdate
                //return `${hours}:${minutes}`;
              }

              var time12 = convertTime12to24(a.StartTime, dateA),
                timeB12 = convertTime12to24(b.StartTime, dateB);

              //sort string descending
              if (dateA < dateB) {
                return 1;
              } else if (dateA > dateB) {
                return -1;
              } else {
                return 0;
              }
            });
          }
        }
      }
    }, 1000)
  }

  //function to display data based on advance search
  setSearchRecordsToDisplay(startInd, endInd) {
    if (!this.loadingSpinner) {
      this.loadingSpinner = true;
    }
    setTimeout(() => {
     this.loadingSpinner = false;
      if (this.pageClick) {
        this.pageClick = false;
      }
    }, 10);
    this.searchData = [];
    var mileagecount = 0;
    this.totalmileage = 0;

    let recordSearchData = [];

    if (!this.pageClick) {
      recordSearchData = this.searchallList.slice(0, this.pageSize);
    } else {
      recordSearchData = this.searchallList.slice(startInd, endInd);
    }
    this.totalrows = this.searchallList.length;
    recordSearchData.forEach((row) => {
      var dayofweek;
      let rowData = {};
      let formatDate = this.fullDateFormat(row);
      let userDate = this.dateFormat(row);
      if (row.Day_Of_Week__c != undefined) {
        dayofweek = row.Day_Of_Week__c.toString().slice(0, 3);
      } else {
        dayofweek = "";
        dayofweek = dayofweek.toString();
      }

      let strTime = this.TimeFormat(row.ConvertedStartTime__c);
      let enTime = this.TimeFormat(row.ConvertedEndTime__c);
      rowData.id = row.Id;
      rowData.TripId = row.Trip_Id__c;
      rowData.Mileage = row.Mileage__c.toString();
      rowData.TripOrigin = row.Trip_Origin__c;
      rowData.TripDestination = row.Trip_Destination__c;
      if (row.Trip_Destination__c != undefined) {
        let getState = this.validateState(row.Trip_Destination__c);
        rowData.State = getState.slice(0, 2);
      }
      if (row.Way_Points__c != undefined) {
        rowData.waypoint = row.Way_Points__c;
      }
      rowData.TriplogMap = row.Triplog_Map__c;
      rowData.TimeZone = row.TimeZone__c;
      rowData.TripStatus = row.Trip_Status__c;
      rowData.TrackingMethod = row.Tracing_Style__c;
      rowData.FromLocation = row.Origin_Name__c;
      rowData.ToLocation = row.Destination_Name__c;
      rowData.Day = dayofweek;
      rowData.userdate = userDate.toString();
      rowData.StartTime = strTime.toString();
      rowData.EndTime = enTime.toString();
      rowData.Date = formatDate.toString();
      rowData.Time =
        enTime === "" ?
        strTime.toString() :
        strTime === "" ?
        enTime.toString() :
        strTime.toString() + " " + "-" + " " + enTime.toString();
      rowData.Tags = row.Tag__c;
      rowData.notes = row.Notes__c;
      rowData.DriveTime = (row.Driving_Time__c === undefined) ? '' : row.Driving_Time__c;
      rowData.StayTime = (row.Stay_Time__c === undefined) ? '' : row.Stay_Time__c;
      rowData.TotalTime = (row.Drive_Stay_Time__c === undefined) ? '' : row.Drive_Stay_Time__c;
      rowData.FromLatitude = row.From_Location__Latitude__s;
      rowData.FromLongitude = row.From_Location__Longitude__s;
      rowData.ToLatitude = row.To_Location__Latitude__s;
      rowData.ToLongitude = row.To_Location__Longitude__s;
      if (row.EmployeeReimbursement__r) {
        rowData.TripLogApi = row.EmployeeReimbursement__r.Contact_Id__r.Account.Triplog_API__c;
        if (
          row.EmployeeReimbursement__r.Contact_Id__r.External_Email__c === undefined
        ) {
          rowData.emailID = '';
        } else {
          rowData.emailID =
            row.EmployeeReimbursement__r.Contact_Id__r.External_Email__c;
        }
        rowData.Name = row.EmployeeReimbursement__r.Contact_Id__r.Name;
        rowData.VehicleType =
          row.EmployeeReimbursement__r.Contact_Id__r.Vehicle_Type__c;
      }

      this.searchData.push(rowData);
    });
    if (this.searchData.length != 0) {
      this.searchData.forEach((value) => {
        mileagecount = mileagecount + parseFloat(value.Mileage);
        mileagecount =
          Math.round(
            parseFloat((mileagecount * Math.pow(10, 2)).toFixed(2))
          ) / Math.pow(10, 2);
      });

      this.totalmileage = mileagecount;
    }



  }

  validateState(stateVal) {
    var regDigit = /\b\d{5}\b/g,
      tripSate, bool;
    bool = /^[0-9,-.]*$/.test(stateVal);
    if (!bool) {
      let state = stateVal;
      let digit = state.slice(-5);
      if (digit.match(regDigit)) {
        tripSate = stateVal.slice(-9);
      } else {
        tripSate = '';
      }
    } else {
      tripSate = '';
    }

    return tripSate;
  }
  // Pagination event
  pageEventClick(event) {
    this.pageClick = true;
    this.isRowSplitterExcecuted = false;
    let page = event.detail;
    let perpage = this.pageSize;
    let startIndex = page * perpage - perpage;
    let endIndex = page * perpage;
    if (this.searchData.length != 0) {
      this.setSearchRecordsToDisplay(startIndex, endIndex);
    } else {
      this.setRecordsToDisplay(startIndex, endIndex);
    }
  }
  //function to display default data
  setRecordsToDisplay(startInd, endInd) {
    if (!this.loadingSpinner) {
      this.loadingSpinner = true;
    }
    setTimeout(() => {
    this.loadingSpinner = false;
      if (this.pageClick) {
        this.pageClick = false;
      }
    }, 10);
    this.isRenderCallbackActionExecuted = true;
    var mileagecount = 0;
    this.currentData = [];
    this.totalmileage = 0;

    let apexData = [];
    let recordData = [];
    let exportCSV = [];
    apexData = JSON.parse(JSON.stringify(this.wiredData));
    exportCSV = apexData;

    // for csv data export to excel Starts -->
    exportCSV.forEach((rowCsv) => {
      var dayofweek;
      let exportcsvData = {};
      let formatDate = this.fullDateFormat(rowCsv);
      let userDate = this.dateFormat(rowCsv);
      if (rowCsv.Day_Of_Week__c != undefined) {
        dayofweek = rowCsv.Day_Of_Week__c.toString().slice(0, 3);
      } else {
        dayofweek = "";
        dayofweek = dayofweek.toString();
      }
      let strTime = this.TimeFormat(rowCsv.ConvertedStartTime__c);
      let enTime = this.TimeFormat(rowCsv.ConvertedEndTime__c);
      exportcsvData.id = rowCsv.Id;
      exportcsvData.Mileage = (rowCsv.Mileage__c === undefined) ? '' : rowCsv.Mileage__c.toString();
      exportcsvData.TripOrigin = rowCsv.Trip_Origin__c;
      exportcsvData.TripDestination = rowCsv.Trip_Destination__c;
      if (rowCsv.Trip_Destination__c != undefined) {
        let getState = this.validateState(rowCsv.Trip_Destination__c);
        exportcsvData.State = getState.slice(0, 2);
      }
      exportcsvData.TriplogMap = rowCsv.Triplog_Map__c;
      exportcsvData.TripStatus = rowCsv.Trip_Status__c;
      exportcsvData.TrackingMethod = rowCsv.Tracing_Style__c;
      exportcsvData.FromLocation = rowCsv.Origin_Name__c;
      exportcsvData.ToLocation = rowCsv.Destination_Name__c;
      exportcsvData.Day = dayofweek;
      exportcsvData.userdate = userDate.toString();
      exportcsvData.StartTime = strTime.toString();
      exportcsvData.EndTime = enTime.toString();
      exportcsvData.Date = formatDate.toString();
      exportcsvData.Time =
        enTime === "" ?
        strTime.toString() :
        strTime === "" ?
        enTime.toString() :
        strTime.toString() + " " + "-" + " " + enTime.toString();
      exportcsvData.Tags = rowCsv.Tag__c;
      exportcsvData.notes = rowCsv.Notes__c;
      exportcsvData.DriveTime = (rowCsv.Driving_Time__c === undefined) ? '' : rowCsv.Driving_Time__c;
      exportcsvData.StayTime = (rowCsv.Stay_Time__c === undefined) ? '' : rowCsv.Stay_Time__c;
      exportcsvData.TotalTime = (rowCsv.Drive_Stay_Time__c === undefined) ? '' : rowCsv.Drive_Stay_Time__c;
      if (rowCsv.EmployeeReimbursement__r) {
        if (
          rowCsv.EmployeeReimbursement__r.Contact_Id__r.External_Email__c === undefined
        ) {
          exportcsvData.emailID = '';
        } else {
          exportcsvData.emailID =
            rowCsv.EmployeeReimbursement__r.Contact_Id__r.External_Email__c;
        }
      }
      if (rowCsv.EmployeeReimbursement__c) {
        exportcsvData.Name =
          rowCsv.EmployeeReimbursement__r.Contact_Id_Name__c;
        exportcsvData.VehicleType =
          rowCsv.EmployeeReimbursement__r.Contact_Id__r.Vehicle_Type__c;
      }

      this.csvExportData.push(exportcsvData);
    });
    // console.log(this.csvExportData);
    // for csv data export to excel Ends -->
    if (!this.pageClick) {
      recordData = apexData.slice(0, this.pageSize);
    } else {
      recordData = apexData.slice(startInd, endInd);
    }
    recordData = this.defaultSortingByDate(recordData, "ConvertedStartTime__c");
    this.totalrows = apexData.length;
    recordData.forEach((row) => {
      var dayofweek;
      let rowData = {};
      let formatDate = this.fullDateFormat(row);
      let userDate = this.dateFormat(row);
      if (row.Day_Of_Week__c != undefined) {
        dayofweek = row.Day_Of_Week__c.toString().slice(0, 3);
      } else {
        dayofweek = "";
        dayofweek = dayofweek.toString();
      }
      let strTime = this.TimeFormat(row.ConvertedStartTime__c);
      let enTime = this.TimeFormat(row.ConvertedEndTime__c);
      rowData.id = row.Id;
      rowData.TripId = row.Trip_Id__c;
      rowData.Mileage = (row.Mileage__c === undefined) ? '' : row.Mileage__c.toString();
      rowData.TripOrigin = row.Trip_Origin__c;
      rowData.TripDestination = row.Trip_Destination__c;
      if (row.Trip_Destination__c != undefined) {
        let getState = this.validateState(row.Trip_Destination__c);
        rowData.State = getState.slice(0, 2);
      }
      rowData.TriplogMap = row.Triplog_Map__c;
      rowData.TimeZone = row.TimeZone__c;
      rowData.TripStatus = row.Trip_Status__c;
      if (row.Way_Points__c != undefined) {
        rowData.waypoint = row.Way_Points__c;
      }

      rowData.TrackingMethod = row.Tracing_Style__c;
      rowData.FromLocation = row.Origin_Name__c;
      rowData.ToLocation = row.Destination_Name__c;
      rowData.Day = dayofweek;
      rowData.userdate = userDate.toString();
      rowData.StartTime = strTime.toString();
      rowData.EndTime = enTime.toString();
      rowData.Date = formatDate.toString();
      rowData.Time =
        enTime === "" ?
        strTime.toString() :
        strTime === "" ?
        enTime.toString() :
        strTime.toString() + " " + "-" + " " + enTime.toString();
      rowData.Tags = row.Tag__c;
      rowData.notes = row.Notes__c;
      rowData.DriveTime = (row.Driving_Time__c === undefined) ? '' : row.Driving_Time__c;
      rowData.StayTime = (row.Stay_Time__c === undefined) ? '' : row.Stay_Time__c;
      rowData.TotalTime = (row.Drive_Stay_Time__c === undefined) ? '' : row.Drive_Stay_Time__c;
      rowData.FromLatitude = row.From_Location__Latitude__s;
      rowData.FromLongitude = row.From_Location__Longitude__s;
      rowData.ToLatitude = row.To_Location__Latitude__s;
      rowData.ToLongitude = row.To_Location__Longitude__s;

      if (row.EmployeeReimbursement__r) {
        rowData.TripLogApi = row.EmployeeReimbursement__r.Contact_Id__r.Account.Triplog_API__c;
        if (
          row.EmployeeReimbursement__r.Contact_Id__r.External_Email__c === undefined
        ) {
          rowData.emailID = '';
        } else {
          rowData.emailID =
            row.EmployeeReimbursement__r.Contact_Id__r.External_Email__c;
        }
      }
      if (row.EmployeeReimbursement__c) {
        rowData.Name = row.EmployeeReimbursement__r.Contact_Id_Name__c;
        rowData.VehicleType =
          row.EmployeeReimbursement__r.Contact_Id__r.Vehicle_Type__c;
      }

      this.currentData.push(rowData);
    });
    //  console.log('Modified',this.currentData);
    if (this.currentData.length != 0) {
      this.currentDataLength = true;
      this.currentData.forEach((value) => {
        mileagecount = mileagecount + parseFloat(value.Mileage);
        mileagecount =
          Math.round(
            parseFloat((mileagecount * Math.pow(10, 2)).toFixed(2))
          ) / Math.pow(10, 2);
      });

      this.totalmileage = mileagecount;
    } else {
      this.currentDataLength = false;
    }



  }

  actionForPerPage = (pageEntry) => {
    this.isPerPageActionExecuted = true;
    this.isRowSplitterExcecuted = false;
    var pageRecord = [],
      searchPageRecord = [];
    pageRecord = JSON.parse(JSON.stringify(this.wiredData));
    searchPageRecord = JSON.parse(JSON.stringify(this.searchallList));
    this.pageSize = pageEntry;
    if (this.searchData.length != 0) {
      // this.getSearchData(this.searchallList);
      this.template.querySelector("c-paginator").pageData(searchPageRecord, this.pageSize);
      this.setSearchRecordsToDisplay();
    } else {
      this.template.querySelector("c-paginator").pageData(pageRecord, this.pageSize);
      this.setRecordsToDisplay();
    }

  }
  // Change event of display number of records in table based on dropdown values
  handleRecordsPerPage(event) {
    var $pageNo;
    $pageNo = parseInt(event.target.value);
    setTimeout(() => {
      this.actionForPerPage($pageNo);
    }, 2)
  }

  // Click event to check all checkbox checked in table
  IsAllCheckForApprove(event) {
    //console.log('checkbox checked for All', event);
    // process.exit(0);
    var checkbox = this.template.querySelectorAll(".checkboxCheckUncheck");
    var checkbox2 = this.template.querySelectorAll(
      ".checkboxCheckUncheckSearch"
    );
    if (this.searchData.length != 0) {
      if (event.target.checked === true) {
        checkbox2.forEach(value => {
          value.checked = true;
        });
        this.CheckUncheckForSearchApprove();
      } else {
        checkbox2.forEach(value => {
          value.checked = false;
        });
      }
    } else {
      if (event.target.checked === true) {
        //  console.time("foreach")
        checkbox.forEach(value => {
          value.checked = true;
        });
        // console.timeEnd("foreach");
        this.CheckUncheckForApprove();
      } else {
        checkbox.forEach(value => {
          value.checked = false;
        });
      }
    }
  }

  //Click event to check single checkbox checked for advance search data
  CheckUncheckForSearchApprove() {
    var checkboxlist = this.template.querySelectorAll(
      ".checkboxCheckUncheckSearch"
    );
    var approveCheckForSearch = [];

    checkboxlist.forEach((list, index) => {
      if (list.checked === true) {
        if (this.searchData[index].id === list.dataset.id) {
          approveCheckForSearch.push({
            Id: list.dataset.id,
            employeeEmailId: this.searchData[index].emailID,
          });
        }
      }
    });
    this.approveRejectCheckSearch = approveCheckForSearch;
    if (this.approveRejectCheckSearch != 0) {
      const approveRejectSearch = new CustomEvent(
        "handleapproverejectsearchevent", {
          detail: this.approveRejectCheckSearch,
        }
      );

      this.dispatchEvent(approveRejectSearch);
    }
  }

  //Click event to check single checkbox checked for default data
  CheckUncheckForApprove() {
    var checkboxlist = this.template.querySelectorAll(".checkboxCheckUncheck");
    var approveCheck = [];
    //  chkblistlen = checkboxlist.length;

    checkboxlist.forEach((list, index) => {
      if (list.checked === true) {
        if (this.currentData[index].id === list.dataset.id) {
          approveCheck.push({
            Id: list.dataset.id,
            employeeEmailId: this.currentData[index].emailID,
          });
        }
      }
    });
    this.approveRejectCheck = approveCheck;
    if (this.approveRejectCheck.length != 0) {
      const approveReject = new CustomEvent("handleapproverejectevent", {
        detail: this.approveRejectCheck,
      });
      this.dispatchEvent(approveReject);
    }
  }

  // Style row based on approve and reject trips
  RowStatusStyle() {
    var row = this.template.querySelectorAll(".collapsible");
    if (this.searchData.length != 0) {
      // var j = this.searchData.length;
      this.searchData.forEach((rowItem, index) => {
        var routeicon = this.template.querySelectorAll('.ms-help-icon');
        if (rowItem.FromLatitude === undefined && rowItem.FromLongitude === undefined &&
          rowItem.ToLatitude === undefined && rowItem.ToLongitude === undefined) {
          if (row[index].dataset.id === routeicon[index].dataset.id) {
            routeicon[index].classList.add('slds-hide');
          }
        } else {
          routeicon[index].classList.remove('slds-hide')
        }

        if (rowItem.TripStatus === "Approved") {
          this.statusAppImg = LwcDesignImage + "/LwcImages/status_Approve.png";
          let imgAppClass = this.template.querySelectorAll(".statusApImage");
          if (rowItem.id === row[index].dataset.id) {
            row[index].style.backgroundColor = "#b3ffe6";
            if (row[index].dataset.id === imgAppClass[index].dataset.id) {
              imgAppClass[index].style.display = "block";
            }
          }
        } else if (rowItem.TripStatus === "Rejected") {
          let imgRejClass = this.template.querySelectorAll(".statusRejImage");
          this.statusRejImg = LwcDesignImage + "/LwcImages/status_Reject.png";
          if (rowItem.id === row[index].dataset.id) {
            row[index].style.backgroundColor = "#f4a4a4";
            if (row[index].dataset.id === imgRejClass[index].dataset.id) {
              imgRejClass[index].style.display = "block";
            }
          }
        }
      })
    } else {
      this.currentData.forEach((rowElem, ind) => {
        var routeicon = this.template.querySelectorAll('.ms-help-icon');
        if (rowElem.FromLatitude === undefined && rowElem.FromLongitude === undefined &&
          rowElem.ToLatitude === undefined && rowElem.ToLongitude === undefined) {
          if (row[ind].dataset.id === routeicon[ind].dataset.id) {
            routeicon[ind].classList.add('slds-hide');
          }
        } else {
          routeicon[ind].classList.remove('slds-hide')
        }
        if (rowElem.TripStatus === "Approved") {
          this.statusAppImg = LwcDesignImage + "/LwcImages/status_Approve.png";
          let imgAppClass = this.template.querySelectorAll(".statusApImage");
          if (rowElem.id === row[ind].dataset.id) {
            row[ind].style.backgroundColor = "#b3ffe6";
            if (row[ind].dataset.id === imgAppClass[ind].dataset.id) {
              imgAppClass[ind].style.display = "block";
            }
          }
        } else if (rowElem.TripStatus === "Rejected") {
          let imgRejClass = this.template.querySelectorAll(".statusRejImage");
          this.statusRejImg = LwcDesignImage + "/LwcImages/status_Reject.png";
          if (rowElem.id === row[ind].dataset.id) {
            row[ind].style.backgroundColor = "#f4a4a4";
            if (row[ind].dataset.id === imgRejClass[ind].dataset.id) {
              imgRejClass[ind].style.display = "block";
            }
          }
        }
      });
    }
  }

  // Send formatted excel data to child component 'c-excel-sheet'
  xlsFormatter(data) {
    let Header = Object.keys(data[0]);
    Header[5] = "Start Time";
    Header[6] = "End Time";
    Header[7] = "Stay Time";
    Header[8] = "Drive Time";
    Header[9] = "Total Time";
    Header[11] = "Mileage (mi)";
    Header[12] = "From Location Name";
    Header[13] = "From Location Address";
    Header[14] = "To Location Name";
    Header[15] = "To Location Address";
    Header[19] = "Tracking Method";
    this.xlsHeader.push(Header);
    this.filename = "Taylor Bailey's Mileage Details";
    this.workSheetNameList.push(this.filename);
    this.xlsData.push(data);
    this.template.querySelector("c-excel-sheet").download();
  }

  // function to format date with week day
  fullDateFormat(rowObj) {
    if (rowObj.ConvertedStartTime__c != undefined) {
      let newdate = new Date(rowObj.ConvertedStartTime__c);
      let dayofweek;
      let dd = newdate.getDate();
      let mm = newdate.getMonth() + 1;
      let yy = newdate.getFullYear();
      if (rowObj.Day_Of_Week__c != undefined) {
        dayofweek = rowObj.Day_Of_Week__c.toString().slice(0, 3);
      } else {
        dayofweek = "";
        dayofweek = dayofweek.toString();
      }
      return mm + "/" + ("0" + dd).slice(-2) + "/" + yy + " " + dayofweek;
    } else {
      return "";
    }
  }
  // function to format date
  dateFormat(rowObj) {
    if (rowObj.ConvertedStartTime__c != undefined) {
      let newdate = new Date(rowObj.ConvertedStartTime__c);
      let dd = newdate.getDate();
      let mm = newdate.getMonth() + 1;
      let yy = newdate.getFullYear();

      return mm + "/" + dd + "/" + yy;
    } else {
      return "";
    }
  }

  // Trip Status Tooltip Starts
  handleMouseEnter(event) {
    let targetId = event.target.dataset.id;
    this.template
      .querySelector(`c-tooltip-component[data-id="${targetId}"]`)
      .classList.remove("slds-hide");
  }
  handleMouseLeave(event) {
    let targetId = event.target.dataset.id;
    this.template
      .querySelector(`c-tooltip-component[data-id="${targetId}"]`)
      .classList.add("slds-hide");
  }
  // Trip Status Tooltip Ends

  // function to format time
  TimeFormat(timeObj) {
    if (timeObj != undefined) {
      let startendTime = new Date(timeObj);
      let convertedTime = startendTime.toLocaleTimeString("en-US", {
        timeZone: "America/Panama",
        hour: "2-digit",
        minute: "2-digit",
      });
      return convertedTime;
    } else {
      return "";
    }
  }

  // Dynamic row creation
  createRow(rowElem) {
    rowElem.classList.add("list-split-top");
    var table = this.template.querySelector(".accordion_table");
    var extraRow = table.insertRow(rowElem.rowIndex);
    extraRow.className = "extra_row";
    var cell = extraRow.insertCell(0);
    cell.setAttribute("colspan", "10");
    cell.style["padding"] = "0px";
    cell.style["line-height"] = "0px";
    cell.innerHTML =
      "<div class='row_splitter' style='height: 8px;background-color: #ffffff;border-right: 1px solid #dfdfdf;border-top: #dfdfdf 1px solid'></div>";
  }

  // Delete Unused rows from table
  deleteRow() {
    var i, tblRowLen;
    var table = this.template.querySelector(".accordion_table");
    var tableRow = table.rows;

    tblRowLen = tableRow.length;
    for (i = tblRowLen; i > 0; i--) {
      if (tableRow[i] != undefined) {
        if (tableRow[i].className === "extra_row") {
          table.deleteRow(i);
        }
      }
    }
    this.isPerPageActionExecuted = false;
  }

  // Row Splitter after every new date
  rowSplitter() {
    this.isRowSplitterExcecuted = true;
    var i,
      extraRow,
      rowslen,
      regExp = /(\d{1,4}([.\-/])\d{1,2}([.\-/])\d{1,4})/g;
    extraRow = this.template.querySelectorAll(".collapsible");
    rowslen = extraRow.length;
    if (!this.allowSorting) {
      if (rowslen > 0) {
        for (i = 0; i < rowslen; i++) {
          let beforeRow = extraRow[i];
          let afterRow = extraRow[i + 1];
          if (beforeRow != undefined && afterRow != undefined) {
            let beforeRowDate = new Date(
              beforeRow.cells[3].textContent.match(regExp)
            );
            let afterRowDate = new Date(
              afterRow.cells[3].textContent.match(regExp)
            );
            if (beforeRowDate < afterRowDate) {
              this.createRow(afterRow);
            }
          }
        }
      }
    }
    if (this.searchFlag || this.isPerPageActionExecuted) {
      this.isRowSplitterExcecuted = false;
    }
  }


  // fires when a component is inserted into the DOM.
  connectedCallback() {
    if (this.pageSizeOptions && this.pageSizeOptions.length > 0) {
      this.selectBool = true;
      this.pageSize = this.pageSizeOptions[2];
    }
    this.apexMethodCall();
  }

  // fires after every render of the component.
  renderedCallback() {
    if (this.selectBool) {
      let selected = this.template.querySelector('.recordperpageSelect');
      selected.value = this.pageSizeOptions[2];
      this.selectBool = false;
    }
    var i, rowslen;
    if (this.isPerPageActionExecuted || this.searchFlag || this.pageClick) {
      this.deleteRow();
    }
    if (!this.isRenderCallbackActionExecuted && !this.isRowSplitterExcecuted) {
      this.rowSplitter();
    }

    let rows = [];
    rows = this.template.querySelectorAll(".collapsible");
    rowslen = rows.length;
    // avoid change in row style while sorting
    if (!this.allowSorting) {
      if (rowslen > 0) {
        for (i = 0; i < rowslen; i++) {
          let even_row = rows[i * 2];
          let odd_row = rows[i * 2 + 1];
          if (even_row != undefined) {
            even_row.classList.add("even");
          }
          if (odd_row != undefined) {
            odd_row.classList.add("odd");
          }
        }

        this.RowStatusStyle();
      }
    }
    this.isRenderCallbackActionExecuted = false;
  }
}