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

    /**
   * Get Total CA of orders
   */
  @AuraEnabled(cacheable=true)
  public static Decimal getTotalCA(){
    // Calculate CA
    AggregateResult[] result = [SELECT SUM(TotalAmount) totalCA FROM Order WHERE status='Ordered'];
    Decimal totalCA = 0;
    if (!result.isEmpty()) totalCA = (Decimal)result[0].get('totalCA');
    return totalCA;
  }

  /**
   * Get orders by owner
   */
  @AuraEnabled(cacheable=true)
  public static Map<String,List<Order>> getOrdersByOwner(){
    // Map contains orders by owner
    Map<String,List<Order>> commands = new Map<String,List<Order>>();

    // get orders with status = 'Ordered'
    Order[] records = [SELECT Id, TotalAmount, Owner.Name FROM Order WHERE status='Ordered'];

    // store each order by Owner.Name in the Map
    for (Order record : records) {
      List<Order> orders = new List<Order>();
      if (commands.containsKey(record.Owner.Name)) {
        orders = commands.get(record.Owner.Name);
      }
      orders.add(record);
      commands.put(record.Owner.Name, orders);
    }

    // return orders group by owner
    return commands;
  }
}