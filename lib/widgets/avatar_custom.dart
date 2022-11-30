import 'package:flutter/material.dart';
import 'package:random_color/random_color.dart';

class AvatarCustom extends StatelessWidget {
  AvatarCustom({Key? key, this.height = 24, required this.child, this.color})
      : super(key: key);

  final double height;
  final Widget child;
  final Color? color;

  RandomColor _randomColor = RandomColor();

  @override
  Widget build(BuildContext context) {
    Color _color =
        _randomColor.randomColor(colorBrightness: ColorBrightness.light);
    return ClipRRect(
      borderRadius: BorderRadius.circular(height),
      child: Container(
        height: height,
        width: height,
        decoration: BoxDecoration(
            shape: BoxShape.circle, color: color == null ? _color : color),
        child: Center(child: child),
      ),
    );
  }
}
