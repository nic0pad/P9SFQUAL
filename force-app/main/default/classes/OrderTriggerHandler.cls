/**
 * Class with all methods use in the trigger OrderTrigger
 * 
 * @author Nicolas Padiou
 */
public with sharing class OrderTriggerHandler {
  /**
   * Calculate NetAmount field for each order : TotalAmount - ShipmentCost
   * 
   * @param orders List of orders
   */
  public static void calculateNetAmount(List<Order> orders) {
    for(Order o : orders) {
      Decimal shipmentCost = 0;
      if (o.ShipmentCost__c != null) shipmentCost = o.ShipmentCost__c;
      o.NetAmount__c = o.TotalAmount - shipmentCost;
    }
  }

  /**
   * Update CA Account for each order
   * 
   * @param orders List of orders
   */
  public static void updateAccountCA(List<Order> orders) {
    // get map with total amount by account Id
    Map<Id, Decimal> accountAmount = OrderTriggerHandler.getTotalAmountByAccount(orders);

    // Saved "Chiffre d'affaire" for each account
    List<Account> accounts = [SELECT Id, Chiffre_d_affaire__c FROM Account WHERE Id = :accountAmount.keySet()];
    if (accounts.size()>0) {
      for(Account account : accounts) {
        Decimal ca = accountAmount.get(account.Id);
        if (account.Chiffre_d_affaire__c != null)  ca += account.Chiffre_d_affaire__c;
        account.Chiffre_d_affaire__c = ca;
      }
      update accounts;
    }
  }

  /**
   * Get total amount for each account
   * 
   * @param orders List of orders
   * 
   * @return Map<Id, Decimal> a map with total amount by account Id
   */
  private static Map<Id, Decimal> getTotalAmountByAccount(List<Order> orders) {
    Map<Id, Decimal> accountAmount = new Map<Id, Decimal>();

    for(Order o : orders) {
      Decimal totalAmount = o.TotalAmount;
      if(accountAmount.containsKey(o.AccountId)) {
        totalAmount = accountAmount.get(o.AccountId);
        totalAmount += o.TotalAmount;
      }
      accountAmount.put(o.AccountId, totalAmount);
    }

    return accountAmount;
  }
}
