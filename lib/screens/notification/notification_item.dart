import 'package:badges/badges.dart';
import 'package:cicle_mobile_f3/controllers/notification_list_controller.dart';

import 'package:cicle_mobile_f3/models/member_model.dart';
import 'package:cicle_mobile_f3/models/notification_item_model.dart';
import 'package:cicle_mobile_f3/utils/constant.dart';
import 'package:cicle_mobile_f3/utils/helpers.dart';
import 'package:cicle_mobile_f3/utils/notification_type_adapter.dart';
import 'package:cicle_mobile_f3/widgets/avatar_custom.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';

class NotificationItem extends StatelessWidget {
  NotificationItem({
    Key? key,
    required this.item,
    this.canSelect = false,
    required this.onLongPress,
    required this.markAsRead,
    required this.controller,
  }) : super(key: key);
  final NotificationItemModel item;
  final bool canSelect;
  final Function onLongPress;
  final box = GetStorage();
  final Function markAsRead;
  final NotificationListController controller;

  @override
  Widget build(BuildContext context) {
    NotifAdapterModel itemAdapter = NotificationTypeAdapter.init(item);
    final userString = box.read(KeyStorage.logedInUser);
    MemberModel _templogedInUser = MemberModel.fromJson(userString);
    String _userId = _templogedInUser.sId;
    List<String> checkIds = [_userId];
    bool isSelfNotif = item.sender.sId == _userId;
    List<Activities> filteredActivities = item.activities
        .where((activity) => !activity.readBy
            .any((element) => checkIds.contains(element.reader)))
        .toList();
    bool isRead = isSelfNotif ? true : filteredActivities.length <= 0;
    var parseDate = DateTime.parse(item.updatedAt).toLocal();
    String time = DateFormat.Hm().format(parseDate);
    var day = parseDate.day;
    var month = months[parseDate.month - 1];
    var year = parseDate.year;

    return GestureDetector(
      onTap: () {
        if (controller.isCheckListOpen) {
          if (!isRead) {
            controller.toggleCheckBoxItem(item.sId);
          } else {
            showAlert(message: "select only unread notifications");
          }
          return;
        }
        itemAdapter.redirect();
        if (!isRead) {
          markAsRead(item.sId);
        }
      },
      child: Opacity(
        opacity: isRead ? 0.7 : 1,
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 23.w, vertical: 2.5.w),
          padding: EdgeInsets.symmetric(vertical: 9.w, horizontal: 10.w),
          decoration: BoxDecoration(
            color: isRead ? Colors.white : Color(0xffFFEEC3),
            borderRadius: BorderRadius.circular(10.w),
            boxShadow: [
              BoxShadow(
                color:
                    isRead ? Colors.transparent : Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 3,
                offset: Offset(0, 1), // changes position of shadow
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 10.0, bottom: 10),
                        child: AvatarCustom(
                            color: Colors.white,
                            height: 34.w,
                            child: Image.network(
                              getPhotoUrl(url: itemAdapter.photoUrl),
                              fit: BoxFit.cover,
                              height: 34.w,
                              width: 34.w,
                            )),
                      ),
                      Positioned(
                          bottom: 5,
                          right: 10,
                          child: AvatarCustom(
                              height: 16,
                              child: Center(child: itemAdapter.icon))),
                    ],
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                                child: Text(
                              removeHtmlTag(itemAdapter.content),
                              style: TextStyle(
                                  fontSize: 11.w,
                                  fontWeight: isRead
                                      ? FontWeight.w600
                                      : FontWeight.bold),
                            )),
                            SizedBox(
                              width: 10,
                            ),
                            isRead
                                ? Container()
                                : Badge(
                                    animationType: BadgeAnimationType.fade,
                                    badgeContent: Text(
                                      filteredActivities.length.toString(),
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 11.w),
                                    ),
                                  ),
                            controller.isCheckListOpen && !isRead
                                ? Obx(() {
                                    int checkIndexItemOnListSelected =
                                        controller.listSelectedItem
                                            .indexWhere((o) => o == item.sId);
                                    bool isItemSelected =
                                        checkIndexItemOnListSelected >= 0
                                            ? true
                                            : false;
                                    return Checkbox(
                                        activeColor: Color(0xff42E591),
                                        value: isItemSelected,
                                        onChanged: (value) {
                                          controller
                                              .toggleCheckBoxItem(item.sId);
                                        });
                                  })
                                : SizedBox()
                          ],
                        ),
                        SizedBox(
                          height: 4,
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.sender.fullName == ''
                                  ? 'Cicle'
                                  : item.sender.fullName,
                              style: TextStyle(fontSize: 9.w),
                            ),
                            Text(
                              ' - ',
                              style: TextStyle(fontSize: 9.w),
                            ),
                            Flexible(
                                child: Text(
                              item.team!.name == ''
                                  ? 'Reminder'
                                  : item.team!.name,
                              style: TextStyle(fontSize: 9.w),
                            )),
                          ],
                        ),
                        SizedBox(
                          height: 4,
                        ),
                        Align(
                            alignment: Alignment.bottomLeft,
                            child: Text('$day $month $year $time',
                                style: TextStyle(
                                    fontSize: 9.w, color: Color(0xff708FC7)))),
                      ],
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
