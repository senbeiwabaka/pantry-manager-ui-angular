import { Component, OnInit } from '@angular/core';
import { ApiService } from '../services/api.service';
import { LoggingService } from '../services/logging.service';
import { GroceryListItem } from '../shared/models/grocery-list-item';
import { PagedData } from '../shared/models/paged-data';

@Component({
  selector: 'app-grocery-list',
  templateUrl: './grocery-list.component.html',
  styleUrls: ['./grocery-list.component.css']
})
export class GroceryListComponent implements OnInit {

  dtOptions: DataTables.Settings = {};

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
        emptyTable: 'No items in grocery list',
      },
      ajax: (_dataTablesParameters: any, callback): void => {
        this.logging.log('data table parameters: ', _dataTablesParameters);

        this.apiService.get<PagedData<InventoryItem>>('/pantry-manager/groceries')
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
          data: null,
          render: (data) => {
            return '<input type="checkbox" />'
          }
        },
        {
          data: 'inventory.product.label'
        },
        {
          data: 'quantity'
        }]
    };
  }

}
