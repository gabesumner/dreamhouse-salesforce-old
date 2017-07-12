@RestResource(urlMapping='/CreateAppActivity/*')
global with sharing class CreateAppActivityREST {

@HttpGet
  global static void create() {
      RestContext.response.addHeader('Content-Type', 'application/json');
    try {
        ID property = RestContext.request.params.get('property');
        ID broker = RestContext.request.params.get('broker');
        string message = RestContext.request.params.get('message');
        ID user = UserInfo.getUserId();
        AppActivity__c appactivity = new AppActivity__c();
        appactivity.Name = message;
        appactivity.Property__c = property;
        appactivity.Broker__c = broker;
        appactivity.User__c = user;
        insert appactivity;
        RestContext.response.responseBody = Blob.valueOf('{ "message" : "Success" }');
    } catch (Exception e) {
        RestContext.response.responseBody = Blob.valueOf('{ "message" : "Error" }');
    }
}
}