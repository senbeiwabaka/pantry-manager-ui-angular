import { Product } from "./product";

export interface InventoryItem {
    count: number,
    number_used_in_past_30_days: number,
    on_grocery_list: boolean,
    product: Product
}
