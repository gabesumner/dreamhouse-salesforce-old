trigger AppActivityTrigger on AppActivity__c (before insert) {

    for(AppActivity__c activity: Trigger.new) {
        List<Contact> contacts;
        Contact contact;
        User user;

        // First make sure we have either a Contact or User to work with
        if (String.isEmpty(activity.User__c) && String.isEmpty(activity.Contact__c)) {
            activity.addError('Either Contact or User must be set!');
        }

        // If we weren't passed a User, then attempt to fetch it from the Contact record and set the new activity with it.
        if (String.isEmpty(activity.User__c)) {
            contacts = [SELECT User__c FROM Contact WHERE Id=:activity.Contact__c ];
            try {
                activity.User__c = contacts[0].User__c;
            }
            catch (Exception e) {
                // It's fine. It just means we added a activity for a contact and have no connected User.
            }
        }

        // If we weren't passed a Contact, then we need to fetch it or create it.
        if (String.isEmpty(activity.Contact__c)) {
            contacts = [SELECT Id, User__c FROM Contact WHERE User__c=:activity.User__c ];

            // If contacts is empty then we have no Contact record for this user, let's create it.
            if ( contacts.isEmpty() ) {
                List<User> users = [SELECT Id, FirstName, LastName, Username FROM User WHERE Id=:activity.User__c];
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
                contact.User__c = activity.user__c;
                update contact;
            }

            // Okay, we're ready to add the activity as soon as we set the Contact field.
            activity.contact__c = contact.Id;
        }

    }
}