public with sharing class PushPropertyRecommendation {

	@InvocableMethod(label='Push Property Recommendation' description='Send a customer notification when brokers recommend a property.')
	public static void pushNotification (List<string> favoriteIDs) {
        Id favoriteID = favoriteIDs[0]; // If bulk, only post first to avoid spamming
        Favorite__c favorite = [SELECT Property__c, Recommendation__c, User__c, CreatedById from Favorite__c WHERE Id=:favoriteId];
        Property__c property = [SELECT Name, Price__c from Property__c WHERE Id=:favorite.Property__c];
        User broker = [SELECT Name FROM User WHERE Id=:favorite.CreatedById];
        //String message = '{aps: {alert: "' + broker.Name + ' suggested you look at this property: ' + property.Name + ' - $' + property.Price__c.setScale(0).format() + '",sound: "default"}}';
        //String message = '{alert: "' + broker.Name + ' suggested you look at this property: ' + property.Name + ' - $' + property.Price__c.setScale(0).format() + '",sound: "default"}';
        String message = 'Your broker suggested you look at this property: ' + property.Name + ' - $' + property.Price__c.setScale(0).format();

        Set<String> userIds = new Set<String>();
        userIds.add(favorite.user__c);

        Messaging.PushNotification msg =  new Messaging.PushNotification();
        Map<String, Object> payload = Messaging.PushNotificationPayload.apple(message, '', null, null);
        msg.setPayload(payload);
        msg.send('DreamHouse_Mobile_App', userIds);
    }
}