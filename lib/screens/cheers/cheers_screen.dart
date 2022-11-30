import 'package:cicle_mobile_f3/controllers/cheers_sumary_controller.dart';

import 'package:cicle_mobile_f3/controllers/profile_controller.dart';

import 'package:cicle_mobile_f3/models/notif_as_cheers_model.dart';
import 'package:cicle_mobile_f3/utils/helpers.dart';
import 'package:cicle_mobile_f3/utils/notification_as_cheers_type_adapter.dart';
import 'package:cicle_mobile_f3/widgets/avatar_custom.dart';
import 'package:cicle_mobile_f3/widgets/cheer_item.dart';
import 'package:cicle_mobile_f3/widgets/comment_item.dart';
import 'package:cicle_mobile_f3/widgets/error_something_wrong.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'dart:math' as math;

class CheersScreen extends StatelessWidget {
  CheersScreen({Key? key}) : super(key: key);

  CheersSumaryController _cheersSumaryController =
      Get.put(CheersSumaryController());

  RefreshController refreshController =
      RefreshController(initialRefresh: false);

  void onRefresh() async {
    await _cheersSumaryController.refresh();
    refreshController.refreshCompleted();
  }

  void onLoadMore() async {
    print('load more');
    await _cheersSumaryController.getMore();
    print('load more done');

    refreshController.loadComplete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Row(
          children: [
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
          ],
        ),
      ),
      body: Obx(() {
        if (_cheersSumaryController.isLoading) {
          return Center(child: CircularProgressIndicator());
        }

        if (!_cheersSumaryController.isLoading &&
            _cheersSumaryController.errorMessage != '') {
          return Center(
              child: ErrorSomethingWrong(
            refresh: onRefresh,
            message: _cheersSumaryController.errorMessage,
          ));
        }

        if (!_cheersSumaryController.isLoading &&
            _cheersSumaryController.list.isEmpty) {
          return _hasEmptyData();
        }

        return _hasData();
      }),
    );
  }

  SmartRefresher _hasEmptyData() {
    var column = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          margin: EdgeInsets.symmetric(horizontal: 34, vertical: 20),
          padding: EdgeInsets.symmetric(horizontal: 50.w),
          width: 306.w,
          height: Get.height - 140,
          child: Center(
            child: Text(
              'No cheers found\nStart cheering others so you can have it too! 😀',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11.sp, color: Color(0xffB5B5B5)),
            ),
          ),
        )
      ],
    );
    return SmartRefresher(
      header: WaterDropMaterialHeader(),
      controller: refreshController,
      onRefresh: () => onRefresh(),
      child: ListView.builder(
          padding: EdgeInsets.only(top: 4),
          itemCount: 1,
          itemBuilder: (ctx, index) {
            return column;
          }),
    );
  }

  Image _buildHeader() {
    return Image.asset(
      'assets/images/header_cheers.png',
      fit: BoxFit.fitWidth,
      width: double.infinity,
    );
  }

  SliverPersistentHeader makeHeader() {
    return SliverPersistentHeader(
      pinned: true,
      delegate: _SliverAppBarDelegate(
        minHeight: 60.0,
        maxHeight: 146.0,
        child: _buildHeader(),
      ),
    );
  }

  Obx _hasData() {
    return Obx(() => SmartRefresher(
          enablePullUp: true,
          header: WaterDropMaterialHeader(),
          controller: refreshController,
          onRefresh: () => onRefresh(),
          onLoading: () => onLoadMore(),
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
          child: CustomScrollView(
            slivers: <Widget>[
              makeHeader(),
              SliverList(
                delegate: SliverChildListDelegate(
                  _cheersSumaryController.list
                      .asMap()
                      .map((key, value) => MapEntry(
                          key,
                          ListItem(
                            item: _cheersSumaryController.list[key],
                            index: key,
                            list: _cheersSumaryController.list,
                          )))
                      .values
                      .toList(),
                ),
              ),
            ],
          ),
        ));
  }
}

