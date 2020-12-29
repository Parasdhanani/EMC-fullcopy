import {
    LightningElement,
    api,
    track
} from 'lwc';
// import {
//     ShowToastEvent
// } from 'lightning/platformShowToastEvent';
import approveMileages from '@salesforce/apex/GetDriverData.approveMileages';

export default class ModalPopup extends LightningElement {
    @api modalHeader;
    @api modalContent;
    @api approvedTripList;
    @api isChecked = false;
    @api ModalClassList() {
        let sectionElement = this.template.querySelector("section");
        return sectionElement;
    }
    @api ModalBackdrop() {
        let modalbackdrop = this.template.querySelector("div.modalBackdrops");
        return modalbackdrop;
    }
    @track sendEmailValue = false;

    // Yes Button Click Event
    handleEmailSend() {
        this.sendEmailValue = true;
        this.SendEmailCheck();
        this.template.querySelector("section").classList.add("slds-hide");
        this.template
            .querySelector("div.modalBackdrops")
            .classList.add("slds-hide");
        window.location.reload();
    }

    // No Button Click Event
    handleNoEmailSend() {
        this.sendEmailValue = false;
        this.SendEmailCheck();
        this.template.querySelector("section").classList.add("slds-hide");
        this.template
            .querySelector("div.modalBackdrops")
            .classList.add("slds-hide");
        window.location.reload();
    }

    // Will Send Email To List Of Users For Approve / Reject
    SendEmailCheck() {
        this.approveTrip = this.approvedTripList;
        this.selectedCheck = this.isChecked;
        approveMileages({
                checked: this.selectedCheck,
                emailaddress: this.approveTrip,
                sendEmail: this.sendEmailValue
            })
            .then((result) => {
                console.log(result);
            })
            .catch((error) => {
                console.log(error)
            })
    }

    // Close 'X' Event
    handleCancel() {
        this.template.querySelector("section").classList.add("slds-hide");
        this.template
            .querySelector("div.modalBackdrops")
            .classList.add("slds-hide");
    }
    //   showSuccessToast() {
    //     const evt = new ShowToastEvent({
    //         title: 'Record Update',
    //         message: 'Application is loaded ',
    //         variant: 'success',
    //         mode: 'dismissable'
    //     });
    //     this.dispatchEvent(evt);
    // }
}