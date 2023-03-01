/**
 * Class with methods related to Order object
 * 
 * @author Nicolas Padiou
 */
public with sharing class OrderService {
  /**
   * Calculate NetAmount field : TotalAmount - ShipmentCost
   * 
   * @param order : an order
   */
  public static void calculateNetAmount(Order o) {
      Decimal shipmentCost = 0;
      if (o.ShipmentCost__c != null) shipmentCost = o.ShipmentCost__c;
      o.NetAmount__c = o.TotalAmount - shipmentCost;
  }

  /**
   * Get AccountIds for order with status Ordered
   * 
   * @param orderIds : list of order ids
   * 
   * @return list of account ids
   */
  public static Set<Id> getAccountIdsWithOrderedOrder(Set<Id> orderIds) {
    Set<Id> accoundIds = new Set<Id>();
    for(Order o : [SELECT AccountId FROM Order WHERE Id IN:orderIds AND Status='Ordered']) {
      accoundIds.add(o.AccountId);
    }
    return accoundIds;
  }
}