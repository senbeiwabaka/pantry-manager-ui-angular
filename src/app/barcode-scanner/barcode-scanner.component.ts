import { AfterViewInit, Component, OnDestroy, ViewChild } from '@angular/core';
import { QuaggaJSResultObject } from '@ericblade/quagga2';
import { BarcodeScannerLivestreamComponent } from 'ngx-barcode-scanner';
import { Product } from '../shared/models/product';
import { concatMap, iif, mergeMap, of } from 'rxjs';
import { ApiService } from '../services/api.service';
import { LoggingService } from '../services/logging.service';
import { InventoryItem } from '../shared/models/inventory-item';
import { GroceryListItem } from '../shared/models/grocery-list-item';

@Component({
  selector: 'app-barcode-scanner',
  templateUrl: './barcode-scanner.component.html',
  styleUrls: ['./barcode-scanner.component.css']
})
export class BarcodeScannerComponent implements AfterViewInit, OnDestroy {
  private barcode: string = '';
  private detectedValues = new Map();

  @ViewChild(BarcodeScannerLivestreamComponent)
  public barcodeScanner: BarcodeScannerLivestreamComponent | undefined;

  public product: Product | undefined = undefined;
  public message: string = '';
  public isAdding: boolean = true;

  /**
   *
   */
  constructor(private readonly apiService: ApiService, private readonly logging: LoggingService) {
  }

  ngOnDestroy(): void {
    this.barcodeScanner?.stop();
  }

  ngAfterViewInit(): void {
    this.barcodeScanner?.start();
  }

  onValueChanges(result: QuaggaJSResultObject): void {
    this.barcode = result.codeResult?.code || '';

    if (this.detectedValues.has(this.barcode)) {
      const detectedCount = this.detectedValues.get(this.barcode) + 1;

      if (detectedCount > 10) {
        // After we've detected the same value 10 times we can be certain this is the correct one.
        this.detectedValues = new Map();
        this.barcodeScanner?.stop();

        this.product = undefined;
        this.message = 'Adding item...';

        this.add();
      }
      else {
        this.detectedValues.set(this.barcode, detectedCount);
      }
    }
    else {
      this.detectedValues.set(this.barcode, 1);
    }


    if (this.product?.upc === '' || this.product?.upc != this.barcode) {

    }
  }

  add(): void {
    this.barcodeScanner?.stop();

    var inventoryItem: InventoryItem | undefined = undefined;
    var groceryListItem: GroceryListItem | undefined = undefined;

    this.apiService.get<Product | undefined>(`/pantry-manager/product/${this.barcode}`)
      .pipe(
        concatMap(returnedProduct =>
          iif(
            () => this.productCheckState(returnedProduct),
            of(returnedProduct), // product exists so return it
            this.apiService.get<Product>(`/pantry-manager/upc-lookup/${this.barcode}`)
              .pipe(
                mergeMap(productResult => this.apiService.post<Product, Product>(`/pantry-manager/product`, productResult))
              )
          ) // product didn't exist so added it
        ),
      )
      .subscribe({
        next: (successfulItem) => {
          if (successfulItem) {
            this.product = successfulItem;
          } else {
            this.product = undefined;
          }
        },
        complete: () => {
          if (this.product) {

            this.apiService.get<InventoryItem>(`pantry-manager/inventory/${this.product!.upc}`)
              .pipe(
                concatMap(returnedInventoryItem =>
                  iif(
                    () => returnedInventoryItem !== undefined,
                    this.apiService.post<InventoryItem, Product>(`/pantry-manager/inventory/${this.product!.upc}/1`, this.product!), // inventory item existed so quantity was incremented
                    this.apiService.post<InventoryItem, Product>(`/pantry-manager/inventory`, this.product!) // inventory item did not exist so we added with a count of 1
                  )
                )
              )
              .subscribe({
                next: (returnedInventoryItem) => {
                  inventoryItem = returnedInventoryItem;
                },
                complete: () => {
                  console.debug('inventory item: ', inventoryItem);
                  if (inventoryItem) {
                    this.apiService.get<GroceryListItem>(`/pantry-manager/groceries/${this.product!.upc}`)
                      .pipe(
                        concatMap(returnedGroceryListItem =>
                          iif(
                            () => returnedGroceryListItem !== undefined,
                            of(returnedGroceryListItem), // grocery list item existed
                            this.apiService.post<GroceryListItem, InventoryItem>(`/pantry-manager/groceries`, inventoryItem!) // grocery list item did not exist so we added it
                          ))
                      )
                      .subscribe({
                        next: (returnedGroceryListItem) => {
                          console.debug('grocery item: ', returnedGroceryListItem);

                          groceryListItem = returnedGroceryListItem;
                        },
                        complete: () => {
                          console.debug('grocery item: ', groceryListItem);
                          if (groceryListItem) {
                            this.message = `Item ${this.product!.brand} added successfully`;

                            this.barcodeScanner?.start();
                            this.barcode = '';
                          }
                        }
                      });
                  }
                }
              });
          } else {
            this.message = `Item ${this.barcode} was not added successfully`;

            this.barcodeScanner?.start();
            this.barcode = '';
          }
        },
        error: (error) => {
          console.error(error);

          this.message = `Item ${this.barcode} was not added successfully`;
          this.barcodeScanner?.start();
          this.barcode = '';
        }
      });
  }

  productCheckState(product: Product | undefined): boolean {
    return product !== undefined && product !== null;
  }
}
