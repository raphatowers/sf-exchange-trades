import { LightningElement, wire } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import getBookedTrades from '@salesforce/apex/ExchangeTradeController.getBookedTrades';

const columns = [
    { label: 'Sell CCY', fieldName: 'sellCurrency' },
    { label: 'Sell Amount', fieldName: 'sellAmount', type: 'number' },
    { label: 'Buy CCY', fieldName: 'buyCurrency' },
    { label: 'Buy Amount', fieldName: 'buyAmount', type: 'number' },
    { label: 'Rate', fieldName: 'rate', type: 'number' },
    { label: 'Date Booked', fieldName: 'dateBooked', type: 'date' },
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
}