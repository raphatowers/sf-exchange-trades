import { LightningElement, wire } from 'lwc';
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

    @wire(getBookedTrades)
    wiredBookedTrades({ error, data }) {
        if (data) {
            this.data = data;
        } else if (error) {

        }
    }
}