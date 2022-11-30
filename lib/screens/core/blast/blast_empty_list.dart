import 'package:flutter/material.dart';

class EmptyBlast extends StatelessWidget {
  const EmptyBlast({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 34.0),
          child: Text(
            'Start adding new Blast for your team to keep them informed. You can also decide something without meeting!',
            textAlign: TextAlign.center,
            style:
                TextStyle(height: 2.5, color: Color(0xffB5B5B5), fontSize: 11),
          ),
        ),
      ),
    );
  }
}