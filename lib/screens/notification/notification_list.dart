import 'package:cicle_mobile_f3/controllers/notification_list_controller.dart';

import 'package:cicle_mobile_f3/models/notification_item_model.dart';
import 'package:cicle_mobile_f3/screens/notification/notification_item.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class NotificationList extends StatelessWidget {
  NotificationList(
      {Key? key,
      required this.id,
      required this.index,
      required this.activeId,
      required this.controller})
      : super(key: key);

  final String id;
  final int index;
  final String activeId;
  final NotificationListController controller;

  RefreshController refreshController =
      RefreshController(initialRefresh: false);

  void onRefresh() async {
    await controller.refresh();

    refreshController.refreshCompleted();
  }

  void onLoadMore() async {
    await controller.loadMore();
    refreshController.loadComplete();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Obx(() {
        if (controller.notificationList.isEmpty) {
          return _buildEmpty();
        }
        return SmartRefresher(
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
              padding: EdgeInsets.zero,
              itemCount: controller.notificationList.length,
              itemBuilder: (_, index) {
                NotificationItemModel item = controller.notificationList[index];
                return NotificationItem(
                    controller: controller,
                    item: item,
                    onLongPress: () {},
                    canSelect: false,
                    markAsRead: (String notificationId) {
                      controller.updateNotifItemAsRead(notificationId);
                    });
              }),
        );
      }),
    );
  }

  SmartRefresher _buildEmpty() {
    return SmartRefresher(
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
          padding: EdgeInsets.zero,
          itemCount: 1,
          itemBuilder: (_, index) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 100.0, left: 66, right: 66),
                child: Column(
                  children: [
                    Image.asset(
                        'assets/images/notification-list-empty-state.png'),
                    Text(
                      'All set',
                      style: TextStyle(color: Color(0xffB5B5B5)),
                    ),
                    Text('Your newest notification will appear here',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Color(0xffB5B5B5)))
                  ],
                ),
              ),
            );
          }),
    );
  }
}
