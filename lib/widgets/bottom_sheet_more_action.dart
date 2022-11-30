import 'package:cicle_mobile_f3/utils/my_flutter_app_icons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'default_alert.dart';

class BottomSheetMoreAction extends StatelessWidget {
  BottomSheetMoreAction({
    Key? key,
    this.closeOverlays = true,
    required this.onDelete,
    required this.onEdit,
    this.titleAlert = 'are you sure to delete this item ?',
    this.textEdit = 'Edit',
    this.textDelete = 'Archive',
    this.showEdit = true,
  }) : super(key: key);

  final bool closeOverlays;
  final Function onEdit;
  final Function onDelete;
  final String titleAlert;
  final String textEdit;
  final String textDelete;
  final bool showEdit;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: showEdit ? 135 : 95,
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
          showEdit == true
              ? Column(
                  children: [
                    ListTile(
                      minLeadingWidth: 0,
                      leading: Icon(
                        MyFlutterApp.mdi_square_edit_outline,
                        color: Color(0xff708FC7),
                      ),
                      onTap: () => onEdit(),
                      title: Text(
                        textEdit,
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
                  ],
                )
              : SizedBox(),
          ListTile(
            minLeadingWidth: 0,
            leading: Padding(
              padding: const EdgeInsets.only(left: 2),
              child: Icon(
                MyFlutterApp.archive,
                size: 20,
                color: Color(0xff708FC7),
              ),
            ),
            onTap: () {
              Get.dialog(DefaultAlert(
                onSubmit: () {
                  onDelete();
                },
                onCancel: () {
                  Get.back();
                },
                title: titleAlert,
                textSubmit: 'Ok',
                textSubmitColor: Color(0xff708FC7),
              ));
            },
            title: Text(textDelete,
                style: TextStyle(
                    color: Color(0xff708FC7),
                    fontSize: 12,
                    fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}
