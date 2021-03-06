import { LightningElement, track } from 'lwc';
import { Close, Submit } from './events.js';
import getExchangeRates from '@salesforce/apex/ExchangeTradeController.getExchangeRates';
import createNewTrade from '@salesforce/apex/ExchangeTradeController.createNewTrade';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { LABELS } from './labels';
import { stringFormat } from './utils';

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
	isLoading = false;

	handleClose() {
		this.dispatchEvent(new Close());
	}

    handleSubmit() {
		this.dispatchEvent(new Submit());
        this.handleClose();
        this.dispatchEvent(
            new ShowToastEvent({
                message: LABELS.newTradeSuccessfullyCreated,
                variant: 'success',
                mode: 'sticky',
            })
        );
    }

    handleSellCurrencyChange(event) {
        this.sellCurrency = event.target.value;
        this.handleRates();
    }

    handleRates() {
	    this.isLoading = true;
        getExchangeRates({
            currencyCode: this.sellCurrency
        })
        .then((result) => {
            this.buyCurrencies = result;
            this.isLoading = false;
        })
        .catch((error) => {
            this.rate = '-';
            this.buyCurrency = '';
            this.buyCurrencies = [];
            this.buyAmount = null;

            this.dispatchEvent(
				new ShowToastEvent({
					message: stringFormat(LABELS.newTradeErrorRetrievingData, error.body.message),
					variant: 'error',
                    mode: 'sticky',
				})
			);
            this.isLoading = false;
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

	get labels() {
		return LABELS;
	}
}