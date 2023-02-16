trigger OrderTrigger on Order (before update) {
    for(Order o : Trigger.new) {
      Decimal cost = 0;
      if (o.ShipmentCost__c != null) cost = o.ShipmentCost__c;
      o.NetAmount__c = o.TotalAmount - cost;
    }
}