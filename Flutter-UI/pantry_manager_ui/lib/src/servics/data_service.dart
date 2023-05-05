import 'package:qinject/qinject.dart';

import '../interfaces/api_service_interface.dart';
import '../models/inventory_item.dart';
import '../models/product.dart';

class DataService implements IApiService {
  DataService(Qinjector qinjector);

  @override
  Future<bool> addProduct(Product product) {
    // TODO: implement addProduct
    throw UnimplementedError();
  }

  @override
  Future<bool> checkOrAddGroceryItem(InventoryItem inventoryItem) {
    // TODO: implement checkOrAddGroceryItem
    throw UnimplementedError();
  }

  @override
  Future<InventoryItem?> getOrAddInventoryItem(Product product) {
    // TODO: implement getOrAddInventoryItem
    throw UnimplementedError();
  }

  @override
  Future<Product?> getProduct(String upc) {
    // TODO: implement getProduct
    throw UnimplementedError();
  }

  @override
  Future<Product?> lookupProduct(String upc) {
    // TODO: implement lookupProduct
    throw UnimplementedError();
  }

  @override
  Future<bool> updateInventoryItemCount(String upc, int count) {
    // TODO: implement updateInventoryItemCount
    throw UnimplementedError();
  }
}
