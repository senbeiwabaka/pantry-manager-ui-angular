import 'package:flutter/material.dart';
import 'package:pantry_manager_ui/src/interfaces/api_service_interface.dart';
import 'package:pantry_manager_ui/src/servics/logger.dart';
import 'package:qinject/qinject.dart';

import 'package:simple_barcode_scanner/simple_barcode_scanner.dart';

import '../models/product.dart';
import '../models/settings.dart';

class BarcodeScannerPage extends StatefulWidget {
  const BarcodeScannerPage({super.key});

  @override
  State<BarcodeScannerPage> createState() => _BarcodeScannerPageState();
}

class _BarcodeScannerPageState extends State<BarcodeScannerPage> {
  final _log = getLogger();
  final Settings _settings = Qinject.use<void, Settings>();
  final IApiService _apiService = Qinject.use<void, IApiService>();

  var userMessage = "Nothing scanned";
  var imageUrl = '';
  var isAdding = true;

  @override
  Widget build(BuildContext context) {
    _log.d("settings: $_settings");

    return Material(
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
                product = await _apiService.getProduct(scannedResult);

                // Product is not already in the system so look it up from the food API
                if (product == null) {
                  product = await _apiService.lookupProduct(scannedResult);

                  // Product was found in food API
                  if (product != null) {
                    successful = await _apiService.addProduct(product);
                  }
                } else {
                  successful = true;
                }

                // Product was successfully added to system so we now add Inventory Item and Grocery List Item
                if (successful) {
                  var inventoryItem =
                      await _apiService.getOrAddInventoryItem(product!);

                  _log.d(inventoryItem);

                  successful = inventoryItem != null;

                  if (successful) {
                    successful =
                        await _apiService.checkOrAddGroceryItem(inventoryItem);

                    _log.d("grocery add check successfully: $successful");
                  }
                }

                _log.d("successfully: $successful");

                // Product, Inventory Item, and Grocery Item were succesfully added to system
                if (successful) {
                  if (isAdding) {
                    await _apiService.updateInventoryItemCount(product!.upc, 1);
                  } else {
                    await _apiService.updateInventoryItemCount(
                        product!.upc, -1);
                  }
                }
              }

              setState(() {
                if (successful) {
                  userMessage = scannedResult;

                  _log.d('upc is $userMessage');
                  _log.d('product is $product');

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
        Text(userMessage)
      ]),
    );
  }
}
