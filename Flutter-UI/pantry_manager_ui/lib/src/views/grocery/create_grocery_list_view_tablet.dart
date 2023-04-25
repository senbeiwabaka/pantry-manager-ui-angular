import 'package:flutter/material.dart';

import '../../pages/create_grocery_list_page.dart';
import '../../widgets/app_drawer.dart';

class CreateGroceryListViewTablet extends StatelessWidget {
  const CreateGroceryListViewTablet({super.key});

  @override
  Widget build(BuildContext context) {
    var children = [
      const Expanded(
        child: CreateGroceryListPage(),
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
