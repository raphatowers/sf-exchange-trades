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

    @TestVisible
    private void setMock(IExchangeTradeService serviceMock) {
        serviceInstance = serviceMock;
    }

    private static String API_ENDPOINT = 'http://data.fixer.io/api/latest?access_key={0}&base={1}';
    private static String REQUEST_METHOD_GET = 'GET';

    private static String GROUP_TYPE_QUEUE = 'Queue';
    private static String GROUP_CHATTER_NAME = 'Trade reviewers';
    private static String CHATTER_TYPE_LINK = 'LinkPost';
    private static String SLASH = '/';

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
            new List<String> { GROUP_TYPE_QUEUE },
            new List<String> { GROUP_CHATTER_NAME }
        );

        if (!groupMembers.isEmpty()) {
            String baseUrl = URL.getSalesforceBaseUrl().toExternalForm();
            List<FeedItem> posts = new List<FeedItem>();

            for (Trade__c trade : trades) {
                String body = formatChatterBodyPost(trade);

                for(GroupMember groupMember : groupMembers) {
                    posts.add(new FeedItem(
                        ParentId = groupMember.UserOrGroupId,
                        Body = body,
                        Type = CHATTER_TYPE_LINK,
                        Title = Label.NewTradeChatterPostLinkTitle,
                        LinkUrl = baseUrl + SLASH + trade.Id
                    ));
                }
            }

            insert posts;
        }
    }

    @TestVisible
    private String formatChatterBodyPost(Trade__c trade) {
        return String.format(Label.NewTradeChatterPostBody, new List<String> {
            trade.Sell_Currency__c,
            String.valueOf(trade.Sell_Amount__c),
            trade.Buy_Currency__c,
            String.valueOf(trade.Buy_Amount__c),
            String.valueOf(trade.Rate__c),
            trade.Date_Booked__c.format()
        });
    }

    public class ExchangeTradeException extends Exception {}

    @TestVisible
    private class ExchangeRates {
        public Boolean success;
        public Map<String, Decimal> rates;
        public RequestError error;
    }

    @TestVisible
    private class RequestError {
        public String type;
    }
}