import 'package:flutter/material.dart';

import '../../pages/setup_page.dart';

class SetupViewMobile extends StatelessWidget {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  SetupViewMobile({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const <Widget>[SetupPage()],
      ),
    );
  }
}
