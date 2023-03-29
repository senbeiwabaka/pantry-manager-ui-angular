import { AfterViewInit, Component, OnDestroy, OnInit, ViewChild } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { QuaggaJSResultObject } from '@ericblade/quagga2';
import { BarcodeScannerLivestreamComponent } from 'ngx-barcode-scanner';
import { Product } from '../shared/models/product';
import { concatMap, flatMap, iif, map, mergeMap, Observable, of, Subject, Subscriber, takeUntil, tap } from 'rxjs';
import { ApiService } from '../services/api.service';
import { LoggingService } from '../services/logging.service';
import { InventoryItem } from '../shared/models/inventory-item';

@Component({
  selector: 'app-barcode-scanner',
  templateUrl: './barcode-scanner.component.html',
  styleUrls: ['./barcode-scanner.component.css']
})
export class BarcodeScannerComponent implements AfterViewInit, OnDestroy {
  private readonly unsubscribe$ = new Subject<void>();

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
    this.unsubscribe$.next();
    this.unsubscribe$.complete();
  }

  ngAfterViewInit(): void {
    this.barcodeScanner?.start();
  }

  onValueChanges(result: QuaggaJSResultObject): void {
    this.barcode = result.codeResult?.code || '';

    console.debug('on value changes: ', result);

    if (this.detectedValues.has(this.barcode)) {
      const detectedCount = this.detectedValues.get(this.barcode) + 1;

      if (detectedCount > 10) {
        const barcodeValue = this.barcode;
        // After we've detected the same value 10 times we can be certain this is the correct one.
        this.detectedValues = new Map();
        this.barcodeScanner?.stop();

        this.Add();
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

  Add(): void {
    this.barcodeScanner?.stop();

    this.apiService.get<Product>(`/pantry-manager/product/${this.barcode}`)
      .pipe(
        // map(productResult => { console.debug('result: ', productResult); return productResult !== undefined; }),

        concatMap(returnedProduct =>
          iif(
            () => returnedProduct != null, // condition
            this.apiService.get<InventoryItem>(`pantry-manager/inventory/${returnedProduct.upc}`)
              .pipe(
                tap((value) => console.debug('inventory item ', value)),
                concatMap(returnedInventoryItem =>
                  iif(
                    () => returnedInventoryItem != null && returnedInventoryItem != undefined, // condition
                    this.apiService.patchPost(`/pantry-manager/inventory/${returnedProduct.upc}/1`), // trueResult
                    this.apiService.post<InventoryItem, Product>(`/pantry-manager/inventory`, returnedProduct) // falseResult
                  )
                )
              ), // trueResult
            this.apiService.get<Product>(`/pantry-manager/upc-lookup/${this.barcode}`)
              .pipe(
                mergeMap(productResult => this.apiService.post<Product, Product>(`/pantry-manager/product`, productResult))
              )) // falseResult
        ),


        // mergeMap(exists => {
        //   if (exists) {
        //     return of(exists);
        //   } else {
        //     return this.apiService.get<Product>(`/pantry-manager/upc-lookup/${this.barcode}`)
        //       .pipe(
        //         mergeMap(productResult => this.apiService.post<Product, Product>(`/pantry-manager/product`, productResult))
        //       );
        //   }
        // }),

        // map(productResult => { this.product = productResult; return of(productResult) }),

        // mergeMap(() =>
        //   this.apiService.get<Product>(`/pantry-manager/inventory/${this.barcode}`)
        //     .pipe(map(inventoryItem => inventoryItem !== undefined))
        // )
      )
      .subscribe({
        next: (successfulItem) => {
          console.log('subscribe next? ', successfulItem);
          if (successfulItem && successfulItem as InventoryItem) {
            this.product = (successfulItem as InventoryItem).product;

          } else {
            this.product = undefined;
          }
        },
        complete: () => {
          console.log('subscribe complete? ', this.product);

          if (this.product) {
            // this.apiService.get<InventoryItem>(`pantry-manager/inventory/${this.product.upc}`)
            //   .pipe(
            //     tap((value) => this.logging.log('inventory item ', value)),
            //     concatMap(returnedInventoryItem =>
            //       iif(
            //         () => returnedInventoryItem != null, // condition
            //         this.apiService.put<InventoryItem, InventoryItem>(`/pantry-manager/inventory`, { count: 1, product: this.product! }), // trueResult
            //         this.apiService.post<InventoryItem, Product>(`/pantry-manager/inventory`, this.product!) // falseResult
            //       )
            //     )
            //   );
            this.message = `Item ${this.product.brand} added successfully`;
          } else {
            this.message = `Item ${this.barcode} was not added successfully`;
          }

          this.barcodeScanner?.start();
          this.barcode = '';
        },
        error: (error) => {
          console.error(error);
        }
      });
  }
}
