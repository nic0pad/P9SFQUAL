/**
 * Class to test the class OrderTriggerHandler and the trigger OrderTrigger
 * 
 * @author Nicolas Padiou
 */
@isTest
private class OrderTriggerHandlerTest {
    @isTest static void testCalculateNetAmount() {
      // Create Product
      Product2 product = TestDataFactory.createProduct();

      // Generate Pricebook Id
      Id pricebookId = Test.getStandardPricebookId();
    
      // Create a PricebookEntry
      PricebookEntry standardPrice = TestDataFactory.createPricebookEntry(pricebookId, product, 100);

      // Create an test Account
      Account account = TestDataFactory.createAccount('TestAccount');

      // Create 3 orders with and without shipment cost
      Order order1 = TestDataFactory.createOrder(100, account, pricebookId);
      Order order2 = TestDataFactory.createOrder(200, account, pricebookId);
      Order order3 = TestDataFactory.createOrder(null, account, pricebookId);

      List<OrderItem> orderItems = new List<OrderItem>();
      orderItems.add(TestDataFactory.createOrderItem(order1.Id, product, 1000, 1, standardPrice.Id));
      orderItems.add(TestDataFactory.createOrderItem(order1.Id, product, 2000, 2, standardPrice.Id));
      orderItems.add(TestDataFactory.createOrderItem(order2.Id, product, 1500, 2, standardPrice.Id));
      orderItems.add(TestDataFactory.createOrderItem(order2.Id, product, 4000, 1, standardPrice.Id));
      orderItems.add(TestDataFactory.createOrderItem(order3.Id, product, 1000, 3, standardPrice.Id));
      orderItems.add(TestDataFactory.createOrderItem(order3.Id, product, 500, 1, standardPrice.Id));

      insert orderItems;

      List<Order> orders = [SELECT Id, TotalAmount, AccountId, Status, NetAmount__c, ShipmentCost__c FROM Order];

      // Check if NetAmount is right for each order
      System.assertEquals(4900, orders[0].NetAmount__c);
      System.assertEquals(6800, orders[1].NetAmount__c);
      System.assertEquals(3500, orders[2].NetAmount__c);

      // Update orders
      update orders;

      // Check if NetAmount is always right for each orders
      Order order = [SELECT Id, TotalAmount, AccountId, Status, NetAmount__c, ShipmentCost__c FROM Order WHERE Id = :order1.Id];
      System.assertEquals(4900, order.NetAmount__c);

      order = [SELECT Id, TotalAmount, AccountId, Status, NetAmount__c, ShipmentCost__c FROM Order WHERE Id = :order2.Id];
      System.assertEquals(6800, order.NetAmount__c);

      order = [SELECT Id, TotalAmount, AccountId, Status, NetAmount__c, ShipmentCost__c FROM Order WHERE Id = :order3.Id];
      System.assertEquals(3500, order.NetAmount__c);
    }

    @isTest static void testUpdateAccountCA() {
      // Create Product
      Product2 product = TestDataFactory.createProduct();

      // Generate Pricebook Id
      Id pricebookId = Test.getStandardPricebookId();
    
      // Create a PricebookEntry
      PricebookEntry standardPrice = TestDataFactory.createPricebookEntry(pricebookId, product, 100);

      // Create a test Accounts
      Account account1 = TestDataFactory.createAccount('TestAccount1');
      Account account2 = TestDataFactory.createAccount('TestAccount2');

      // Create a list of test Orders
      List<Order> orders = new List<Order>();
      Order order1 = TestDataFactory.createOrder(300, account1, pricebookId);
      orders.add(order1);
      Order order2 = TestDataFactory.createOrder(null, account2, pricebookId);
      orders.add(order2);
      Order order3 = TestDataFactory.createOrder(null, account1, pricebookId);
      orders.add(order3);
      Order order4 = TestDataFactory.createOrder(100, account2, pricebookId);
      orders.add(order4);

      List<OrderItem> orderItems = new List<OrderItem>();
      orderItems.add(TestDataFactory.createOrderItem(order1.Id, product, 1000, 1, standardPrice.Id));
      orderItems.add(TestDataFactory.createOrderItem(order1.Id, product, 2000, 2, standardPrice.Id));
      orderItems.add(TestDataFactory.createOrderItem(order2.Id, product, 1500, 2, standardPrice.Id));
      orderItems.add(TestDataFactory.createOrderItem(order2.Id, product, 4000, 1, standardPrice.Id));
      orderItems.add(TestDataFactory.createOrderItem(order3.Id, product, 1000, 3, standardPrice.Id));
      orderItems.add(TestDataFactory.createOrderItem(order3.Id, product, 500, 1, standardPrice.Id));
      orderItems.add(TestDataFactory.createOrderItem(order4.Id, product, 3000, 1, standardPrice.Id));
      orderItems.add(TestDataFactory.createOrderItem(order4.Id, product, 2000, 1, standardPrice.Id));

      insert orderItems;

      Account account = [SELECT Id, Chiffre_d_affaire__c FROM Account WHERE Id = :account1.Id];
      System.assertEquals(8500, account.Chiffre_d_affaire__c);

      account = [SELECT Id, Chiffre_d_affaire__c FROM Account WHERE Id = :account2.Id];
      System.assertEquals(12000, account.Chiffre_d_affaire__c);
    }
}