import { HttpClient, HttpHeaders } from '@angular/common/http';
import { Injectable } from '@angular/core';
import { catchError, Observable, of, tap } from 'rxjs';
import { LoggingService } from './logging.service';

@Injectable({
  providedIn: 'root'
})
export class ApiService {
  private readonly httpOptions = {
    headers: new HttpHeaders({ 'Content-Type': 'application/json', 'accept': 'application/json' })
  };

  constructor(private readonly http: HttpClient, private readonly logging: LoggingService) { }

  public get<T>(url: string): Observable<T> {
    this.logging.log('logging::get url: ', url);

    return this.http.get<T>(url).pipe(
      tap(value => console.debug('fetched ', value)),
      catchError(this.handleError<T>(`GET '${url}'`))
    );
  }

  public post<T, V>(url: string, item: V): Observable<T> {
    this.logging.log('logging::post url: ', url);
    this.logging.log('logging::post item: ', item);

    return this.http.post<T>(url, item, this.httpOptions).pipe(
      tap((value: T) => console.debug('added ', value)),
      catchError(this.handleError<T>(`POST '${url}'`))
    );
  }

  public put<T, V>(url: string, item: V): Observable<T> {
    this.logging.log('logging::put url: ', url);
    this.logging.log('logging::put item: ', item);

    return this.http.put<T>(url, item, this.httpOptions).pipe(
      tap((value: T) => console.debug('updated ', value)),
      catchError(this.handleError<T>(`PUT '${url}'`))
    );
  }

  handleError<T>(operation = 'operation', result?: T): any {
    return (error: any): Observable<T> => {

      // TODO: better job of transforming error for user consumption
      this.logging.log(`logging::${operation} failed: ${error.message}`);

      // Let the app keep running by returning an empty result.
      const failedResult = of(result as T);

      this.logging.log('logging::result: ', result);
      this.logging.log('logging::failedResult: ', failedResult);

      return failedResult;
    };
  }
}
