import { InventoryItem } from "./inventory-item";

export interface GroceryListItem {
    quantity: number,
    shopped: boolean,
    standard_quantity: number,
    inventory_item: InventoryItem | null
}