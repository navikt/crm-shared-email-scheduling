import { LightningElement, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

export default class ListViewButton extends NavigationMixin(LightningElement) {
    @api listViewApiName;
    @api sObjectApiName;

    openListView(evt) {
        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: this.sObjectApiName,
                actionName: 'list'
            },
            state: {
                filterName: this.listViewApiName
            }
        });
    }
}
