import 'dart:convert';

import 'package:http/http.dart' as http;

import '../interfaces/api_service_interface.dart';
import '../models/brocade_upc_lookup.dart';
import '../models/grocery_list_item.dart';
import '../models/gtin_upc_lookup.dart';
import '../models/inventory_item.dart';
import '../models/product.dart';
import 'database_service.dart';

class DataService implements IApiService {
  final DatabaseService _databaseService;

  DataService(this._databaseService);

  @override
  Future<bool> addProduct(Product product) async {
    return await _databaseService.insertData(product);
  }

  @override
  Future<bool> checkOrAddGroceryItem(InventoryItem inventoryItem) async {
    var groceryListItem = await _databaseService.getData<GroceryListItem>(
        inventoryItem.product.upc) as GroceryListItem?;

    if (groceryListItem == null) {
      groceryListItem = GroceryListItem(
          upc: inventoryItem.product.upc,
          quantity: 0,
          shopped: false,
          standardQuantity: 0,
          count: 0);

      return await _databaseService.insertData(groceryListItem);
    }

    return true;
  }

  @override
  Future<InventoryItem?> getOrAddInventoryItem(Product product) async {
    var inventoryItem = await _databaseService
        .getData<InventoryItem>(product.upc) as InventoryItem?;

    if (inventoryItem == null) {
      inventoryItem = InventoryItem(
          count: 1,
          numberUsedInPast30Days: 0,
          onGroceryList: false,
          product: product);

      if (await _databaseService.insertData(inventoryItem)) {
        return inventoryItem;
      }
    }

    return null;
  }

  @override
  Future<Product?> getProduct(String upc) async {
    return await _databaseService.getData<Product>(upc) as Product?;
  }

  @override
  Future<Product?> lookupProduct(String upc) async {
    final gtinSearchUrl =
        Uri.parse("https://www.gtinsearch.org/api/items/$upc");

    var response = await http.get(gtinSearchUrl);

    if (response.statusCode == 200) {
      var decodedBody = jsonDecode(response.body);

      if (decodedBody is Map<String, dynamic>) {
        final data = GtinUPCLookup.fromJson(decodedBody);

        return Product(upc: data.upc, brand: data.brand, label: data.label);
      }
    }

    final brocadeUrl = Uri.parse("https://www.brocade.io/api/items/$upc");

    response = await http.get(brocadeUrl);

    if (response.statusCode == 200) {
      final data = BrocadeUPCLookup.fromJson(jsonDecode(response.body));

      return Product(upc: data.upc, brand: data.brand, label: data.label);
    }

    return null;
  }

  @override
  Future<bool> updateInventoryItemCount(String upc, int count) async {
    var inventoryItem =
        await _databaseService.getData<InventoryItem>(upc) as InventoryItem;

    inventoryItem = InventoryItem(
        count: inventoryItem.count + count,
        numberUsedInPast30Days: inventoryItem.numberUsedInPast30Days,
        onGroceryList: inventoryItem.onGroceryList,
        product: inventoryItem.product);

    return await _databaseService.updateData(inventoryItem);
  }
}
