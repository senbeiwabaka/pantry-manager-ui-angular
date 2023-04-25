import 'package:flutter/material.dart';

import '../../pages/grocery_list_page.dart';
import '../../widgets/app_drawer.dart';

class GroceryListViewTablet extends StatelessWidget {
  const GroceryListViewTablet({super.key});

  @override
  Widget build(BuildContext context) {
    var children = [
      const Expanded(
        child: GroceryListPage(),
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
