public class ExchangeTradeController {
    
    @AuraEnabled
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

    public class ExchangeRate {
        @AuraEnabled
        public String currencyCode;
        @AuraEnabled
        public Decimal rate;

        public ExchangeRate (String currencyCode, Decimal rate) {
            this.currencyCode = currencyCode;
            this.rate = rate;
        }
    }
}
