@IsTest
// Data Factory to create Test object used in Unit Test
public class TestDataFactory {
  /**
   * Create a test object Order
   */
  public static Order createOrder(Decimal unitPrice, Decimal shipmentCost) {
    // Create Product
    Product2 product = TestDataFactory.createProduct();

    // Generate Pricebook Id
    Id pricebookId = Test.getStandardPricebookId();
    
    // Create a PricebookEntry
    PricebookEntry standardPrice = TestDataFactory.createPricebookEntry(pricebookId, product, unitPrice);

    // Create an Account
    Account account = TestDataFactory.createAccount();
    
    Date startDate = System.today().addDays(-1);

    // Create a Contract
    Contract contract = TestDataFactory.createContract(account, startDate);

    // Create a new order
    Order order = new Order(
      ContractId = contract.Id,
      AccountId = account.Id,
      EffectiveDate = startDate,
	    Status = 'Draft',
      PriceBook2Id = pricebookId,
      ShipmentCost__c = shipmentCost
    );
    insert order;

    OrderItem orderItem = new OrderItem(
      OrderId = order.id,
      Quantity = 1,
      UnitPrice = unitPrice,
      Product2id = product.id,
      PricebookEntryId = standardPrice.id
    );
    insert orderItem;
    
    return order;
  }

  // Create a test product
  public static Product2 createProduct() {
    Product2 product = new Product2(
      Name = 'Test Product',
      Description='Test Product',
      productCode = 'ABC',
      isActive = true
    );
    insert product;

    return product;
  }

  // Create a test account
  public static Account createAccount() {
    Account account = new Account(
      Name='TestAccount',
      Industry = 'Banking'
    );
    insert account;

    return account;
  }

  // Create a test contract
  public static Contract createContract(Account account, Date startDate) {
    Contract contract = new Contract(
      AccountId=account.Id,
      Status='Draft',
      StartDate = startDate,
      ContractTerm=10
    );
    insert contract;

    return contract;
  }

  // Create a PricebookEntry test
  public static PricebookEntry createPricebookEntry(Id pricebookId, Product2 product, Decimal unitPrice){
    PricebookEntry standardPrice = new PricebookEntry(
      Pricebook2Id = pricebookId,
      Product2Id = product.Id,
      UnitPrice = unitPrice,
      IsActive = true,
      UseStandardPrice = false
    );
    insert standardPrice ;

    return standardPrice;
  }
}