import 'package:badges/badges.dart';
import 'package:cicle_mobile_f3/models/board_list_item_model.dart';
import 'package:cicle_mobile_f3/models/card_model.dart';

import 'package:cicle_mobile_f3/utils/helpers.dart';

import 'package:cicle_mobile_f3/widgets/horizontal_list_user.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

class BoardFullFill extends StatelessWidget {
  const BoardFullFill({Key? key, this.list = const [], required this.boardList})
      : super(key: key);
  final List<CardModel> list;
  final List<BoardListItemModel> boardList;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: double.infinity,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Color(0xfff4f4f4),
          border: Border.all(color: Color(0xffF0F1F7))),
      child: SingleChildScrollView(
        physics: NeverScrollableScrollPhysics(),
        child: Column(
          children: [
            ...list
                .asMap()
                .map((key, value) {
                  CardModel item = value;
                  return MapEntry(key, _buildItem(item));
                })
                .values
                .toList(),
          ],
        ),
      ),
    );
  }

  Container _buildItem(CardModel item) {
    String title = item.name == '' ? 'untitled' : item.name;
    String description = removeHtmlTag(item.desc);
    String? firstLabel = item.labels.length > 0 ? item.labels[0].name : null;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        color: Colors.white,
      ),
      margin: EdgeInsets.only(left: 2.w, right: 2.w, bottom: 0, top: 5.w),
      padding: EdgeInsets.all(4.w),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              item.isPublic == false
                  ? Padding(
                      padding: const EdgeInsets.only(right: 2.0, top: 2.5),
                      child: Icon(
                        Icons.lock_rounded,
                        size: 9,
                      ),
                    )
                  : SizedBox(),
              Expanded(
                child: Container(
                  child: Text(title,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: TextStyle(
                          fontSize: 9.w, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
          SizedBox(
            height: 1.w,
          ),
          _buildListIcon(item, description),
          SizedBox(
            height: 2.w,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                height: 14,
                child: HorizontalListUser(
                    max: 3,
                    width: 12.w,
                    margin: EdgeInsets.only(right: 2),
                    textStylePlus: TextStyle(fontSize: 6.sp),
                    textStyle: TextStyle(fontSize: 5.5),
                    members: item.members),
              ),
              SizedBox(
                width: 5,
              ),
              Flexible(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(3.w),
                  child: firstLabel != null
                      ? Badge(
                          padding:
                              EdgeInsets.symmetric(vertical: 2, horizontal: 8),
                          shape: BadgeShape.square,
                          badgeColor: Color(0xffB0F1FF),
                          badgeContent: Text(
                            firstLabel,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                fontSize: 9.w,
                                color: Colors.black,
                                fontWeight: FontWeight.bold),
                          ),
                        )
                      : Container(),
                ),
              )
            ],
          )
        ],
      ),
    );
  }

  Padding _buildListIcon(CardModel card, String description) {
    bool isDueDate = false;

    String dueDate = '';
    String day = '';
    if (card.dueDate != '') {
      DateTime date = DateTime.parse(card.dueDate);
      String dayName = DateFormat('MMM').format(date);
      day = date.day.toString();
      dueDate = dayName;

      var dateNow = DateTime.now();

      isDueDate = dateNow.compareTo(date) > 0 ? true : false;
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          card.dueDate != ''
              ? _buildDueDate(isDueDate, dueDate, day, card)
              : Container(),
          description.length > 0
              ? Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2.0),
                  child: Icon(
                    Icons.description_outlined,
                    size: 13,
                    color: Color(0xffB5B5B5),
                  ),
                )
              : Container(),
          card.comments.length > 0
              ? Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2.0),
                  child: Row(
                    children: [
                      Icon(
                        Icons.chat_bubble_outline_rounded,
                        size: 13,
                        color: Color(0xffB5B5B5),
                      ),
                      SizedBox(
                        width: 2.5,
                      ),
                      Text(
                        card.comments.length.toString(),
                        style:
                            TextStyle(fontSize: 8.w, color: Color(0xffB5B5B5)),
                      )
                    ],
                  ),
                )
              : Container(),
          card.attachments.length > 0
              ? Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 0.0),
                  child: Row(
                    children: [
                      Icon(
                        Icons.attach_file_sharp,
                        size: 13,
                        color: Color(0xffB5B5B5),
                      ),
                      Text(
                        card.attachments.length.toString(),
                        overflow: TextOverflow.ellipsis,
                        style:
                            TextStyle(fontSize: 8.w, color: Color(0xffB5B5B5)),
                      )
                    ],
                  ),
                )
              : Container(),
        ],
      ),
    );
  }

  Container _buildDueDate(
      bool isDueDate, String dueDate, String day, CardModel card) {
    List<BoardListItemModel> filterCurrentBoardListItem = boardList
        .where((element) => element.cards.any((e) => e.sId == card.sId))
        .toList();

    var dateParseFromUtc = DateTime.parse(card.dueDate).toLocal();
    getContainerColor() {
      if (filterCurrentBoardListItem[0].complete.status) {
        if (filterCurrentBoardListItem[0].complete.type == "done") {
          return Colors.green;
        } else {
          return Colors.grey.withOpacity(0.25);
        }
      } else {
        return getDueCardColor(dateParseFromUtc);
      }
    }

    getLocalTextColor() {
      if (filterCurrentBoardListItem[0].complete.status) {
        if (filterCurrentBoardListItem[0].complete.type == "done") {
          return Colors.white;
        } else {
          return Colors.red;
        }
      } else {
        return getDueTextColor(dateParseFromUtc);
      }
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4, vertical: 3),
      decoration: BoxDecoration(
          color: getContainerColor(), borderRadius: BorderRadius.circular(5)),
      child: Row(
        children: [
          Icon(
            Icons.notifications_active,
            size: 15,
            color: getLocalTextColor(),
          ),
          SizedBox(
            width: 2,
          ),
          Text(
            '$dueDate $day',
            style: TextStyle(
              fontSize: 7.w,
              color: getLocalTextColor(),
            ),
          )
        ],
      ),
    );
  }
}
