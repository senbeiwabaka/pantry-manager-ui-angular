import { AfterViewInit, Component, OnDestroy, OnInit, ViewChild } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { QuaggaJSResultObject } from '@ericblade/quagga2';
import { BarcodeScannerLivestreamComponent } from 'ngx-barcode-scanner';
import { Product } from '../shared/models/product';
import { Subject, takeUntil } from 'rxjs';
import { ApiService } from '../services/api.service';
import { LoggingService } from '../services/logging.service';

@Component({
  selector: 'app-barcode-scanner',
  templateUrl: './barcode-scanner.component.html',
  styleUrls: ['./barcode-scanner.component.css']
})
export class BarcodeScannerComponent implements AfterViewInit, OnDestroy {
  private readonly unsubscribe$ = new Subject<void>();

  private barcode: string = '';

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

    if (this.product?.upc === '' || this.product?.upc != this.barcode) {
      this.barcodeScanner?.stop();

      this.apiService.get<Product>(`http://localhost:8000/pantry-manager/upc-lookup\\${this.barcode}`)
        .subscribe({
          next: result => {
            console.debug('result: ', result);

            if (result) {
              this.product = result as Product;

              console.debug('Product after: ', this.product);

              this.apiService.post<Product>(`http://localhost:8000/pantry-manager/product`, this.product)
                .subscribe({
                  next: postResult => {
                    this.logging.log(`post result: ${postResult}`);
                  }
                });
            }
            else {
              this.message = 'Product not found';
            }

            setTimeout(() => {
              this.message = '';
              this.barcodeScanner?.start();
              this.product = undefined;
            }, 3000);
          }
        });
    }
  }
}
