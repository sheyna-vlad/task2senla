public class SK_LightningMapCmpController {
  @AuraEnabled
  public static List<Account> findAccountsForMap() {
    return [
      SELECT
        id,
        name,
        billingCity,
        billingStreet,
        billingCountry,
        billingPostalCode,
        billingState,
        Latitude__c,
        Longitude__c
      FROM Account
    ];
  }
}
