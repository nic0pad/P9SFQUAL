public with sharing class OrderTriggerHandler {
    public static void calculateNetAmount(List<Order> newOrders) {
      for(Order o : newOrders) {
        Decimal cost = 0;
        if (o.ShipmentCost__c != null) cost = o.ShipmentCost__c;
        o.NetAmount__c = o.TotalAmount - cost;
      }
    }
}
