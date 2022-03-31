import { LightningElement, api } from 'lwc';
import { Close, Submit } from './events.js';
import { LABELS } from './labels';

export default class BaseModal extends LightningElement {
    /**
     * The title of the modal window.
     * @type {String}
     */
     @api title;

    /**
     * The title of the submit button.
     * @type {String}
     */
     @api submitTitle;

     /**
     * Callback function fired by the submit button
     * @type {function}
     */
     @api submitCallback

     handleCloseClick() {
         this.dispatchEvent(new Close());
     }

     async handleSubmit() {
        await this.submitCallback();
        this.dispatchEvent(new Submit());
    }

	get labels() {
		return LABELS;
	}
}