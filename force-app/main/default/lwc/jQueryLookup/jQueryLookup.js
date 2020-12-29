import { LightningElement } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { loadScript, loadStyle } from 'lightning/platformResourceLoader';
import jqueryMinJS from '@salesforce/resourceUrl/jqueryminjsv1';
import selectizeJS from '@salesforce/resourceUrl/selectizejs';
import selectizeminJS from '@salesforce/resourceUrl/selectizeminjs';
import selectizeCss from '@salesforce/resourceUrl/selectizeCss';
import selectizeDefaultcss from '@salesforce/resourceUrl/selectizeDefaultcss';
import selectizeBoots2 from '@salesforce/resourceUrl/selectizeBoots2';
import selectizeBoots3 from '@salesforce/resourceUrl/selectizeBoots3';
export default class JQueryLookup extends LightningElement {
    ready = false;
    renderedCallback() {
        Promise.all([
            loadScript(this, jqueryMinJS),
            loadScript(this, selectizeJS),
            loadScript(this,selectizeminJS),
            loadStyle(this, selectizeCss),
            loadStyle(this,selectizeDefaultcss),
            loadStyle(this,selectizeBoots2),
            loadStyle(this,selectizeBoots3)
        ]).then(() => { 
            $(this.template.querySelector('.slds-truncate')).text("JQuery Loaded");   
            $(this.template.querySelector('.demo-default')).selectize({
                placeholder: 'Select a person ...',
                valueField: 'value',
				labelField: 'name',
                options: [
                {value:'4' , name: 'Thomas Edison'},
                {value: '1', name: 'Nikola'},
                {value: '3', name: 'Nikola Tesla'},
                {value: '5', name: 'Arnold Schwarzenegger'} ],
                create: true,
                searchField: ['name'],
				sortField: [
						{field: 'name', direction: 'asc'}
				],
            });         
         }).catch(error => {
             console.log(error)
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error loading Jquery',
                    message: error,
                    variant: 'error'
                })
            );
        });
    }
    connectedCallback(){
      //  this.ready = true;
  
    }
}