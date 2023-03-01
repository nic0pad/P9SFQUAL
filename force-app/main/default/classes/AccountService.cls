/**
 * Class with methods related to Account object
 * 
 * @author Nicolas Padiou
 */
public with sharing class AccountService {
  /**
   * Update CA for each account with order in Status Ordered
   * 
   * @param accountIds : List id of accounts to update
   */
  public static void updateCA(Set<Id> accountIds) {
    List<Account> accountsToUpdate = new List<Account>();

    for (Id accountId : accountIds) {
      // Calculate CA for the account
      AggregateResult[] result = [SELECT SUM(TotalAmount) totalCA FROM Order WHERE AccountId = :accountId AND status='Ordered' GROUP BY AccountId];
      
      // Update Chiffre_d_affaire__c field with the CA
      Account updateAccount = new Account();
      updateAccount.Chiffre_d_affaire__c = 0;
      if (!result.isEmpty()) updateAccount.Chiffre_d_affaire__c = (Decimal)result[0].get('totalCA');
      updateAccount.Id = accountId;

      accountsToUpdate.add(updateAccount);
    }
    
    // Update accounts
    update accountsToUpdate;
  }
}