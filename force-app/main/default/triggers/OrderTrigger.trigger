/**
 * Trigger for the object Order
 * 
 * @author Nicolas Padiou
 */
trigger OrderTrigger on Order (before update, after update) {
  if (Trigger.isUpdate) {
    if (Trigger.isBefore) {
      // Calculate the NetAmount field for each order
      for (Order o : Trigger.new) {
        OrderService.calculateNetAmount(o);
      }
    }
    else if (Trigger.isAfter) {
      // set list of Order Id to update
      Set<Id> orderIds = new Set<Id>();
      for (Order o : Trigger.new) {
        orderIds.add(o.Id);
      }
      
      // get accounts with ordered order
      Set<Id> accountIds = OrderService.getAccountIdsWithOrderedOrder(orderIds);

      // update CA field for each account
      AccountService.updateCA(accountIds);
    }
  }
}
