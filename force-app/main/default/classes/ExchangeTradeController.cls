public class ExchangeTradeController {

    @AuraEnabled(cacheable=true)
    public static List<Trade> getBookedTrades(){
        try {
            List<Trade__c> trades = ExchangeTradeSelector.getInstance().selectAll();
            List<Trade> bookedTrades = new List<Trade>();

            for (Trade__c trade : trades) {
                bookedTrades.add(new Trade(trade.Sell_Currency__c, trade.Sell_Amount__c, trade.Buy_Currency__c, trade.Buy_Amount__c, trade.Rate__c, trade.Date_Booked__c));
            }

            return bookedTrades;
        } catch (Exception e) {
            throw getAuraException(e.getMessage());
        }
    }

    @AuraEnabled(cacheable=true)
    public static List<ExchangeRate> getExchangeRates(String currencyCode){
        try {
            Map<String, Decimal> rateValueByCode = ExchangeTradeService.getInstance().getExchangeRates(currencyCode);
            List<ExchangeRate> exchangeRates = new List<ExchangeRate>();

            for (String code : rateValueByCode.keySet()) {
                exchangeRates.add(new ExchangeRate(code, rateValueByCode.get(code)));
            }

            return exchangeRates;
        } catch (Exception e) {
            throw getAuraException(e.getMessage());
        }
    }

    @AuraEnabled
    public static void createNewTrade(Trade newTrade){
        try {
            if (newTrade != null) {
                insert new Trade__c (
                    Sell_Currency__c = newTrade.sellCurrency,
                    Sell_Amount__c = newTrade.sellAmount,
                    Buy_Currency__c = newTrade.buyCurrency,
                    Buy_Amount__c = newTrade.buyAmount,
                    Rate__c = newTrade.rate,
                    Date_Booked__c = Datetime.now()
                );
            }
        } catch (Exception e) {
            throw getAuraException(e.getMessage());
        }
    }

    private static AuraHandledException getAuraException(String message) {
        AuraHandledException auraEx = new AuraHandledException(message);
        auraEx.setMessage(message);
        return auraEx;
    }

    public class Trade {
        @AuraEnabled
        public String sellCurrency { get; set; }
        @AuraEnabled
        public Decimal sellAmount { get; set; }
        @AuraEnabled
        public String buyCurrency { get; set; }
        @AuraEnabled
        public Decimal buyAmount { get; set; }
        @AuraEnabled
        public Decimal rate { get; set; }
        @AuraEnabled
        public Datetime dateBooked { get; set; }

        public Trade() {}

        public Trade(String sellCurrency, Decimal sellAmount, String buyCurrency, Decimal buyAmount, Decimal rate, Datetime dateBooked) {
            this.sellCurrency = sellCurrency;
            this.sellAmount = sellAmount;
            this.buyCurrency = buyCurrency;
            this.buyAmount = buyAmount;
            this.rate = rate;
            this.dateBooked = dateBooked;
        }
    }

    public class ExchangeRate {
        @AuraEnabled
        public String label;
        @AuraEnabled
        public String value;
        @AuraEnabled
        public Decimal rate;

        public ExchangeRate (String currencyCode, Decimal rate) {
            this.label = currencyCode;
            this.value = currencyCode;
            this.rate = rate;
        }
    }
}