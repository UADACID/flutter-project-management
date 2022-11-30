import 'package:cicle_mobile_f3/controllers/schedule_form_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class ScheduleFormTitle extends StatelessWidget {
  ScheduleFormTitle({
    Key? key,
  }) : super(key: key);

  ScheduleFormController _scheduleFormController =
      Get.put(ScheduleFormController());

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 23),
      padding: EdgeInsets.fromLTRB(11, 5, 11, 11),
      decoration: BoxDecoration(
          border: Border.all(color: Color(0xffECECEC)),
          color: Colors.white,
          borderRadius: BorderRadius.circular(5.w)),
      child: TextField(
        controller: _scheduleFormController.titleTextEditingController,
        maxLines: 3,
        minLines: 1,
        onChanged: (value) {
          _scheduleFormController.title = value;
        },
        style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.normal),
        decoration: InputDecoration(
          isDense: true,
          hintText: 'Type your event here...',
          hintStyle:
              TextStyle(color: Colors.grey.withOpacity(0.5), fontSize: 12.sp),
          enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xffECECEC))),
        ),
      ),
    );
  }
}
