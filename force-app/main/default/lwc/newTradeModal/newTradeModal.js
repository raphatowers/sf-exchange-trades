import { LightningElement } from 'lwc';
import { Close } from './events.js';
export default class NewTradeModal extends LightningElement {
    

	handleClose() {
		this.dispatchEvent(new Close());
	}

    handleCreate() {

    }
}