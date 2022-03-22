public with sharing class ExchangeTradeService implements IExchangeTradeService {
    public interface IExchangeTradeService {
        Map<String, Decimal> getExchangeRates(String currencyCode);
        void createChatterPosts(List<Trade__c> trades);
    }

    private static IExchangeTradeService serviceInstance;
    public static IExchangeTradeService getInstance() {
        if (serviceInstance == null) {
            serviceInstance = new ExchangeTradeService();
        }

        return serviceInstance;
    }

    private static String API_ENDPOINT = 'http://data.fixer.io/api/latest?access_key={0}&base={1}';
    private static String REQUEST_METHOD_GET = 'GET';

    public Map<String, Decimal> getExchangeRates(String currencyCode) {

        String apiAccessKey = ExchangeTradeSettings__c.getInstance().API_Access_Key__c;
        String endPoint = String.format(API_ENDPOINT, new List<String>{ apiAccessKey, currencyCode });

        HttpRequest httpRequest = new HttpRequest();
		httpRequest.setEndpoint(endPoint);
		httpRequest.setMethod(REQUEST_METHOD_GET);
		HttpResponse httpResponse = new Http().send(httpRequest);

		ExchangeRates ratesResponse = (ExchangeRates) JSON.deserialize(
			httpResponse.getBody(),
            ExchangeRates.class
		);

        if (ratesResponse.success) {
            return ratesResponse.rates;
        } else {
            throw new ExchangeTradeException(ratesResponse.error.type);
        }
    }

    public void createChatterPosts(List<Trade__c> trades) {
        List<GroupMember> groupMembers = GroupSelector.getInstance().selectMembersByGroupTypesAndNames(
            new List<String> {'Queue'},
            new List<String> {'Trade reviewers'}
        );

        if (!groupMembers.isEmpty()) {
            String t = 'Sell Currency: {0}\nSell Amount: {1}\nBuy Currency: {2}\nBuy Amount: {3}\nRate: {4}\nBooked Date: {5}\nLink to the trade: {6}/{7}';
            String baseUrl = URL.getSalesforceBaseUrl().toExternalForm();
            List<FeedItem> posts = new List<FeedItem>();

            for (Trade__c trade : trades) {
                String body = formatChatterBodyPost(trade, t, baseUrl);

                for(GroupMember groupMember : groupMembers) {
                    posts.add(new FeedItem(
                        ParentId = groupMember.UserOrGroupId,
                        Title = 'New Trade has been created',
                        Body = 'Trade body'
                    ));
                }
            }

            insert posts;
        }
    }

    private String formatChatterBodyPost(Trade__c trade, String template, String baseUrl) {
        return String.format(template, new List<String> {
            trade.Sell_Currency__c,
            String.valueOf(trade.Sell_Amount__c),
            trade.Buy_Currency__c,
            String.valueOf(trade.Buy_Amount__c),
            String.valueOf(trade.Rate__c),
            trade.Date_Booked__c.format(),
            baseUrl,
            trade.Id
        });
    }

    public class ExchangeTradeException extends Exception {}

    private class ExchangeRates {
        Boolean success;
        public Map<String, Decimal> rates;
        public RequestError error;
    }

    private class RequestError {
        public String type;
    }
}