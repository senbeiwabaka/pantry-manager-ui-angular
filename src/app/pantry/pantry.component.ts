import { Component, OnInit } from '@angular/core';
import { ApiService } from '../services/api.service';
import { LoggingService } from '../services/logging.service';
import { InventoryItem } from '../shared/models/inventory-item';

@Component({
  selector: 'app-pantry',
  templateUrl: './pantry.component.html',
  styleUrls: ['./pantry.component.css']
})
export class PantryComponent implements OnInit {

  constructor(private readonly apiService: ApiService, private readonly logging: LoggingService) { }

  ngOnInit(): void {
    this.apiService.get<InventoryItem[]>('http://localhost:8000/pantry-manager/inventory')
      .subscribe({
        next: result => {
          this.logging.log(`get result: ${result}`);
          console.debug('result: ', result);
        }
      });
  }
}
