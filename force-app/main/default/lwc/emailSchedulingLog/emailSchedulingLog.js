import { LightningElement, wire, api, track } from 'lwc';
import getLogData from '@salesforce/apex/EmailSchedulingLog.getLogData';
import { refreshApex } from '@salesforce/apex';

const columns = [
    { label: 'Name', fieldName: 'MainUrl', type: 'url', typeAttributes: { label: { fieldName: 'Main' }, target: '_self' } },
    { label: 'Status', fieldName: 'Status', type: 'text' },
    { label: 'Date', fieldName: 'DateSent', type: 'date-local' },
];

export default class EmailSchedulingLog extends LightningElement {

    @api recordId;
    @track data;
    @track isLoading = true;
    columns = columns;

    connectedCallback() {
        this.load();
    }

    load() {
        console.log('test');
        this.isLoading = true;
        getLogData({ recordId: this.recordId })
            .then(result => {

                var tempData = JSON.parse(JSON.stringify(result));

                for (var i = 0; i < tempData.length; i++) {

                    tempData[i]._children = tempData[i]['Children'];
                    delete tempData[i].Children;

                }

                this.data = tempData;

                this.isLoading = false;
            }).catch(error => { });
    }

    refresh() {

        this.isLoading = true;

        // delay to notify user that refresh actually started
        // eslint-disable-next-line @lwc/lwc/no-async-operation
        setTimeout(() => {
            this.load();
        }, 300);

    }

    get isEmpty() {
        if (this.data) {
            return this.data.length == 0;
        } else {
            return true;
        }
    }
}