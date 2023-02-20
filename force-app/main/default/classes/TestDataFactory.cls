@IsTest
public class TestDataFactory {
  public static void createTestRecords(Decimal shipmentCost) {

    Product2 product = new Product2(
      Name = 'Test Product',
      Description='Test Product',
      productCode = 'ABC',
      isActive = true
    );
    insert product;

    Id pricebookId = Test.getStandardPricebookId();
        
    PricebookEntry standardPrice = new PricebookEntry(
      Pricebook2Id = pricebookId,
      Product2Id = product.Id,
      UnitPrice = 1000,
      IsActive = true,
      UseStandardPrice = false
    );
    insert standardPrice ;

    Account account = new Account(
      Name='TestAccount',
      Industry = 'Banking'
    );
    insert account;
    Date startDate = System.today().addDays(-1);
    Contract contract = new Contract(
      AccountId=account.Id,
      Status='Draft',
      StartDate = startDate,
      ContractTerm=10
    );
    insert contract;

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
      UnitPrice = 1000,
      Product2id = product.id,
      PricebookEntryId = standardPrice.id
    );
    insert orderItem;

    List<Order> orders = new List<Order>();
    orders.add(order);
    update orders;
  }
}