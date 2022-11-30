import 'package:flutter/material.dart';
import 'package:shimmer_animation/shimmer_animation.dart';

class ShimmerCustom extends StatelessWidget {
  const ShimmerCustom(
      {Key? key,
      this.height = 0,
      this.width = 0,
      this.enable = true,
      this.child, this.borderRadius = 2})
      : super(key: key);
  final double height;
  final double width;
  final bool enable;
  final Widget? child;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: Shimmer(
        enabled: enable,
        child: Container(
          width: width,
          height: height,
          color: Colors.grey.withOpacity(0.25),
          child: child != null ? child : SizedBox(),
        ),
      ),
    );
  }
}
