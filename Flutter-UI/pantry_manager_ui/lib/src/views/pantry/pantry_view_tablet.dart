import 'package:flutter/material.dart';

import '../../pages/pantry_page.dart';
import '../../widgets/app_drawer.dart';

class PantryViewTablet extends StatelessWidget {
  const PantryViewTablet({super.key});

  @override
  Widget build(BuildContext context) {
    var children = [
      const Expanded(
        child: PantryPage(),
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
