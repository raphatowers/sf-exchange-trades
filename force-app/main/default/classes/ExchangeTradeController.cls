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
            throw new AuraHandledException(e.getMessage());
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
            throw new AuraHandledException(e.getMessage());
        }
    }

    public class Trade {
        @AuraEnabled
        public String sellCurrency;
        @AuraEnabled
        public Decimal sellAmount;
        @AuraEnabled
        public String buyCurrency;
        @AuraEnabled
        public Decimal buyAmount;
        @AuraEnabled
        public Decimal rate;
        @AuraEnabled
        public Datetime dateBooked;

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