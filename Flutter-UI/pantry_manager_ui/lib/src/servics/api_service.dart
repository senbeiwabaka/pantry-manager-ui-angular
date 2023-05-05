import 'dart:convert';

import 'package:qinject/qinject.dart';
import 'package:http/http.dart' as http;

import '../interfaces/api_service_interface.dart';
import '../models/inventory_item.dart';
import '../models/product.dart';
import '../models/settings.dart';
import 'logger.dart';

class ApiService implements IApiService {
  final _log = getLogger();

  final Settings _settings = Qinject.use<ApiService, Settings>();

  ApiService(Qinjector qinjector);

  @override
  Future<Product?> getProduct(String upc) async {
    var productLookupUri =
        Uri.parse("${_settings.url}/pantry-manager/product/$upc");

    var response = await http.get(productLookupUri);

    if (response.statusCode == 200) {
      var data = Product.fromJson(jsonDecode(response.body));

      return data;
    } else {
      _log.d("get product status code: ${response.statusCode}");
    }

    return null;
  }

  @override
  Future<Product?> lookupProduct(String upc) async {
    var upcLookupUri =
        Uri.parse("${_settings.url}/pantry-manager/upc-lookup/$upc");

    var response = await http.get(upcLookupUri);

    if (response.statusCode == 200) {
      var data = Product.fromJson(jsonDecode(response.body));

      return data;
    } else {
      _log.d("upc lookup status code: ${response.statusCode}");
      _log.d("upc scanned: $upc");
    }

    return null;
  }

  @override
  Future<bool> addProduct(Product product) async {
    var addProductUri = Uri.parse("${_settings.url}/pantry-manager/product");
    var encodedProduct = jsonEncode(product,
        toEncodable: (Object? value) => Product.toJson(product));

    try {
      var response = await http.post(addProductUri,
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: encodedProduct,
          encoding: Encoding.getByName("utf-8"));

      _log.d("add product status code: ${response.statusCode}");
    } catch (ex) {
      _log.e(ex);

      return false;
    }

    return true;
  }

  @override
  Future<InventoryItem?> getOrAddInventoryItem(Product product) async {
    var inventoryItemLookupUrl =
        Uri.parse("${_settings.url}/pantry-manager/inventory/${product.upc}");
    var response = await http.get(inventoryItemLookupUrl);

    if (response.statusCode == 200) {
      var data = InventoryItem.fromJson(jsonDecode(response.body));

      return data;
    }

    var inventoryItemAddUrl =
        Uri.parse("${_settings.url}/pantry-manager/inventory");
    var encodedProduct = jsonEncode(product,
        toEncodable: (Object? value) => Product.toJson(product));

    try {
      var response = await http.post(inventoryItemAddUrl,
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: encodedProduct,
          encoding: Encoding.getByName("utf-8"));

      _log.d("inventory item post status code: ${response.statusCode}");

      if (response.statusCode == 201) {
        var data = InventoryItem.fromJson(jsonDecode(response.body));

        return data;
      }
    } catch (ex) {
      _log.e(ex);
    }

    return null;
  }

  @override
  Future<bool> checkOrAddGroceryItem(InventoryItem inventoryItem) async {
    var groceryItemLookupUrl = Uri.parse(
        "${_settings.url}/pantry-manager/groceries/${inventoryItem.product.upc}");
    var response = await http.get(groceryItemLookupUrl);

    if (response.statusCode == 200) {
      return true;
    }

    var groceryItemAddUrl =
        Uri.parse("${_settings.url}/pantry-manager/groceries");
    var encoded = jsonEncode(inventoryItem,
        toEncodable: (Object? value) => InventoryItem.toJson(inventoryItem));

    _log.d("inventory item encoded: $encoded");

    try {
      var response = await http.post(groceryItemAddUrl,
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: encoded,
          encoding: Encoding.getByName("utf-8"));

      _log.d("grocery item post status code: ${response.statusCode}");
    } catch (ex) {
      _log.e(ex);

      return false;
    }

    return true;
  }

  @override
  Future<bool> updateInventoryItemCount(String upc, int count) async {
    var inventoryItemCountUrl =
        Uri.parse("${_settings.url}/pantry-manager/inventory/$upc/$count");
    var response = await http.post(inventoryItemCountUrl);

    if (response.statusCode == 200) {
      return true;
    }

    return false;
  }
}
