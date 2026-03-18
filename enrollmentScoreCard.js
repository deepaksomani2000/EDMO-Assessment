import { LightningElement, api, wire } from 'lwc';
import getLatestScore from '@salesforce/apex/EnrollmentScoreController.getLatestScore';

export default class EnrollmentScoreCard extends LightningElement {

    @api recordId; // Contact Id
    score;

    @wire(getLatestScore, { contactId: '$recordId' })
    wiredScore({ error, data }) {
        if (data) {
            this.score = data;
        } else {
            this.score = null;
        }
    }

    // Priority label
    get priorityLabel() {
        if (!this.score) return '';

        const s = this.score.Score__c;

        if (s >= 75) return 'Hot';
        if (s >= 40) return 'Warm';
        return 'Cold';
    }

    // Badge styling
    get badgeClass() {
        const base = 'slds-badge ';

        if (!this.score) return base;

        const s = this.score.Score__c;

        if (s >= 75) return base + 'slds-theme_error';     // Red
        if (s >= 40) return base + 'slds-theme_warning';   // Orange
        return base + 'slds-theme_info';                   // Blue
    }
}
