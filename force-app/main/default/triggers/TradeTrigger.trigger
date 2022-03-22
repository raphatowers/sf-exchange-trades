trigger TradeTrigger on Trade__c (after insert) {
    ExchangeTradeService.getInstance().createChatterPosts(Trigger.new);
}