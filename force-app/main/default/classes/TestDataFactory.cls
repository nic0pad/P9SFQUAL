@IsTest
public class TestDataFactory {
  public static void createOrders(Decimal unitPrice, Decimal shipmentCost) {
    Order order = TestDataFactory.createOrder(unitPrice, shipmentCost);

    List<Order> orders = new List<Order>();
    orders.add(order);
    update orders;
  }

  public static Order createOrder(Decimal unitPrice, Decimal shipmentCost) {
    
    Product2 product = TestDataFactory.createProduct();

    Id pricebookId = Test.getStandardPricebookId();
        
    PricebookEntry standardPrice = TestDataFactory.createPricebookEntry(pricebookId, product, unitPrice);

    Account account = TestDataFactory.createAccount();
    
    Date startDate = System.today().addDays(-1);

    Contract contract = TestDataFactory.createContract(account, startDate);

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

  public static Account createAccount() {
    Account account = new Account(
      Name='TestAccount',
      Industry = 'Banking'
    );
    insert account;

    return account;
  }

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