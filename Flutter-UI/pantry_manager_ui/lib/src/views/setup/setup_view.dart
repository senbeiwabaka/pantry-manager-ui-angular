import 'package:flutter/material.dart';
import 'package:responsive_builder/responsive_builder.dart';

import 'setup_view_mobile.dart';
import 'setup_view_tablet.dart';

class SettignsView extends StatelessWidget {
  const SettignsView({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenTypeLayout.builder(
      mobile: (context) => const SetupViewMobile(),
      tablet: (_) => const SetupViewTablet(),
    );
  }
}
