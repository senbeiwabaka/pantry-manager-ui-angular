import { ComponentFixture, TestBed } from '@angular/core/testing';

import { CreateGroceryListComponent } from './create-grocery-list.component';
import { RouterTestingModule } from '@angular/router/testing';
import { ApiService } from '../services/api.service';
import { HttpClientTestingModule } from '@angular/common/http/testing';

describe('CreateGroceryListComponent', () => {
  let apiServiceSpy: jasmine.SpyObj<ApiService>;
  let component: CreateGroceryListComponent;
  let fixture: ComponentFixture<CreateGroceryListComponent>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [HttpClientTestingModule, RouterTestingModule],
      declarations: [CreateGroceryListComponent],
      providers: [
        CreateGroceryListComponent,
        { provide: ApiService, useClass: apiServiceSpy }
      ]
    })
      .compileComponents();

    fixture = TestBed.createComponent(CreateGroceryListComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
