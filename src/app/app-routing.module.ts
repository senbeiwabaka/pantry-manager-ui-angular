import { NgModule } from '@angular/core';
import { RouterModule, Routes } from '@angular/router';
import { BarcodeScannerComponent } from './barcode-scanner/barcode-scanner.component';
import { GroceryListComponent } from './grocery-list/grocery-list.component';
import { PantryComponent } from './pantry/pantry.component';
import { CreateGroceryListComponent } from './create-grocery-list/create-grocery-list.component';

const routes: Routes = [
  { path: 'pantry', component: PantryComponent },
  { path: 'create-grocery-list', component: CreateGroceryListComponent },
  { path: 'grocery-list', component: GroceryListComponent },
  { path: 'barcode-scanner', component: BarcodeScannerComponent },
  { path: '', redirectTo: '/barcode-scanner', pathMatch: 'full' },
  { path: '**', redirectTo: '/barcode-scanner' }
];

@NgModule({
  imports: [RouterModule.forRoot(routes)],
  exports: [RouterModule]
})
export class AppRoutingModule { }
