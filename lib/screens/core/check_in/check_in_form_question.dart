import 'package:cicle_mobile_f3/controllers/check_in_form_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'check_in_form.dart';

class CheckInFormQuestion extends StatelessWidget {
  CheckInFormQuestion({
    Key? key,
  }) : super(key: key);
  CheckInFormController _checkInFormController =
      Get.put(CheckInFormController());

  @override
  Widget build(BuildContext context) {
    return Container(
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
            'What question do you want to ask?',
            style: labelStyle.copyWith(fontSize: 11.sp),
          ),
          TextField(
            controller: _checkInFormController.questionTextEditingController,
            maxLines: 5,
            minLines: 1,
            onChanged: (value) {
              _checkInFormController.question = value;
            },
            style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
            decoration: InputDecoration(
              isDense: true,
              hintText: 'type question here...',
              hintStyle: TextStyle(
                  color: Colors.grey.withOpacity(0.5), fontSize: 11.sp),
              enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Color(0xffECECEC))),
            ),
          )
        ],
      ),
    );
  }
}
