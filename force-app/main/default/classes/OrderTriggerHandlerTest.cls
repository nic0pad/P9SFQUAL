@isTest
private class OrderTriggerHandlerTest {
    @isTest static void testCalculateNetAmountWithShipment() {

      TestDataFactory.createOrders(1000, 100);

      List<Order> orders = [SELECT Id, TotalAmount, AccountId, Status, NetAmount__c, ShipmentCost__c FROM Order];

      OrderTriggerHandler.calculateNetAmount(orders);

      System.assertEquals(900, orders[0].NetAmount__c);
    }

    @isTest static void testCalculateNetAmountWithoutShipment() {

      TestDataFactory.createOrders(1000, null);

      List<Order> orders = [SELECT Id, TotalAmount, AccountId, Status, NetAmount__c, ShipmentCost__c FROM Order];

      OrderTriggerHandler.calculateNetAmount(orders);

      System.assertEquals(1000, orders[0].NetAmount__c);
    }
}