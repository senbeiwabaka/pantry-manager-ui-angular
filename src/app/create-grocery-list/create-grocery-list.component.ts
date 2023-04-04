import { Component, OnInit, QueryList, ViewChildren } from '@angular/core';
import { Router } from '@angular/router';
import { ApiService } from '../services/api.service';
import { GroceryListItem } from '../shared/models/grocery-list-item';
import { PagedData } from '../shared/models/paged-data';
import { List } from 'linqts';
import { SortableHeaderDirective } from '../shared/sortable-header.directive';
import { SortEvent, getNestedProperty } from '../shared/sorting';

@Component({
  selector: 'app-create-grocery-list',
  templateUrl: './create-grocery-list.component.html',
  styleUrls: ['./create-grocery-list.component.css']
})
export class CreateGroceryListComponent implements OnInit {
  private readonly wantedItemsToQuantity: Map<string, number> = new Map<string, number>();

  public groceryItems: List<GroceryListItem> = new List<GroceryListItem>();

  @ViewChildren(SortableHeaderDirective)
  headers: QueryList<SortableHeaderDirective> | undefined;

  constructor(private readonly router: Router, private readonly apiService: ApiService) { }

  ngOnInit(): void {
    this.apiService.get<PagedData<GroceryListItem>>('/pantry-manager/groceries')
      .subscribe(response => {
        console.debug('response: ', response);
        this.groceryItems.AddRange(response.data);
      });
  }

  public increaseQuantity(id: string): void {
    const groceryItem: GroceryListItem = this.groceryItems.Single(groceryItem => groceryItem?.upc === id);

    if (groceryItem) {
      groceryItem.quantity++;

      const upc: string = groceryItem.upc;

      if (this.wantedItemsToQuantity.get(upc)) {
        let quantity: number = this.wantedItemsToQuantity.get(upc) || 0;

        quantity++;

        this.wantedItemsToQuantity.set(upc, quantity);
      }
      else {
        this.wantedItemsToQuantity.set(upc, 1);
      }
    }
  }

  public decreaseQuantity(id: string): void {
    const groceryItem: GroceryListItem = this.groceryItems.Single(groceryItem => groceryItem?.upc === id);

    if (groceryItem) {
      // If there wasn't any quantity already selected then don't do anything
      if (groceryItem.quantity === 0) {
        return;
      }

      groceryItem.quantity--;

      // If the quantity has now become less than zero then reset it to zero (probably not needed now)
      if (groceryItem.quantity <= 0) {
        groceryItem.quantity = 0;
      }

      const upc: string = groceryItem.upc;

      if (this.wantedItemsToQuantity.get(upc)) {
        let quantity: number = this.wantedItemsToQuantity.get(upc) || 0;

        quantity--;

        this.wantedItemsToQuantity.set(upc, quantity);
      }
      else {
        this.wantedItemsToQuantity.set(upc, -1);
      }
    }
  }

  public async doGroceryShopping() {
    const iterator = this.wantedItemsToQuantity[Symbol.iterator]();

    for (const item of iterator) {
      const key: string = item[0];
      const value: number = item[1];
      const groceryItem: GroceryListItem = this.groceryItems.Single(x => x?.upc === key);

      // if (value > 0) {
      //   await this.apiService.post(`${environment.baseServiceUrl}/pantry-manager/groceryList/add/${value}`, groceryItem.inventoryItem).toPromise();
      // }

      // if (value < 0) {
      //   await this.http.post(`${environment.baseServiceUrl}/pantry-manager/groceryList/remove/${(value * -1)}`, groceryItem.inventoryItem).toPromise();
      // }
    }

    this.router.navigateByUrl("/grocery-list");
  }

  sortOn($event: SortEvent) {
    this.headers?.forEach(header => {
      if (header.sortable !== $event.property) {
        header.direction = '';
      }
    });

    const keySelector = (item: GroceryListItem) => {
      return getNestedProperty($event.property, item);
    }

    if ($event.direction === 'asc') {
      this.groceryItems.OrderBy(keySelector);
    }
    else {
      this.groceryItems.OrderByDescending(keySelector);
    }
  }
}
