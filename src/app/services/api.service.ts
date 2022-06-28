import { HttpClient, HttpHeaders } from '@angular/common/http';
import { Injectable } from '@angular/core';
import { catchError, Observable, of, tap } from 'rxjs';
import { LoggingService } from './logging.service';

@Injectable({
  providedIn: 'root'
})
export class ApiService {
  private readonly httpOptions = {
    headers: new HttpHeaders({ 'Content-Type': 'application/json' })
  };

  constructor(private readonly http: HttpClient, private readonly logging: LoggingService) { }

  public get<T>(url: string, upc: string): Observable<T> {
    return this.http.get<T>(`${url}\\${upc}`).pipe(
      tap(value => this.logging.log(`fetched ${value} upc=${upc}`)),
      catchError(this.handleError<T>(`get upc=${upc}`))
    );
  }

  public post<T>(url: string, item: T): Observable<T> {
    console.debug('item: ', item);
    return this.http.post<T>(url, item, this.httpOptions).pipe(
      tap((value: T) => { console.debug('value: ', value); this.logging.log(`added ${value}`); }),
      catchError(this.handleError<T>('added item'))
    );
  }

  handleError<T>(operation = 'operation', result?: T): any {
    return (error: any): Observable<T> => {

      // TODO: send the error to remote logging infrastructure
      // console.error(error); // log to console instead

      // TODO: better job of transforming error for user consumption
      this.logging.log(`${operation} failed: ${error.message}`);

      // Let the app keep running by returning an empty result.
      return of(result as T);
    };
  }
}
