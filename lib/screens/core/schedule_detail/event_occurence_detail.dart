import 'dart:io';

import 'package:cicle_mobile_f3/controllers/download_controller.dart';
import 'package:cicle_mobile_f3/controllers/event_detail_controller.dart';
import 'package:cicle_mobile_f3/controllers/event_occurence_controller.dart';
import 'package:cicle_mobile_f3/models/cheer_item_model.dart';
import 'package:cicle_mobile_f3/models/member_model.dart';
import 'package:cicle_mobile_f3/screens/core/schedule_detail/schedule_detail_screen.dart';
import 'package:cicle_mobile_f3/utils/constant.dart';
import 'package:cicle_mobile_f3/utils/helpers.dart';
import 'package:cicle_mobile_f3/widgets/avatar_custom.dart';
import 'package:cicle_mobile_f3/widgets/bottom_sheet_add_subscriber.dart';
import 'package:cicle_mobile_f3/widgets/bottom_sheet_more_action.dart';
import 'package:cicle_mobile_f3/widgets/comments.dart';
import 'package:cicle_mobile_f3/widgets/dialog_selectable_webview.dart';
import 'package:cicle_mobile_f3/widgets/error_something_wrong.dart';
import 'package:cicle_mobile_f3/widgets/form_add_comment.dart';
import 'package:cicle_mobile_f3/widgets/form_add_comment_widget.dart';
import 'package:cicle_mobile_f3/widgets/horizontal_list_member.dart';
import 'package:cicle_mobile_f3/widgets/list_cheers.dart';
import 'package:cicle_mobile_f3/widgets/webview_cummon.dart';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class EventOccurenceDetail extends StatelessWidget {
  EventOccurenceDetail({Key? key}) : super(key: key);
  String? teamId = Get.parameters['teamId'];
  String? scheduleId = Get.parameters['scheduleId'];
  String companyId = Get.parameters['companyId'] ?? '';

  EventOccurenceDetailController _eventOccurenceDetailController = Get.find();

  onDelete() async {
    Get.back();
    await Future.delayed(Duration(milliseconds: 300));
    Get.back();
    await Future.delayed(Duration(milliseconds: 300));
    showAlert(message: 'Event has been archived');
    Get.back();
  }

  onEdit() async {
    Get.back();
    await Future.delayed(Duration(milliseconds: 300));
    String occurrenceId = _eventOccurenceDetailController.occurenceId;
    Get.toNamed(
        '${RouteName.scheduleFormScreen(teamId: teamId!, companyId: companyId)}?scheduleId=$scheduleId&type=edit&occurrenceId=$occurrenceId');
  }

  onPressMore() async {
    _eventOccurenceDetailController.commentController.keyEditor.currentState
        ?.unFocus();
    await Future.delayed(Duration(milliseconds: 300));
    Get.bottomSheet(BottomSheetMoreAction(
      onDelete: onDelete,
      onEdit: onEdit,
      titleAlert: 'Delete event',
    ));
  }

  onPressAdd() {
    Get.bottomSheet(
        BottomSheetAddSubscriber(
          listAllProjectMembers: _eventOccurenceDetailController.teamMembers,
          listSelectedMembers: _eventOccurenceDetailController.members,
          onDone: (List<MemberModel> listSelected) {
            _eventOccurenceDetailController.toggleMembers(listSelected);
          },
        ),
        isDismissible: false,
        isScrollControlled: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        titleSpacing: 0,
        title: Obx(() => _eventOccurenceDetailController.isLoading
            ? SizedBox()
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _eventOccurenceDetailController.eventDetail.title!,
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
                          '${RouteName.teamDetailScreen(companyId)}/${_eventOccurenceDetailController.currentTeam.sId}?destinationIndex=5');
                    },
                    child: Text(
                      '[Schedule] - ${_eventOccurenceDetailController.currentTeam.name}',
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
        if (_eventOccurenceDetailController.isLoading) {
          return Center(child: CircularProgressIndicator());
        }

        if (!_eventOccurenceDetailController.isLoading &&
            _eventOccurenceDetailController.errorMessage != '') {
          return Center(
              child: ErrorSomethingWrong(
            refresh: () async {
              return _eventOccurenceDetailController.init();
            },
            message: _eventOccurenceDetailController.errorMessage,
          ));
        }

        return Column(
          children: [
            Expanded(
                child: Comments(
              onRefresh: () async {
                return _eventOccurenceDetailController.init();
              },
              commentController:
                  _eventOccurenceDetailController.commentController,
              header: _buildBody(),
              teamName: _eventOccurenceDetailController.currentTeam.name,
              moduleName: 'Schedule',
              parentTitle:
                  _eventOccurenceDetailController.eventDetail.title ?? '',
            )),
            Opacity(
              opacity: _eventOccurenceDetailController.showFormCheers ? 0 : 1,
              child: FormAddCommentWidget(
                  members: _eventOccurenceDetailController.teamMembers,
                  commentController:
                      _eventOccurenceDetailController.commentController),
            )
          ],
        );
      }),
    );
  }

  Column _buildBody() {
    return Column(
      children: [
        Container(
          color: Colors.white,
          child: Column(
            children: [
              SizedBox(
                height: 12,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 23.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _eventOccurenceDetailController.eventDetail.isPublic ==
                            false
                        ? Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: Icon(
                              Icons.lock_rounded,
                              size: 18,
                            ),
                          )
                        : SizedBox(),
                    Expanded(
                      child: Obx(() => Text(
                            _eventOccurenceDetailController.eventDetail.title ??
                                'no title',
                            style: TextStyle(
                                fontSize: 24, fontWeight: FontWeight.w600),
                          )),
                    ),
                    IconButton(
                        onPressed: onPressMore,
                        icon: Icon(
                          Icons.more_vert,
                          color: Color(0xff979797),
                        ))
                  ],
                ),
              ),
              SizedBox(
                height: 15,
              ),
              _buildCreator(),
              SizedBox(
                height: 15,
              ),
              _buildDate(),
              SizedBox(
                height: 15,
              ),
              _buildRepeat(),
              SizedBox(
                height: 5,
              ),
              _buildButtonAddToCalendar(),
              SizedBox(
                height: 15,
              ),
              _buildNotes(),
              SizedBox(
                height: 35,
              ),
              _buildListMember(),
              SizedBox(
                height: 15,
              ),
              _buildListCheers(_eventOccurenceDetailController),
              SizedBox(
                height: 19,
              )
            ],
          ),
        ),
        SizedBox(
          height: 4,
        ),
        Container(
          width: double.infinity,
          padding: EdgeInsets.fromLTRB(34, 15, 34, 15),
          color: Colors.white,
          child: Text(
            'Comments & Activities',
            style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600),
          ),
        ),
        SizedBox(
          height: 15,
        ),
      ],
    );
  }

  Container _buildListCheers(EventOccurenceDetailController controller) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.only(left: 21, top: 10, right: 16, bottom: 8),
      child: Obx(() => ListCheers(
            cheers: controller.cheers.isEmpty ? [] : controller.cheers,
            logedInUserId: controller.logedInUserId,
            setShowFormCheers: (value) {
              controller.showFormCheers = value;
            },
            showFormCheers: controller.showFormCheers,
            submitAdd: (String value) {
              controller.addCheer(value);
            },
            submitDelete: (CheerItemModel item) {
              Get.back();
              controller.deleteCheer(item);
            },
          )),
    );
  }

  Obx _buildCreator() {
    return Obx(() {
      String userName =
          _eventOccurenceDetailController.eventDetail.creator!.fullName;
      String photoUrl =
          _eventOccurenceDetailController.eventDetail.creator!.photoUrl;
      String time = DateFormat.Hm().format(
          DateTime.parse(_eventOccurenceDetailController.eventDetail.createdAt!)
              .toLocal());
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Row(
          children: [
            AvatarCustom(
              height: 24,
              child: Image.network(
                getPhotoUrl(url: photoUrl),
                fit: BoxFit.cover,
                height: 24,
                width: 24,
              ),
            ),
            SizedBox(
              width: 10,
            ),
            Text(
              userName,
              style: TextStyle(
                  fontSize: 11.sp,
                  color: Color(0xff708FC7),
                  fontWeight: FontWeight.w600),
            ),
            SizedBox(
              width: 7,
            ),
            Container(
              width: 1,
              height: 12,
              color: Colors.grey,
            ),
            SizedBox(
              width: 7,
            ),
            Text(time,
                style: TextStyle(
                    fontSize: 9.sp,
                    color: Colors.black.withOpacity(0.5),
                    fontWeight: FontWeight.w600))
          ],
        ),
      );
    });
  }

  Obx _buildDate() {
    return Obx(() {
      DateTime startedDay =
          DateTime.parse(_eventOccurenceDetailController.eventDetail.startDate!)
              .toLocal();
      String startedDayName = DateFormat('EE, MMM d yyyy').format(startedDay);
      String startedTime = DateFormat('hh:mm a').format(startedDay);

      DateTime finishedDay =
          DateTime.parse(_eventOccurenceDetailController.eventDetail.endDate!)
              .toLocal();
      String finishedDayName = DateFormat('EE, MMM d yyyy').format(finishedDay);
      String finishedTime = DateFormat('hh:mm a').format(finishedDay);

      bool checkIsSameDay = isSameDayHelper(startedDay, finishedDay);

      String endDateAdapter =
          checkIsSameDay ? finishedTime : '$finishedDayName at $finishedTime';

      getDuration() {
        final difference = finishedDay.difference(startedDay).inDays;
        if (difference > 0) {
          return '($difference days)';
        }
        return '';
      }

      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 24),
        padding: EdgeInsets.fromLTRB(8, 8, 8, 8),
        decoration: BoxDecoration(
            color: Color(0xffDEEAFF), borderRadius: BorderRadius.circular(5)),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('When : ',
                style: TextStyle(
                    fontSize: 11.sp,
                    color: Color(0xff262727),
                    fontWeight: FontWeight.bold)),
            SizedBox(
              width: 4,
            ),
            Expanded(
              child: Text(
                  '$startedDayName at $startedTime - $endDateAdapter ${getDuration()}',
                  style: TextStyle(
                      fontSize: 11.sp,
                      color: Color(0xff262727),
                      fontWeight: FontWeight.normal)),
            )
          ],
        ),
      );
    });
  }

  Container _buildRepeat() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: EdgeInsets.fromLTRB(8, 8, 8, 8),
      decoration: BoxDecoration(
          color: Color(0xffDEEAFF), borderRadius: BorderRadius.circular(5)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Repeat : ',
              style: TextStyle(
                  fontSize: 11.sp,
                  color: Color(0xff262727),
                  fontWeight: FontWeight.bold)),
          SizedBox(
            width: 4,
          ),
          Obx(() => Text(
                '${_eventOccurenceDetailController.eventDetail.originalStartPattern!.readableText?.toUpperCase()}',
                style:
                    TextStyle(fontSize: 11.sp, fontWeight: FontWeight.normal),
              ))
        ],
      ),
    );
  }

  _onLongPressItem(String content) {
    Get.dialog(DialogSelectableWebView(
        content: content
            .replaceAll(">target='_blank'", "")
            .replaceAll("id='isPasted'>", "")
        // .replaceAll(
        //     RegExp(r'(http(s?):)([/|.|\w|\s|-])*\.(?:jpg|gif|png)'), "")
        ));
    showAlert(message: 'to copy text you can select the content below');
  }

  Container _buildNotes() {
    return Container(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Notes:',
                  style:
                      TextStyle(fontSize: 11.sp, fontWeight: FontWeight.bold),
                )),
            SizedBox(
              height: 2,
            ),
            Container(
              width: double.infinity,
              height: 1,
              color: Color(0xff708FC7),
            ),
            SizedBox(
              height: 10,
            ),
            Obx(() => GestureDetector(
                  onLongPress: () {
                    _onLongPressItem(
                        _eventOccurenceDetailController.eventDetail.content ??
                            'This event has no additional notes');
                  },
                  child: HtmlWidget(
                    _eventOccurenceDetailController.eventDetail.content ??
                        'This event has no additional notes',
                    onTapUrl: parseLinkPressed,
                    textStyle: TextStyle(fontSize: 11.sp),
                  ),
                ))
          ],
        ),
      ),
    );
  }

  GestureDetector _buildButtonAddToCalendar() {
    return GestureDetector(
      onTap: () {
        Get.bottomSheet(BottomSheetAddToCalendar(
          onPressAddToGoogleCal: () async {
            String url = _eventOccurenceDetailController
                .eventDetail.googleCalendar!.eventGCalTemplateLink!;

            if (Platform.isAndroid) {
              await canLaunch(url)
                  ? await launch(url)
                  : showAlert(
                      message: "can't open $url", messageColor: Colors.red);
            } else {
              Navigator.push(
                  Get.context!,
                  MaterialPageRoute(
                      builder: (_) => WebViewCummon(
                          url: _eventOccurenceDetailController.eventDetail
                                  .googleCalendar!.eventGCalTemplateLink ??
                              '')));
            }
          },
          onPressAddToAppleCal: () async {
            DownloadController _downloadController =
                Get.put(DownloadController());
            String url =
                '${Env.BASE_URL}${_eventOccurenceDetailController.eventDetail.googleCalendar?.eventIcsLink}';
            print(url);
            try {
              var grant = await checkPermission();
              if (grant == true) {
                _downloadController.requestDownload(
                    TaskInfo(name: 'apple calendar .ics file', link: url));
                showAlert(message: 'download apple calendar .ics file');
                Get.back();
              }
            } catch (e) {
              errorMessageMiddleware(e);
            }
          },
        ));
      },
      child: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          margin: EdgeInsets.only(left: 23),
          padding: EdgeInsets.symmetric(horizontal: 10),
          height: 26,
          decoration: BoxDecoration(boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 1,
              offset: Offset(1, 1),
            ),
          ], color: Color(0xffFDC532), borderRadius: BorderRadius.circular(5)),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.add, color: Color(0xff385282)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  'Add to my calendar',
                  style: TextStyle(
                    color: Color(0xff385282),
                    decoration: TextDecoration.underline,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Obx _buildListMember() {
    return Obx(() {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            Align(
                alignment: Alignment.centerRight,
                child: Text(
                  '${_eventOccurenceDetailController.members.length} people are invited',
                  style: TextStyle(fontSize: 12.sp, color: Color(0xff708FC7)),
                )),
            SizedBox(
              height: 10,
            ),
            Row(
              children: [
                GestureDetector(
                  onTap: onPressAdd,
                  child: Container(
                      height: 25,
                      width: 25,
                      decoration: BoxDecoration(
                          color: Color(0xff708FC7), shape: BoxShape.circle),
                      child: Center(
                        child: Icon(
                          Icons.add,
                          color: Colors.white,
                        ),
                      )),
                ),
                SizedBox(
                  width: 2,
                ),
                Expanded(
                  child: HorizontalListMember(
                    height: 25,
                    fontSize: 10,
                    marginItem: EdgeInsets.only(right: 2),
                    members: _eventOccurenceDetailController.members.isEmpty
                        ? []
                        : _eventOccurenceDetailController.members,
                  ),
                ),
              ],
            )
          ],
        ),
      );
    });
  }
}
