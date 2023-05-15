import 'package:flutter/material.dart';

import '../../pages/setup_page.dart';

class SetupViewMobile extends StatelessWidget {
  const SetupViewMobile({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      // key: _scaffoldKey,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[SetupPage()],
      ),
    );
  }
}
