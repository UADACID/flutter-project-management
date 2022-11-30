import 'package:badges/badges.dart';
import 'package:cicle_mobile_f3/controllers/notification_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NotificationFilterDrawer extends StatelessWidget {
  NotificationFilterDrawer({Key? key}) : super(key: key);
  NotificationController _notificationController = Get.find();

  @override
  Widget build(BuildContext context) {
    double statusBarHeight = MediaQuery.of(context).viewPadding.top;

    return Container(
      width: GetPlatform.isMobile ? Get.width - 50 : 342,
      color: Colors.white,
      child: Column(
        children: [
          SizedBox(
            height: statusBarHeight,
          ),
          _buildHeader(),
          Divider(),
          SizedBox(
            height: 4,
          ),
          _buildDefaultView(),
          SizedBox(
            height: 19,
          ),
          _buildSearchTeam(),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [_buildTeamFilter()],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Container _buildSearchTeam() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text('Team filter'),
              GestureDetector(
                onTap: () {
                  _notificationController.resetFilter();
                  Get.back();
                },
                child: Padding(
                  padding: const EdgeInsets.only(left: 8.0, bottom: 8),
                  child: Text(
                    'reset',
                    style: TextStyle(color: Color(0xffFF7171)),
                  ),
                ),
              ),
            ],
          ),
          TextField(
            controller: _notificationController.searchKeyFilterController,
            style: TextStyle(fontSize: 12),
            onChanged: (value) {
              _notificationController.searchKeyFilter = value;
            },
            decoration: InputDecoration(
              isDense: true,
              fillColor: Colors.white,
              filled: true,
              contentPadding: EdgeInsets.fromLTRB(15, 15, 10, 15),
              hintText: "Search teams...",
              hintStyle: TextStyle(color: Color(0xffB5B5B5), fontSize: 11),
              enabledBorder: OutlineInputBorder(
                borderRadius: new BorderRadius.circular(10),
                borderSide: BorderSide(color: Color(0xffD6D6D6)),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(10),
                ),
              ),
              prefixIconConstraints:
                  BoxConstraints(maxHeight: 20, minWidth: 40),
              suffixIconConstraints:
                  BoxConstraints(maxHeight: 20, minWidth: 40),
              prefixIcon: Icon(
                Icons.search,
                color: Color(0xffFDC532),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Container _buildTeamFilter() => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Obx(() => Column(
              children: [
                ..._notificationController.listTabItem
                    .asMap()
                    .map((key, value) {
                      int counter = 0;
                      var selectedTeamWithCounter = _notificationController
                          .listTeamWithCounter
                          .where((o) => o.id == value.id)
                          .toList();
                      if (selectedTeamWithCounter.isNotEmpty) {
                        counter = selectedTeamWithCounter[0].unreadNotification;
                      }

                      bool matchWithSearchKey = value.name
                          .toLowerCase()
                          .contains(_notificationController.searchKeyFilter
                              .toLowerCase());

                      if (value.id == 'all' || value.id == 'all_unread') {
                        return MapEntry(key, SizedBox());
                      }
                      if (counter == 0 &&
                          _notificationController.activeTabId.value ==
                              value.id) {
                        return MapEntry(
                            key,
                            counter == 0 && matchWithSearchKey
                                ? _buildTeamItem(value, counter)
                                : SizedBox());
                      }
                      return MapEntry(
                          key,
                          counter != 0 && matchWithSearchKey
                              ? _buildTeamItem(value, counter)
                              : SizedBox());
                    })
                    .values
                    .toList()
              ],
            )),
      );

  GestureDetector _buildTeamItem(TabNotifItem value, int counter) {
    return GestureDetector(
      onTap: () async {
        _notificationController.activeTabId.value = value.id;
        await Future.delayed(Duration(milliseconds: 300));
        Get.back();
      },
      child: Container(
          margin: EdgeInsets.only(top: 6),
          padding: EdgeInsets.only(top: 7.5, bottom: 7.5, left: 12, right: 12),
          width: double.infinity,
          decoration: BoxDecoration(
              border: Border.all(color: Color(0xffD6D6D6)),
              borderRadius: BorderRadius.circular(5)),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Flexible(
                      child: Text(
                        value.name,
                        style: TextStyle(color: Color(0xff7A7A7A)),
                      ),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    counter == 0
                        ? SizedBox()
                        : Badge(
                            badgeColor: Color(0xffEF665D),
                            badgeContent: Text(
                              counter.toString(),
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                  ],
                ),
              ),
              Container(
                height: 20,
                width: 20,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(width: 2, color: Color(0xffB5B5B5))),
                child: _notificationController.activeTabId.value == value.id
                    ? _buildRadioDotSelected()
                    : SizedBox(),
              )
            ],
          )),
    );
  }

  Container _buildRadioDotSelected() {
    return Container(
        margin: EdgeInsets.all(2),
        height: 10,
        width: 10,
        decoration:
            BoxDecoration(shape: BoxShape.circle, color: Color(0xff708FC7)));
  }

  Row _buildHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        IconButton(
            onPressed: () {
              Get.back();
            },
            icon: Icon(Icons.arrow_back_outlined)),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Filter Notification',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xff262727),
                  fontWeight: FontWeight.w600,
                )),
            Text('Set what notifications you want to see',
                style: TextStyle(
                  fontSize: 11,
                  color: Color(0xff7A7A7A),
                )),
          ],
        ),
      ],
    );
  }

  Obx _buildDefaultView() {
    return Obx(() => Container(
          margin: EdgeInsets.symmetric(horizontal: 12),
          padding: EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
              border: Border.all(color: Color(0xffD6D6D6)),
              borderRadius: BorderRadius.circular(4)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 12,
              ),
              Text('Default view'),
              ListTile(
                dense: true,
                minLeadingWidth: 0,
                contentPadding: EdgeInsets.zero,
                title: InkWell(
                    onTap: () {
                      _notificationController.defaultNotificationView.value =
                          DefaultNotificationView.allUnread;
                    },
                    child: const Text(
                      'All unread notifs',
                      style: TextStyle(color: Color(0xff7A7A7A)),
                    )),
                leading: Radio<DefaultNotificationView>(
                  visualDensity: const VisualDensity(
                    horizontal: VisualDensity.minimumDensity,
                    vertical: VisualDensity.minimumDensity,
                  ),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  activeColor: Color(0xff708FC7),
                  value: DefaultNotificationView.allUnread,
                  groupValue:
                      _notificationController.defaultNotificationView.value,
                  onChanged: (DefaultNotificationView? value) {
                    _notificationController.defaultNotificationView.value =
                        value!;
                  },
                ),
              ),
              ListTile(
                dense: true,
                minLeadingWidth: 0,
                contentPadding: EdgeInsets.zero,
                title: InkWell(
                    onTap: () {
                      _notificationController.defaultNotificationView.value =
                          DefaultNotificationView.byGroup;
                    },
                    child: const Text('By group/Division notifs',
                        style: TextStyle(color: Color(0xff7A7A7A)))),
                leading: Radio<DefaultNotificationView>(
                  visualDensity: const VisualDensity(
                    horizontal: VisualDensity.minimumDensity,
                    vertical: VisualDensity.minimumDensity,
                  ),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  activeColor: Color(0xff708FC7),
                  value: DefaultNotificationView.byGroup,
                  groupValue:
                      _notificationController.defaultNotificationView.value,
                  onChanged: (DefaultNotificationView? value) {
                    _notificationController.defaultNotificationView.value =
                        value!;
                  },
                ),
              ),
            ],
          ),
        ));
  }
}
