/**
 * Order Controller
 * 
 * @author Nicolas Padiou
 */
public with sharing class OrderController {
  @AuraEnabled(cacheable=true)
  /**
   * Get Total CA of orders
   */
  public static Decimal getTotalCA(){
    try {
      // Calculate CA
      AggregateResult[] result = [SELECT SUM(TotalAmount) totalCA FROM Order WHERE status='Ordered'];
      Decimal totalCA = 0;
      if (!result.isEmpty()) totalCA = (Decimal)result[0].get('totalCA');
      return totalCA;
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }
}