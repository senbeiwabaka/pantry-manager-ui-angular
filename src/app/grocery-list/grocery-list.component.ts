import { Component, OnInit } from '@angular/core';
import { ApiService } from '../services/api.service';
import { LoggingService } from '../services/logging.service';
import { GroceryListItem } from '../shared/models/grocery-list-item';
import { PagedData } from '../shared/models/paged-data';
import { AdHocInventoryItem } from './models/adhoc-inventory-item';
import { InventoryItem } from '../shared/models/inventory-item';
import { List } from 'linqts';

@Component({
  selector: 'app-grocery-list',
  templateUrl: './grocery-list.component.html',
  styleUrls: ['./grocery-list.component.css']
})
export class GroceryListComponent implements OnInit {
  private itemNames: List<string> = new List<string>();

  public dtOptions: DataTables.Settings = {};
  public adHocInventoryItem: AdHocInventoryItem = { label: "", quantity: 1 };
  public suggestedItems: string[] = [];

  constructor(private readonly apiService: ApiService, private readonly logging: LoggingService) { }

  ngOnInit(): void {
    this.dtOptions = {
      pagingType: 'full_numbers',
      pageLength: 10,
      serverSide: true,
      processing: true,
      searching: false,
      ordering: false,
      responsive: true,
      autoWidth: true,
      language: {
        emptyTable: 'No items in inventory',
      },
      ajax: (_dataTablesParameters: any, callback): void => {
        this.logging.log('data table parameters: ', _dataTablesParameters);


        this.apiService.get<PagedData<GroceryListItem>>('/pantry-manager/groceries')
          .subscribe(response => {
            // this.HasData = response.count > 0;

            callback({
              recordsTotal: response.count,
              recordsFiltered: response.count,
              data: response.data
            });
          });
      },
      columns: [
        {
          data: null,
          render: (data) => {
            console.debug('data: ', data);
            return `<input type='checkbox' id='' />`;
          }
        },
        {
          data: 'label'
        },
        {
          data: 'quantity'
        }
      ]
    };
  }

  public onSubmit(): void {
    if (this.adHocInventoryItem.label === '' || this.adHocInventoryItem.label === undefined || this.adHocInventoryItem.quantity <= 0) {
      return;
    }

    const newInventoryItem: InventoryItem = {
      count: 0,
      product: {
        brand: "",
        category: "",
        image_url: "",
        label: this.adHocInventoryItem.label,
        upc: this.generateUUID()
      },
      // numberUsedInPast30Days: 0,
      // onGroceryList: false
    };

    this.suggestedItems = [];

    this.apiService.post(`/pantry-manager/groceryList/add/${this.adHocInventoryItem.quantity}`, newInventoryItem);

    // const result = await this.http.get<GroceryItem[]>(`${environment.baseServiceUrl}/pantry-manager/groceryList/shopping`).toPromise();

    // this.groceryItems.Clear();
    // this.groceryItems.AddRange(result);

    this.adHocInventoryItem = { label: "", quantity: 1 };
  }

  public onInputSearchTerm(): void {
    this.suggestedItems = [];

    if (this.adHocInventoryItem.label) {
      this.suggestedItems = this.itemNames.Where(x => x != undefined && x.indexOf(this.adHocInventoryItem.label.toLowerCase()) > -1).ToArray();
    }
  }

  // FROM: https://stackoverflow.com/questions/105034/how-to-create-a-guid-uuid
  private generateUUID(): string { // Public Domain/MIT
    let currentTime = new Date().getTime();//Timestamp
    let pageLoadTime = ((typeof performance !== 'undefined') && performance.now && (performance.now() * 1000)) || 0;//Time in microseconds since page-load or 0 if unsupported
    return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function (c) {
      let randomNumber = Math.random() * 16;//random number between 0 and 16
      if (currentTime > 0) {//Use timestamp until depleted
        randomNumber = (currentTime + randomNumber) % 16 | 0;
        currentTime = Math.floor(currentTime / 16);
      } else {//Use microseconds since page-load if supported
        randomNumber = (pageLoadTime + randomNumber) % 16 | 0;
        pageLoadTime = Math.floor(pageLoadTime / 16);
      }
      return (c === 'x' ? randomNumber : (randomNumber & 0x3 | 0x8)).toString(16);
    });
  }
}