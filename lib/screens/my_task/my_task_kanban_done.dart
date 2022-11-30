import 'package:cicle_mobile_f3/controllers/my_task_kanban_done_controller.dart';

import 'package:cicle_mobile_f3/utils/constant.dart';

import 'package:cicle_mobile_f3/widgets/card_item_custom.dart';

import 'package:cicle_mobile_f3/widgets/error_something_wrong.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class MyTaskKanbanDone extends StatelessWidget {
  MyTaskKanbanDone({Key? key}) : super(key: key);

  final MyTaskKanbanDoneController _myTaskKanbanDoneController = Get.find();

  String companyId = Get.parameters['companyId'] ?? '';

  RefreshController refreshController =
      RefreshController(initialRefresh: false);

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.symmetric(horizontal: 23),
        child: Obx(
          () {
            if (_myTaskKanbanDoneController.isLoading &&
                _myTaskKanbanDoneController.cards.isEmpty) {
              return Center(child: CircularProgressIndicator());
            }

            if (!_myTaskKanbanDoneController.isLoading &&
                _myTaskKanbanDoneController.errorMessage != '') {
              return Center(
                  child: ErrorSomethingWrong(
                refresh: () => _myTaskKanbanDoneController.getData(1),
                message: _myTaskKanbanDoneController.errorMessage,
              ));
            }

            if (!_myTaskKanbanDoneController.isLoading &&
                _myTaskKanbanDoneController.cards.isEmpty) {
              return _hasEmptyData();
            }

            return _hasData();
          },
        ));
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
      controller: refreshController,
      onRefresh: () async {
        await _myTaskKanbanDoneController.getData(1);
        refreshController.refreshCompleted();
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
          await _myTaskKanbanDoneController.getData(1);
          refreshController.refreshCompleted();
        },
        onLoading: () async {
          print('load more');
          await _myTaskKanbanDoneController.getMore();
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

  _builtItem(CardMyTask item) {
    return Text('data');
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
              ..._myTaskKanbanDoneController.cards
                  .asMap()
                  .map((key, value) => MapEntry(
                      key,
                      InkWell(
                        onTap: () {
                          Get.toNamed(RouteName.boardDetailScreen(
                              companyId, value.teamId, value.card.sId));
                        },
                        child: Container(
                          width: Get.width / 2 - 28.5,
                          margin: EdgeInsets.only(bottom: 8.w),
                          child: Column(
                            children: [
                              Align(
                                alignment: Alignment.centerRight,
                                child: Container(
                                    constraints: BoxConstraints(
                                      maxWidth: Get.width / 2 - 47.w,
                                    ),
                                    margin: EdgeInsets.only(right: 10),
                                    padding: EdgeInsets.symmetric(
                                        vertical: 3, horizontal: 13),
                                    decoration: BoxDecoration(
                                        color: Color(0xffA9C289),
                                        borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(12),
                                            topRight: Radius.circular(12))),
                                    child: Text(
                                      value.teamName,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold),
                                    )),
                              ),
                              Stack(
                                alignment: Alignment.center,
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                        color: Color(0xffA9C289),
                                        borderRadius:
                                            BorderRadius.circular(12)),
                                    child: Opacity(
                                      opacity: 0.5,
                                      child: CardItemCustom(
                                          customHeightMemberAvatar: 24,
                                          card: value.card),
                                    ),
                                  ),
                                  Icon(
                                    Icons.task_alt_rounded,
                                    size: 50,
                                    color: Colors.white,
                                  )
                                ],
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
