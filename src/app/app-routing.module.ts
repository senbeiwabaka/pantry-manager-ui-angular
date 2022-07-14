import { NgModule } from '@angular/core';
import { RouterModule, Routes } from '@angular/router';
import { BarcodeScannerComponent } from './barcode-scanner/barcode-scanner.component';
import { GroceryListComponent } from './grocery-list/grocery-list.component';
import { PantryComponent } from './pantry/pantry.component';

const routes: Routes = [
  { path: 'grocery-list', component: GroceryListComponent },
  { path: 'pantry', component: PantryComponent },
  { path: 'barcode-scanner', component: BarcodeScannerComponent },
  { path: '', redirectTo: '/barcode-scanner', pathMatch: 'full' }
];

@NgModule({
  imports: [RouterModule.forRoot(routes)],
  exports: [RouterModule]
})
export class AppRoutingModule { }
