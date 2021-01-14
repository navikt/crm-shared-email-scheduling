
import { LightningElement, track } from 'lwc';
import processEmails from "@salesforce/apex/EmailQueueScheduler.processEmailQueue";
import getJobStatus from '@salesforce/apex/EmailQueueScheduler.getJobStatus';

export default class ProcessEmailQueue extends LightningElement {

    @track isLoading = false;
    @track jobIds;
    @track completedJobs = 0;
    @track totalJobs = 1;
    @track isRunning;
    @track error;
    @track buttonText = 'Process';

    processEmails(evt) {

        this.isLoading = true;
        this.jobIds = undefined;

        processEmails().then(result => {
            this.isLoading = false;
            this.jobIds = result;
            this.totalJobs = result.length;
            this.finished = 0;
            this.startProgressBar();
        }).catch(error => {
            this.isLoading = false;
            this.error = error.body.message;
        });
    }

    startProgressBar() {

        this.isRunning = true;
        this.buttonText = "Process More Emails";

        // eslint-disable-next-line @lwc/lwc/no-async-operation
        this._interval = setInterval(() => {
            console.log('run');
            getJobStatus({ jobIds: this.jobIds }).then(result => {
                this.completedJobs = result;

                if (this.isJobComplete) {
                    this.isRunning = false;
                    clearInterval(this._interval);
                }
            });
        }, 3000);

    }

    updateProgessBar() {

    }

    get isJobComplete() {
        return this.completedJobs >= this.totalJobs;
    }

    get progress() {
        return 100 * this.completedJobs / this.totalJobs;
    }

    get showTitle() {
        return !(this.isJobComplete || this.isRunning);
    }
}