import { LightningElement, api } from 'lwc';
import { Close, Submit } from './events.js';

export default class BaseModal extends LightningElement {
    /**
     * The title of the modal window.
     * @type {String}
     */
     @api title;
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
}