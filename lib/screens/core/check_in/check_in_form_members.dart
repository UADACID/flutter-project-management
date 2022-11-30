import 'package:cicle_mobile_f3/controllers/check_in_form_controller.dart';

import 'package:cicle_mobile_f3/models/member_model.dart';
import 'package:cicle_mobile_f3/widgets/bottom_sheet_add_subscriber.dart';

import 'package:cicle_mobile_f3/widgets/horizontal_list_member.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'check_in_form.dart';

class CheckInFormMembers extends StatelessWidget {
  CheckInFormMembers({
    Key? key,
  }) : super(key: key);

  final CheckInFormController _checkInFormController = Get.find();

  onPressAdd() {
    Get.bottomSheet(
        BottomSheetAddSubscriber(
          listAllProjectMembers: _checkInFormController.teamMembers,
          listSelectedMembers: _checkInFormController.members,
          onDone: (List<MemberModel> listSelected) {
            _checkInFormController.setMembers(listSelected);
          },
        ),
        isDismissible: false,
        isScrollControlled: true);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 23.0),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            border: Border.all(width: 1, color: Color(0xffECECEC)),
            borderRadius: BorderRadius.circular(5)),
        padding: EdgeInsets.only(left: 13, top: 6, bottom: 10, right: 2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Who do you want to ask the question?',
              style: labelStyle.copyWith(fontSize: 11.sp),
            ),
            SizedBox(
              height: 10,
            ),
            Row(
              children: [
                GestureDetector(
                  onTap: onPressAdd,
                  child: Container(
                      height: 33.51.w,
                      width: 33.51.w,
                      decoration: BoxDecoration(
                        color: Color(0xff708FC7),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey,
                            offset: Offset(0.0, 2.0),
                            blurRadius: 2.0,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Icon(
                          Icons.add,
                          color: Colors.white,
                        ),
                      )),
                ),
                SizedBox(
                  width: 4,
                ),
                Expanded(
                  child: Container(
                    height: 33.51.w,
                    child: Obx(() {
                      List<MemberModel> members =
                          _checkInFormController.members;
                      members.sort((a, b) => a.fullName.compareTo(b.fullName));
                      return HorizontalListMember(
                        height: 33.51.w,
                        members: members.length == 0 ? [] : members,
                      );
                    }),
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
