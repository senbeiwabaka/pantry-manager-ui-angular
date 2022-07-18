import { Component, OnInit } from '@angular/core';
import { ApiService } from '../services/api.service';
import { LoggingService } from '../services/logging.service';
import { InventoryItem } from '../shared/models/inventory-item';

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
      ajax: (_dataTablesParameters: any, callback): void => {
        this.apiService.get<InventoryItem[]>('/pantry-manager/inventory')
      .subscribe(resp => {
            this.inventoryItems = resp;

            callback({
              recordsTotal: resp.length,
              recordsFiltered: resp,
              data: []
            });
          });
      },
      columns: [{ data: 'count' }, { data: 'label' }, { data: 'upc' }]
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
