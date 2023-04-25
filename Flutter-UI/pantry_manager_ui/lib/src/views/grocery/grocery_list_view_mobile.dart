import 'package:flutter/material.dart';

import '../../pages/grocery_list_page.dart';
import '../../widgets/app_drawer.dart';

class GroceryListViewMobile extends StatelessWidget {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  GroceryListViewMobile({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: const AppDrawer(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(16),
            child: IconButton(
              icon: const Icon(Icons.menu, size: 30),
              onPressed: () {
                _scaffoldKey.currentState!.openDrawer();
              },
            ),
          ),
          const GroceryListPage()
        ],
      ),
    );
  }
}
