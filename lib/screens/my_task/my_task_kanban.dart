import 'package:cicle_mobile_f3/controllers/my_task_kanban_all_controller.dart';
import 'package:cicle_mobile_f3/controllers/my_task_kanban_done_controller.dart';

import 'package:cicle_mobile_f3/utils/constant.dart';

import 'package:cicle_mobile_f3/widgets/card_item_custom.dart';

import 'package:cicle_mobile_f3/widgets/error_something_wrong.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class MyTaskKanban extends StatelessWidget {
  MyTaskKanban({Key? key}) : super(key: key);

  MyTaskKanbanAllController _myTaskKanbanAllController = Get.find();

  RefreshController refreshController =
      RefreshController(initialRefresh: false);

  String companyId = Get.parameters['companyId'] ?? '';

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.symmetric(horizontal: 23),
        child: SmartRefresher(
          header: WaterDropMaterialHeader(),
          controller: refreshController,
          onRefresh: () async {
            await _myTaskKanbanAllController.getData();
            refreshController.refreshCompleted();
          },
          child: SingleChildScrollView(
            child: Obx(
              () {
                if (_myTaskKanbanAllController.isLoading) {
                  return Center(
                      child: Padding(
                    padding: const EdgeInsets.all(40.0),
                    child: CircularProgressIndicator(),
                  ));
                }

                if (!_myTaskKanbanAllController.isLoading &&
                    _myTaskKanbanAllController.errorMessage != '') {
                  return Center(
                      child: ErrorSomethingWrong(
                    refresh: () => _myTaskKanbanAllController.getData(),
                    message: _myTaskKanbanAllController.errorMessage,
                  ));
                }

                return _hasData();
              },
            ),
          ),
        ));
  }

  Column _hasData() {
    return Column(
      children: [
        _buildContainerItem('Overdue', _myTaskKanbanAllController.cardsOverdue,
            _myTaskKanbanAllController.overDueMore.value),
        _buildContainerItem('Due soon', _myTaskKanbanAllController.cardsDueSoon,
            _myTaskKanbanAllController.dueSoonMore.value),
      ],
    );
  }

  Column _buildContainerItem(String title, List<CardMyTask> list, int more) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 18,
        ),
        Padding(
          padding: const EdgeInsets.only(left: 18.0),
          child: Text(
            title,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
          ),
        ),
        SizedBox(
          height: 12,
        ),
        SizedBox(height: 1, child: Divider()),
        SizedBox(
          height: 8,
        ),
        list.isEmpty
            ? Center(
                child: Padding(
                padding: const EdgeInsets.all(30.0),
                child: Text('no data', style: TextStyle(color: Colors.grey)),
              ))
            : Container(
                width: double.infinity,
                child: Wrap(
                  spacing: 8.w,
                  children: [
                    ...list
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
                                                  topRight:
                                                      Radius.circular(12))),
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
        more == 0
            ? SizedBox()
            : InkWell(
                onTap: () {
                  String? teamId = Get.parameters['teamId'];
                  String companyId = Get.parameters['companyId'] ?? '';
                  Get.toNamed(
                      '${RouteName.myTaskKanbanMoreScreen(companyId)}?dueType=$title&teamId=$teamId');
                },
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 8.0, top: 18),
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Text(
                      'Show all ($more more)',
                      style: TextStyle(
                          color: Color(0xffB5B5B5),
                          fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
              )
      ],
    );
  }
}
