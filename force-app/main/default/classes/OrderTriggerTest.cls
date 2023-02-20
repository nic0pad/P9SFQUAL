@isTest
private class OrderTriggerTest {
  @isTest static void testCalculateNetAmountWithShipment() {
    Order order = TestDataFactory.createOrder(1000, 100);

    order = [SELECT Id, TotalAmount, AccountId, Status, NetAmount__c, ShipmentCost__c FROM Order WHERE id = :order.Id];

    System.assertEquals(900, order.NetAmount__c);
  }

  @isTest static void testCalculateNetAmountWithoutShipment() {
    Order order = TestDataFactory.createOrder(1000, null);

    order = [SELECT Id, TotalAmount, AccountId, Status, NetAmount__c, ShipmentCost__c FROM Order WHERE id = :order.Id];

    System.assertEquals(1000, order.NetAmount__c);
  }
}