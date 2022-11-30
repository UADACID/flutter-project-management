import 'package:cicle_mobile_f3/controllers/check_in_form_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'check_in_form.dart';
import 'check_in_form_day_item.dart';

class CheckInFormListdays extends StatelessWidget {
  CheckInFormListdays({
    Key? key,
  }) : super(key: key);

  List<String> days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  CheckInFormController _checkInFormController =
      Get.put(CheckInFormController());

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 23),
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 11.w, horizontal: 11.w),
      decoration: BoxDecoration(
          border: Border.all(color: Color(0xffECECEC), width: 1),
          borderRadius: BorderRadius.circular(5),
          color: Colors.white),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'How often do you want to ask the question?',
            style: labelStyle.copyWith(fontSize: 11.sp),
          ),
          SizedBox(
            height: 6,
          ),
          Container(
            width: double.infinity,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              border: Border.all(color: Color(0xffECECEC), width: 1),
              borderRadius: BorderRadius.circular(5),
            ),
            padding: EdgeInsets.fromLTRB(7.w, 7.w, 7.w, 3.w),
            child: Obx(() => Wrap(
                  children: days
                      .asMap()
                      .map((key, value) {
                        List<String> _selectedDays =
                            _checkInFormController.listOfSelectedDays;
                        int isdayOnSelectedDays = _selectedDays
                            .where((element) => element == value)
                            .length;
                        return MapEntry(
                            key,
                            CheckInFormDayItem(
                              title: value,
                              isSelected:
                                  isdayOnSelectedDays > 0 ? true : false,
                              onPress: () {
                                if (isdayOnSelectedDays > 0) {
                                  _checkInFormController.removeDay(value);
                                } else {
                                  _checkInFormController.addDay = value;
                                }
                              },
                            ));
                      })
                      .values
                      .toList(),
                )),
          )
        ],
      ),
    );
  }
}
