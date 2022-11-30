import 'package:cicle_mobile_f3/models/label_model.dart';
import 'package:cicle_mobile_f3/utils/helpers.dart';
import 'package:flutter/material.dart';

class CardLabel extends StatelessWidget {
  CardLabel({
    Key? key,
    required this.label,
  }) : super(key: key);

  final LabelModel label;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(right: 4, bottom: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        color: HexColor(label.color.name),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6),
        child: Text(
          '${label.name}',
          style: TextStyle(
              fontSize: 13, color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
