import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:pantry_manager_ui/src/servics/logger.dart';

import 'package:simple_barcode_scanner/simple_barcode_scanner.dart';
import 'package:http/http.dart' as http;

import '../models/inventory_item.dart';
import '../models/product.dart';

class BarcodeScanner extends StatefulWidget {
  const BarcodeScanner({super.key});

  @override
  State<BarcodeScanner> createState() => _BarcodeScannerState();
}

class _BarcodeScannerState extends State<BarcodeScanner> {
  final log = getLogger();

  var userMessage = "Nothing scanned";
  var imageUrl = '';
  var isAdding = true;

  Future<Product?> getProduct(String upc) async {
    var productLookupUri = Uri.parse(
        "http://docker-database.localdomain:8000/pantry-manager/product/$upc");

    var response = await http.get(productLookupUri);

    if (response.statusCode == 200) {
      var data = Product.fromJson(jsonDecode(response.body));

      return data;
    } else {
      log.d(response.statusCode);
    }

    return null;
  }

  Future<Product?> lookupProduct(String upc) async {
    var upcLookupUri = Uri.parse(
        "http://docker-database.localdomain:8000/pantry-manager/upc-lookup/$upc");

    var response = await http.get(upcLookupUri);

    if (response.statusCode == 200) {
      var data = Product.fromJson(jsonDecode(response.body));

      return data;
    } else {
      log.d(response.statusCode);
    }

    return null;
  }

  Future<bool> addProduct(Product product) async {
    var addProductUri = Uri.parse(
        "http://docker-database.localdomain:8000/pantry-manager/product");
    var encodedProduct = jsonEncode(product,
        toEncodable: (Object? value) => Product.toJson(product));

    try {
      var response = await http.post(addProductUri,
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: encodedProduct,
          encoding: Encoding.getByName("utf-8"));

      log.d("product post status code: ${response.statusCode}");
    } catch (ex) {
      log.e(ex);

      return false;
    }

    return true;
  }

  Future<InventoryItem?> getOrAddInventoryItem(Product product) async {
    var inventoryItemLookupUrl = Uri.parse(
        "http://docker-database.localdomain:8000/pantry-manager/inventory/${product.upc}");
    var response = await http.get(inventoryItemLookupUrl);

    if (response.statusCode == 200) {
      var data = InventoryItem.fromJson(jsonDecode(response.body));

      return data;
    }

    var inventoryItemAddUrl = Uri.parse(
        "http://docker-database.localdomain:8000/pantry-manager/inventory");
    var encodedProduct = jsonEncode(product,
        toEncodable: (Object? value) => Product.toJson(product));

    try {
      var response = await http.post(inventoryItemAddUrl,
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: encodedProduct,
          encoding: Encoding.getByName("utf-8"));

      log.d("inventory item post status code: ${response.statusCode}");

      if (response.statusCode == 201) {
        var data = InventoryItem.fromJson(jsonDecode(response.body));

        return data;
      }
    } catch (ex) {
      log.e(ex);
    }

    return null;
  }

  Future<bool> checkOrAddGroceryItem(InventoryItem inventoryItem) async {
    var groceryItemLookupUrl = Uri.parse(
        "http://docker-database.localdomain:8000/pantry-manager/groceries/${inventoryItem.product.upc}");
    var response = await http.get(groceryItemLookupUrl);

    if (response.statusCode == 200) {
      return true;
    }

    var groceryItemAddUrl = Uri.parse(
        "http://docker-database.localdomain:8000/pantry-manager/groceries");
    var encoded = jsonEncode(inventoryItem,
        toEncodable: (Object? value) => InventoryItem.toJson(inventoryItem));

    log.d("inventory item encoded: $encoded");

    try {
      var response = await http.post(groceryItemAddUrl,
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: encoded,
          encoding: Encoding.getByName("utf-8"));

      log.d("grocery item post status code: ${response.statusCode}");
    } catch (ex) {
      log.e(ex);

      return false;
    }

    return true;
  }

  Future<bool> updateInventoryItemCount(String upc, int count) async {
    var inventoryItemCountUrl = Uri.parse(
        "http://docker-database.localdomain:8000/pantry-manager/inventory/$upc/$count");
    var response = await http.post(inventoryItemCountUrl);

    if (response.statusCode == 200) {
      return true;
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(children: [
        ElevatedButton(
            onPressed: () async {
              var scannedResult = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SimpleBarcodeScannerPage(
                      isShowFlashIcon: true,
                    ),
                  ));

              Product? product;

              var successful = false;

              if (scannedResult is String) {
                product = await getProduct(scannedResult);

                // Product is not already in the system so look it up from the food API
                if (product == null) {
                  product = await lookupProduct(scannedResult);

                  // Product was found in food API
                  if (product != null) {
                    successful = await addProduct(product);
                  }
                } else {
                  successful = true;
                }

                // Product was successfully added to system so we now add Inventory Item and Grocery List Item
                if (successful) {
                  var inventoryItem = await getOrAddInventoryItem(product!);

                  log.d(inventoryItem);

                  successful = inventoryItem != null;

                  if (successful) {
                    successful = await checkOrAddGroceryItem(inventoryItem);

                    log.d("grocery add check successfully: $successful");
                  }
                }

                log.d("successfully: $successful");

                // Product, Inventory Item, and Grocery Item were succesfully added to system
                if (successful) {
                  if (isAdding) {
                    await updateInventoryItemCount(product!.upc, 1);
                  } else {
                    await updateInventoryItemCount(product!.upc, -1);
                  }
                }
              }

              setState(() {
                if (successful) {
                  userMessage = scannedResult;

                  log.d('upc is $userMessage');
                  log.d('product is $product');

                  if (product!.imageUrl != null) {
                    imageUrl = product.imageUrl!;
                  } else {
                    imageUrl =
                        'https://www.eloan.com/assets/images/not-found-page/404-image-2x.png';
                  }
                } else {
                  userMessage = 'Not found: $scannedResult';
                }
              });
            },
            child: const Text('Scan your item')),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Checkbox(
              value: isAdding,
              onChanged: (newValue) {
                if (newValue != null) {
                  setState(() {
                    isAdding = newValue;
                  });
                }
              }),
          const Text("Add"),
        ]),
        if (imageUrl.isNotEmpty)
          Image.network(
            imageUrl,
            errorBuilder: ((context, error, stackTrace) =>
                const Text("No image found")),
          ),
      ]),
    );
  }
}
