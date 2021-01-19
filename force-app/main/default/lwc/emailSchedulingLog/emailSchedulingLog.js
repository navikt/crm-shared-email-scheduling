import { LightningElement, wire, api, track } from 'lwc';
import getLogData from '@salesforce/apex/EmailSchedulingLog.getLogData';
import { refreshApex } from '@salesforce/apex';

const columns = [
    { label: 'Name', fieldName: 'TargetObjectId', type: 'url', typeAttributes: { label: { fieldName: 'TargetObjectName' }, target: '_self' } },
    { label: 'Status', fieldName: 'Status', type: 'text' },
    { label: 'Subject', fieldName: 'Subject', type: 'text' },
    { label: 'Date', fieldName: 'DateSent', type: 'date-local' },
];

export default class EmailSchedulingLog extends LightningElement {

    @api recordId;
    @track data;
    @track isLoading = true;
    columns = columns;

    @wire(getLogData, { recordId: '$recordId' })
    deWire(result) {
        this.data = result;
        this.isLoading = false;
    }

    refresh() {
        this.isLoading = true;
        return refreshApex(this.data).then(() => {
            this.isLoading = false;
        });
    }

    get isEmpty() {
        if (this.data) {
            return this.data.length == 0;
        } else {
            return true;
        }
    }
}