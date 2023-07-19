import { ComponentFixture, TestBed } from '@angular/core/testing';

import { BarcodeScannerComponent } from './barcode-scanner.component';
import { HttpClientTestingModule } from '@angular/common/http/testing';
import { RouterTestingModule } from '@angular/router/testing';
import { ApiService } from '../services/api.service';

describe('BarcodeScannerComponent', () => {
  let apiServiceSpy: jasmine.SpyObj<ApiService>;
  let component: BarcodeScannerComponent;
  let fixture: ComponentFixture<BarcodeScannerComponent>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [HttpClientTestingModule, RouterTestingModule],
      declarations: [BarcodeScannerComponent],
      providers: [
        BarcodeScannerComponent,
        { provide: ApiService, useClass: apiServiceSpy }
      ]
    })
      .compileComponents();

    fixture = TestBed.createComponent(BarcodeScannerComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
