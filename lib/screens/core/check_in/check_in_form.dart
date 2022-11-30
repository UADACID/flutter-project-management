import 'package:cicle_mobile_f3/controllers/check_in_form_controller.dart';
import 'package:cicle_mobile_f3/widgets/setup_private.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'check_in_form_list_days.dart';
import 'check_in_form_members.dart';
import 'check_in_form_question.dart';
import 'check_in_form_time.dart';

class CheckInForm extends StatelessWidget {
  CheckInForm({Key? key}) : super(key: key);

  CheckInFormController _checkInFormController =
      Get.put(CheckInFormController());
  String typeForm = Get.parameters['type']!;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          elevation: 2,
          titleSpacing: 0,
          title: Obx(() => _checkInFormController.loadingGetData
              ? SizedBox()
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${typeForm.capitalize} Question',
                      maxLines: 1,
                      style: TextStyle(fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                    InkWell(
                      onTap: () => _checkInFormController.navigateToList(),
                      child: Text(
                        '[Check-in] - ${_checkInFormController.currentTeam.name}',
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
                  CheckInFormQuestion(),
                  SizedBox(
                    height: 3,
                  ),
                  CheckInFormListdays(),
                  SizedBox(
                    height: 3,
                  ),
                  CheckInFormTime(),
                  SizedBox(
                    height: 3,
                  ),
                  CheckInFormMembers(),
                  Container(
                    margin: EdgeInsets.only(left: 16, top: 10),
                    child: Obx(() => SetupPrivate(
                        title: 'Is the question for private only?',
                        isPrivate: _checkInFormController.isPrivate,
                        onChange: (bool value) =>
                            _checkInFormController.isPrivate = value)),
                  ),
                  typeForm == 'create' ? _buildButtonAdd() : _buildButtonEdit()
                ],
              ),
            ),
            Obx(() {
              return _checkInFormController.loadingGetData
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

  Padding _buildButtonEdit() {
    return Padding(
      padding: const EdgeInsets.only(top: 15, bottom: 50),
      child: Column(
        children: [
          ElevatedButton(
            onPressed: () {
              _checkInFormController.submitEdit();
            },
            style: ButtonStyle(
                backgroundColor:
                    MaterialStateProperty.all<Color>(Color(0xff708FC7)),
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50.0),
                ))),
            child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 305.w, maxHeight: 36.w),
                child: Container(
                    width: double.infinity,
                    child: Center(
                        child: Text('Save changes',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11.sp,
                            ))))),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
            },
            style: ButtonStyle(
                backgroundColor:
                    MaterialStateProperty.all<Color>(Color(0xffD45757)),
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50.0),
                ))),
            child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 305.w, maxHeight: 36.w),
                child: Container(
                    width: double.infinity,
                    child: Center(
                        child: Text('Cancel',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11.sp,
                            ))))),
          )
        ],
      ),
    );
  }

  Padding _buildButtonAdd() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 23.0, vertical: 37),
      child: ElevatedButton(
        onPressed: () {
          _checkInFormController.submit();
        },
        style: ButtonStyle(
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(50.0),
        ))),
        child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 305.w, maxHeight: 36.w),
            child: Container(
                width: double.infinity,
                child: Center(
                    child: Text('Start collecting answer!',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11.sp,
                          fontWeight: FontWeight.bold,
                        ))))),
      ),
    );
  }
}

TextStyle labelStyle = TextStyle(color: Color(0xff7A7A7A), fontSize: 11);
