import { LightningElement } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { loadScript, loadStyle } from 'lightning/platformResourceLoader';
import DotIn_resource from '@salesforce/resourceUrl/DotIn_resource';
export default class KendoUI extends LightningElement {
    sourceInitialized = false;
    renderedCallback() {
        if (this.sourceInitialized) {
            return;
        }
        this.sourceInitialized = true;

        Promise.all([
            loadStyle(this, DotIn_resource + '/DotIn_resource/kendo.common.min.css'),
            loadStyle(this, DotIn_resource + '/DotIn_resource/kendo.default.min.css'),
            loadScript(this, DotIn_resource + '/DotIn_resource/jquery-1.12.3.min.js'),
            loadScript(this, DotIn_resource + '/DotIn_resource/kendo.all.min.js'),
        ])
            .then(() => {
                this.InitializeCmp();
            })
            .catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error loading Scripts',
                        message: 'error',
                        variant: 'error'
                    })
                );
            });
    }
    InitializeCmp(){
        $(this.template.querySelector('.dropdowntree')).kendoDropDownTree({
            placeholder: "Select ...",
            checkboxes: true,
            checkAll: true,
            autoClose: false,
            dataSource: [
                {
                    text: "Furniture", expanded: true, items: [
                        { text: "Tables & Chairs" },
                        { text: "Sofas" },
                        { text: "Occasional Furniture" }
                    ]
                },
                {
                    text: "Decor", items: [
                        { text: "Bed Linen" },
                        { text: "Curtains & Blinds" },
                        { text: "Carpets" }
                    ]
                }
            ]
        });
    }

}