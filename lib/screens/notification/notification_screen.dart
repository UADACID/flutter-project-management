import 'dart:io';

import 'package:badges/badges.dart';
import 'package:cicle_mobile_f3/controllers/notification_controller.dart';
import 'package:cicle_mobile_f3/controllers/notification_counter_controller.dart';
import 'package:cicle_mobile_f3/controllers/notification_list_controller.dart';
import 'package:cicle_mobile_f3/controllers/search_controller.dart';
import 'package:cicle_mobile_f3/controllers/tab_main_controller.dart';
import 'package:cicle_mobile_f3/screens/notification/notification_list.dart';
import 'package:cicle_mobile_f3/utils/constant.dart';
import 'package:cicle_mobile_f3/utils/helpers.dart';
import 'package:cicle_mobile_f3/widgets/default_alert.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lazy_load_indexed_stack/lazy_load_indexed_stack.dart';

import 'notification_filter_drawer.dart';

class NotificationScreen extends StatelessWidget {
  NotificationScreen({Key? key, this.parentScaffoldKey}) : super(key: key);
  TabMainController _tabMainController = Get.find();

  final parentScaffoldKey;

  final GlobalKey<ScaffoldState> _key = GlobalKey(); // Create a key

  NotificationController _notificationController =
      Get.put(NotificationController());

  NotificationCounterController _notificationCounterController = Get.find();

