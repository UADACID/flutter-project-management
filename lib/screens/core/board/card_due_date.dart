import 'package:cicle_mobile_f3/models/board_list_item_model.dart';
import 'package:cicle_mobile_f3/models/card_model.dart';
import 'package:cicle_mobile_f3/utils/helpers.dart';
import 'package:flutter/material.dart';

class CardDueDate extends StatelessWidget {
  const CardDueDate({
    Key? key,
    required this.card,
    required this.list,
  }) : super(key: key);

  final CardModel card;

  final BoardListItemModel list;

  @override
  Widget build(BuildContext context) {
    if (card.dueDate == '') {
      return Container();
    }

    var dateParseFromUtc = DateTime.parse(card.dueDate).toLocal();
    var day = dateParseFromUtc.day;
    var month = months[dateParseFromUtc.month - 1];

    getContainerColor() {
      if (list.complete.status) {
        if (list.complete.type == "done") {
          return Colors.green;
        } else {
          return Colors.grey.withOpacity(0.25);
        }
      } else {
        return getDueCardColor(dateParseFromUtc);
      }
    }

    getLocalTextColor() {
      if (list.complete.status) {
        if (list.complete.type == "done") {
          return Colors.white;
        } else {
          return Colors.red;
        }
      } else {
        return getDueTextColor(dateParseFromUtc);
      }
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      margin: EdgeInsets.only(right: 4),
      decoration: BoxDecoration(
          color: getContainerColor(), borderRadius: BorderRadius.circular(5)),
      child: Row(
        children: [
          Icon(getIconDueDate(list), size: 18, color: getLocalTextColor()),
          SizedBox(
            width: 6,
          ),
          Text(
            '$month $day',
            style: TextStyle(fontSize: 12, color: getLocalTextColor()),
          ),
        ],
      ),
    );
  }
}
