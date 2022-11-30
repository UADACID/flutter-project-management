import 'package:flutter/material.dart';
import 'package:simple_animations/simple_animations.dart';
import 'package:supercharged/supercharged.dart';

class AnimationFadeAndSlide extends StatelessWidget {
  AnimationFadeAndSlide(
      {Key? key,
      required this.child,
      required this.duration,
      required this.delay})
      : super(key: key);

  final Widget child;
  final Duration duration;
  final Duration delay;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: PlayAnimation<double>(
          tween: (50.0).tweenTo(0.0),
          delay: delay,
          // set a duration
          duration: Duration(milliseconds: duration.inMilliseconds + 200),
          // set a curve
          curve: Curves.easeInOut,
          builder: (context, _, value) {
            return Transform.translate(
              offset: Offset(0, value),
              child: PlayAnimation<double>(
                  tween: (0.0).tweenTo(1.0),
                  delay: delay,
                  // set a duration
                  duration:
                      Duration(milliseconds: duration.inMilliseconds + 300),
                  // set a curve
                  curve: Curves.easeInOut,
                  builder: (context, _, valueOpacity) {
                    return Opacity(opacity: valueOpacity, child: child);
                  }),
            );
          }),
    );
  }
}