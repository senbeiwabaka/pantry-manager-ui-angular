import { Component, OnInit } from '@angular/core';
import { ApiService } from '../services/api.service';
import { LoggingService } from '../services/logging.service';
import { InventoryItem } from '../shared/models/inventory-item';
import { PagedDataInventoryItem } from '../shared/models/paged-data';

@Component({
  selector: 'app-pantry',
  templateUrl: './pantry.component.html',
  styleUrls: ['./pantry.component.css']
})
export class PantryComponent implements OnInit {

  dtOptions: DataTables.Settings = {};
  inventoryItems: InventoryItem[] = [];

  constructor(private readonly apiService: ApiService, private readonly logging: LoggingService) { }

  ngOnInit(): void {
    this.dtOptions = {
      pagingType: 'full_numbers',
      pageLength: 10,
      serverSide: true,
      processing: true,
      searching: false,
      ordering: false,
      ajax: (_dataTablesParameters: any, callback): void => {
        this.logging.log('data table parameters: ', _dataTablesParameters);

        this.apiService.get<PagedDataInventoryItem>('/pantry-manager/inventory')
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

    // this.apiService.get<InventoryItem[]>('/pantry-manager/inventory')
    //   .subscribe({
    //     next: result => {
    //       this.logging.log(`get result: ${result}`);
    //       console.debug('result: ', result);

    //       this.inventoryItems = result;
    //     }
    //   });
  }
}
