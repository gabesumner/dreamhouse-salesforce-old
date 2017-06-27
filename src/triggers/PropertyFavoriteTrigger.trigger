trigger PropertyFavoriteTrigger on Favorite__c (before insert, before update) {
    for(Favorite__c favorite: Trigger.new) {
        List<Contact> contacts;
        Contact contact;
        User user;

        // First make sure we have either a Contact or User to work with
        if (String.isEmpty(favorite.User__c) && String.isEmpty(favorite.Contact__c)) {
            favorite.addError('Either Contact or User must be set!');
        }

        // If this is an insert, then make sure this favorite doesn't already exist (which throws an error). If it does, delete it.
        if (trigger.isInsert) {
            List<Favorite__c> favorites = [SELECT Id FROM Favorite__c WHERE Property__c = :favorite.property__c AND (User__c = :favorite.User__c OR Contact__c = :favorite.Contact__c)];
            delete favorites;
        }

        // If we weren't passed a User, then attempt to fetch it from the Contact record and set the new favorite with it.
        if (String.isEmpty(favorite.User__c)) {
            contacts = [SELECT User__c FROM Contact WHERE Id=:favorite.Contact__c ];
            try {
                favorite.User__c = contacts[0].User__c;
            }
            catch (Exception e) {
                // It's fine. It just means we added a favorite for a contact and have no connected User.
            }
        }

        // If we weren't passed a Contact, then we need to fetch it or create it.
        if (String.isEmpty(favorite.Contact__c)) {
            contacts = [SELECT Id, User__c FROM Contact WHERE User__c=:favorite.User__c ];

            // If contacts is empty then we have no Contact record for this user, let's create it.
            if ( contacts.isEmpty() ) {
                List<User> users = [SELECT Id, FirstName, LastName, Username FROM User WHERE Id=:favorite.User__c];
                try {
                    user = users[0];
                    contact = new Contact();
                    contact.FirstName = user.FirstName;
                    contact.LastName = user.LastName;
                    contact.Email = user.Username;
                    contact.User__c = user.Id;
                    insert contact;
                }
                catch(Exception e) {
                    System.debug('ERROR:' + e);
                }
            }
            else {
                contact = contacts[0];
            }

            // If, for some reason, the User field isn't set on the Contact record, then set it.
            if (String.isEmpty(contact.User__c)) {
                contact.User__c = favorite.user__c;
                update contact;
            }

            // Okay, we're ready to add the favorite as soon as we set the Contact field.
            favorite.contact__c = contact.Id;
        }

    }
}
