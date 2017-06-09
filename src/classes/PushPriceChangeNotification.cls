public with sharing class PushPriceChangeNotification {

    @InvocableMethod(label='Push Price Change Notification')
    public static void pushNotification(List<Id> propertyId) {
        Id propId = propertyId[0]; // If bulk, only post first to avoid spamming
        Property__c property = [SELECT Name, Price__c from Property__c WHERE Id=:propId];
        String message = property.Name + '. New Price: $' + property.Price__c.setScale(0).format();

        Set<String> userIds = new Set<String>();
        List<Favorite__c> favorites = [SELECT user__c from favorite__c WHERE property__c=:propId];
        for (Favorite__c favorite : favorites) {
        	userIds.add(favorite.user__c);
        }

        Messaging.PushNotification msg =  new Messaging.PushNotification();
        Map<String, Object> payload = Messaging.PushNotificationPayload.apple(message, '', null, null);
        msg.setPayload(payload);
        msg.send('DreamHouse_Mobile_App', userIds);
    }

}