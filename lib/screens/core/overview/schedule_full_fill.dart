import 'package:badges/badges.dart';
import 'package:cicle_mobile_f3/models/comment_item_model.dart';
import 'package:cicle_mobile_f3/models/event_item_model.dart';
import 'package:cicle_mobile_f3/utils/helpers.dart';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

class ScheduleFullFill extends StatelessWidget {
  const ScheduleFullFill({Key? key, required this.list}) : super(key: key);
  final Map<String, List<EventItemModel>> list;

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
                .map((key, value) {
                  List<EventItemModel> events = value;
                  return MapEntry(
                      key,
                      ListView.builder(
                          physics: NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: events.length,
                          itemBuilder: (ctx, index) {
                            EventItemModel event = events[index];
                            return _buildItem(event);
                          }));
                })
                .values
                .toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildItem(EventItemModel event) {
    String date =
        DateFormat.yMMMEd().format(DateTime.parse(event.startDate!).toLocal());
    List<CommentItemModel> comments = event.comments!;
    String title = removeHtmlTag(event.title ?? '').trim();

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        color: Colors.white,
      ),
      margin: EdgeInsets.only(left: 2.w, right: 2.w, bottom: 0, top: 5.w),
      padding: EdgeInsets.all(8.w),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              event.isPublic == false
                  ? Padding(
                      padding: const EdgeInsets.only(right: 2.0, top: 2.5),
                      child: Icon(
                        Icons.lock_rounded,
                        size: 9,
                      ),
                    )
                  : SizedBox(),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(date,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: TextStyle(
                            fontSize: 9.w,
                            color: Color(0xff000000),
                            fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              SizedBox(
                width: 15,
              ),
              comments.length > 0
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: Badge(
                        padding:
                            EdgeInsets.symmetric(vertical: 2, horizontal: 3),
                        shape: BadgeShape.square,
                        badgeContent: Text(
                          comments.length.toString(),
                          style: TextStyle(fontSize: 9, color: Colors.white),
                        ),
                      ),
                    )
                  : Container()
            ],
          ),
          title == ""
              ? Container()
              : SizedBox(
                  height: 6.w,
                ),
          title == ""
              ? Container()
              : Row(
                  children: [
                    Expanded(
                        child: Text(removeHtmlTag(title),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                            style: TextStyle(
                                fontSize: 9.w, color: Color(0xff000000)))),
                  ],
                )
        ],
      ),
    );
  }
}
