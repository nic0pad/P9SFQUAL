@isTest
/**
 * OrderTriggerHandlerTest
 * Class to test the class OrderTriggerHandler and the trigger OrderTrigger
 */
private class OrderTriggerHandlerTest {
    @isTest static void testCalculateNetAmount() {
      // Create 3 orders with and without shipment cost
      Order order1 = TestDataFactory.createOrder(1000, 100);
      Order order2 = TestDataFactory.createOrder(2000, 200);
      Order order3 = TestDataFactory.createOrder(1500, null);

      List<Order> orders = [SELECT Id, TotalAmount, AccountId, Status, NetAmount__c, ShipmentCost__c FROM Order];

      // Calculate NetAmount foall orders
      OrderTriggerHandler.calculateNetAmount(orders);

      // Check if NetAmount is right for each order
      System.assertEquals(900, orders[0].NetAmount__c);
      System.assertEquals(1800, orders[1].NetAmount__c);
      System.assertEquals(1500, orders[2].NetAmount__c);

      // Update orders
      update orders;

      // Check if NetAmount is always right for each orders
      Order order = [SELECT Id, TotalAmount, AccountId, Status, NetAmount__c, ShipmentCost__c FROM Order WHERE id = :order1.Id];
      System.assertEquals(900, order.NetAmount__c);

      order = [SELECT Id, TotalAmount, AccountId, Status, NetAmount__c, ShipmentCost__c FROM Order WHERE id = :order2.Id];
      System.assertEquals(1800, order.NetAmount__c);

      order = [SELECT Id, TotalAmount, AccountId, Status, NetAmount__c, ShipmentCost__c FROM Order WHERE id = :order3.Id];
      System.assertEquals(1500, order.NetAmount__c);
    }
}