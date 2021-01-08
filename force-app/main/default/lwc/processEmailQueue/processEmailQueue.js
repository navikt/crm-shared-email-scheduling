
import { LightningElement, track } from 'lwc';
import processEmails from "@salesforce/apex/EmailQueueScheduler.processEmailQueue";

export default class ProcessEmailQueue extends LightningElement {

    @track isLoading = false;
    @track info;
    @track error;

    processEmails(evt) {

        this.isLoading = true;
        this.msg = undefined;

        processEmails().then(result => {
            this.isLoading = false;
            this.info = result;
        }).catch(error => {
            this.isLoading = false;
            this.error = error.body.message;
        });
    }
}