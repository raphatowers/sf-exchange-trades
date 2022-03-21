import { LightningElement, api } from 'lwc';
import { Close } from './events.js';

export default class BaseModal extends LightningElement {
    /**
     * The title of the modal window.
     * @type {String}
     */
     @api title;

     /**
      * @fires module:BaseModal.event:close
      */
     @api
     close() {
         /**
          * Close event.
          * @event module:BaseModal.event:close
          */
         this.dispatchEvent(new Close());
     }

     handleCloseClick() {
         this.dispatchEvent(new Close());
         this.close();
     }

     handleSubmit() {

     }
}