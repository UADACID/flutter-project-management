import 'package:cicle_mobile_f3/controllers/my_task_check_in_all_controller.dart';
import 'package:cicle_mobile_f3/controllers/my_task_check_in_done_controller.dart';
import 'package:cicle_mobile_f3/screens/core/check_in/check_in_screen.dart';
import 'package:cicle_mobile_f3/utils/helpers.dart';
import 'package:cicle_mobile_f3/widgets/avatar_custom.dart';
import 'package:cicle_mobile_f3/widgets/custom_sparator.dart';
import 'package:cicle_mobile_f3/widgets/error_something_wrong.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class MyTaskCheckInDone extends StatelessWidget {
  MyTaskCheckInDone({Key? key}) : super(key: key);

  final MyTaskCheckInDoneController _myTaskCheckInDoneController = Get.find();

  RefreshController refreshController =
      RefreshController(initialRefresh: false);

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.symmetric(horizontal: 23),
        child: Obx(
          () {
            if (_myTaskCheckInDoneController.isLoading &&
                _myTaskCheckInDoneController.questions.isEmpty) {
              return Center(child: CircularProgressIndicator());
            }

            if (!_myTaskCheckInDoneController.isLoading &&
                _myTaskCheckInDoneController.errorMessage != '') {
              return Center(
                  child: ErrorSomethingWrong(
                refresh: () => _myTaskCheckInDoneController.getData(1),
                message: _myTaskCheckInDoneController.errorMessage,
              ));
            }

            if (!_myTaskCheckInDoneController.isLoading &&
                _myTaskCheckInDoneController.questions.isEmpty) {
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
        await _myTaskCheckInDoneController.getData(1);
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
            await _myTaskCheckInDoneController.getData(1);
            refreshController.refreshCompleted();
          },
          onLoading: () async {
            print('load more');
            await _myTaskCheckInDoneController.getMore();
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
              itemCount: _myTaskCheckInDoneController.questions.length,
              itemBuilder: (ctx, index) {
                QuestionMyTask item =
                    _myTaskCheckInDoneController.questions[index];
                return _builtItem(item);
              }),
        ));
  }

  Column _builtItem(QuestionMyTask item) {
    return Column(
      children: [
        SizedBox(
          height: 10,
        ),
        Align(
          alignment: Alignment.centerRight,
          child: Container(
              margin: EdgeInsets.only(right: 5),
              padding: EdgeInsets.symmetric(vertical: 3, horizontal: 13),
              decoration: BoxDecoration(
                  color: Color(0xffA9C289),
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12))),
              child: Text(
                item.teamName,
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
                child: CheckInItem(
                    customPaddingContainer: EdgeInsets.zero,
                    customCardMargin: EdgeInsets.zero,
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
                                  padding: EdgeInsets.only(left: 11, right: 11),
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
                    item: item.question),
              ),
            ),
            Icon(
              Icons.task_alt_rounded,
              size: 70,
              color: Colors.white,
            )
          ],
        )
      ],
    );
  }
}
