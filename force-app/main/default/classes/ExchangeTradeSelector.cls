public class ExchangeTradeSelector implements IExchangeTradeSelector {
    public interface IExchangeTradeSelector {
        List<Trade__c> selectAll();
    }

    private static IExchangeTradeSelector selectorInstance;
    public static IExchangeTradeSelector getInstance() {
        if (selectorInstance == null) {
            selectorInstance = new ExchangeTradeSelector();
        }

        return selectorInstance;
    }
    
    public List<Trade__c> selectAll() {
        String tradeQuery = 'SELECT Sell_Currency__c, Sell_Amount__c, Buy_Currency__c, Buy_Amount__c, Rate__c, Date_Booked__c FROM Trade__c ORDER BY Date_Booked__c DESC';
        return (List<Trade__c>) Database.query(tradeQuery);
    }
}