class ListItem extends StatelessWidget {
  ListItem({
    Key? key,
    required this.item,
    required this.list,
    required this.index,
  }) : super(key: key);

  final NotifAsCheersModel item;
  final List<NotifAsCheersModel> list;
  final int index;
  ProfileController _profileController = Get.put(ProfileController());

  @override
  Widget build(BuildContext context) {
    NotifCheersAdapterModel itemAdapter =
        NotificationAsCheersTypeAdapter.init(item);

    bool isSameFirstDay = checkIsSameFirstDay(list, index);
    String dateCummon =
        DateFormat.yMEd().format(DateTime.parse(item.createdAt).toLocal());
    String dateTimeAgo =
        timeago.format(DateTime.parse(item.createdAt).toLocal());
    bool isCreatedAtMoreThan3dayAgo =
        calculateDifference(DateTime.parse(item.createdAt).toLocal()) <= -3
            ? true
            : false;
    return GestureDetector(
      onTap: () {
        itemAdapter.redirect();
      },
      child: Column(
        children: [
          isSameFirstDay
              ? Container(
                  margin: EdgeInsets.symmetric(vertical: 20),
                  decoration: BoxDecoration(
                      color: Color(0xffFFEEC3),
                      borderRadius: BorderRadius.circular(20)),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 2.0, horizontal: 20),
                    child: Text(
                      isCreatedAtMoreThan3dayAgo ? dateCummon : dateTimeAgo,
                      style: TextStyle(fontSize: 11, color: Color(0xffFDC532)),
                    ),
                  ),
                )
              : Container(
                  margin: EdgeInsets.symmetric(vertical: 15),
                ),
          Container(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 23,
                ),
                Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10.0),
                      child: AvatarCustom(
                          height: 28,
                          child: Image.network(
                            getPhotoUrl(url: _profileController.photoUrl),
                            width: 28,
                            height: 28,
                            fit: BoxFit.cover,
                          )),
                    ),
                    Positioned(
                        bottom: 2,
                        right: 6,
                        child: AvatarCustom(
                            height: 16, child: Center(child: itemAdapter.icon)))
                  ],
                ),
                SizedBox(
                  width: 6,
                ),
                Container(
                    decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Color(0xffC1D6FD)),
                        borderRadius: BorderRadius.circular(5)),
                    width: Get.width / 2.75,
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(itemAdapter.title,
                            style: TextStyle(
                                fontSize: 12, fontWeight: FontWeight.w800)),
                        SizedBox(
                          height: 11,
                        ),
                        itemAdapter.content == ''
                            ? SizedBox()
                            : Text(itemAdapter.content,
                                style: TextStyle(fontSize: 9)),
                        itemAdapter.content == ''
                            ? SizedBox()
                            : SizedBox(
                                height: 11,
                              ),
                        Text(
                          item.team.name,
                          style:
                              TextStyle(color: Color(0xff7A7A7A), fontSize: 7),
                        )
                      ],
                    )),
                SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: Container(
                    child: Wrap(
                      children: [
                        ...item.cheers
                            .asMap()
                            .map((key, value) => MapEntry(
                                  key,
                                  CheerItem(
                                      height: 20,
                                      fontSize: 10,
                                      bgColor: Colors.white,
                                      borderColor: Color(0xffF0F1F7),
                                      item: value),
                                ))
                            .values
                            .toList()
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate({
    required this.minHeight,
    required this.maxHeight,
    required this.child,
  });
  final double minHeight;
  final double maxHeight;
  final Widget child;
  @override
  double get minExtent => minHeight;
  @override
  double get maxExtent => math.max(maxHeight, minHeight);
  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return new SizedBox.expand(child: child);
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return maxHeight != oldDelegate.maxHeight ||
        minHeight != oldDelegate.minHeight ||
        child != oldDelegate.child;
  }
}
