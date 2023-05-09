import 'dart:convert';

import 'package:http/http.dart' as http;

import '../interfaces/api_service_interface.dart';
import '../models/brocade_upc_lookup.dart';
import '../models/gtin_upc_lookup.dart';
import '../models/inventory_item.dart';
import '../models/product.dart';
import 'database_service.dart';

class DataService implements IApiService {
  final DatabaseService _databaseService;

  DataService(this._databaseService);

  @override
  Future<bool> addProduct(Product product) async {
    await _databaseService.insertData(product);

    return true;
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
  Future<Product?> getProduct(String upc) async {
    var product = await _databaseService.getData<Product>(upc);

    return product;
  }

  @override
  Future<Product?> lookupProduct(String upc) async {
    var gtinSearchUrl = Uri.parse("https://www.gtinsearch.org/api/items/$upc");

    var response = await http.get(gtinSearchUrl);

    if (response.statusCode == 200) {
      var decodedBody = jsonDecode(response.body);

      if (decodedBody is Map<String, dynamic>) {
        var data = GtinUPCLookup.fromJson(decodedBody);

        return Product(upc: data.upc, brand: data.brand, label: data.label);
      }
    }

    var brocadeUrl = Uri.parse("https://www.brocade.io/api/items/$upc");

    response = await http.get(brocadeUrl);

    if (response.statusCode == 200) {
      var data = BrocadeUPCLookup.fromJson(jsonDecode(response.body));

      return Product(upc: data.upc, brand: data.brand, label: data.label);
    }

    return null;
  }

  @override
  Future<bool> updateInventoryItemCount(String upc, int count) {
    // TODO: implement updateInventoryItemCount
    throw UnimplementedError();
  }
}
