import { Component, OnInit } from '@angular/core';
import { ApiService } from '../services/api.service';
import { LoggingService } from '../services/logging.service';
import { InventoryItem } from '../shared/models/inventory-item';
import { PagedData } from '../shared/models/paged-data';
import { GroceryListItem } from '../shared/models/grocery-list-item';

@Component({
  selector: 'app-pantry',
  templateUrl: './pantry.component.html',
  styleUrls: ['./pantry.component.css']
})
export class PantryComponent implements OnInit {

  dtOptions: DataTables.Settings = {};

  public HasData: boolean = false;

  constructor(private readonly apiService: ApiService, private readonly logging: LoggingService) { }

  public async onClickUpdateStandardQuantity(): Promise<void> {
    // for (const item of this.pantryItems.ToArray()) {
    //   await this.http.post(`${environment.baseServiceUrl}/pantry-manager/groceryList/standardQuantity/${item.standardQuantity}`, item.inventory).toPromise();
    // }

    window.location.reload();
  }

  public onClickReset(): void {
    window.location.reload();
  }

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
            this.HasData = response.count > 0;

            callback({
              recordsTotal: response.count,
              recordsFiltered: response.count,
              data: response.data
            });
          });
      },
      columns: [
        {
          data: 'count'
        },
        {
          data: 'label'
        },
        {
          data: 'upc'
        },
        {
          data: null,
          render: (data) => {
            console.debug('data: ', data);
            return `<input type='number' id='' min='0' value='0' />`;
          }
        }
      ]
    };
  }
}
