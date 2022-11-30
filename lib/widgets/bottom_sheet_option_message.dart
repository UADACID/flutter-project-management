import 'package:cicle_mobile_f3/models/member_model.dart';
import 'package:cicle_mobile_f3/utils/constant.dart';
import 'package:cicle_mobile_f3/utils/helpers.dart';
import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:get/get.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:get_storage/get_storage.dart';

import 'default_alert.dart';

class BottomSheetOptionMessage extends StatelessWidget {
  BottomSheetOptionMessage({
    Key? key,
    required this.message,
    required this.onDeleteMessage,
    this.isFile = false,
  }) : super(key: key);

  final types.Message message;
  final Function onDeleteMessage;
  final bool isFile;

  final box = GetStorage();

  onSelect() async {
    Get.back();
    await Future.delayed(Duration(milliseconds: 200));
    Get.dialog(
      Center(
        child: Material(
          color: Colors.transparent,
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 16),
            constraints: BoxConstraints(maxHeight: 550),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Container(
                color: Colors.white,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 15.0),
                          child: Text(
                            'you can do select text here',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                        IconButton(
                            onPressed: () {
                              Get.back();
                            },
                            icon: Icon(Icons.close, color: Colors.grey))
                      ],
                    ),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                            border: Border.all(
                                color: Colors.grey.withOpacity(0.5))),
                        margin: EdgeInsets.all(15),
                        padding: EdgeInsets.all(10),
                        child: SingleChildScrollView(
                            child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child:
                              SelectableHtml(data: message.metadata!['text']),
                        )),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  onCopy() {
    String cleanContentFromHtml = removeHtmlTag(message.metadata!['text']);
    Clipboard.setData(ClipboardData(text: cleanContentFromHtml));
    showAlert(message: 'copy text to clipboard');
    Get.back();
  }

  onDelete() {
    // Get.back();
    Get.dialog(DefaultAlert(
        onSubmit: () {
          EasyDebounce.debounce(
              'submit-add-check-in', // <-- An ID for this particular debouncer
              Duration(milliseconds: 300), // <-- The debounce duration
              () {
            onDeleteMessage();
            Get.back();
          } // <-- The target method
              );
        },
        onCancel: () {
          Get.back();
        },
        title: 'are you sure you want to delete message ?'));
  }

  bool isHideDelete() {
    final userString = box.read(KeyStorage.logedInUser);
    MemberModel _templogedInUser = MemberModel.fromJson(userString);
    String messageCreatorId = message.author.id;
    String logedInUserId = _templogedInUser.sId;

    if (message.metadata!['text'] == "This message was deleted") {
      return true;
    }
    if (logedInUserId == messageCreatorId) {
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.only(
          topLeft: Radius.circular(15), topRight: Radius.circular(15)),
      child: Container(
        height: isHideDelete() ? 125 : (isFile ? 70 : 180),
        child: Material(
          child: Column(
            children: [
              SizedBox(
                height: 10,
              ),
              isFile
                  ? SizedBox()
                  : InkWell(
                      onTap: onSelect,
                      child: Container(
                          child: Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(15.0),
                            child: Icon(
                              Icons.select_all,
                              color: Color(0xff708FC7),
                            ),
                          ),
                          Text(
                            'Select',
                            style: TextStyle(
                              color: Color(0xff708FC7),
                            ),
                          ),
                        ],
                      )),
                    ),
              isFile
                  ? SizedBox()
                  : Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: SizedBox(height: 1, child: Divider()),
                    ),
              isFile
                  ? SizedBox()
                  : InkWell(
                      onTap: onCopy,
                      child: Container(
                          child: Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(15.0),
                            child: Icon(
                              Icons.copy,
                              color: Color(0xff708FC7),
                            ),
                          ),
                          Text(
                            'Copy',
                            style: TextStyle(
                              color: Color(0xff708FC7),
                            ),
                          ),
                        ],
                      )),
                    ),
              isFile
                  ? SizedBox()
                  : Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: SizedBox(height: 1, child: Divider()),
                    ),
              isHideDelete()
                  ? SizedBox()
                  : InkWell(
                      onTap: onDelete,
                      child: Container(
                          child: Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(15.0),
                            child: Icon(
                              Icons.delete_outline,
                              color: Color(0xff708FC7),
                            ),
                          ),
                          Text(
                            'Delete',
                            style: TextStyle(
                              color: Color(0xff708FC7),
                            ),
                          ),
                        ],
                      )),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
