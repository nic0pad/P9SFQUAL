/**
 * Class to test the class OrderService and the trigger OrderTrigger
 * 
 * @author Nicolas Padiou
 */
@isTest
public class OrderServiceTest {
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

    // Add products to order
    List<OrderItem> orderItems = new List<OrderItem>();
    orderItems.add(TestDataFactory.createOrderItem(order1.Id, product, 1000, 1, standardPrice.Id));
    orderItems.add(TestDataFactory.createOrderItem(order1.Id, product, 2000, 2, standardPrice.Id));
    orderItems.add(TestDataFactory.createOrderItem(order2.Id, product, 1500, 2, standardPrice.Id));
    orderItems.add(TestDataFactory.createOrderItem(order2.Id, product, 4000, 1, standardPrice.Id));
    orderItems.add(TestDataFactory.createOrderItem(order3.Id, product, 1000, 3, standardPrice.Id));
    orderItems.add(TestDataFactory.createOrderItem(order3.Id, product, 500, 1, standardPrice.Id));

    insert orderItems;

    // Check if NetAmount is always right for each orders
    /**
     * Check if NetAmount is right for each orders
     * order1 ==> TotalAmount:5000 - ShipmentCost:100  ==> NetAmount = 4900
     * order2 ==> TotalAmount:7000 - ShipmentCost:200  ==> NetAmount = 6800
     * order3 ==> TotalAmount:3500 - ShipmentCost:0  ==> NetAmount = 3500
     */
    Order order = [SELECT Id, TotalAmount, AccountId, Status, NetAmount__c, ShipmentCost__c FROM Order WHERE Id = :order1.Id];
    System.assertEquals(4900, order.NetAmount__c);

    order = [SELECT Id, TotalAmount, AccountId, Status, NetAmount__c, ShipmentCost__c FROM Order WHERE Id = :order2.Id];
    System.assertEquals(6800, order.NetAmount__c);

    order = [SELECT Id, TotalAmount, AccountId, Status, NetAmount__c, ShipmentCost__c FROM Order WHERE Id = :order3.Id];
    System.assertEquals(3500, order.NetAmount__c);

    List<Order> orders = [SELECT Id, TotalAmount, AccountId, Status, NetAmount__c, ShipmentCost__c FROM Order];
    // Update orders
    update orders;

    // Check if NetAmount is always right for each orders
    order = [SELECT Id, TotalAmount, AccountId, Status, NetAmount__c, ShipmentCost__c FROM Order WHERE Id = :order1.Id];
    System.assertEquals(4900, order.NetAmount__c);

    order = [SELECT Id, TotalAmount, AccountId, Status, NetAmount__c, ShipmentCost__c FROM Order WHERE Id = :order2.Id];
    System.assertEquals(6800, order.NetAmount__c);

    order = [SELECT Id, TotalAmount, AccountId, Status, NetAmount__c, ShipmentCost__c FROM Order WHERE Id = :order3.Id];
    System.assertEquals(3500, order.NetAmount__c);
  }

  @isTest static void testGetAccountIdsWithOrderedOrder() {
    // Create test Accounts
    Account account1 = TestDataFactory.createAccount('TestAccount1');
    Account account2 = TestDataFactory.createAccount('TestAccount2');
    Account account3 = TestDataFactory.createAccount('TestAccount3');

    // Create Product
    Product2 product = TestDataFactory.createProduct();

    // Generate Pricebook Id
    Id pricebookId = Test.getStandardPricebookId();
  
    // Create a PricebookEntry
    PricebookEntry standardPrice = TestDataFactory.createPricebookEntry(pricebookId, product, 100);

    /**
     * Create 3 orders in Draft status :
     * Account1 ==> order1
     * Account2 ==> order2
     * Account3 ==> order3
     */
    Set<Id> orderIds = new Set<Id>();
    Order order1 = TestDataFactory.createOrder(100, account1, pricebookId);
    Order order2 = TestDataFactory.createOrder(200, account2, pricebookId);
    Order order3 = TestDataFactory.createOrder(100, account3, pricebookId);

    // Add products to order
    List<OrderItem> orderItems = new List<OrderItem>();
    orderItems.add(TestDataFactory.createOrderItem(order1.Id, product, 1000, 1, standardPrice.Id));
    orderItems.add(TestDataFactory.createOrderItem(order1.Id, product, 2000, 2, standardPrice.Id));
    orderItems.add(TestDataFactory.createOrderItem(order3.Id, product, 1000, 3, standardPrice.Id));
    orderItems.add(TestDataFactory.createOrderItem(order3.Id, product, 500, 1, standardPrice.Id));
    insert orderItems;

    /**
     * Update orders :
     * Account1 ==> order1 ==> Ordered
     * Account2 ==> order2 ==> Draft
     * Account3 ==> order3 ==> Ordered
     */
    order1.Status = 'Ordered';
    update order1;

    order3.Status = 'Ordered';
    update order3;

    orderIds.add(order1.Id);
    orderIds.add(order2.Id);
    orderIds.add(order3.Id);

    // Search account with orders in status Ordered
    Set<Id> accountIdsActual = OrderService.getAccountIdsWithOrderedOrder(orderIds);

    // Account1 ==> order1 ==> Ordered : the account IS in the array
    System.assert(accountIdsActual.contains(account1.Id));
    // Account2 ==> order2 ==> Draft : the account IS NOT in the array
    System.assert(!accountIdsActual.contains(account2.Id));
    // Account3 ==> order3 ==> Ordered : the account IS in the array
    System.assert(accountIdsActual.contains(account3.Id));
  }
}