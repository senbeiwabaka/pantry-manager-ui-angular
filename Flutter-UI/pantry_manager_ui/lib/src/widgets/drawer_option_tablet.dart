import 'package:flutter/material.dart';

class DrawerOptionTabletPortrait extends StatelessWidget {
  final String? title;
  final IconData? iconData;
  final StatelessWidget page;

  const DrawerOptionTabletPortrait({
    Key? key,
    this.title,
    this.iconData,
    required this.page,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 152,
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          IconButton(
            icon: Icon(iconData, size: 45),
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).push(
                  MaterialPageRoute(builder: (BuildContext context) => page));
            },
          ),
          Text(title!, style: const TextStyle(fontSize: 20)),
        ],
      ),
    );
  }
}
