import newTrade from '@salesforce/label/c.NewTrade';
import create from '@salesforce/label/c.Create';
import sellCurrency from '@salesforce/label/c.SellCurrency';
import buyCurrency from '@salesforce/label/c.BuyCurrency';
import sellAmount from '@salesforce/label/c.SellAmount';
import buyAmount from '@salesforce/label/c.BuyAmount';
import rate from '@salesforce/label/c.Rate';
import selectCurrency from '@salesforce/label/c.SelectCurrency';
import newTradeErrorRetrievingData from '@salesforce/label/c.NewTradeErrorRetrievingData';
import newTradeSuccessfullyCreated from '@salesforce/label/c.NewTradeSuccessfullyCreated';

export const LABELS = {
	newTrade,
	create,
	sellCurrency,
	buyCurrency,
	sellAmount,
	buyAmount,
	rate,
	selectCurrency,
	newTradeErrorRetrievingData,
	newTradeSuccessfullyCreated,
}