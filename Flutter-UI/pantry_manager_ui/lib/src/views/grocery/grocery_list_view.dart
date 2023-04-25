import 'package:flutter/material.dart';
import 'package:responsive_builder/responsive_builder.dart';

import 'grocery_list_view_mobile.dart';
import 'grocery_list_view_tablet.dart';

class GroceryListView extends StatelessWidget {
  const GroceryListView({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenTypeLayout.builder(
      mobile: (context) => GroceryListViewMobile(),
      tablet: (_) => const GroceryListViewTablet(),
    );
  }
}
