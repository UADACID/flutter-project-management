import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cicle_mobile_f3/controllers/download_controller.dart';
import 'package:cicle_mobile_f3/utils/helpers.dart';
import 'package:cicle_mobile_f3/widgets/bottom_sheet_option_message.dart';
import 'package:cicle_mobile_f3/widgets/inline_widget_html.dart';
import 'package:cicle_mobile_f3/widgets/photo_view_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:mime/mime.dart';

class MessageRight extends StatelessWidget {
  MessageRight({
    Key? key,
    required this.message,
    required this.donwloadController,
    required this.onDeleteMessage,
    required this.onDeleteAttachment,
  }) : super(key: key);
  final types.Message message;
  final DownloadController? donwloadController;
  final Function onDeleteMessage;
  final Function onDeleteAttachment;

  @override
  Widget build(BuildContext context) {
    DateTime date = DateTime.fromMillisecondsSinceEpoch(message.createdAt!);
    String time = DateFormat('hh:mm a').format(date);
    if (message.metadata!['type'] == 'file') {
      return _fileMessage(time);
    }
    if (message.metadata!['type'] == 'image') {
      return _imageMessage(time);
    }
    return _textMessage(time);
  }

  onDownload(String url, String name) async {
    var grant = await checkPermission();
    print('name $name');
    if (grant == true && donwloadController != null) {
      donwloadController!.requestDownload(TaskInfo(name: name, link: url));
    }
  }

  Stack _fileMessage(String time) {
    String title = message.metadata!['text'];
    String path = message.metadata!['path'];

    int size = message.metadata!['size'];
    String extension = message.metadata!['extension'];
    String ext = extensionFromMime(extension);
    final bytes = size;

    return Stack(
      children: [
        Container(
          padding: EdgeInsets.all(8.w),
          constraints:
              BoxConstraints(maxWidth: Get.width / 1.7, minWidth: 50.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(
                getPathExtention(mimeType: ext),
                width: Get.width / 2.7,
                height: Get.width / 2.7,
                fit: BoxFit.scaleDown,
              ),
              Text(
                title,
                style: TextStyle(fontSize: 12.sp),
                textAlign: TextAlign.center,
              ),
              SizedBox(
                height: 10,
              ),
              OutlinedButton(
                  onPressed: () async {
                    await Future.delayed(Duration(milliseconds: 250));
                    onDownload(path, title);
                  },
                  child: Text(
                    'Download',
                    style: TextStyle(fontSize: 12.sp, color: Colors.blue),
                    textAlign: TextAlign.center,
                  )),
              SizedBox(
                height: 10,
              ),
              Align(
                alignment: Alignment.bottomRight,
                child: Container(
                  padding: const EdgeInsets.all(1.0),
                  child: Text(
                    time.toString(),
                    style: TextStyle(
                        fontSize: 10.w, color: Colors.black.withOpacity(0.3)),
                  ),
                ),
              )
            ],
          ),
        ),
        Positioned(
          top: 0,
          right: 0,
          child: InkWell(
            onTap: () {
              Get.bottomSheet(BottomSheetOptionMessage(
                message: message,
                onDeleteMessage: onDeleteAttachment,
                isFile: true,
              ));
            },
            child: Container(
                decoration: BoxDecoration(color: Colors.black.withOpacity(0.1)),
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: Icon(
                  Icons.more_horiz,
                  color: Colors.white,
                )),
          ),
        ),
      ],
    );
  }

  GestureDetector _imageMessage(time) {
    String path = message.metadata!['path'];

    var localImage = Image.file(
      File(path),
    );
    var remoteImage = CachedNetworkImage(imageUrl: path);
    var image = path[0] == '/' ? localImage : remoteImage;
    return GestureDetector(
      onTap: () {
        Get.dialog(PhotoViewSection(
          url: path,
        ));
      },
      child: Container(
          constraints:
              BoxConstraints(maxWidth: Get.width / 1.7, minWidth: 50.w),
          child: Stack(
            children: [
              image,
              Positioned(
                  bottom: 4,
                  right: 4,
                  child: Container(
                    color: Colors.black.withOpacity(0.5),
                    padding: const EdgeInsets.all(1.0),
                    child: Text(
                      time.toString(),
                      style: TextStyle(fontSize: 11.w, color: Colors.white),
                    ),
                  )),
              Positioned(
                top: 4,
                right: 4,
                child: InkWell(
                  onTap: () {
                    Get.bottomSheet(BottomSheetOptionMessage(
                      message: message,
                      onDeleteMessage: onDeleteAttachment,
                      isFile: true,
                    ));
                  },
                  child: Container(
                      decoration:
                          BoxDecoration(color: Colors.black.withOpacity(0.5)),
                      padding:
                          EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      child: Icon(
                        Icons.more_horiz,
                        color: Colors.white,
                      )),
                ),
              ),
            ],
          )),
    );
  }

  InkWell _textMessage(String time) {
    return InkWell(
      onTap: () async {
        Get.bottomSheet(BottomSheetOptionMessage(
          message: message,
          onDeleteMessage: onDeleteMessage,
        ));
      },
      child: Container(
        padding: EdgeInsets.all(10.w),
        constraints: BoxConstraints(maxWidth: Get.width / 1.7, minWidth: 50.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            HtmlWidget(
              message.metadata!['text'],
              textStyle: TextStyle(fontSize: 12.w),
              factoryBuilder: () => InlineWidget(),
              onTapUrl: parseLinkPressed,
              onTapImage: (ImageMetadata imageData) {
                String url = imageData.sources.length > 0
                    ? imageData.sources.first.url
                    : 'default uri';
                Get.dialog(PhotoViewSection(
                  url: url,
                ));
              },
            ),
            SizedBox(
              height: 4,
            ),
            Text(
              time.toString(),
              style: TextStyle(
                  fontSize: 10.w, color: Colors.black.withOpacity(0.3)),
            )
          ],
        ),
      ),
    );
  }
}
