import { AfterViewInit, Component, OnDestroy, OnInit, ViewChild } from '@angular/core';
import { ApiService } from '../services/api.service';
import { LoggingService } from '../services/logging.service';
import { GroceryListItem } from '../shared/models/grocery-list-item';
import { PagedData } from '../shared/models/paged-data';
import { InventoryItem } from '../shared/models/inventory-item';
import { List } from 'linqts';
import { Router } from '@angular/router';
import { FormControl, FormGroup, Validators } from '@angular/forms';
import { DataTableDirective } from 'angular-datatables';
import { Subject } from 'rxjs';
import { LoggingType } from '../shared/models/logging-type';

@Component({
  selector: 'app-grocery-list',
  templateUrl: './grocery-list.component.html',
  styleUrls: ['./grocery-list.component.css']
})
export class GroceryListComponent implements AfterViewInit, OnDestroy, OnInit {
  private itemNames: List<string> = new List<string>();

  @ViewChild(DataTableDirective, { static: false })
  datatableElement: DataTableDirective | null = null;

  dtOptions: DataTables.Settings = {};

  dtTrigger: Subject<any> = new Subject();

  public suggestedItems: string[] = [];

  public adHocItemForm = new FormGroup({
    label: new FormControl<string>('', [Validators.required]),
    quantity: new FormControl<number>(1, [Validators.required, Validators.min(1)]),
  });

  constructor(
    private readonly apiService: ApiService,
    private readonly logging: LoggingService,
    private readonly router: Router) { }

  ngAfterViewInit(): void {
    // this.drawTable();
  }

  ngOnDestroy(): void {
    this.dtTrigger.unsubscribe();
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
        this.logging.log('data table parameters: ', LoggingType.Debug, _dataTablesParameters);

        this.apiService.get<PagedData<GroceryListItem>>(`/pantry-manager/groceries/shopping-list?length=${_dataTablesParameters.length}&page=${_dataTablesParameters.start}`)
          .subscribe(response => {
            response.data.forEach(result => {
              this.itemNames.Add(result.label.toLocaleLowerCase());
            })

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

  public async onSubmit(): Promise<void> {
    if (this.adHocItemForm.value.label === '' || this.adHocItemForm.value.label === null || this.adHocItemForm.value.quantity === null || this.adHocItemForm.value.quantity! <= 0) {
      return;
    }

    const newInventoryItem: InventoryItem = {
      count: 0,
      product: {
        brand: "",
        category: "",
        image_url: "",
        label: this.adHocItemForm.value.label!,
        upc: this.generateUUID()
      },
      number_used_in_past_30_days: 0,
      on_grocery_list: true
    };

    this.suggestedItems = [];

    let itemToUpdate: boolean = false;

    this.apiService.post<GroceryListItem, InventoryItem>(`/pantry-manager/groceries/add-adhoc/${this.adHocItemForm.value.quantity}`, newInventoryItem)
      .subscribe({ next: () => { }, complete: () => { itemToUpdate = true; } });

    // const result = await this.http.get<GroceryItem[]>(`${environment.baseServiceUrl}/pantry-manager/groceryList/shopping`).toPromise();

    // this.groceryItems.Clear();
    // this.groceryItems.AddRange(result);

    while (!itemToUpdate) {
      await new Promise(f => setTimeout(f, 1000));
    }

    this.drawTable();

    this.adHocItemForm.reset();
    this.adHocItemForm.controls.quantity.setValue(1);
  }

  public onInputSearchTerm(): void {
    this.logging.log('onInputSearchTerm: ');

    this.suggestedItems = [];

    if (this.adHocItemForm.value.label) {
      this.suggestedItems = this.itemNames.Where(x => x != undefined && x.indexOf(this.adHocItemForm.value.label!.toLowerCase()) > -1).ToArray();
    }
  }

  public shoppingDone(): void {
    this.apiService.voidPost(`/pantry-manager/groceries/shopping/done`).subscribe();
    this.router.navigate(['/scan']);
  }

  get name() { return this.adHocItemForm.get('label'); }

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

  private drawTable(): void {
    this.logging.log('drawTable: ');

    if (this.datatableElement?.dtInstance) {
      this.datatableElement.dtInstance.then((dtInstance: DataTables.Api) => {
        dtInstance.ajax.reload();

        this.dtTrigger.next(null);
      });
    }
  }
}