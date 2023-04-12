import 'dart:async';

import 'package:flutter/material.dart';

import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';

import 'package:barcode_scan/barcode_scan.dart';

class BarcodeScanner extends StatelessWidget {
  const BarcodeScanner({super.key});

  Future<void> startBarcodeScanStream() async {
    FlutterBarcodeScanner.getBarcodeStreamReceiver(
            '#ff6666', 'Cancel', true, ScanMode.BARCODE)!
        .listen((barcode) => print(barcode));
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(children: [
        ElevatedButton(
            onPressed: () => startBarcodeScanStream(),
            child: Text('Start barcode scan stream'))
      ]),
    );
  }
}
