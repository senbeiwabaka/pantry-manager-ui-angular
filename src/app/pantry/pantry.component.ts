import { Component, OnInit } from '@angular/core';
import { ApiService } from '../services/api.service';
import { LoggingService } from '../services/logging.service';
import { InventoryItem } from '../shared/models/inventory-item';
import { PagedData } from '../shared/models/paged-data';

@Component({
  selector: 'app-pantry',
  templateUrl: './pantry.component.html',
  styleUrls: ['./pantry.component.css']
})
export class PantryComponent implements OnInit {

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
        emptyTable: 'No items in inventory',
      },
      ajax: (_dataTablesParameters: any, callback): void => {
        this.logging.log('data table parameters: ', _dataTablesParameters);

        this.apiService.get<PagedData<InventoryItem>>('/pantry-manager/inventory')
          .subscribe(response => {
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
          data: 'product.label'
        },
        {
          data: 'product.upc'
        }]
    };
  }
}
