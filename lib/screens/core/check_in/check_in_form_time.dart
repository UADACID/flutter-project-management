import 'package:cicle_mobile_f3/controllers/check_in_form_controller.dart';
import 'package:date_time_picker/date_time_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'check_in_form.dart';

class CheckInFormTime extends StatelessWidget {
  CheckInFormTime({
    Key? key,
  }) : super(key: key);

  CheckInFormController _checkInFormController =
      Get.put(CheckInFormController());

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 23),
      padding: EdgeInsets.symmetric(vertical: 11, horizontal: 11),
      decoration: BoxDecoration(
          border: Border.all(color: Color(0xffECECEC), width: 1),
          borderRadius: BorderRadius.circular(5),
          color: Colors.white),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Obx(() => Text(
                'At what time? ${_checkInFormController.time}',
                style: labelStyle.copyWith(fontSize: 11.sp),
              )),
          SizedBox(
            height: 5,
          ),
          Obx(() {
            var time = _checkInFormController.time == ''
                ? ''
                : DateFormat.jm().format(DateFormat("hh:mm:ss")
                    .parse("${_checkInFormController.time}:00"));
            return _checkInFormController.time != ''
                ? Container(
                    height: 36.w,
                    margin: EdgeInsets.symmetric(vertical: 4),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(17),
                        color: Color(0xffDADADA)),
                    child: Center(child: Text(time)),
                  )
                : Container();
          }),
          Container(
            height: 36.w,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(17),
              color: Color(0xff708FC7),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey,
                  offset: Offset(0.0, 2.0),
                  blurRadius: 2.0,
                ),
              ],
            ),
            child: Stack(
              children: [
                Obx(() => Align(
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _checkInFormController.time == ''
                                ? Icons.timelapse
                                : Icons.edit_outlined,
                            color: Colors.white,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 10.0),
                            child: Text(
                              _checkInFormController.time == ''
                                  ? 'set time'
                                  : 'Edit time',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11.sp,
                                  fontWeight: FontWeight.normal),
                            ),
                          )
                        ],
                      ),
                    )),
                Obx(() {
                  return DateTimePicker(
                    controller: _checkInFormController.timeEditingController,
                    initialTime: _checkInFormController.initEditTime,
                    locale: Locale('en', 'US'),
                    use24HourFormat: false,
                    textAlign: TextAlign.center,
                    type: DateTimePickerType.time,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.only(
                          left: 15, bottom: 17.w, top: 12.w, right: 15),
                    ),
                    style: TextStyle(
                        color: Colors.transparent,
                        fontWeight: FontWeight.normal,
                        fontSize: 11),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                    dateLabelText: '',
                    onChanged: (val) {
                      _checkInFormController.time = val;
                    },
                  );
                }),
              ],
            ),
          )
        ],
      ),
    );
  }
}
