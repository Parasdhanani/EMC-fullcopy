import {
  LightningElement,
  api,
  track
} from 'lwc';

export default class FilterModalPopup extends LightningElement {
  @track calStartDate;
  @track calEndDate;
  @track filterFromDate;
  @track filterToDate;
  @api modalHeader;
  @api modalContent;
  @api fromDate;
  @api toDate;
  @api csvFiledata = [];
  @api downloadCSVFile() {
     // console.log("csvdownloaded",this.csvFiledata);
      let rowEnd = '\n';
      let csvString = '';
      let regExp = /^[0-9/]*$/gm;
      let regExpForTime = /^[0-9:\sAM|PM]*$/gm
      let decimalExp = /^(\d*\.)?\d+$/gm
      // this set elminates the duplicates if have any duplicate keys
      let rowData = new Set();


      // getting keys from data
      this.csvFiledata.forEach(function(record) {
          Object.keys(record).forEach(function(key) {
              rowData.add(key);
          });
      });

      // Array.from() method returns an Array object from any object with a length property or an iterable object.
      rowData = Array.from(rowData);

      // splitting using ','
      csvString += rowData.join(',');
      csvString += rowEnd;

     // console.log(rowData);
      var i=0;
      this.csvFiledata.forEach((filedata)=>{
             let colVal = 0;
             rowData.forEach((row,ind)=>{
                     // Key value 
                     // Ex: Id, Name
                     let rowKey = row;
                  //  console.log(rowKey)
                     // add , after every value except the first.
                     if (colVal > 0) {
                         csvString += ',';
                     }
                     // If the column is undefined, it as blank in the CSV file.
                   //  console.log(this.csvFiledata[ind],filedata);
                     let value = filedata[rowKey] === undefined ? '' : filedata[rowKey];
                  //   console.log(value)
                     if (value != null) {
                         if (value.match(regExp) || value.match(regExpForTime) || value.match(decimalExp)) {
                             csvString += '="' + value + '"';
                         } else {
                             csvString += '"' + value + '"';
                         }
                     } else {
                         csvString += '"' + value + '"';
                     }
     
                     colVal++;
                 
             })
             csvString += rowEnd;
        })
        // validating keys in data
        // for (let key in rowData) {
        //    // console.log(key);
        //     if (rowData.hasOwnProperty(key)) {
        //         // Key value 
        //         // Ex: Id, Name
        //         let rowKey = rowData[key];
        //         console.log(rowKey);
        //         // add , after every value except the first.
        //         if (colVal > 0) {
        //             csvString += ',';
        //         }
        //         // If the column is undefined, it as blank in the CSV file.
        //       //  console.log(this.csvFiledata[ind],filedata);
        //         let value = this.csvFiledata[ind][rowKey] === undefined ? '' : this.csvFiledata[ind][rowKey];
        //         if (value != null) {
        //             if (value.match(regExp) || value.match(regExpForTime) || value.match(decimalExp)) {
        //                 csvString += '="' + value + '"';
        //             } else {
        //                 csvString += '"' + value + '"';
        //             }
        //         } else {
        //             csvString += '"' + value + '"';
        //         }

        //         colVal++;
        //     }
        // }
        // csvString += rowEnd;
   //   })
    //   for (i = 0; i < this.csvFiledata.length; i++) {
    //       let colVal = 0;

    //       // validating keys in data
    //       for (let key in rowData) {
    //           if (rowData.hasOwnProperty(key)) {
    //               // Key value 
    //               // Ex: Id, Name
    //               let rowKey = rowData[key];
    //               // add , after every value except the first.
    //               if (colVal > 0) {
    //                   csvString += ',';
    //               }
    //               // If the column is undefined, it as blank in the CSV file.

    //               let value = this.csvFiledata[i][rowKey] === undefined ? '' : this.csvFiledata[i][rowKey];
    //               if (value != null) {
    //                   if (value.match(regExp) || value.match(regExpForTime) || value.match(decimalExp)) {
    //                       csvString += '="' + value + '"';
    //                   } else {
    //                       csvString += '"' + value + '"';
    //                   }
    //               } else {
    //                   csvString += '"' + value + '"';
    //               }

    //               colVal++;
    //           }
    //       }
    //       csvString += rowEnd;
    //   }
      //console.log(csvString);
    //  var blobdata = new Blob([csvString],{type : 'text/csv'});
      // Creating anchor element to download
      let downloadElement = document.createElement('a');
    //  downloadElement.setAttribute("href", window.URL.createObjectURL(blobdata));
     // downloadElement.setAttribute("download", 'all_trips_' + this.fromDate + '_to_' + this.toDate + '.csv');
    //  document.body.appendChild(downloadElement);
   //   downloadElement.click();
      // This  encodeURI encodes special characters, except: , / ? : @ & = + $ # (Use encodeURIComponent() to encode these characters).
       downloadElement.href = 'data:text/csv;charset=utf-8,' + encodeURI(csvString);
      downloadElement.target = '_self';
      // CSV File Name
        downloadElement.download = 'all_trips_' + this.fromDate + '_to_' + this.toDate + '.csv';
      // below statement is required if you are using firefox browser
         document.body.appendChild(downloadElement);
         //click() Javascript function to download CSV file
         downloadElement.click();
  }
  // Filter Modal To Pass Data To Parent Component
  @api ModalClassList() {
      let sectionElement = this.template.querySelector("section");
      return sectionElement;
  }
  @api ModalBackdrop() {
      let modalbackdrop = this.template.querySelector("div.modalBackdrops");
      return modalbackdrop;
  }

  // From Date Change Event
  changeFromHandler(event) {
      this.calStartDate = event.target.value;
      const selectedFilterDate = new CustomEvent("handlefilterdateevent", {
          detail: this.calStartDate
      })
      this.dispatchEvent(selectedFilterDate);
  }

 // To Date Change Event
  changeToHandler(event) {
      this.calEndDate = event.target.value;
      const selectedFilterEndDate = new CustomEvent("handlefiltertodateevent", {
          detail: this.calEndDate
      });

      this.dispatchEvent(selectedFilterEndDate);
  }

  //On Cancel Modal
  handleCancel() {
      this.template.querySelector("section").classList.add("slds-hide");
      this.template
          .querySelector("div.modalBackdrops")
          .classList.add("slds-hide");
  }
}