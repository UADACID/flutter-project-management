import 'package:cicle_mobile_f3/controllers/schedule_form_controller.dart';
import 'package:date_time_picker/date_time_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class ScheduleFormStartTime extends StatelessWidget {
  ScheduleFormStartTime({
    Key? key,
  }) : super(key: key);

  ScheduleFormController _scheduleFormController =
      Get.put(ScheduleFormController());

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
          Text(
            'Starts',
            style: TextStyle(fontSize: 11.sp),
          ),
          SizedBox(
            height: 5,
          ),
          Obx(() {
            var time = '';
            if (_scheduleFormController.startDate != '') {
              DateTime parseDate =
                  DateTime.parse(_scheduleFormController.startDate);
              String dayName = DateFormat('EEEE').format(parseDate);
              String monthName = DateFormat.yMMM().format(parseDate);
              String timeName = DateFormat.jm().format(parseDate);

              time = '$dayName ${parseDate.day} $monthName $timeName';
            }
            return _scheduleFormController.startDate != ''
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
                color: Color(0xff708FC7)),
            child: Stack(
              children: [
                Obx(() => Align(
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _scheduleFormController.startDate == ''
                                ? Icons.timelapse
                                : Icons.edit_outlined,
                            color: Colors.white,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 10.0),
                            child: Text(
                              _scheduleFormController.startDate == ''
                                  ? 'Set date'
                                  : 'Edit date',
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
                  if (_scheduleFormController.loadingGetData) {
                    return SizedBox();
                  }
                  return DateTimePicker(
                    controller:
                        _scheduleFormController.startDateEditingController,
                    locale: Locale('en', 'US'),
                    use24HourFormat: false,
                    textAlign: TextAlign.center,
                    type: DateTimePickerType.dateTime,
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
                      _scheduleFormController.startDate = val;
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
