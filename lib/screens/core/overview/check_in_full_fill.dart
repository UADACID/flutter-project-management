import 'package:cicle_mobile_f3/models/questionItemModel.dart';

import 'package:cicle_mobile_f3/widgets/horizontal_list_user.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CheckInFullFill extends StatelessWidget {
  const CheckInFullFill({Key? key, this.list = const []}) : super(key: key);
  final List<QuestionItemModel> list;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Color(0xfff4f4f4),
        border: Border.all(color: Color(0xffF0F1F7)),
      ),
      child: SingleChildScrollView(
        physics: NeverScrollableScrollPhysics(),
        child: Column(
          children: [
            ...list
                .asMap()
                .map((key, value) {
                  QuestionItemModel item = value;
                  return MapEntry(key, _buildItem(item));
                })
                .values
                .toList(),
          ],
        ),
      ),
    );
  }

  Container _buildItem(QuestionItemModel item) {
    String title = item.title == '' ? 'untitled' : item.title;
    int counterMembers = item.subscribers.length;
    String days = '';
    item.schedule.days.forEach((element) {
      days += element;
    });
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        color: Colors.white,
      ),
      margin: EdgeInsets.only(left: 2.w, right: 2.w, bottom: 0, top: 5.w),
      padding: EdgeInsets.all(4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  decoration: BoxDecoration(
                      color: Color(0xffDEEAFF),
                      borderRadius: BorderRadius.circular(7)),
                  child: Text('Asking $counterMembers people every $days',
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: TextStyle(
                          fontSize: 9.w,
                          color: Color(0xff7A7A7A),
                          fontWeight: FontWeight.normal)),
                ),
              ),
            ],
          ),
          SizedBox(
            height: 4.w,
          ),
          Row(
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
                child: Text(title,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: TextStyle(
                        fontSize: 9.w,
                        color: Color(0xff1F3762),
                        fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          SizedBox(
            height: 6.w,
          ),
          Container(
            height: 14,
            child: HorizontalListUser(
                max: 8,
                width: 12.w,
                margin: EdgeInsets.only(right: 2),
                textStyle: TextStyle(fontSize: 5.5),
                members: item.subscribers),
          )
        ],
      ),
    );
  }
}
