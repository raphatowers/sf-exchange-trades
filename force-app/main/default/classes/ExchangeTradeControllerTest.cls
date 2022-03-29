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

    private static void assertTrade(Trade__c expected, ExchangeTradeController.Trade actual) {
        System.assertEquals(expected.Sell_Currency__c, actual.sellCurrency);
        System.assertEquals(expected.Sell_Amount__c, actual.sellAmount);
        System.assertEquals(expected.Buy_Currency__c, actual.buyCurrency);
        System.assertEquals(expected.Buy_Amount__c, actual.buyAmount);
        System.assertEquals(expected.Date_Booked__c, actual.dateBooked);
    }
}
