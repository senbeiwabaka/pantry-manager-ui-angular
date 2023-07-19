import { Injectable, NgModule } from '@angular/core';
import { RouterModule, RouterStateSnapshot, Routes, TitleStrategy } from '@angular/router';
import { BarcodeScannerComponent } from './barcode-scanner/barcode-scanner.component';
import { GroceryListComponent } from './grocery-list/grocery-list.component';
import { PantryComponent } from './pantry/pantry.component';
import { CreateGroceryListComponent } from './create-grocery-list/create-grocery-list.component';
import { Title } from '@angular/platform-browser';

const routes: Routes = [
  { path: 'pantry', component: PantryComponent, title: 'Pantry' },
  { path: 'create-grocery-list', component: CreateGroceryListComponent, title: 'Create grocery list' },
  { path: 'grocery-list', component: GroceryListComponent, title: 'Grocery list' },
  { path: 'barcode-scanner', component: BarcodeScannerComponent, title: 'Scan items' },
  { path: '', redirectTo: '/barcode-scanner', pathMatch: 'full' },
  { path: '**', redirectTo: '/barcode-scanner' }
];

@Injectable({ providedIn: 'root' })
export class TemplatePageTitleStrategy extends TitleStrategy {
  constructor(private readonly title: Title) {
    super();
  }

  override updateTitle(routerState: RouterStateSnapshot) {
    const title = this.buildTitle(routerState);
    if (title !== undefined) {
      this.title.setTitle(`Pantry Manager | ${title}`);
    }
  }
}

@NgModule({
  imports: [RouterModule.forRoot(routes)],
  exports: [RouterModule],
  providers: [
    { provide: TitleStrategy, useClass: TemplatePageTitleStrategy },
  ]
})
export class AppRoutingModule { }
