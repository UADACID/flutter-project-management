import 'package:flutter/material.dart';

class MenuItemOverview extends StatelessWidget {
  const MenuItemOverview({
    Key? key,
    required this.label,
    this.child = const SizedBox(),
    this.color,
  }) : super(key: key);
  final String label;
  final Widget child;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(1),
      child: Center(
          child: Column(
        children: [
          SizedBox(
            height: 18,
          ),
          Text(
            label,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          SizedBox(
            height: 9,
          ),
          Expanded(
              child: Container(
            width: double.infinity,
            height: double.infinity,
            margin: EdgeInsets.symmetric(horizontal: 11),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
            ),
            child: child,
          )),
          SizedBox(
            height: 25,
          ),
        ],
      )),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(50),
          color: color == null ? Theme.of(context).cardColor : color),
    );
  }
}
