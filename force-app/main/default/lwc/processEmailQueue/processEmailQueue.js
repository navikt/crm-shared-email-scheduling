import { LightningElement, track, api } from 'lwc';
import processEmails from '@salesforce/apex/EmailQueueScheduler.processEmailQueue';
import getJobStatus from '@salesforce/apex/EmailQueueScheduler.getJobStatus';

export default class ProcessEmailQueue extends LightningElement {
    @track isLoading = false;
    @track jobIds;
    @track completedJobs = 0;
    @track totalJobs = 1;
    @track isRunning;
    @track error;

    @api status;
    @api title;
    @api buttonName;

    processEmails(evt) {
        this.isLoading = true;
        this.jobIds = undefined;

        processEmails({ status: this.status })
            .then((result) => {
                this.isLoading = false;
                this.jobIds = result;
                this.totalJobs = result.length;
                if (result.length > 0) {
                    this.startProgressBar();
                    this.buttonName = this.buttonName + ' again';
                }
            })
            .catch((error) => {
                this.isLoading = false;
                this.error = error.body.message;
            });
    }

    startProgressBar() {
        this.isRunning = true;
        this.completedJobs = 0;

        // eslint-disable-next-line @lwc/lwc/no-async-operation
        this._interval = setInterval(() => {
            console.log('run');
            getJobStatus({ jobIds: this.jobIds }).then((result) => {
                this.completedJobs = result;

                if (this.isJobComplete) {
                    this.isRunning = false;
                    clearInterval(this._interval);
                }
            });
        }, 6000);
    }

    updateProgessBar() {}

    get isJobComplete() {
        return this.completedJobs >= this.totalJobs;
    }

    get progress() {
        return (100 * this.completedJobs) / this.totalJobs;
    }

    get showTitle() {
        return !(this.isJobComplete || this.isRunning);
    }
}
