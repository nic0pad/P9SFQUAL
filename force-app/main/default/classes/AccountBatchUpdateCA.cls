/**
 * Batch to update CA of all accounts
 * 
 * @author Nicolas Padiou
 */
public class AccountBatchUpdateCA implements Database.Batchable<SObject> {
  public Database.QueryLocator start(Database.BatchableContext bc) {
    // Select all account
    return Database.getQueryLocator('SELECT Id FROM Account');
  }
  public void execute(Database.BatchableContext bc, List<Account> records) {
    // Set account ids
    Set<Id> accountIds = (new Map<Id,SObject>(records)).keySet();
    // Call AccountService method to Update CA
    AccountService.updateCA(accountIds);
  }
  public void finish(Database.BatchableContext bc) {
  }
}