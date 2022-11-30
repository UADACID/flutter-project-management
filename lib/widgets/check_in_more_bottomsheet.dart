import 'package:cicle_mobile_f3/controllers/check_in_detail_controller.dart';
import 'package:cicle_mobile_f3/utils/constant.dart';
import 'package:cicle_mobile_f3/utils/my_flutter_app_icons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'default_alert.dart';

class CheckInMoreBottomSheet extends StatelessWidget {
  CheckInMoreBottomSheet({
    Key? key,
    required this.id,
    this.closeOverlays = true,
    required this.checkInDetailController,
  }) : super(key: key);

  final String id;
  final bool closeOverlays;

  final CheckInDetailController checkInDetailController;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 135,
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16), topRight: Radius.circular(16))),
      child: Column(
        children: [
          SizedBox(
            height: 15,
          ),
          Container(
            width: 39,
            height: 6,
            decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.5),
                borderRadius: BorderRadius.circular(5)),
          ),
          ListTile(
            minLeadingWidth: 0,
            leading: Icon(
              MyFlutterApp.mdi_square_edit_outline,
              color: Color(0xff708FC7),
            ),
            onTap: () async {
              String teamId = Get.parameters['teamId']!;
              String companyId = Get.parameters['companyId']!;
              Get.back();
              await Future.delayed(Duration(milliseconds: 300));
              Get.toNamed(RouteName.checkInForm(companyId, teamId, id, 'edit'));
            },
            title: Text(
              'Edit',
              style: TextStyle(
                  color: Color(0xff708FC7),
                  fontSize: 12,
                  fontWeight: FontWeight.w600),
            ),
          ),
          Container(
              padding: EdgeInsets.symmetric(horizontal: 21),
              constraints: BoxConstraints(maxHeight: 0),
              child: Divider()),
          ListTile(
            minLeadingWidth: 0,
            leading: Icon(
              MyFlutterApp.mdi_trash_can_outline,
              color: Color(0xffFF7171),
            ),
            onTap: () {
              Get.dialog(DefaultAlert(
                onSubmit: () {
                  checkInDetailController.archiveQuestion();
                  Get.back(closeOverlays: closeOverlays);
                  if (closeOverlays == false) {
                    Get.back();
                  }
                },
                onCancel: () {
                  Get.back();
                },
                title: 'Archive question?',
                textSubmit: 'Yes',
                textSubmitColor: Color(0xffFF7171),
              ));
            },
            title: Text('Archive',
                style: TextStyle(
                    color: Color(0xffFF7171),
                    fontSize: 12,
                    fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}
