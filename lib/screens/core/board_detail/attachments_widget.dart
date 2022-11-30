import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cicle_mobile_f3/controllers/board_detail_controller.dart';
import 'package:cicle_mobile_f3/controllers/download_controller.dart';
import 'package:cicle_mobile_f3/models/card_model.dart';
import 'package:cicle_mobile_f3/models/member_model.dart';
import 'package:cicle_mobile_f3/utils/helpers.dart';
import 'package:cicle_mobile_f3/widgets/default_alert.dart';
import 'package:cicle_mobile_f3/widgets/photo_view_section.dart';
import 'package:cicle_mobile_f3/widgets/shimmer_custom.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:mime/mime.dart';

import 'board_detail_screen.dart';

class AttachmentWidget extends StatelessWidget {
  AttachmentWidget({
    Key? key,
    required this.boardDetailController,
  }) : super(key: key);

  final BoardDetailController boardDetailController;

  onPressAttachment() async {
    FilePickerResult? result =
        await FilePicker.platform.pickFiles(allowMultiple: true);

    if (result != null) {
      List<File> files = result.paths.map((path) => File(path!)).toList();

      List<Attachments> _attachments = [];

      for (var i = 0; i < files.length; i++) {
        String fileName = result.files[i].name;

        String? path = result.paths[i] ?? '';
        print(path);
        Attachments _attachment = Attachments(
            name: fileName,
            url: path,
            creator: MemberModel(),
            sId: getRandomString(5));

        _attachments.add(_attachment);
      }
      boardDetailController.addAttachments(_attachments);
    } else {}
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 23.0, vertical: 15),
        child: Container(
            width: double.infinity,
            child: Obx(() {
              if (boardDetailController.isLoading) {
                return _buildLoading();
              }

              return _buildHasData();
            })),
      ),
    );
  }

  Column _buildLoading() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Attachments',
          style: label,
        ),
        SizedBox(
          height: 4,
        ),
        ShimmerCustom(
          height: 36,
          borderRadius: 17,
          width: double.infinity,
        )
      ],
    );
  }

  Obx _buildHasData() {
    return Obx(() => boardDetailController.attachments.isEmpty
        ? _buildEmpty()
        : Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                border: Border.all(color: Color(0xffECECEC))),
            padding: EdgeInsets.fromLTRB(6, 6, 0, 6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Attachments',
                      style: label,
                    ),
                    InkWell(
                      onTap: onPressAttachment,
                      child: Container(
                        height: 22,
                        width: 40,
                        margin: EdgeInsets.only(right: 6),
                        decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.5),
                                blurRadius: 1,
                                offset: Offset(1, 1),
                              ),
                            ],
                            color: Color(0xff708FC7),
                            borderRadius: BorderRadius.circular(3)),
                        child: Center(
                            child:
                                Icon(Icons.add, color: Colors.white, size: 18)),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 6,
                ),
                Container(
                    height: 120,
                    child: ListView.builder(
                        itemCount: boardDetailController.attachments.length,
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (ctx, index) {
                          return AttachmentItem(
                            value: boardDetailController.attachments[index],
                            boardDetailController: boardDetailController,
                          );
                        })),
              ],
            ),
          ));
  }

  Column _buildEmpty() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Attachments',
          style: label,
        ),
        SizedBox(
          height: 4,
        ),
        ElevatedButton(
          onPressed: onPressAttachment,
          style: ButtonStyle(
              backgroundColor:
                  MaterialStateProperty.all<Color>(Color(0xff708FC7)),
              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(17.0),
              ))),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.attach_file_sharp,
                  color: Colors.white,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 16.0),
                  child: Text(
                    'Attach file',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.normal),
                  ),
                )
              ],
            ),
          ),
        )
      ],
    );
  }
}

class AttachmentItem extends StatelessWidget {
  AttachmentItem({
    Key? key,
    required this.value,
    required this.boardDetailController,
  }) : super(key: key);

  final Attachments value;
  final BoardDetailController boardDetailController;
  DownloadController _downloadController = Get.put(DownloadController());

