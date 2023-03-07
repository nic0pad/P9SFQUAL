/**
 * Class to test the class AccountService and the trigger OrderTrigger
 * 
 * @author Nicolas Padiou
 */
@isTest
public class AccountServiceTest {
  /**
   * Verify the calculated CA is right
   * The CA is calculated just for order with Status == 'Ordered'
   */
  @isTest static void testUpdateCA() {
    // Create test Accounts
    Set<Id> accountIds = new Set<Id>();
    Account account1 = TestDataFactory.createAccount('TestAccount1');
    insert account1;
    accountIds.add(account1.Id);
    Account account2 = TestDataFactory.createAccount('TestAccount2');
    insert account2;
    accountIds.add(account2.Id);
    Account account3 = TestDataFactory.createAccount('TestAccount3');
    insert account3;
    accountIds.add(account3.Id);

    // Create Product
    Product2 product = TestDataFactory.createProduct();

    // Generate Pricebook Id
    Id pricebookId = Test.getStandardPricebookId();
  
    // Create a PricebookEntry
    PricebookEntry standardPrice = TestDataFactory.createPricebookEntry(pricebookId, product, 100);

    /**
     * Create 3 orders in Draft status :
     * Account1 ==> order1 + order 2
     * Account2 ==> order3
     * Account3 ==> no order
     */
    Set<Id> orderIds = new Set<Id>();
    Order order1 = TestDataFactory.createOrder(100, account1, pricebookId);
    insert order1;
    Order order2 = TestDataFactory.createOrder(200, account1, pricebookId);
    insert order2;
    Order order3 = TestDataFactory.createOrder(100, account2, pricebookId);
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

    // Update order1 Status to Ordered
    order1.Status = 'Ordered';
    update order1;

    /**
     * Verify CA for each account
     * Account1 ==> order1(Ordered)(5000) + order2(Draft)(7000) ==> CA = 5000
     * Account2 ==> order3(Draft)(3500) ==> CA = 0
     * Account3 ==> no order
     */
    Account account = [SELECT Id, Chiffre_d_affaire__c FROM Account WHERE Id = :account1.Id];
    System.assertEquals(5000, account.Chiffre_d_affaire__c);

    account = [SELECT Id, Chiffre_d_affaire__c FROM Account WHERE Id = :account2.Id];
    System.assertEquals(0, account.Chiffre_d_affaire__c);
    
    account = [SELECT Id, Chiffre_d_affaire__c FROM Account WHERE Id = :account3.Id];
    System.assertEquals(0, account.Chiffre_d_affaire__c);

    // Update order2 Status to Activated
    order2.Status = 'Activated';
    update order2;

    // Update order3 Status to Ordered
    order3.Status = 'Ordered';
    update order3;

    /**
     * Verify CA for each account
     * Account1 ==> order1(Ordered)(5000) + order2(Activated)(7000) ==> CA = 5000
     * Account2 ==> order3(Ordered)(3500) ==> CA = 3500
     * Account3 ==> no order
     */
    account = [SELECT Id, Chiffre_d_affaire__c FROM Account WHERE Id = :account1.Id];
    System.assertEquals(5000, account.Chiffre_d_affaire__c);

    account = [SELECT Id, Chiffre_d_affaire__c FROM Account WHERE Id = :account2.Id];
    System.assertEquals(3500, account.Chiffre_d_affaire__c);
    
    account = [SELECT Id, Chiffre_d_affaire__c FROM Account WHERE Id = :account3.Id];
    System.assertEquals(0, account.Chiffre_d_affaire__c);

    // Update order2 Status to Ordered
    order2.Status = 'Ordered';
    update order2;

    /**
     * Verify CA
     * Account1 ==> order1(Ordered)(5000) + order2(Ordered)(7000) ==> CA = 12000
     */
    account = [SELECT Id, Chiffre_d_affaire__c FROM Account WHERE Id = :account1.Id];
    System.assertEquals(12000, account.Chiffre_d_affaire__c);
  }
}