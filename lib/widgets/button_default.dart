import 'package:flutter/material.dart';

class ButtonDefault extends StatelessWidget {
  const ButtonDefault({Key? key, this.child, required this.onPress})
      : super(key: key);
  final Widget? child;
  final Function onPress;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () => onPress(),
      style: ButtonStyle(
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(50.0),
      ))),
      child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 305, maxHeight: 40),
          child: Container(
              width: double.infinity,
              child: Center(child: child ?? Container()))),
    );
  }
}
