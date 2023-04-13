import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:simple_barcode_scanner/simple_barcode_scanner.dart';
import 'package:http/http.dart' as http;

import '../models/product.dart';

class BarcodeScanner extends StatefulWidget {
  const BarcodeScanner({super.key});

  @override
  State<BarcodeScanner> createState() => _BarcodeScannerState();
}

class _BarcodeScannerState extends State<BarcodeScanner> {
  String userMessage = "Nothing scanned";
  String imageUrl = '';
  var isAdding = true;

  Future<String> _calculation() async {
    var url = Uri.parse(
        "http://docker-database.localdomain:8000/pantry-manager/upc-lookup/047495210002");

    var response = await http.get(url);

    if (response.statusCode == 200) {
      var data = Product.fromJson(jsonDecode(response.body));

      return data.upc;
    }

    return '';
  }

  Future<Product?> getProduct(String upc) async {
    var upcLookupUrl = Uri.parse(
        "http://docker-database.localdomain:8000/pantry-manager/upc-lookup/${upc}");
    var productLookupUrl = Uri.parse(
        "http://docker-database.localdomain:8000/pantry-manager/product/${upc}");

    var response = await http.get(productLookupUrl);

    if (response.statusCode == 200) {
      var data = Product.fromJson(jsonDecode(response.body));

      return data;
    } else if (response.statusCode == 404) {
      response = await http.get(upcLookupUrl);

      if (response.statusCode == 200) {
        var data = Product.fromJson(jsonDecode(response.body));

        return data;
      }
    } else {
      print(response.statusCode);
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(children: [
        FutureBuilder(
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return Text(snapshot.data!);
            } else {
              return Text("test");
            }
          },
          future: _calculation(),
        ),
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

              if (scannedResult is String) {
                userMessage = scannedResult;
                product = await getProduct(userMessage);
              }

              setState(() {
                if (product != null) {
                  print('upc is $userMessage');
                  print('product is $product');

                  if (product.imageUrl != null) {
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
        if (imageUrl.isNotEmpty) Image.network(imageUrl),
      ]),
    );
  }
}
