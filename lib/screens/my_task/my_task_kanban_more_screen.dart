import 'package:cicle_mobile_f3/controllers/my_task_controller.dart';
import 'package:cicle_mobile_f3/controllers/my_task_kanban_more_controller.dart';
import 'package:cicle_mobile_f3/utils/constant.dart';
import 'package:cicle_mobile_f3/widgets/card_item_custom.dart';
import 'package:cicle_mobile_f3/widgets/error_something_wrong.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'my_task_filter.dart';

class MyTaskKanbanMoreScreen extends StatelessWidget {
  MyTaskKanbanMoreScreen({Key? key}) : super(key: key);

  final MyTaskKanbanMoreController _myTaskKanbanMoreController = Get.find();
  MyTaskController _myTaskController = Get.find();
  String companyId = Get.parameters['companyId'] ?? '';

  RefreshController refreshController =
      RefreshController(initialRefresh: false);

  RefreshController emptyRefreshController =
      RefreshController(initialRefresh: false);

  @override
  Widget build(BuildContext context) {
    String _dueType = Get.parameters['dueType'] ?? '';
    String _title = 'My Task - Kanban';
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_title),
            Text(
              _dueType,
              style: TextStyle(
                  fontSize: 12,
                  color: Color(0xff708FC7),
                  fontWeight: FontWeight.w600),
            )
          ],
        ),
        centerTitle: false,
        actions: [
          IconButton(
              onPressed: () {
                Get.dialog(MyTaskFilter());
              },
              icon: Obx(() => Icon(
                    Icons.filter_alt_outlined,
                    color: _myTaskController.hasFilter()
                        ? Color(0xffF0B418)
                        : Color(0xffB5B5B5),
                  )))
        ],
      ),
      body: Container(
          padding: EdgeInsets.symmetric(horizontal: 23),
          child: Obx(
            () {
              if (_myTaskKanbanMoreController.isLoading &&
                  _myTaskKanbanMoreController.cards.isEmpty) {
                return Center(child: CircularProgressIndicator());
              }

              if (!_myTaskKanbanMoreController.isLoading &&
                  _myTaskKanbanMoreController.errorMessage != '') {
                return Center(
                    child: ErrorSomethingWrong(
                  refresh: () => _myTaskKanbanMoreController.getData(),
                  message: _myTaskKanbanMoreController.errorMessage,
                ));
              }

              if (!_myTaskKanbanMoreController.isLoading &&
                  _myTaskKanbanMoreController.cards.isEmpty) {
                return _hasEmptyData();
              }

              return _hasData();
            },
          )),
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
          height: Get.height / 2,
          child: Center(
            child: Text(
              'No cards found',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11.sp, color: Color(0xffB5B5B5)),
            ),
          ),
        )
      ],
    );
    return SmartRefresher(
      header: WaterDropMaterialHeader(),
      controller: emptyRefreshController,
      onRefresh: () async {
        await _myTaskKanbanMoreController.getData();
        emptyRefreshController.refreshCompleted();
      },
      child: ListView.builder(
          padding: EdgeInsets.only(top: 4),
          itemCount: 1,
          itemBuilder: (ctx, index) {
            return column;
          }),
    );
  }

  Widget _hasData() {
    return Obx(() => SmartRefresher(
        enablePullUp: true,
        header: WaterDropMaterialHeader(),
        controller: refreshController,
        onRefresh: () async {
          await _myTaskKanbanMoreController.getData();
          refreshController.refreshCompleted();
        },
        onLoading: () async {
          print('load more');
          await _myTaskKanbanMoreController.getMore();
          print('load more done');

          refreshController.loadComplete();
        },
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
        child: SingleChildScrollView(
            child: Column(
          children: [
            _buildHorizontalSection(),
          ],
        ))));
  }

  Column _buildHorizontalSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 18,
        ),
        SizedBox(
          height: 8,
        ),
        Container(
          width: double.infinity,
          child: Wrap(
            spacing: 8.w,
            children: [
              ..._myTaskKanbanMoreController.cards
                  .asMap()
                  .map((key, value) => MapEntry(
                      key,
                      InkWell(
                        onTap: () {
                          Get.toNamed(RouteName.boardDetailScreen(
                              companyId, value.teamId, value.card.sId));
                        },
                        child: Container(
                          width: Get.width / 2 - 27.w,
                          margin: EdgeInsets.only(bottom: 8.w),
                          child: Column(
                            children: [
                              Align(
                                alignment: Alignment.centerRight,
                                child: Container(
                                    margin: EdgeInsets.only(right: 7),
                                    padding: EdgeInsets.symmetric(
                                        vertical: 3, horizontal: 13),
                                    decoration: BoxDecoration(
                                        color: Color(0xff708FC7),
                                        borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(12),
                                            topRight: Radius.circular(12))),
                                    child: Text(
                                      value.teamName,
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold),
                                    )),
                              ),
                              CardItemCustom(
                                customHeightMemberAvatar: 24,
                                card: value.card,
                              ),
                            ],
                          ),
                        ),
                      )))
                  .values
                  .toList()
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0, top: 18),
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Text(
              '',
              style: TextStyle(
                  color: Color(0xffB5B5B5), fontWeight: FontWeight.w800),
            ),
          ),
        )
      ],
    );
  }
}
