import 'package:flutter/material.dart';
import 'package:responsive_builder/responsive_builder.dart';

import 'create_grocery_list_view_mobile.dart';
import 'create_grocery_list_view_tablet.dart';

class CreateGroceryListView extends StatelessWidget {
  const CreateGroceryListView({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenTypeLayout.builder(
      mobile: (context) => CreateGroceryListViewMobile(),
      tablet: (_) => const CreateGroceryListViewTablet(),
    );
  }
}
