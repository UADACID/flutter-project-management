import 'package:cicle_mobile_f3/controllers/my_task_blast_done_controller.dart';

import 'package:cicle_mobile_f3/screens/core/blast/blast_item.dart';

import 'package:cicle_mobile_f3/utils/helpers.dart';
import 'package:cicle_mobile_f3/widgets/avatar_custom.dart';
import 'package:cicle_mobile_f3/widgets/custom_sparator.dart';
import 'package:cicle_mobile_f3/widgets/error_something_wrong.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class MyTaskBlastDone extends StatelessWidget {
  MyTaskBlastDone({Key? key}) : super(key: key);

  final MyTaskBlastDoneController _myTaskBlastDoneController = Get.find();

  RefreshController refreshController =
      RefreshController(initialRefresh: false);

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.symmetric(horizontal: 23),
        child: Obx(
          () {
            if (_myTaskBlastDoneController.isLoading &&
                _myTaskBlastDoneController.posts.isEmpty) {
              return Center(child: CircularProgressIndicator());
            }

            if (!_myTaskBlastDoneController.isLoading &&
                _myTaskBlastDoneController.errorMessage != '') {
              return Center(
                  child: ErrorSomethingWrong(
                refresh: () => _myTaskBlastDoneController.getData(1),
                message: _myTaskBlastDoneController.errorMessage,
              ));
            }

            if (!_myTaskBlastDoneController.isLoading &&
                _myTaskBlastDoneController.posts.isEmpty) {
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
              'No question found',
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
        await _myTaskBlastDoneController.getData(1);
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
            await _myTaskBlastDoneController.getData(1);
            refreshController.refreshCompleted();
          },
          onLoading: () async {
            print('load more');
            await _myTaskBlastDoneController.getMore();
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
          child: ListView.builder(
              padding: EdgeInsets.only(top: 18),
              itemCount: _myTaskBlastDoneController.posts.length,
              itemBuilder: (ctx, index) {
                PostMyTask item = _myTaskBlastDoneController.posts[index];
                return _builtItem(item);
              }),
        ));
  }

  Column _builtItem(PostMyTask item) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 8,
        ),
        Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: Container(
                  margin: EdgeInsets.only(right: 7),
                  padding: EdgeInsets.symmetric(vertical: 3, horizontal: 13),
                  decoration: BoxDecoration(
                      color: Color(0xffA9C289),
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(12),
                          topRight: Radius.circular(12))),
                  child: Text(
                    'Dept. Marketing',
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
                      borderRadius: BorderRadius.circular(8)),
                  child: Opacity(
                    opacity: 0.5,
                    child: BlastItem(
                        customMargin: EdgeInsets.zero,
                        showMore: false,
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
                                      padding:
                                          EdgeInsets.only(left: 23, right: 15),
                                      child: Row(
                                        children: [
                                          AvatarCustom(
                                            child: Image.network(
                                              getPhotoUrl(
                                                  url: item.lastComment!.creator
                                                      .photoUrl),
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
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ),
                                          SizedBox(
                                            width: 3,
                                          ),
                                          Flexible(
                                              child: Text(
                                            removeHtmlTag(
                                                item.lastComment!.content),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ))
                                        ],
                                      ),
                                    ),
                                  ],
                                )),
                        item: item.post),
                  ),
                ),
                Icon(
                  Icons.task_alt_rounded,
                  size: 70,
                  color: Colors.white,
                )
              ],
            ),
          ],
        ),
      ],
    );
  }
}
