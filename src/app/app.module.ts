import { NgModule } from '@angular/core';
import { BrowserModule } from '@angular/platform-browser';
import { ReactiveFormsModule } from '@angular/forms';

import { AppRoutingModule } from './app-routing.module';
import { AppComponent } from './app.component';
import { BarcodeScannerComponent } from './barcode-scanner/barcode-scanner.component';
import { BarcodeScannerLivestreamModule } from 'ngx-barcode-scanner';
import { NgbModalModule, NgbNavModule } from '@ng-bootstrap/ng-bootstrap';
import { GroceryListComponent } from './grocery-list/grocery-list.component';
import { HttpClientModule } from '@angular/common/http';
import { PantryComponent } from './pantry/pantry.component';

@NgModule({
  declarations: [
    AppComponent,
    BarcodeScannerComponent,
    GroceryListComponent,
    PantryComponent
  ],
  imports: [
    BrowserModule,
    AppRoutingModule,
    ReactiveFormsModule,
    BarcodeScannerLivestreamModule,
    NgbModalModule,
    NgbNavModule,
    HttpClientModule
  ],
  providers: [],
  bootstrap: [AppComponent]
})
export class AppModule { }
