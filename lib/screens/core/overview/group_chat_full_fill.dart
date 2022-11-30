import 'package:cicle_mobile_f3/models/member_model.dart';
import 'package:cicle_mobile_f3/models/message_item_model.dart';

import 'package:cicle_mobile_f3/utils/constant.dart';
import 'package:cicle_mobile_f3/utils/helpers.dart';

import 'package:cicle_mobile_f3/widgets/avatar_custom.dart';
import 'package:cicle_mobile_f3/widgets/inline_widget_html.dart';
import 'package:flutter/material.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:intl/intl.dart';

class GroupChatFullFill extends StatelessWidget {
  GroupChatFullFill({Key? key, this.list = const []}) : super(key: key);
  final List<MessageItemModel> list;
  final box = GetStorage();

  String dummyContent1 = 'selamat puasa juga ya, semoga lancar';
  String dummyContent2 =
      'Selamat berpuasa semuanya, mohon maaf juga kalau ada salah salah, semoga puasanya tahun ini lancar...';

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(4),
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10), color: Color(0xfff4f4f4)),
      child: SingleChildScrollView(
        reverse: true,
        physics: NeverScrollableScrollPhysics(),
        child: Column(
          children: [
            ...list
                .asMap()
                .map((key, value) {
                  final userString = box.read(KeyStorage.logedInUser);

                  MemberModel logedInUser = MemberModel.fromJson(userString);
                  MessageItemModel item = value;
                  String creatorId = item.creator.sId;
                  int position = creatorId == logedInUser.sId ? 1 : 0;
                  String imageUser = item.customMessage.author.imageUrl!;
                  return MapEntry(
                      key,
                      Container(
                        margin: EdgeInsets.only(top: 5.w),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            position == 0
                                ? AvatarCustom(
                                    child: Image.network(
                                      getPhotoUrl(url: imageUser),
                                      width: 16,
                                      height: 15.w,
                                      fit: BoxFit.cover,
                                    ),
                                    height: 15.w,
                                  )
                                : Container(),
                            SizedBox(
                              width: 2.w,
                            ),
                            Expanded(
                              child:
                                  Container(child: _buildItem(position, item)),
                            ),
                          ],
                        ),
                      ));
                })
                .values
                .toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildItem(int position, MessageItemModel item) {
    types.Message message = item.customMessage;
    if (message.metadata!['type'] == 'file') {
      return Align(
          alignment:
              position == 0 ? Alignment.centerLeft : Alignment.centerRight,
          child: Container(
              decoration: BoxDecoration(
                  color: position == 0 ? Colors.white : Color(0xffFFEEC3),
                  borderRadius: BorderRadius.circular(5.w)),
              child: _fileMessage(message)));
    }
    if (message.metadata!['type'] == 'image') {
      return Align(
          alignment:
              position == 0 ? Alignment.centerLeft : Alignment.centerRight,
          child: Container(
              padding: EdgeInsets.all(1.w),
              color: position == 0 ? Colors.white : Color(0xffFFEEC3),
              child: _imageMessage(message)));
    }
    return Align(
        alignment: position == 0 ? Alignment.centerLeft : Alignment.centerRight,
        child: Container(
            decoration: BoxDecoration(
                color: position == 0 ? Colors.white : Color(0xffFFEEC3),
                borderRadius: BorderRadius.circular(5.w)),
            child: _textMessage(message)));
  }

  Container _textMessage(types.Message message) {
    DateTime date = DateTime.fromMillisecondsSinceEpoch(message.createdAt!);
    String time = DateFormat('hh:mm a').format(date);
    return Container(
      padding: EdgeInsets.all(5.w),
      constraints: BoxConstraints(maxWidth: 75.w, minWidth: 50.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          HtmlWidget(
            message.metadata!['text'],
            textStyle: TextStyle(fontSize: 6.w),
            factoryBuilder: () => InlineWidget(isSmall: true),
            onTapUrl: parseLinkPressed,
          ),
          SizedBox(
            height: 2,
          ),
          Text(
            time.toString(),
            style:
                TextStyle(fontSize: 6.w, color: Colors.black.withOpacity(0.3)),
          )
        ],
      ),
    );
  }

  Container _fileMessage(types.Message message) {
    String title = message.metadata!['text'];

    int size = message.metadata!['size'];
    String extension = message.metadata!['extension'];
    final bytes = size;

    return Container(
        padding: EdgeInsets.all(4.w),
        constraints: BoxConstraints(maxWidth: 75.w, minWidth: 50.w),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Theme.of(Get.context!).primaryColor.withOpacity(0.5),
              ),
              child: Icon(
                Icons.description_outlined,
                size: 6.w,
                color: Colors.white,
              ),
            ),
            SizedBox(
              width: 5.w,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                      child: Text(
                    title,
                    style: TextStyle(
                        fontSize: 6.w,
                        fontWeight: FontWeight.bold,
                        color: Colors.black.withOpacity(0.5)),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  )),
                  Text(extension,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: TextStyle(
                          fontSize: 6.w, color: Colors.black.withOpacity(0.5)))
                ],
              ),
            ),
          ],
        ));
  }

  Container _imageMessage(types.Message message) {
    String path = message.metadata!['path'];
    DateTime date = DateTime.fromMillisecondsSinceEpoch(message.createdAt!);
    String time = DateFormat('hh:mm a').format(date);
    return Container(
      child: Container(
          child: Stack(
        children: [
          Image.network(
            getPhotoUrl(url: path),
            width: 50.w,
          ),
          Positioned(
              bottom: 2.w,
              right: 2.w,
              child: Container(
                color: Colors.black.withOpacity(0.5),
                padding: const EdgeInsets.all(1.0),
                child: Text(
                  time.toString(),
                  style: TextStyle(fontSize: 6.w, color: Colors.white),
                ),
              )),
        ],
      )),
    );
  }
}
