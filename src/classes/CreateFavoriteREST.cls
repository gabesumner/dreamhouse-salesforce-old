@RestResource(urlMapping='/CreateFavorite/*')
global with sharing class CreateFavoriteREST {

@HttpGet
  global static void create() {
      RestContext.response.addHeader('Content-Type', 'application/json');
    try {
        ID propertyID = RestContext.request.params.get('id');
        ID userID = UserInfo.getUserId();
        Favorite__c favorite = new Favorite__c();
        favorite.Property__c = propertyID;
        favorite.User__c = userID;
        insert favorite;
        RestContext.response.responseBody = Blob.valueOf('{ "message" : "Success" }');
    } catch (Exception e) {
        RestContext.response.responseBody = Blob.valueOf('{ "message" : "Error" }');
    }
}
}