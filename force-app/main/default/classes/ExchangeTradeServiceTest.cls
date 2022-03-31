@isTest(seeAllData=false)
private class ExchangeTradeServiceTest {
    @isTest
    static void getExchangeRates_successfulRequest_currencyCodeRatesAreReturned() {
        // Given
        String currencyCode = 'EUR';

        MockHttpResponseGenerator mock = new MockHttpResponseGenerator(currencyCode, true);
        Test.setMock(HttpCalloutMock.class, mock);

        // When
        Map<String, Decimal> actualRates = ExchangeTradeService.getInstance().getExchangeRates(currencyCode);

        // Then
        System.assertEquals(mock.rates, actualRates);
    }

    @isTest
    static void getExchangeRates_errorRequest_exceptionIsThrown() {
        // Given
        String currencyCode = 'EUR';

        MockHttpResponseGenerator mock = new MockHttpResponseGenerator(currencyCode, false);
        Test.setMock(HttpCalloutMock.class, mock);

        try {
            // When
            ExchangeTradeService.getInstance().getExchangeRates(currencyCode);
            System.assert(false, 'Exception expected.');
        } catch(ExchangeTradeService.ExchangeTradeException e) {
            // Then
            System.assertEquals(mock.error, e.getMessage());
        }
    }

    @isTest
    static void createChatterPosts_noQueueOrMembers_postsAreNotCreated() {
        // Given
		User tradeUser = createUserAndQueue(false);
        List<Trade__c> trades = createTrades();

        // When
        System.runAs(new User(Id = tradeUser.Id)) {
            ExchangeTradeService.getInstance().createChatterPosts(trades);
        }

        // Then
        List<FeedItem> posts = [SELECT Id FROM FeedItem WHERE ParentId = :tradeUser.Id];
        System.assertEquals(true, posts.isEmpty());
    }

    @isTest
    static void createChatterPosts_userInQueue_postsAreCreatedForQueueUsers() {
        // Given
		User tradeUser = createUserAndQueue(true);
        List<Trade__c> trades = createTrades();

        // When
        ExchangeTradeService service = new ExchangeTradeService();
        System.runAs(new User(Id = tradeUser.Id)) {
            service.createChatterPosts(trades);
        }

        // Then
        List<FeedItem> posts = [SELECT Id, Body FROM FeedItem WHERE ParentId = :tradeUser.Id ORDER BY CreatedDate DESC];
        System.assertEquals(2, posts.size());

        for (Integer i = posts.size() - 1; i >= 0; i--) {
            System.assertEquals(service.formatChatterBodyPost(trades[i]), posts[i].Body);
        }
    }

    private static List<Trade__c> createTrades() {
        return new List<Trade__c> {
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
    }

    private static User createUserAndQueue(Boolean addMemberUser) {
        Profile standardProfile = [SELECT Id FROM profile WHERE name = 'Standard User'];
		User tradeUser = new User(
			alias = 'test',
			email = 'testuser@testorg.com',
			emailencodingkey = 'UTF-8',
			lastname = 'Testing',
			languagelocalekey = 'en_US',
			localesidkey = 'en_US',
			profileid = standardProfile.Id,
			timezonesidkey = 'America/Los_Angeles',
			username = 'testuser@testorg.com.' + Integer.valueof((Math.random() * 100))
		);
        insert tradeUser;

        if (addMemberUser) {
            Group queue = new Group(
                Type = 'Queue',
                Name = 'Trade reviewers'
            );
            upsert queue;

            GroupMember tradeMember = new GroupMember(
                UserOrGroupId = tradeUser.Id,
                GroupId = queue.Id
            );
            insert tradeMember;
        }

        return tradeUser;
    }

    public class MockHttpResponseGenerator implements HttpCalloutMock {
        public Map<String, Decimal> rates;
        public String error;

        private String apiKey;
        private String currencyCode;
        private Boolean success;

        private MockHttpResponseGenerator(String currencyCode, Boolean success) {
            this.currencyCode = currencyCode;
            this.success = success;

            if (this.success) {
                this.rates = new Map<String, Decimal> {
                    'GBP' => 0.80,
                    'USD' => 1.2,
                    'JPY' => 100
                };
            } else {
                this.error = 'Something went wrong!';
            }
        }

        public HTTPResponse respond(HTTPRequest req) {
            String endPoint = String.format('http://data.fixer.io/api/latest?access_key={0}&base={1}', new List<String>{ this.apiKey, this.currencyCode });
            System.assertEquals(endPoint, req.getEndpoint());
            System.assertEquals('GET', req.getMethod());

            ExchangeTradeService.ExchangeRates responseData = new ExchangeTradeService.ExchangeRates();
            responseData.success = this.success;

            if (this.success) {
                responseData.rates = this.rates;
            } else {
                responseData.error = new ExchangeTradeService.RequestError();
                responseData.error.type = this.error;
            }

            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody(JSON.serialize(responseData));
            res.setStatusCode(this.success ? 200 : 500);
            return res;
        }
    }
}