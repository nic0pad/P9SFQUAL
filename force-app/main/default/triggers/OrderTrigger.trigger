/**
 * Trigger for the object Order
 * 
 * @author Nicolas Padiou
 */
trigger OrderTrigger on Order (before update, after update) {
  if (Trigger.isUpdate) {
    if (Trigger.isBefore) {
      // Calculate the NetAmount field for each order
      OrderTriggerHandler.calculateNetAmount(Trigger.new);
    } else if (Trigger.isAfter) {
      // Update the CA field in Account for each order
      OrderTriggerHandler.updateAccountCA(Trigger.new);
    }
  }
}
