import 'package:flutter/material.dart';

class DrawerOptionMobilePortrait extends StatelessWidget {
  final String? title;
  final IconData? iconData;
  final StatelessWidget page;

  const DrawerOptionMobilePortrait({
    Key? key,
    this.title,
    this.iconData,
    required this.page,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 25),
      height: 80,
      child: Row(
        children: <Widget>[
          IconButton(
            icon: Icon(iconData, size: 45),
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).push(
                  MaterialPageRoute(builder: (BuildContext context) => page));
            },
          ),
          const SizedBox(
            width: 25,
          ),
          Text(
            title!,
            style: const TextStyle(fontSize: 21),
          )
        ],
      ),
    );
  }
}

class DrawerOptionMobileLandscape extends StatelessWidget {
  final IconData? iconData;
  final StatelessWidget page;

  const DrawerOptionMobileLandscape({
    Key? key,
    this.iconData,
    required this.page,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      alignment: Alignment.center,
      child: IconButton(
        icon: Icon(iconData, size: 45),
        onPressed: () {
          Navigator.of(context).pop();
          Navigator.of(context)
              .push(MaterialPageRoute(builder: (BuildContext context) => page));
        },
      ),
    );
  }
}