  getWidgetByExt() {
    String mimeType = lookupMimeType(value.url) ?? '';
    String ext = mimeType == '' ? '' : extensionFromMime(mimeType);
    if (value.url[0] == '/') {
      return Center(
        child: SizedBox(
          height: 30,
          width: 30,
          child: CircularProgressIndicator(),
        ),
      );
    }
    switch (ext) {
      case 'png':
      case 'gif':
      case 'jpe':
        return GestureDetector(
          onTap: () {
            Get.dialog(PhotoViewSection(
              url: getPhotoUrl(url: value.url),
            ));
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(5.0),
            child: CachedNetworkImage(
              imageUrl: getPhotoUrl(url: value.url),
              fit: BoxFit.cover,
            ),
          ),
        );
      case '':
        return Center(
            child: Text('?',
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                )));
      default:
        return Center(
          child: Container(
              width: 50,
              height: 50,
              child: Image.asset(getPathExtention(mimeType: ext),
                  fit: BoxFit.cover)),
        );
    }
  }

  onEditTitle() {
    boardDetailController.textEditingControllerAttachmentName.text = value.name;
    Get.dialog(
        FormEdit(item: value, boardDetailController: boardDetailController));
  }

  onremove() {
    Get.dialog(DefaultAlert(
      onSubmit: () {
        Get.back();
        boardDetailController.deleteAttachment(value);
      },
      onCancel: () {
        Get.back();
      },
      title: 'Delete Attachment?',
      description: 'Deleting a attachment is forever. There is no undo.',
      showDescription: true,
    ));
  }

  onDownload() async {
    var grant = await checkPermission();
    if (grant == true) {
      Get.dialog(DefaultAlert(
          onSubmit: () {
            showAlert(message: 'start downloading ${value.name} files');
            Get.back();
            _downloadController.requestDownload(
                TaskInfo(name: value.name, link: getPhotoUrl(url: value.url)));
          },
          onCancel: () {
            Get.back();
          },
          title: 'are you sure you want to download the ${value.name} file'));
    }
  }

  @override
  Widget build(BuildContext context) {
    var parseStringDate;
    String dayName = '';
    String updatedAt = '';
    bool isLocalFile = value.url[0] == '/';

    if (value.url[0] != '/') {
      parseStringDate = DateTime.parse(value.updatedAt).toLocal();
      dayName = DateFormat('E').format(parseStringDate);
      updatedAt = DateFormat('dd MMM yyyy hh.mm a').format(parseStringDate);
    }

    return GestureDetector(
      onTap: () async {},
      child: Container(
        width: 120,
        margin: EdgeInsets.only(right: 6),
        child: Stack(
          children: [
            Container(
              height: 96,
              child: Stack(
                children: [
                  Container(
                    height: 96,
                    width: 120,
                    child: getWidgetByExt(),
                  ),
                  Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                          width: double.infinity,
                          color: Colors.white.withOpacity(0.75),
                          padding:
                              EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          child: Text(
                            value.name,
                            style: TextStyle(fontSize: 8),
                            maxLines: 1,
                          ))),
                  Positioned(top: 0, right: -12, child: _buildMoreButton())
                ],
              ),
            ),
            Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 4),
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                        color: Color(0xffFFEEC3),
                        borderRadius: BorderRadius.circular(5)),
                    child: Text(
                      '$dayName $updatedAt',
                      style: TextStyle(fontSize: 8),
                      maxLines: 1,
                    )))
          ],
        ),
      ),
    );
  }

  Widget _buildMoreButton() {
    return SizedBox(
      height: 25,
      child: Container(
        margin: EdgeInsets.only(right: 3, top: 3),
        child: PopupMenuButton(
          offset: Offset(-5, 5),
          icon: Container(
            decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.5),
                borderRadius: BorderRadius.circular(3)),
            child: Icon(
              Icons.more_vert_outlined,
              color: Color(0xff7A7A7A),
            ),
          ),
          padding: EdgeInsets.all(0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5),
          ),
          itemBuilder: (context) => [
            PopupMenuItem(
              height: 35,
              child: Text(
                "Edit Title",
                style: TextStyle(fontSize: 14, color: Color(0xff979797)),
              ),
              value: 1,
            ),
            PopupMenuItem(
              height: 35,
              child: Text(
                "Remove",
                style: TextStyle(fontSize: 14, color: Color(0xff979797)),
              ),
              value: 2,
            ),
            PopupMenuItem(
              height: 35,
              child: Text(
                "Download",
                style: TextStyle(fontSize: 14, color: Color(0xff979797)),
              ),
              value: 3,
            ),
          ],
          onSelected: (int value) {
            switch (value) {
              case 1:
                return onEditTitle();
              case 2:
                return onremove();
              case 3:
                return onDownload();

              default:
                return;
            }
          },
        ),
      ),
    );
  }
}

class FormEdit extends StatelessWidget {
  const FormEdit({
    Key? key,
    required this.boardDetailController,
    required this.item,
  }) : super(key: key);
  final Attachments item;
  final BoardDetailController boardDetailController;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Material(
        color: Colors.transparent,
        child: Center(
          child: Container(
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(10)),
            margin: EdgeInsets.symmetric(horizontal: 30),
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text('Edit Attachment'),
                    InkWell(
                        onTap: () {
                          Get.back();
                        },
                        child: Icon(Icons.close))
                  ],
                ),
                SizedBox(
                  height: 15,
                ),
                TextField(
                  controller:
                      boardDetailController.textEditingControllerAttachmentName,
                  decoration: InputDecoration(
                    isDense: true,
                    fillColor: Colors.white,
                    filled: true,
                    contentPadding: EdgeInsets.only(
                        left: 20, right: 20, top: 19, bottom: 19),
                    hintText: "name...",
                    hintStyle: TextStyle(color: Color(0xffB5B5B5)),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: new BorderRadius.circular(10.0),
                      borderSide:
                          BorderSide(color: Colors.black.withOpacity(0.1)),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: const BorderRadius.all(
                        const Radius.circular(10.0),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 15,
                ),
                ElevatedButton(
                    onPressed: () async {
                      FocusScope.of(context).unfocus();
                      await Future.delayed(Duration(milliseconds: 300));
                      boardDetailController.updateAttachmentName(
                          item,
                          boardDetailController
                              .textEditingControllerAttachmentName.text);
                      await Future.delayed(Duration(milliseconds: 300));
                      Get.back();
                    },
                    child: Container(
                        width: double.infinity,
                        child: Center(
                            child: Text(
                          'Update',
                          style: TextStyle(color: Colors.white),
                        ))))
              ],
            ),
          ),
        ),
      ),
    );
  }
}
