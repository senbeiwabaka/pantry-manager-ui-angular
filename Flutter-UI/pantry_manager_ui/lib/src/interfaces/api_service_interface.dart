import '../models/inventory_item.dart';
import '../models/product.dart';

abstract class IApiService {
  Future<Product?> getProduct(String upc);

  Future<Product?> lookupProduct(String upc);

  Future<bool> addProduct(Product product);

  Future<InventoryItem?> getOrAddInventoryItem(Product product);

  Future<bool> checkOrAddGroceryItem(InventoryItem inventoryItem);

  Future<bool> updateInventoryItemCount(String upc, int count);
}
