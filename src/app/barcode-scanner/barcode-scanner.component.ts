import { AfterViewInit, Component, OnInit, ViewChild } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { QuaggaJSResultObject } from '@ericblade/quagga2';
import { BarcodeScannerLivestreamComponent } from 'ngx-barcode-scanner';
import { Product } from '../shared/models/product';

@Component({
  selector: 'app-barcode-scanner',
  templateUrl: './barcode-scanner.component.html',
  styleUrls: ['./barcode-scanner.component.css']
})
export class BarcodeScannerComponent implements AfterViewInit {
  @ViewChild(BarcodeScannerLivestreamComponent)
  public barcodeScanner: BarcodeScannerLivestreamComponent | undefined;

  public barcode: string = '';
  public product: Product = { brand: '', category: '', image_url: 'https://upload.wikimedia.org/wikipedia/commons/thumb/d/db/Tse_logo.jpg/320px-Tse_logo.jpg', label: '', upc: '' };

  /**
   *
   */
  constructor(private httpClient: HttpClient) {

  }

  ngAfterViewInit(): void {
    this.barcodeScanner?.start();
  }

  onValueChanges(result: QuaggaJSResultObject): void {
    console.debug('result: ', result);
    this.barcode = result.codeResult?.code || '';
    console.debug('Product before: ', this.product);

    // this.httpClient.get<Product>(`http://infrastructure-pi-2.home.arpa:5000/pantry-manager/upc-lookup/${this.barcode}`).toPromise().then((result) => {
    //   console.debug('result: ', result);

    //   if (result) {
    //     this.product = result;

    //     console.debug('Product after: ', this.product);
    //   }
    // });

    if (this.product.upc === '' || this.product.upc != this.barcode) {
      this.barcodeScanner?.stop();
      this.httpClient.get<Product>(`http://localhost:8000/pantry-manager/upc-lookup/${this.barcode}`).toPromise().then((result) => {
        console.debug('result: ', result);

        if (result) {
          this.product = result as Product;

          console.debug('Product after: ', this.product);
        }
      });
    }
  }

  onStarted(started: any): void {
    console.debug(`started ${started}`);
  }

}
