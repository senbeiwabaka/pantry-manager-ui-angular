import 'package:flutter/material.dart';

import '../../pages/barcode_page.dart';
import '../../widgets/app_drawer.dart';

class BarcodeViewTablet extends StatelessWidget {
  const BarcodeViewTablet({super.key});

  @override
  Widget build(BuildContext context) {
    var children = [
      const Expanded(
        child: BarcodeScannerPage(),
      ),
      const AppDrawer(),
    ];
    var orientation = MediaQuery.of(context).orientation;
    return Scaffold(
      body: orientation == Orientation.portrait
          ? Column(children: children)
          : Row(children: children.reversed.toList()),
    );
  }
}
