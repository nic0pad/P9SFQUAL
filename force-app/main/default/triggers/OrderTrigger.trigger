/**
 * Trigger for the object Order
 * 
 * @author Nicolas Padiou
 */
trigger OrderTrigger on Order (before update, after update) {
  // calculate Net Amount for each order
  if (Trigger.isUpdate && Trigger.isBefore) {
    OrderService.calculateNetAmount(Trigger.new);
  }

  // update account CA for each order
  if (Trigger.isUpdate && Trigger.isAfter) {
    OrderService.updateCA(Trigger.new);
  }
}
