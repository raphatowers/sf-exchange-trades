@IsTest(seeAllData=false)
private class ExchangeTradeSelectorTest {
    @IsTest
    static void selectAll_severalTradesCreated_allRetrievedAndProperlySorted() {
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
        List<Trade__c> actualTrades = ExchangeTradeSelector.getInstance().selectAll();

        // Then
        System.assertEquals(2, actualTrades.size());
        System.assertEquals('USD', actualTrades[0].Buy_Currency__c);
        System.assertEquals('GBP', actualTrades[1].Buy_Currency__c);
    }
}