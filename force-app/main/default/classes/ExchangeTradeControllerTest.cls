@isTest(seeAllData=false)
private class ExchangeTradeControllerTest {
    @isTest
    static void getBookedTrades_noTradesCreated_emptyList() {
        // Given
        // When
        List<ExchangeTradeController.Trade> actualTrades = ExchangeTradeController.getBookedTrades();

        // Then
        System.assertEquals(true, actualTrades.isEmpty());
    }

    @isTest
    static void getBookedTrades_someTradesCreated_areReturnedProperlySorted() {
        // Given
        List<Trade__c> trades = new List<Trade__c> {
            new Trade__c(
                Sell_Currency__c = 'EUR',
                Sell_Amount__c = 100,
                Buy_Currency__c = 'GBP',
                Buy_Amount__c = 90,
                Rate__c = 0.9,
                Date_Booked__c = Datetime.newInstance(2022, 4, 17, 7, 45, 30)
            ),
            new Trade__c(
                Sell_Currency__c = 'EUR',
                Sell_Amount__c = 1000,
                Buy_Currency__c = 'USD',
                Buy_Amount__c = 1100,
                Rate__c = 1.1,
                Date_Booked__c = Datetime.newInstance(2022, 4, 17, 8, 45, 30)
            )
        };
        insert trades;

        // When
        List<ExchangeTradeController.Trade> actualTrades = ExchangeTradeController.getBookedTrades();

        // Then
        System.assertEquals(2, actualTrades.size());
        assertTrade(trades[1], actualTrades[0]);
        assertTrade(trades[0], actualTrades[1]);
    }

    @isTest
    static void getBookedTrades_error_exceptionThrownProperlyHandled() {
        // Given
        String error = 'Something went wrong!';
        ExchangeTradeSelectorMock mock = new ExchangeTradeSelectorMock(error);
        ExchangeTradeSelector selector = new ExchangeTradeSelector();
        selector.setMock(mock);

        // When
        try {
            ExchangeTradeController.getBookedTrades();
            System.assert(false, 'Exception expected');
        } catch (AuraHandledException e) {
            // Then
            System.assertEquals(error, e.getMessage());
        }
    }

    @isTest
    static void getExchangeRates_currencyRatesAvailable_ratesAreParsedAndReturned() {
        // Given
        String currencyCode = 'EUR';
        Map<String, Decimal> rateValueByCode = new Map<String, Decimal> {
            'GBP' => 1.5,
            'USD' => 0.7
        };
        ExchangeTradeServiceMock serviceMock = new ExchangeTradeServiceMock(rateValueByCode);
        new ExchangeTradeService().setMock(serviceMock);

        // When
        List<ExchangeTradeController.ExchangeRate> actualRates = ExchangeTradeController.getExchangeRates(currencyCode);

        // Then
        Integer count = 0;
        for (String expectedCurrencyCode : rateValueByCode.keySet()) {
            assertExchangeRate(expectedCurrencyCode, rateValueByCode.get(expectedCurrencyCode), actualRates[count]);
            count++;
        }
    }

    @isTest
    static void getExchangeRates_error_exceptionThrownProperlyHandled() {
        // Given
        String error = 'Something went wrong!';
        ExchangeTradeServiceMock serviceMock = new ExchangeTradeServiceMock(error);
        new ExchangeTradeService().setMock(serviceMock);

        // When
        try {
            ExchangeTradeController.getExchangeRates('Any currency');
            System.assert(false, 'Exception expected');
        } catch (AuraHandledException e) {
            // Then
            System.assertEquals(error, e.getMessage());
        }
    }

    private static void assertTrade(Trade__c expected, ExchangeTradeController.Trade actual) {
        System.assertEquals(expected.Sell_Currency__c, actual.sellCurrency);
        System.assertEquals(expected.Sell_Amount__c, actual.sellAmount);
        System.assertEquals(expected.Buy_Currency__c, actual.buyCurrency);
        System.assertEquals(expected.Buy_Amount__c, actual.buyAmount);
        System.assertEquals(expected.Date_Booked__c, actual.dateBooked);
    }

    private static void assertExchangeRate(String expectedCurrency, Decimal expectedRate, ExchangeTradeController.ExchangeRate actual) {
        System.assertEquals(expectedCurrency, actual.label);
        System.assertEquals(expectedCurrency, actual.value);
        System.assertEquals(expectedRate, actual.rate);
    }

    private class ExchangeTradeSelectorMock implements ExchangeTradeSelector.IExchangeTradeSelector {
        public String error;

        public ExchangeTradeSelectorMock(String error) {
            this.error = error;
        }

        public List<Trade__c> selectAll() {
            if (String.isNotBlank(error)) {
                throw new MockException(error);
            }

            return new List<Trade__c>();
        }
    }

    private class ExchangeTradeServiceMock implements ExchangeTradeService.IExchangeTradeService {
        public Map<String, Decimal> rateValueByCode;
        public String error;

        public ExchangeTradeServiceMock(Map<String, Decimal> rateValueByCode) {
            this.rateValueByCode = rateValueByCode;
        }

        public ExchangeTradeServiceMock(String error) {
            this.error = error;
        }

        public Map<String, Decimal> getExchangeRates(String currencyCode) {
            if (String.isNotBlank(error)) {
                throw new MockException(error);
            }

            return this.rateValueByCode;
        }

        public void createChatterPosts(List<Trade__c> trades) {

        }
    }

    public class MockException extends Exception {}
}
