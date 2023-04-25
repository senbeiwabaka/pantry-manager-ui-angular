import 'package:flutter/material.dart';
import 'package:responsive_builder/responsive_builder.dart';

import 'drawer_option_mobile.dart';
import 'drawer_option_tablet.dart';

class DrawerOption extends StatelessWidget {
  final String? title;
  final IconData? iconData;
  final StatelessWidget page;

  const DrawerOption({
    Key? key,
    this.title,
    this.iconData,
    required this.page,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ScreenTypeLayout.builder(
      mobile: (_) => OrientationLayoutBuilder(
        landscape: (context) => DrawerOptionMobileLandscape(
          iconData: iconData,
          page: page,
        ),
        portrait: (context) => DrawerOptionMobilePortrait(
          title: title,
          iconData: iconData,
          page: page,
        ),
      ),
      tablet: (_) => OrientationLayoutBuilder(
        portrait: (context) => DrawerOptionTabletPortrait(
          iconData: iconData,
          title: title,
          page: page,
        ),
        landscape: (context) => DrawerOptionTabletPortrait(
          iconData: iconData,
          title: title,
          page: page,
        ),
      ),
    );
  }
}
