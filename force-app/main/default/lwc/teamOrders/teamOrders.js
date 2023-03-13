import { LightningElement, wire } from 'lwc';
import getTotalCA from '@salesforce/apex/OrderController.getTotalCA';

export default class TeamOrders extends LightningElement {
  data;
  error;
  @wire(getTotalCA) totalCA({data, error}) {
    if (data) {
      this.data = data;
      this.error = undefined;
    } else if (error) {
      this.error = error;
      this.data = undefined;
    }
  };
  valeur = 1000;
}