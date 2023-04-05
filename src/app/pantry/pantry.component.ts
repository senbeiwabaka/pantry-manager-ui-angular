import { Component, OnInit } from '@angular/core';
import { ApiService } from '../services/api.service';
import { LoggingService } from '../services/logging.service';
import { PagedData } from '../shared/models/paged-data';
import { GroceryListItem } from '../shared/models/grocery-list-item';
import * as $ from 'jquery';
import { List } from 'linqts';

@Component({
  selector: 'app-pantry',
  templateUrl: './pantry.component.html',
  styleUrls: ['./pantry.component.css']
})
export class PantryComponent implements OnInit {
  public dtOptions: DataTables.Settings = {};
  public HasData: boolean = false;

  constructor(private readonly apiService: ApiService, private readonly logging: LoggingService) { }

  public async onClickUpdateStandardQuantity(): Promise<void> {
    const itemsToUpdate: List<boolean> = new List<boolean>();
    const quantities = $('.quantity').toArray();
    quantities.forEach(element => {
      const value = $(element).val();
      const upc = $(element).data('upc');

      this.apiService.voidPost(`/pantry-manager/groceries/standard-quantity/${upc}/${value}`)
        .subscribe({ next: () => { }, complete: () => { itemsToUpdate.Add(true); } });
    });

    while (itemsToUpdate.Count() !== quantities.length) {
      await new Promise(f => setTimeout(f, 1000));
    }
    
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
            return `<input type='number' class='quantity' min='0' value='${data.standard_quantity}' data-upc='${data.upc}' />`;
          }
        }
      ]
    };
  }
}
