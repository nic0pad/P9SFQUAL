import { LightningElement, track, wire } from 'lwc';
import getOrdersByOwner from '@salesforce/apex/OrderService.getOrdersByOwner';

export default class TeamOrdersByOwner extends LightningElement {
  @track listOrdersByOwner = [];
  error = undefined;
  @wire(getOrdersByOwner) ordersByOwner({data, error}) {
    if(data) {
      for(let key in data) {
        if (data.hasOwnProperty(key)) {
          this.listOrdersByOwner.push({key: key, value: data[key]});
        }
      }
    }
    else if(error) {
      this.error = error;
    }
  };
}