import 'package:flutter/material.dart';

import '../../pages/setup_page.dart';

class SetupViewTablet extends StatelessWidget {
  const SetupViewTablet({super.key});

  @override
  Widget build(BuildContext context) {
    var children = [
      const Expanded(
        child: SetupPage(),
      ),
    ];
    var orientation = MediaQuery.of(context).orientation;
    return Scaffold(
      body: orientation == Orientation.portrait
          ? Column(children: children)
          : Row(children: children.reversed.toList()),
    );
  }
}
