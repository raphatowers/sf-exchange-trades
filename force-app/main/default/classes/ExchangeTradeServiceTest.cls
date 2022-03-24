@isTest
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
