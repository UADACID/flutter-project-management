import 'package:cicle_mobile_f3/controllers/schedule_form_controller.dart';

import 'package:cicle_mobile_f3/widgets/setup_private.dart';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'schedule_form_end_time.dart';
import 'schedule_form_members.dart';
import 'schedule_form_notes.dart';
import 'schedule_form_start_time.dart';
import 'schedule_form_title.dart';
import 'schedule_from_repeat.dart';

class ScheduleFormScreen extends StatelessWidget {
  ScheduleFormScreen({Key? key}) : super(key: key);

  String? type = Get.parameters['type'];
  String? scheduleId = Get.parameters['scheduleId'];
  String? occurrenceId = Get.parameters['occurrenceId'];
  ScheduleFormController _scheduleFormController =
      Get.put(ScheduleFormController());

  @override
  Widget build(BuildContext context) {
    String _prefix = occurrenceId == null ? '' : 'Reccurring';
    String _title = type == null ? 'Create Event' : 'Edit Event $_prefix';
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          elevation: 1,
          centerTitle: false,
          titleSpacing: 0,
          title: Obx(() => _scheduleFormController.loadingGetData
              ? SizedBox()
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _title,
                      maxLines: 1,
                      style: TextStyle(fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                    InkWell(
                      onTap: () => _scheduleFormController.navigateToList(),
                      child: Text(
                        '[Schedule] - ${_scheduleFormController.currentTeam.name}',
                        maxLines: 1,
                        style: TextStyle(
                            fontSize: 11.sp,
                            color: Color(0xff708FC7),
                            fontWeight: FontWeight.w600),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                )),
        ),
        body: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(
                    height: 16,
                  ),
                  ScheduleFormTitle(),
                  SizedBox(
                    height: 7.w,
                  ),
                  ScheduleFormStartTime(),
                  SizedBox(
                    height: 7.w,
                  ),
                  ScheduleFormEndTime(),
                  SizedBox(
                    height: 7.w,
                  ),
                  ScheduleFormRepeat(),
                  SizedBox(
                    height: 7.w,
                  ),
                  ScheduleFormMembers(),
                  SizedBox(
                    height: 7.w,
                  ),
                  ScheduleFormNotes(),
                  Container(
                    margin: EdgeInsets.only(left: 16, top: 10),
                    child: Obx(() => SetupPrivate(
                        title: 'Is the event for private only?',
                        isPrivate: _scheduleFormController.isPrivate,
                        onChange: (bool value) =>
                            _scheduleFormController.isPrivate = value)),
                  ),
                  SizedBox(
                    height: 10.w,
                  ),
                  Column(
                    children: [
                      type == null
                          ? _buildButtonAdd(context)
                          : _buildButtonEdit(context),
                      ElevatedButton(
                        onPressed: () {
                          Get.back();
                        },
                        style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all<Color>(
                                Color(0xffD45757)),
                            shape: MaterialStateProperty.all<
                                RoundedRectangleBorder>(RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50.0),
                            ))),
                        child: ConstrainedBox(
                            constraints: BoxConstraints(
                                maxWidth: 305.w, maxHeight: 36.w),
                            child: Container(
                                width: double.infinity,
                                child: Center(
                                    child: Text('Cancel',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 11.sp,
                                        ))))),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 10.w,
                  ),
                ],
              ),
            ),
            Obx(() {
              return _scheduleFormController.loadingGetData
                  ? Container(
                      color: Theme.of(Get.context!).cardColor.withOpacity(0.5),
                      height: double.infinity,
                      width: double.infinity,
                      child: Center(child: CircularProgressIndicator()),
                    )
                  : SizedBox();
            })
          ],
        ),
      ),
    );
  }

  ElevatedButton _buildButtonAdd(BuildContext context) {
    return ElevatedButton(
      onPressed: _scheduleFormController.submit,
      style: ButtonStyle(
          backgroundColor:
              MaterialStateProperty.all<Color>(Theme.of(context).primaryColor),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50.0),
          ))),
      child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 305.w, maxHeight: 36.w),
          child: Container(
              width: double.infinity,
              child: Center(
                  child: Text('Post Event',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11.sp,
                      ))))),
    );
  }

  ElevatedButton _buildButtonEdit(BuildContext context) {
    return ElevatedButton(
      onPressed: _scheduleFormController.submitEdit,
      style: ButtonStyle(
          backgroundColor:
              MaterialStateProperty.all<Color>(Theme.of(context).primaryColor),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50.0),
          ))),
      child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 305.w, maxHeight: 36.w),
          child: Container(
              width: double.infinity,
              child: Center(
                  child: Text('Publish Change',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11.sp,
                      ))))),
    );
  }
}
