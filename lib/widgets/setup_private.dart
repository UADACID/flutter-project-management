import 'package:flutter/material.dart';

class SetupPrivate extends StatelessWidget {
  const SetupPrivate({
    Key? key,
    required this.title,
    required this.isPrivate,
    required this.onChange,
  }) : super(key: key);

  final String title;
  final bool isPrivate;
  final Function(bool) onChange;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 9.0, top: 11),
            child: Text(title,
                style: TextStyle(fontSize: 12, color: Color(0xff979797))),
          ),
          Switch(value: isPrivate, onChanged: onChange)
        ],
      ),
    );
  }
}
