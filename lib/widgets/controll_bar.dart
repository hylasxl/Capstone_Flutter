import 'package:flutter/material.dart';

class ControllBar extends StatelessWidget implements PreferredSizeWidget {
  const ControllBar({super.key, required this.hideSearchIcon});
  final bool hideSearchIcon;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: Transform.translate(
            offset: Offset(-40, -5),
            child: Image.asset(
              "assets/icon/logo-narrow-spacing.png",
              width: 200 ,
              height: 112.5 ,
              fit: BoxFit.contain,
            )),
        actions: [
          if (!hideSearchIcon)
            IconButton(
              icon: Icon(Icons.search),
              onPressed: () {
              },
            ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
