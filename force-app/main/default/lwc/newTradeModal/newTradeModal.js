import { LightningElement, track } from 'lwc';
import { Close, Submit } from './events.js';
import getExchangeRates from '@salesforce/apex/ExchangeTradeController.getExchangeRates';
import createNewTrade from '@salesforce/apex/ExchangeTradeController.createNewTrade';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class NewTradeModal extends LightningElement {
    supportedCurrencies = [
        { label: 'EUR', value: 'EUR' },
        { label: 'USD', value: 'USD' },
        { label: 'GBP', value: 'GBP' },
    ];
    buyCurrencies = [];
    sellCurrency = '';
    buyCurrency = '';
    rate = '-';
    sellAmount;
    buyAmount;

	handleClose() {
		this.dispatchEvent(new Close());
	}

    handleSubmit() {
		this.dispatchEvent(new Submit());
        this.handleClose();
    }

    handleSellCurrencyChange(event) {
        this.sellCurrency = event.target.value;
        this.handleRates();
    }

    handleRates() {
        getExchangeRates({
            currencyCode: this.sellCurrency
        })
        .then((result) => {
            this.buyCurrencies = result;
        })
        .catch((error) => {
            this.rate = '-';
            this.buyCurrency = '';
            this.buyCurrencies = [];
            this.buyAmount = null;

            this.dispatchEvent(
				new ShowToastEvent({
					message: error.body.message,
					variant: 'error',
                    mode: 'sticky',
				})
			);
        });
    }

    handleBuyCurrencyChange(event) {
        this.buyCurrency = event.target.value;
        this.rate = this.buyCurrencies.find(currency => currency.value == this.buyCurrency).rate;
        this.updateBuyAmount();
    }

    handleSellAmountChange(event) {
        this.sellAmount = event.target.value;
        this.updateBuyAmount();
    }

    updateBuyAmount() {
        if (this.sellAmount && this.rate) {
            this.buyAmount = this.sellAmount * this.rate;
        } else {
            this.buyAmount = null;
        }
    }

    handleCreate = () => {
        createNewTrade({
            newTrade: {
                sellCurrency: this.sellCurrency,
                sellAmount: this.sellAmount,
                buyCurrency: this.buyCurrency,
                buyAmount: this.buyAmount,
                rate: this.rate,
            }
        });
    }
}