import 'package:flutter/material.dart';

class DisplayedAvatar extends StatelessWidget {
  final double size;
  final String avatarUrl;
  const DisplayedAvatar(
      {super.key, required this.avatarUrl, required this.size});

  @override
  Widget build(BuildContext context) {
    bool isPng = avatarUrl.toLowerCase().endsWith('.png');
    return ClipOval(
      child: SizedBox(
        width: size,
        height: size,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (!isPng) Container(color: Colors.white),
            Image.network(
              avatarUrl,
              fit: BoxFit.cover,
              cacheHeight: int.parse(size.toStringAsFixed(0)),
              cacheWidth: int.parse(size.toStringAsFixed(0)),
            ),
          ],
        ),
      ),
    );
  }
}
