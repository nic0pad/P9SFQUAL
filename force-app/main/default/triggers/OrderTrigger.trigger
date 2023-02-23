trigger OrderTrigger on Order (before update) {
  // Calculate the NetAmount field for each order
  OrderTriggerHandler.calculateNetAmount(Trigger.new);
}
