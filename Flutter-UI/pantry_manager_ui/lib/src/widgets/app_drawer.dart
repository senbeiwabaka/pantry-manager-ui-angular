import 'package:flutter/material.dart';
import 'package:responsive_builder/responsive_builder.dart';

import '../views/barcode/barcode_view.dart';
import '../views/grocery/create_grocery_list_view.dart';
import '../views/grocery/grocery_list_view.dart';
import '../views/pantry/pantry_view.dart';
import 'app_drawer_mobile.dart';
import 'app_drawer_tablet.dart';
import 'drawer_option.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ScreenTypeLayout.builder(
      mobile: (_) => const AppDrawerMobile(),
      tablet: (_) => OrientationLayoutBuilder(
        portrait: (context) => const AppDrawerTabletPortrait(),
        landscape: (context) => const AppDrawerTabletLandscape(),
      ),
    );
  }

  static List<Widget> getDrawerOptions() {
    return [
      const DrawerOption(
          title: 'Barcode Scanner', iconData: Icons.image, page: BarcodeView()),
      const DrawerOption(
          title: 'Grocery List',
          iconData: Icons.photo_filter,
          page: GroceryListView()),
      const DrawerOption(
          title: 'Pantry', iconData: Icons.message, page: PantryView()),
      const DrawerOption(
          title: 'Create Grocery List',
          iconData: Icons.settings,
          page: CreateGroceryListView()),
    ];
  }
}
