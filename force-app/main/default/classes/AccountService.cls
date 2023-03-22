/**
 * Class with methods related to Account object
 * 
 * @author Nicolas Padiou
 */
public with sharing class AccountService {
  /**
   * Update CA for each accounts with orders in Status Ordered
   * 
   * @param accountIds : List id of accounts to update
   */
  public static void updateCA(Set<Id> accountIds) {
    // List of accounts to update
    List<Account> accountsToUpdate = new List<Account>();

    // Search order and calculate CA for each accounts
    AggregateResult[] results = [SELECT AccountId, SUM(TotalAmount) totalCA FROM Order WHERE AccountId IN :accountIds AND status='Ordered' GROUP BY AccountId];
    for (AggregateResult result : results) {
      // Add account with CA in the accountsToUpdate List
      accountsToUpdate.add(new Account(
        Id = (Id)result.get('AccountId'),
        Chiffre_d_affaire__c = (Decimal)result.get('totalCA')
      ));
      // Remove account found of the account List
      accountIds.remove((Id)result.get('AccountId'));
    }

    // If account not found with orders, update CA to 0
    for (Id accountId : accountIds) {
      // Add account with CA = 0 in the accountsToUpdate List
      accountsToUpdate.add(new Account(
        Id = accountId,
        Chiffre_d_affaire__c = 0
      ));
    }

    // Update accounts
    update accountsToUpdate;
  }
}