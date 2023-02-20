trigger OrderTrigger on Order (before update) {
  OrderTriggerHandler.calculateNetAmount(Trigger.new);
}