  @override
  Widget build(BuildContext context) {
    var appBar = AppBar();
    double appBarHeight = appBar.preferredSize.height;
    double statusBarHeight = MediaQuery.of(context).viewPadding.top;
    return Scaffold(
      key: _key,
      endDrawer: NotificationFilterDrawer(),
      onEndDrawerChanged: (bool value) {
        _tabMainController.isTabHide.value = value;
      },
      body: Stack(
        children: [
          Obx(() => _notificationController.isLoading
              ? Align(
                  alignment: Alignment.center,
                  child: CircularProgressIndicator())
              : LazyLoadIndexedStack(
                  index: _notificationController.activeTabIndex,
                  children: [
                    ..._notificationController.listTabItem
                        .asMap()
                        .map((key, value) => MapEntry(
                              key,
                              GetX<NotificationListController>(
                                  tag: value.id,
                                  init: NotificationListController(),
                                  initState: (state) {
                                    state.controller!.getData(
                                        value.id,
                                        _notificationController
                                            .activeCompanyId);
                                    // }
                                  },
                                  builder: (controller) {
                                    return Container(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          SizedBox(
                                            height: statusBarHeight,
                                          ),
                                          Container(
                                            height: appBarHeight,
                                            color: Colors.white,
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Row(
                                                  children: [
                                                    _buttonToCheersScreen(),
                                                    SizedBox(
                                                      width: 4,
                                                    ),
                                                    _buildFilterButton(),
                                                  ],
                                                ),
                                                controller.isCheckListOpen
                                                    ? Stack(
                                                        alignment:
                                                            AlignmentDirectional
                                                                .center,
                                                        children: [
                                                          _buildActionCheckListOpen(
                                                              controller),
                                                          controller
                                                                  .isLoadingOverlay
                                                              ? GestureDetector(
                                                                  onTap: () {
                                                                    showAlert(
                                                                        message:
                                                                            'waiting for mark selected notif as read');
                                                                  },
                                                                  child:
                                                                      Container(
                                                                    width: 150,
                                                                    height: 35,
                                                                    color: Colors
                                                                        .transparent,
                                                                  ),
                                                                )
                                                              : SizedBox()
                                                        ],
                                                      )
                                                    : IconButton(
                                                        onPressed: () {
                                                          if (!controller
                                                              .canMarkAll) {
                                                            Get.dialog(
                                                                DefaultAlert(
                                                                    hideCancel:
                                                                        true,
                                                                    onSubmit:
                                                                        () {
                                                                      Get.back();
                                                                    },
                                                                    onCancel:
                                                                        () {
                                                                      Get.back();
                                                                    },
                                                                    title:
                                                                        'there is no unread item notification in the current list, you can try to keep scrolling down to find it'));
                                                            return;
                                                          }
                                                          controller
                                                                  .isCheckListOpen =
                                                              true;
                                                        },
                                                        icon: Icon(
                                                          Icons.checklist_rtl,
                                                          color:
                                                              Color(0xff708FC7),
                                                        ))
                                              ],
                                            ),
                                          ),
                                          SizedBox(
                                            height: 60,
                                          ),
                                          Expanded(
                                            child: controller.isLoading
                                                ? Center(
                                                    child:
                                                        CircularProgressIndicator())
                                                : Stack(
                                                    children: [
                                                      NotificationList(
                                                        id: value.id,
                                                        index: key,
                                                        activeId:
                                                            _notificationController
                                                                .activeTabId
                                                                .value,
                                                        controller: controller,
                                                      ),
                                                      controller
                                                              .isLoadingOverlay
                                                          ? Container(
                                                              color: Colors
                                                                  .black
                                                                  .withOpacity(
                                                                      0.5),
                                                              child: Center(
                                                                  child:
                                                                      CircularProgressIndicator()),
                                                            )
                                                          : SizedBox()
                                                    ],
                                                  ),
                                          )
                                          // _buildContentTab(),
                                        ],
                                      ),
                                    );
                                  }),
                            ))
                        .values
                        .toList(),
                  ],
                )),
          Obx(() => _notificationController.isLoading
              ? SizedBox()
              : Positioned(
                  top: statusBarHeight + appBarHeight,
                  child: _buildListTab(appBarHeight)))
        ],
      ),
    );
  }

  GestureDetector _buildFilterButton() {
    return GestureDetector(
      onTap: () {
        _key.currentState!.openEndDrawer();
      },
      child: Container(
        padding: EdgeInsets.all(4),
        decoration: BoxDecoration(
            border: Border.all(color: Color(0xffD6D6D6)),
            borderRadius: BorderRadius.circular(4)),
        child: Icon(Icons.filter_alt_outlined, color: Color(0xffB5B5B5)),
      ),
    );
  }

  Row _buildActionCheckListOpen(NotificationListController controller) {
    return Row(
      children: [
        IconButton(
            onPressed: () {
              controller.isCheckListOpen = false;
            },
            icon: Icon(
              Icons.close,
              color: Color(0xffFF7171),
            )),
        IconButton(
            onPressed: () {
              Get.dialog(DefaultAlert(
                  onSubmit: () {
                    Get.back();
                    controller.markAllSelectionAsRead();
                  },
                  onCancel: () {
                    Get.back();
                  },
                  title:
                      "are you sure to mark all selected notifications as read"));
            },
            icon: Icon(
              Icons.done_all,
              color: Color(0xff42E591),
            )),
        Checkbox(
            activeColor: Color(0xff42E591),
            value: controller.isCheckAll,
            onChanged: (value) {
              controller.toggleCheckAll(value!);
            }),
      ],
    );
  }

  InkWell _buttonToCheersScreen() {
    return InkWell(
      onTap: () {
        String teamId = Get.parameters['teamId'] ?? '';
        String companyId = Get.parameters['companyId'] ?? '';
        String path = '${RouteName.cheersScreen(companyId)}?teamId=$teamId';
        Get.put(SearchController()).insertListRecenlyViewed(RecentlyViewed(
            moduleName: 'Cheers',
            companyId: companyId,
            path: path,
            teamName: ' ',
            title: 'Cheers Summary',
            subtitle: 'Home  >  Notification  >  Cheers',
            uniqId: 'Cheers'));
        Get.toNamed(path);
      },
      child: Container(
        margin: EdgeInsets.only(left: Platform.isIOS ? 16 : 16),
        padding: EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
            border: Border.all(color: Color(0xffFFE49B)),
            borderRadius: BorderRadius.circular(20)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 10,
            ),
            Image.asset(
              'assets/images/cheers.png',
              fit: BoxFit.contain,
              width: 24,
              height: 24,
            ),
            SizedBox(
              width: 6,
            ),
            Text('Cheers',
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xffF0B418))),
            SizedBox(
              width: 10,
            ),
          ],
        ),
      ),
    );
  }

  Obx _buildListTab(double height) {
    return Obx(() => Container(
          height: height,
          width: Get.width,
          color: Colors.white,
          child: SingleChildScrollView(
            controller: _notificationController.listTabsScrollController,
            scrollDirection: Axis.horizontal,
            child: Row(
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

                      return MapEntry(
                          key,
                          Stack(
                            children: [
                              _buildTabItem(key, value, counter),
                              value.id == 'all' || value.id == 'all_unread'
                                  ? _buildCounterAll(value)
                                  : _buildCounterTeam(counter)
                            ],
                          ));
                    })
                    .values
                    .toList()
              ],
            ),
          ),
        ));
  }

  Positioned _buildCounterAll(TabNotifItem value) {
    return Positioned(
        top: 0,
        right: 10,
        child: _notificationCounterController.counterUnreadNonChat == 0
            ? SizedBox()
            : value.id == 'all'
                ? SizedBox()
                : Badge(
                    badgeColor: Color(0xffEF665D),
                    shape: _notificationCounterController.counterUnreadNonChat
                                .toString()
                                .length >
                            1
                        ? BadgeShape.square
                        : BadgeShape.circle,
                    borderRadius: BorderRadius.circular(50),
                    badgeContent: Text(
                      _notificationCounterController.counterUnreadNonChat
                          .toString(),
                      style: TextStyle(color: Colors.white, fontSize: 10),
                    ),
                  ));
  }

  Positioned _buildCounterTeam(int counter) {
    return Positioned(
        top: 0,
        right: 10,
        child: counter == 0
            ? SizedBox()
            : Badge(
                badgeColor: Color(0xffEF665D),
                shape: counter.toString().length > 1
                    ? BadgeShape.square
                    : BadgeShape.circle,
                borderRadius: BorderRadius.circular(50),
                badgeContent: Text(
                  counter.toString(),
                  style: TextStyle(color: Colors.white, fontSize: 10),
                ),
              ));
  }

  Widget _buildTabItem(int key, TabNotifItem value, int counter) {
    if (counter == 0 && _notificationController.activeTabId.value == value.id) {
      return _tabTeamItem(key, value);
    }
    if (counter == 0 && value.id.length > 10) {
      return SizedBox();
    }
    return _tabTeamItem(key, value);
  }

  Container _tabTeamItem(int key, TabNotifItem value) {
    return Container(
      margin: EdgeInsets.only(right: 16, left: key == 0 ? 16 : 0, top: 10),
      child: GestureDetector(
        onTap: () {
          _notificationController.setIndex(key, value.id);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
              color: _notificationController.activeTabId.value == value.id
                  ? Color(0xffFFEEC3)
                  : Colors.transparent,
              border: Border.all(
                  width: 2,
                  color: _notificationController.activeTabId.value == value.id
                      ? Color(0xffFFEEC3)
                      : Color(0xffECECEC)),
              borderRadius: BorderRadius.circular(25)),
          child: Text(
            value.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                color: _notificationController.activeTabId.value == value.id
                    ? Color(0xffF0B418)
                    : Color(0xffB5B5B5)),
          ),
        ),
      ),
    );
  }
}
