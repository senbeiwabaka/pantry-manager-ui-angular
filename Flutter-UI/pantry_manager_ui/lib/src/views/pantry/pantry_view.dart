import 'package:flutter/material.dart';
import 'package:responsive_builder/responsive_builder.dart';

import 'pantry_view_mobile.dart';
import 'pantry_view_tablet.dart';

class PantryView extends StatelessWidget {
  const PantryView({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenTypeLayout.builder(
      mobile: (context) => PantryViewMobile(),
      tablet: (_) => const PantryViewTablet(),
    );
  }
}
