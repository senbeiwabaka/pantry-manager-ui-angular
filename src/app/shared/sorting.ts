export function getNestedProperty(property: string, item: any) {
    let myColumn = property.split('.');
    const nestingLevel = myColumn.length;
    let i = 0;
    let a = item as any;
    while( i < nestingLevel ) { a = a[myColumn[i]]; i++; }
    return a;
  }
  
  export type SortDirection = 'asc' | 'desc' | '';
  
  export interface SortEvent {
    property: string;
    direction: SortDirection;
  }
  
  
  