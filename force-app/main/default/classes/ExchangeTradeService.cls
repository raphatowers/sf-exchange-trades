public with sharing class ExchangeTradeService {
    public interface API {
        Map<String, Decimal> getExchangeRates(String currencyCode);
    }

    private static String API_ENDPOINT = 'http://data.fixer.io/api/latest?access_key={0}&base={1}';
    private static String API_ACCESS_KEY = '';
    private static String REQUEST_METHOD_GET = 'GET';

    public Map<String, Decimal> getExchangeRates(String currencyCode) {

        String endPoint = String.format(API_ENDPOINT, new List<String>{
            API_ACCESS_KEY,
            currencyCode
        });

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
