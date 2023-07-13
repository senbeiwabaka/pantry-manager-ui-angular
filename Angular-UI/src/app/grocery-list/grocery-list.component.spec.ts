import { HttpClientTestingModule, HttpTestingController } from "@angular/common/http/testing";
import { ComponentFixture, TestBed } from "@angular/core/testing";
import { ApiService } from "../services/api.service";
import { GroceryListComponent } from "./grocery-list.component";
import { HttpClient } from "@angular/common/http";
import { RouterTestingModule } from "@angular/router/testing";

describe('GroceryListComponent', () => {
  let httpClient: HttpClient;
  let httpTestingController: HttpTestingController;
  let apiServiceSpy: jasmine.SpyObj<ApiService>;
  let component: GroceryListComponent;
  let fixture: ComponentFixture<GroceryListComponent>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [HttpClientTestingModule, RouterTestingModule],
      declarations: [GroceryListComponent],
      providers: [
        GroceryListComponent,
        { provide: ApiService, useClass: apiServiceSpy }
      ]
    })
      .compileComponents();

    httpClient = TestBed.inject(HttpClient);
    httpTestingController = TestBed.inject(HttpTestingController);
    fixture = TestBed.createComponent(GroceryListComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
