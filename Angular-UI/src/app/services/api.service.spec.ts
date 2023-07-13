import { HttpClientTestingModule, HttpTestingController } from '@angular/common/http/testing';

import { TestBed } from '@angular/core/testing';

import { ApiService } from './api.service';
import { HttpClient } from '@angular/common/http';

describe('ApiService', () => {
  let httpClient: HttpClient;
  let httpTestingController: HttpTestingController;
  let service: ApiService;

  beforeEach(() => {
    TestBed.configureTestingModule({
      imports: [HttpClientTestingModule]
    });

    httpClient = TestBed.inject(HttpClient);
    httpTestingController = TestBed.inject(HttpTestingController);
    service = TestBed.inject(ApiService);
  });

  it('should be created', () => {
    expect(service).toBeTruthy();
  });
});
