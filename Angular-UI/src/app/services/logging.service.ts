import { Injectable } from '@angular/core';
import { LoggingType } from '../shared/models/logging-type';

@Injectable({
  providedIn: 'root'
})
export class LoggingService {
  public log(message: string, loggingType: LoggingType = LoggingType.Debug, ...params: any[]): void {

    switch (loggingType) {
      case LoggingType.Debug:
        console.debug(message, params);
        break;

      case LoggingType.Info:
        console.info(message, params);
        break;

      case LoggingType.Warning:
      case LoggingType.Error:
      default:
        console.log(message, params);
    }
  }
}
