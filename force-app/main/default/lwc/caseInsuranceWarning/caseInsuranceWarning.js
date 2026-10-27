import { LightningElement, api, wire } from 'lwc';
import checkEligibility from '@salesforce/apex/CaseInsuranceWarningController.checkEligibility';

export default class CaseInsuranceWarning extends LightningElement {
    @api recordId;

    @wire(checkEligibility, { caseId: '$recordId' })
    eligibilityResult;

    get showWarning() {
        return this.eligibilityResult.data?.showWarning === true;
    }

    get warningMessage() {
        return this.eligibilityResult.data?.warningMessage
            ?? 'Customer not eligible for Insurance. Please route the case to Contact center until Approval received.';
    }
}