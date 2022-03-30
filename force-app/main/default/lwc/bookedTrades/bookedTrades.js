import { LightningElement, wire } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import getBookedTrades from '@salesforce/apex/ExchangeTradeController.getBookedTrades';
import { LABELS } from './labels';

const columns = [
    { label: LABELS.sellCurrency, fieldName: 'sellCurrency' },
    { label: LABELS.sellAmount, fieldName: 'sellAmount', type: 'number' },
    { label: LABELS.buyCurrency, fieldName: 'buyCurrency' },
    { label: LABELS.buyAmount, fieldName: 'buyAmount', type: 'number' },
    { label: LABELS.rate, fieldName: 'rate', type: 'number' },
    { label: LABELS.dateBooked, fieldName: 'dateBooked', type: 'date' },
];

export default class BookedTrades extends LightningElement {
    data = [];
    columns = columns;
    isModalOpen = false;

    @wire(getBookedTrades)
    wiredTrades;

    refreshTrades() {
        this.closeModal();
        refreshApex(this.wiredTrades);
    }

    openModal() {
        this.isModalOpen = true;
    }

    closeModal() {
        this.isModalOpen = false;
    }

	get labels() {
		return LABELS;
	}
}