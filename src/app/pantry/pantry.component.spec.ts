import { ComponentFixture, TestBed } from '@angular/core/testing';
import { PantryComponent } from './pantry.component';
import { ApiService } from '../services/api.service';
import { HttpClient } from '@angular/common/http';
import { HttpClientTestingModule, HttpTestingController } from '@angular/common/http/testing';

describe('PantryComponent', () => {
  let httpClient: HttpClient;
  let httpTestingController: HttpTestingController;
  let apiServiceSpy: jasmine.SpyObj<ApiService>;
  let component: PantryComponent;
  let fixture: ComponentFixture<PantryComponent>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [HttpClientTestingModule],
      declarations: [PantryComponent],
      providers: [
        PantryComponent,
        { provide: ApiService, useClass: apiServiceSpy }
      ]
    })
      .compileComponents();

    httpClient = TestBed.inject(HttpClient);
    httpTestingController = TestBed.inject(HttpTestingController);
    fixture = TestBed.createComponent(PantryComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
