import 'package:flutter/material.dart';
import 'package:responsive_builder/responsive_builder.dart';

import 'barcode_view_mobile.dart';
import 'barcode_view_tablet.dart';

class BarcodeView extends StatelessWidget {
  const BarcodeView({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenTypeLayout.builder(
      mobile: (context) => BarcodeViewMobile(),
      tablet: (_) => const BarcodeViewTablet(),
    );
  }
}
