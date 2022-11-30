import 'package:cicle_mobile_f3/controllers/check_in_detail_controller.dart';

import 'package:cicle_mobile_f3/models/member_model.dart';
import 'package:cicle_mobile_f3/utils/constant.dart';

import 'package:cicle_mobile_f3/widgets/check_in_more_bottomsheet.dart';
import 'package:cicle_mobile_f3/widgets/comments.dart';
import 'package:cicle_mobile_f3/widgets/error_something_wrong.dart';

import 'package:cicle_mobile_f3/widgets/form_add_comment_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class CheckInDetailScreen extends StatelessWidget {
  CheckInDetailScreen({Key? key}) : super(key: key);
  final String id = Get.parameters['checkInId']!;
  String companyId = Get.parameters['companyId'] ?? '';

  CheckInDetailController checkInDetailController =
      Get.find<CheckInDetailController>();

  bool onNotification(ScrollEndNotification t) {
    if (t.metrics.pixels > 0 && t.metrics.atEdge) {
      print('I am at the end');
    } else {
      print('I am at the start');
    }
    return true;
  }

  onPressMore() async {
    checkInDetailController.commentController.keyEditor.currentState?.unFocus();
    await Future.delayed(Duration(milliseconds: 300));
    Get.bottomSheet(CheckInMoreBottomSheet(
      id: id,
      checkInDetailController: checkInDetailController,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        checkInDetailController.commentController.keyEditor.currentState
            ?.unFocus();
      },
      child: Scaffold(
        appBar: AppBar(
          centerTitle: false,
          titleSpacing: 0,
          title: Obx(() => checkInDetailController.isLoading
              ? SizedBox()
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      checkInDetailController.questionDetail.title,
                      maxLines: 1,
                      style: TextStyle(fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                    InkWell(
                      onTap: () async {
                        Get.reset();
                        await Future.delayed(Duration(milliseconds: 300));

                        Get.offAllNamed(RouteName.dashboardScreen(companyId));
                        await Future.delayed(Duration(milliseconds: 300));
                        Get.toNamed(
                            '${RouteName.teamDetailScreen(companyId)}/${checkInDetailController.currentTeam.sId}?destinationIndex=6');
                      },
                      child: Text(
                        '[Check-in] - ${checkInDetailController.currentTeam.name}',
                        maxLines: 1,
                        style: TextStyle(
                            fontSize: 11,
                            color: Color(0xff708FC7),
                            fontWeight: FontWeight.w600),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                )),
        ),
        body: Obx(() {
          if (checkInDetailController.isLoading) {
            return Center(child: CircularProgressIndicator());
          }

          if (!checkInDetailController.isLoading &&
              checkInDetailController.errorMessage != '') {
            return Center(
                child: ErrorSomethingWrong(
              refresh: () async {
                return checkInDetailController.init();
              },
              message: checkInDetailController.errorMessage,
            ));
          }
          return Column(
            children: [
              Expanded(
                child: Comments(
                  onRefresh: () async {
                    return checkInDetailController.init();
                  },
                  header: _buildCheckInBody(),
                  commentController: checkInDetailController.commentController,
                  teamName: checkInDetailController.currentTeam.name,
                  moduleName: 'Check-Ins',
                  parentTitle: checkInDetailController.questionDetail.title,
                ),
              ),
              Obx(() => FormAddCommentWidget(
                  members: checkInDetailController.teamMembers.isEmpty
                      ? []
                      : checkInDetailController.teamMembers,
                  commentController: checkInDetailController.commentController))
            ],
          );
        }),
      ),
    );
  }

  Obx _buildCheckInBody() {
    return Obx(() {
      List<MemberModel> members =
          checkInDetailController.questionDetail.subscribers;
      String days = '';
      for (var i = 0;
          i < checkInDetailController.questionDetail.schedule.days.length;
          i++) {
        days += ' ${checkInDetailController.questionDetail.schedule.days[i]},';
      }
      int utcHour = checkInDetailController.questionDetail.schedule.hour;
      int utcMinute = checkInDetailController.questionDetail.schedule.minute;

      DateTime today = DateTime.now().toUtc();
      DateTime baseDate = DateTime.utc(
              today.year, today.month, today.day, utcHour, utcMinute, 0)
          .toLocal();
      String time = DateFormat('hh:mm a').format(baseDate);

      String title = checkInDetailController.questionDetail.title;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 10.0),
                  child: Text(
                      'Asking ${members.length} people every $days at $time',
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Color(0xff7a7a7a))),
                ),
              ),
              IconButton(
                  onPressed: onPressMore,
                  icon: Icon(
                    Icons.more_horiz,
                    color: Color(0xffB5B5B5),
                  ))
            ],
          ),
          Container(
              width: double.infinity,
              margin: EdgeInsets.symmetric(horizontal: 19),
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(5)),
              child: Row(
                children: [
                  checkInDetailController.questionDetail.isPublic
                      ? SizedBox()
                      : Padding(
                          padding: const EdgeInsets.only(right: 4.0),
                          child: Icon(
                            Icons.lock_rounded,
                            size: 14,
                          ),
                        ),
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                          height: 1.5,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xff1F3762)),
                    ),
                  ),
                ],
              )),
          Container(
            height: 21,
          ),
          Container(
            color: Colors.white,
            alignment: Alignment.centerLeft,
            padding: EdgeInsets.symmetric(vertical: 15, horizontal: 27),
            child: Text('Answers & Activities',
                style: TextStyle(
                    height: 1.5,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xff262727))),
          ),
          SizedBox(
            height: 56,
          ),
        ],
      );
    });
  }
}
