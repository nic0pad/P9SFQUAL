import { LightningElement, wire } from 'lwc';
import getTotalCA from '@salesforce/apex/OrderService.getTotalCA';

export default class TeamOrders extends LightningElement {
  totalCA;
  error;

  @wire(getTotalCA) totalCA({data, error}) {
    if (data) {
      this.totalCA = data;
      this.error = undefined;
    } else if (error) {
      this.error = error;
      this.totalCA = undefined;
    }
  };
}