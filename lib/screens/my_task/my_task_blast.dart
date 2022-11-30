import 'package:cicle_mobile_f3/controllers/my_task_blast_all_controller.dart';
import 'package:cicle_mobile_f3/controllers/my_task_blast_done_controller.dart';

import 'package:cicle_mobile_f3/screens/core/blast/blast_item.dart';
import 'package:cicle_mobile_f3/utils/constant.dart';
import 'package:cicle_mobile_f3/utils/helpers.dart';
import 'package:cicle_mobile_f3/widgets/avatar_custom.dart';
import 'package:cicle_mobile_f3/widgets/custom_sparator.dart';
import 'package:cicle_mobile_f3/widgets/error_something_wrong.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class MyTaskBlast extends StatelessWidget {
  MyTaskBlast({Key? key}) : super(key: key);

  MyTaskBlastAllController _myTaskBlastAllController = Get.find();

  RefreshController refreshController =
      RefreshController(initialRefresh: false);

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.symmetric(horizontal: 23),
        child: SmartRefresher(
          header: WaterDropMaterialHeader(),
          controller: refreshController,
          onRefresh: () async {
            await _myTaskBlastAllController.getData();
            refreshController.refreshCompleted();
          },
          child: SingleChildScrollView(
            child: Obx(
              () {
                if (_myTaskBlastAllController.isLoading) {
                  return Center(
                      child: Padding(
                    padding: const EdgeInsets.all(40.0),
                    child: CircularProgressIndicator(),
                  ));
                }

                if (!_myTaskBlastAllController.isLoading &&
                    _myTaskBlastAllController.errorMessage != '') {
                  return Center(
                      child: ErrorSomethingWrong(
                    refresh: () => _myTaskBlastAllController.getData(),
                    message: _myTaskBlastAllController.errorMessage,
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
        _buildContainerItem('Overdue', _myTaskBlastAllController.postsOverdue,
            _myTaskBlastAllController.overDueMore.value),
        _buildContainerItem('Due soon', _myTaskBlastAllController.postsDueSoon,
            _myTaskBlastAllController.dueSoonMore.value),
      ],
    );
  }

  Column _buildContainerItem(String title, List<PostMyTask> list, int more) {
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
            : Column(
                children: [
                  ...list
                      .asMap()
                      .map((key, value) => MapEntry(key, _buildItem(value)))
                      .values
                      .toList()
                ],
              ),
        more == 0
            ? SizedBox()
            : InkWell(
                onTap: () {
                  String? teamId = Get.parameters['teamId'];
                  String companyId = Get.parameters['companyId'] ?? '';
                  Get.toNamed(
                      '${RouteName.myTaskBlastMoreScreen(companyId)}?dueType=$title&teamId=$teamId');
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

  Container _buildItem(PostMyTask item) {
    return Container(
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: Container(
                margin: EdgeInsets.only(right: 7),
                padding: EdgeInsets.symmetric(vertical: 3, horizontal: 13),
                decoration: BoxDecoration(
                    color: Color(0xff708FC7),
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12))),
                child: Text(
                  item.teamName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontSize: 12,
                      color: Colors.white,
                      fontWeight: FontWeight.bold),
                )),
          ),
          BlastItem(
              showMore: false,
              customMargin: EdgeInsets.zero,
              customFooter: item.lastComment == null
                  ? SizedBox()
                  : Container(
                      padding: EdgeInsets.symmetric(vertical: 9),
                      child: Column(
                        children: [
                          CustomSparator(
                            color: Color(0xffD6D6D6),
                          ),
                          SizedBox(
                            height: 9,
                          ),
                          Padding(
                            padding: EdgeInsets.only(left: 23, right: 15),
                            child: Row(
                              children: [
                                AvatarCustom(
                                  child: Image.network(
                                    getPhotoUrl(
                                        url:
                                            item.lastComment!.creator.photoUrl),
                                    height: 28,
                                    width: 28,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                SizedBox(
                                  width: 9,
                                ),
                                Text(
                                  item.lastComment!.creator.fullName,
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                SizedBox(
                                  width: 3,
                                ),
                                Flexible(
                                    child: Text(
                                  removeHtmlTag(item.lastComment!.content),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ))
                              ],
                            ),
                          ),
                        ],
                      )),
              item: item.post),
        ],
      ),
    );
  }
}
