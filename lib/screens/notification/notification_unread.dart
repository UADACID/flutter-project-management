import 'package:cicle_mobile_f3/controllers/notification_counter_controller.dart';
import 'package:cicle_mobile_f3/controllers/notification_unread_controller.dart';
import 'package:cicle_mobile_f3/models/notification_item_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class NotificationUnread extends StatelessWidget {
  NotificationUnread({
    Key? key,
  }) : super(key: key);

  NotificationUnreadController _notificationUnreadController =
      Get.put(NotificationUnreadController());
  NotificationCounterController _notificationCounterController =
      Get.put(NotificationCounterController());
  RefreshController refreshController =
      RefreshController(initialRefresh: false);

  void onRefresh() async {
    _notificationCounterController.init();
    await _notificationUnreadController.refresh();
    refreshController.refreshCompleted();
  }

  void onLoadMore() async {
    await _notificationUnreadController.loadMore();
    refreshController.loadComplete();
  }

  void onLongPress() {
    print('on long press');
    _notificationUnreadController.canSelect =
        !_notificationUnreadController.canSelect;
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (_notificationUnreadController.isLoading &&
          _notificationUnreadController.notificationList.length == 0) {
        return Container(
          child: Scaffold(
            body: Center(child: CircularProgressIndicator()),
          ),
        );
      }

      if (!_notificationUnreadController.isLoading &&
          _notificationUnreadController.notificationList.isEmpty) {
        return SmartRefresher(
          controller: refreshController,
          onRefresh: onRefresh,
          child: Container(
            height: 200,
            child: Center(
              child: Text(
                'You have no unread notification at the moment!',
                style: TextStyle(color: Colors.grey.withOpacity(0.5)),
              ),
            ),
          ),
        );
      }

      return _buildWithData();
    });
  }

  markAsRead(String notifId) {
    _notificationUnreadController.updateNotifItemAsRead(notifId);
  }

  Obx _buildWithData() {
    return Obx(() => SmartRefresher(
          enablePullUp: true,
          physics: BouncingScrollPhysics(),
          header: WaterDropMaterialHeader(),
          controller: refreshController,
          onRefresh: onRefresh,
          onLoading: onLoadMore,
          footer: CustomFooter(
            builder: (BuildContext context, LoadStatus? mode) {
              Widget body;
              if (mode == LoadStatus.idle) {
                body = SizedBox();
              } else if (mode == LoadStatus.loading) {
                body = CircularProgressIndicator();
              } else if (mode == LoadStatus.failed) {
                body = Text("Load Failed!Click retry!");
              } else if (mode == LoadStatus.canLoading) {
                body = Text("release to load more");
              } else {
                body = Text("No more Data");
              }
              return Container(
                height: 55.0,
                child: Center(child: body),
              );
            },
          ),
          child: ListView.builder(
              itemCount: _notificationUnreadController.notificationList.length,
              padding: EdgeInsets.only(top: 10),
              itemBuilder: (ctx, index) {
                NotificationItemModel item =
                    _notificationUnreadController.notificationList[index];
                if (item.service.serviceType == 'chatMention' ||
                    item.service.serviceType == 'chat') {
                  return SizedBox();
                }

                return SizedBox();
              }),
        ));
  }
}
