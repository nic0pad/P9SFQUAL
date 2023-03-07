@isTest
private class AccountBatchUpdateCATest {
  @testSetup
  static void setup() {
    // Saved in a map, differents prices for each account
    Map<Integer, Decimal> price = new Map<Integer, Decimal>();
    // Create accounts
    List<Account> accounts = new List<Account>();
    for (Integer i=0;i<10;i++) {
      price.put(i, 1000 * (i+1));
      accounts.add(TestDataFactory.createAccount('TestAccount' + i));
    }
    insert accounts;

    // Create Contract for each account
    List<Contract> contracts = new List<Contract>();
    for (Account account : [SELECT Id FROM Account ORDER BY Name]) {
      contracts.add(TestDataFactory.createContract(account.Id));
    }
    insert contracts;

    // Create Product
    Product2 product = TestDataFactory.createProduct();

    // Generate Pricebook Id
    Id pricebookId = Test.getStandardPricebookId();
  
    // Create a PricebookEntry
    PricebookEntry standardPrice = TestDataFactory.createPricebookEntry(pricebookId, product, 100);

    // Create 120 orders for each account
    // and activated each contract
    List<Order> orders = new List<Order>();
    contracts = new List<Contract>();
    for (Account account : [SELECT Id FROM Account ORDER BY Name]) {
      Contract contract = [SELECT Id, Status FROM Contract WHERE AccountId = :account.Id];
      for (Integer i=0;i<120;i++) {
        orders.add(TestDataFactory.createOrder(null, account.Id, pricebookId, contract.Id));
      }
      contract.Status = 'Activated';
      contracts.add(contract);
    }
    insert orders;
    update contracts;

    // Create one item for each orders, with a different price for each account.
    // And update the status of orders.
    orders = new List<Order>();
    List<OrderItem> orderItems = new List<OrderItem>();
    Integer indexPrice = 0;
    for (Account account : [SELECT Id FROM Account ORDER BY Name]) {
      Decimal unitPrice = price.get(indexPrice);
      for (Order order : [SELECT Id, Status FROM Order WHERE AccountId = :account.Id]) {
        orderItems.add(TestDataFactory.createOrderItem(order.Id, product, unitPrice, 1, standardPrice.Id));
        order.Status = 'Ordered';
        orders.Add(order);
      }
      indexPrice++;
    }
    insert orderItems;
    update orders;
  }

  @isTest static void test() {
    Test.startTest();
    AccountBatchUpdateCA batch = new AccountBatchUpdateCA();
    Database.executeBatch(batch);
    Test.stopTest();
    // Check if the CA field is equal to the expected CA
    Integer indexPrice = 1;
    for (Account account : [SELECT Id, Chiffre_d_affaire__c FROM Account ORDER BY Name]) {
      Decimal expectedCA = 1000 * indexPrice * 120;
      System.assertEquals(expectedCA, account.Chiffre_d_affaire__c);
      indexPrice++;
    }
  }
}