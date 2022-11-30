import 'package:badges/badges.dart';
import 'package:cicle_mobile_f3/controllers/notification_all_controller.dart';
import 'package:cicle_mobile_f3/controllers/private_chat_controller.dart';
import 'package:cicle_mobile_f3/controllers/search_controller.dart';
import 'package:cicle_mobile_f3/models/member_model.dart';
import 'package:cicle_mobile_f3/models/notification_item_model.dart';
import 'package:cicle_mobile_f3/utils/constant.dart';
import 'package:cicle_mobile_f3/utils/helpers.dart';
import 'package:cicle_mobile_f3/widgets/avatar_custom.dart';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class ChatItem extends StatelessWidget {
  ChatItem({
    Key? key,
    required this.item,
  }) : super(key: key);
  final DummyChatItemModel item;
  final box = GetStorage();
  PrivateChatController _privateChatController = Get.find();
  NotificationAllController _notificationAllController =
      Get.put(NotificationAllController());

  @override
  Widget build(BuildContext context) {
    final userString = box.read(KeyStorage.logedInUser);
    MemberModel _templogedInUser = MemberModel.fromJson(userString);
    MemberModel member = item.members
        .firstWhere((element) => element.sId != _templogedInUser.sId);

    return Obx(() {
      String _userId = _templogedInUser.sId;
      List<String> checkIds = [_userId];
      List<Activities> filteredActivities = [];
      List<NotificationItemModel> notifForThisChatItem = _privateChatController
          .listNotifChat
          .where((element) => element.service.serviceId == item.id)
          .toList();
      if (notifForThisChatItem.isNotEmpty) {
        filteredActivities = notifForThisChatItem[0]
            .activities
            .where((activity) => !activity.readBy
                .any((element) => checkIds.contains(element.reader)))
            .toList();
      }
      return InkWell(
        onTap: () {
          if (filteredActivities.isNotEmpty) {
            _notificationAllController
                .updateNotifItemAsRead(notifForThisChatItem[0].sId);
          }

          String? teamId = Get.parameters['teamId'];
          String companyId = Get.parameters['companyId'] ?? '';
          String path =
              '${RouteName.privateChatDetailScreen(companyId, item.id)}?teamId=$teamId';
          // handle for history viewed
          Get.put(SearchController()).insertListRecenlyViewed(RecentlyViewed(
              moduleName: 'private-chat-detail',
              companyId: companyId,
              path: path,
              teamName: ' ',
              title: member.fullName,
              subtitle: 'Home  >  Menu  >  Inbox  >  ${member.fullName}',
              uniqId: item.id));
          Get.toNamed(path);
        },
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.symmetric(vertical: 10.w),
              margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 2.5),
              decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 0.5,
                      offset: Offset(0, 0), // changes position of shadow
                    ),
                  ],
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10.w)),
              child: Row(
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10.w),
                    child: AvatarCustom(
                      height: 43.w,
                      child: Image.network(
                        getPhotoUrl(url: member.photoUrl),
                        height: 43.w,
                        width: 43.w,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          member.fullName,
                          style: TextStyle(
                              fontSize: 12.w, fontWeight: FontWeight.bold),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(
                          height: 2.w,
                        ),
                        Text(
                          removeHtmlTag(item.lastMessage.content),
                          style: TextStyle(
                              fontSize: 11.w, fontWeight: FontWeight.normal),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: filteredActivities.isEmpty
                        ? SizedBox()
                        : Badge(
                            animationType: BadgeAnimationType.scale,
                            padding: EdgeInsets.symmetric(
                                vertical: 2.w, horizontal: 5.w),
                            shape: BadgeShape.circle,
                            animationDuration: Duration(milliseconds: 200),
                            badgeContent: Text(
                              filteredActivities.length.toString(),
                              style: TextStyle(
                                  fontSize: 10.w, color: Colors.white),
                            ),
                          ),
                  ),
                  SizedBox(
                    width: 15,
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 2,
            )
          ],
        ),
      );
    });
  }
}
