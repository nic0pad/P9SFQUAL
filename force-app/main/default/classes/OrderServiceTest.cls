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
    insert account;

    // Create 3 orders with and without shipment cost
    Order order1 = TestDataFactory.createOrder(100, account, pricebookId);
    insert order1;
    Order order2 = TestDataFactory.createOrder(200, account, pricebookId);
    insert order2;
    Order order3 = TestDataFactory.createOrder(null, account, pricebookId);
    insert order3;

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
    insert account1;
    Account account2 = TestDataFactory.createAccount('TestAccount2');
    insert account2;
    Account account3 = TestDataFactory.createAccount('TestAccount3');
    insert account3;

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
    insert order1;
    Order order2 = TestDataFactory.createOrder(200, account2, pricebookId);
    insert order2;
    Order order3 = TestDataFactory.createOrder(100, account3, pricebookId);
    insert order3;

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

  @isTest static void testGetTotalCA() {
    // Create test Accounts
    Account account1 = TestDataFactory.createAccount('TestAccount1');
    insert account1;

    // Create Product
    Product2 product = TestDataFactory.createProduct();

    // Generate Pricebook Id
    Id pricebookId = Test.getStandardPricebookId();
  
    // Create a PricebookEntry
    PricebookEntry standardPrice = TestDataFactory.createPricebookEntry(pricebookId, product, 100);

    /**
     * Create 2 orders in Draft status :
     * Account1 ==> order1
     * Account2 ==> order2
     */
    Set<Id> orderIds = new Set<Id>();
    Order order1 = TestDataFactory.createOrder(100, account1, pricebookId);
    insert order1;
    Order order2 = TestDataFactory.createOrder(200, account1, pricebookId);
    insert order2;

    // Add products to order
    List<OrderItem> orderItems = new List<OrderItem>();
    orderItems.add(TestDataFactory.createOrderItem(order1.Id, product, 1000, 1, standardPrice.Id));
    orderItems.add(TestDataFactory.createOrderItem(order1.Id, product, 2000, 2, standardPrice.Id));
    orderItems.add(TestDataFactory.createOrderItem(order2.Id, product, 1000, 3, standardPrice.Id));
    orderItems.add(TestDataFactory.createOrderItem(order2.Id, product, 500, 1, standardPrice.Id));
    insert orderItems;

    /**
     * Update orders :
     * Account1 ==> order1 ==> Ordered
     */
    order1.Status = 'Ordered';
    update order1;

    Decimal totalCA = OrderService.getTotalCA();
    System.assertEquals(5000, totalCA);
  }

  @isTest static void testGetOrdersByOwner(){
    // Setup test data
    // Create a unique UserName
    String uniqueUserName = 'standarduser' + DateTime.now().getTime() + '@testorg.com';
    // This code runs as the system user
    Profile p = [SELECT Id FROM Profile WHERE Name='Standard User' or Name = 'Utilisateur standard'];
    User u = new User(Alias = 'standt', Email='standarduser@testorg.com',
    EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
    LocaleSidKey='en_US', ProfileId = p.Id,
    TimeZoneSidKey='America/Los_Angeles',
      UserName=uniqueUserName);

    System.runAs(u) {
        // The following code runs as user 'u'
        System.debug('Current User: ' + UserInfo.getUserName());
        System.debug('Current Profile: ' + UserInfo.getProfileId());
    }

    // Create test Accounts
    Account account1 = TestDataFactory.createAccount('TestAccount1');
    insert account1;

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
    insert order1;
    Order order2 = TestDataFactory.createOrder(200, account1, pricebookId);
    insert order2;
    Order order3 = TestDataFactory.createOrder(100, account1, pricebookId);
    insert order3;

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

    Map<String,List<Order>> ordersByOwner = OrderService.getOrdersByOwner();

    System.assert(ordersByOwner.containsKey(order1.Owner.Name));
    List<Order> orders = ordersByOwner.get(order1.Owner.Name);
    System.assertEquals(2, orders.size());
    Order order = orders.get(0);
    System.assertEquals(order1.Id, order.Id);
    order = orders.get(1);
    System.assertEquals(order3.Id, order.Id);
  }
}