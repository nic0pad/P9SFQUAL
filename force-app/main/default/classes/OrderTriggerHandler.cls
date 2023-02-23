public with sharing class OrderTriggerHandler {
  /**
   * Calculate NetAmount field for each order
   */
  public static void calculateNetAmount(List<Order> newOrders) {
    for(Order o : newOrders) {
      Decimal shipmentCost = 0;
      if (o.ShipmentCost__c != null) shipmentCost = o.ShipmentCost__c;
      o.NetAmount__c = o.TotalAmount - shipmentCost;
    }
  }
}
