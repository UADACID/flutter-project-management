import 'dart:io';

import 'package:cicle_mobile_f3/controllers/download_controller.dart';
import 'package:cicle_mobile_f3/controllers/notification_all_controller.dart';
import 'package:cicle_mobile_f3/controllers/private_chat_controller.dart';
import 'package:cicle_mobile_f3/controllers/private_chat_detail_controller.dart';
import 'package:cicle_mobile_f3/controllers/team_detail_controller.dart';
import 'package:cicle_mobile_f3/models/member_model.dart';
import 'package:cicle_mobile_f3/models/notification_item_model.dart';
import 'package:cicle_mobile_f3/utils/my_flutter_app_icons.dart';
import 'package:cicle_mobile_f3/widgets/bottom_sheet_attachment.dart';
import 'package:cicle_mobile_f3/widgets/error_something_wrong.dart';
import 'package:cicle_mobile_f3/widgets/members_mention_container.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:image_picker/image_picker.dart' as sourceType;

import 'core/group_chat/message_left.dart';
import 'core/group_chat/message_right.dart';

class PrivateChatDetailScreen extends StatelessWidget {
  PrivateChatDetailScreen({Key? key}) : super(key: key);
  String? teamId = Get.parameters['teamId'];

  PrivateChatDetailController _privateChatDetailController = Get.find();

  DownloadController _downloadController = Get.put(DownloadController());

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_privateChatDetailController.showMentionBox) {
          _privateChatDetailController.showMentionBox = false;
          return Future.value(false);
        }
        return Future.value(true);
      },
      child: Scaffold(
        appBar: AppBar(
          title: Obx(() => Text(
                '${_privateChatDetailController.title}',
                style: TextStyle(fontSize: 16),
              )),
          elevation: 0.0,
        ),
        body: Obx(() {
          if (_privateChatDetailController.isLoading) {
            return Center(child: CircularProgressIndicator());
          }

          if (!_privateChatDetailController.isLoading &&
              _privateChatDetailController.errorMessage != '') {
            return Center(
              child: ErrorSomethingWrong(
                  message: _privateChatDetailController.errorMessage,
                  refresh: () {
                    _privateChatDetailController.getMessages();
                  }),
            );
          }
          return Stack(
            children: [
              BodyGroupChat(
                  controller: _privateChatDetailController,
                  downloadController: _downloadController),
              Obx(() => _privateChatDetailController.showOverlay
                  ? Stack(
                      children: [
                        Container(
                            height: double.infinity,
                            width: double.infinity,
                            color: Colors.black.withOpacity(0.5),
                            child: Center(
                                child: Stack(
                              alignment: Alignment.center,
                              children: [
                                CircularProgressIndicator(),
                                Text(
                                  '${_privateChatDetailController.uploadProgress.ceil()} %',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 11),
                                ),
                              ],
                            ))),
                        Align(
                          alignment: Alignment.topRight,
                          child: IconButton(
                              onPressed:
                                  _privateChatDetailController.cancelUploadFile,
                              icon: Icon(Icons.close, color: Colors.white)),
                        )
                      ],
                    )
                  : SizedBox())
            ],
          );
        }),
      ),
    );
  }
}

class BodyGroupChat extends StatelessWidget {
  BodyGroupChat(
      {Key? key, required this.controller, required this.downloadController})
      : super(key: key);

  final PrivateChatDetailController controller;

  final DownloadController downloadController;

  PrivateChatController _privateChatController = Get.find();
  NotificationAllController _notificationAllController =
      Get.put(NotificationAllController());

  String? teamId = Get.parameters['teamId'];

  void _addMessage(types.Message message) {
    controller.addMessage(message);
  }

  void _handleAtachmentPressed() {
    Get.bottomSheet(BottomSheetAttachment(
      onPressCamera: () {
        _handleImageSelectionCamera();
      },
      onPressDoc: () {
        _handleFileSelection();
      },
      onPressgallery: () {
        _handleImageSelection();
      },
    ));
  }

  void _handleFileSelection() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      File file = File(result.files.single.path!);

      String fileName = result.files[0].name;
      String? extension = result.files[0].extension ?? '';
      int size = result.files[0].size;
      String? path = result.files[0].path ?? '';

      final message = types.CustomMessage(
          author: types.User(id: controller.logedInUserId),
          createdAt: DateTime.now().millisecondsSinceEpoch,
          id: const Uuid().v4(),
          metadata: {
            'text': fileName,
            'extension': extension,
            'size': size,
            'path': path,
            'type': 'file'
          });

      controller.addAttachment(message);
      Get.back();
    } else {
      // User canceled the picker
    }
  }

  void _handleImageSelectionCamera() async {
    final result = await ImagePicker().pickImage(
      source: sourceType.ImageSource.camera,
      imageQuality: 70,
      maxWidth: 1440,
    );

    if (result != null) {
      final bytes = await result.readAsBytes();
      final image = await decodeImageFromList(bytes);
      final name = result.path.split('/').last;

      final message = types.CustomMessage(
          author: types.User(id: controller.logedInUserId),
          createdAt: DateTime.now().millisecondsSinceEpoch,
          id: const Uuid().v4(),
          metadata: {
            'text': name,
            'size': bytes.length,
            'path': result.path,
            'width': image.width.toDouble(),
            'height': image.height.toDouble(),
            'type': 'image'
          });

      controller.addAttachment(message);
      Get.back();
    } else {
      // User canceled the picker
    }
  }

  void _handleImageSelection() async {
    final result = await ImagePicker().pickImage(
      source: sourceType.ImageSource.gallery,
      imageQuality: 70,
      maxWidth: 1440,
    );

    if (result != null) {
      final bytes = await result.readAsBytes();
      final image = await decodeImageFromList(bytes);
      final name = result.path.split('/').last;

      final message = types.CustomMessage(
          author: types.User(id: controller.logedInUserId),
          createdAt: DateTime.now().millisecondsSinceEpoch,
          id: const Uuid().v4(),
          metadata: {
            'text': name,
            'size': bytes.length,
            'path': result.path,
            'width': image.width.toDouble(),
            'height': image.height.toDouble(),
            'type': 'image'
          });

      controller.addAttachment(message);
      Get.back();
    } else {
      // User canceled the picker
    }
  }

  void _handleSendPressed(types.PartialText message) {
    var content = message.text;

    print(message.text);
    bool hasNewLine = message.text.contains("\n");
    print('hasNewLine $hasNewLine');

    final mailPattern = r"\b[\w\.-]+@[\w\.-]+\.\w{2,4}\b";
    final regEx = RegExp(mailPattern, multiLine: true);

    // link extraction
    // RegExp exp = new RegExp(
    //   r'(?:(?:https?|ftp):\/\/)?[\w/\-?=%.]+\.[\w/\-?=%.]+',
    // );
    final exp = RegExp(
        r"((https?:www\.)|(https?:\/\/)|(www\.))[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9]{1,6}(\/[-a-zA-Z0-9()@:%_\+.~#?&\/=]*)?");

    String _newContent = '';
    var _splitStringBySpace = content.split(" ");
    for (var i = 0; i < _splitStringBySpace.length; i++) {
      var _stringByIndex = _splitStringBySpace[i];
      if (GetUtils.isEmail(_stringByIndex)) {
        _newContent += '$_stringByIndex ';
      } else if (exp.hasMatch(_stringByIndex)) {
        // final obtainedLink = exp.allMatches(_stringByIndex).map((m) {
        //   return m.group(0);
        // }).join(',');
        // var splitLinks = obtainedLink.split(',');

        // _newContent +=
        //     '<a href=\"${splitLinks[0]}\" rel=\"noopener noreferrer\" target=\"_blank\">${splitLinks[0]}</a> ';

        // ----- new fixing -----
        // final obtainedLink = exp.allMatches(_stringByIndex).map((m) {
        //   return m.group(0);
        // }).join(',');
        // print(_stringByIndex);
        // var splitLinks = _stringByIndex.split(',');
        // _newContent +=
        //     '<a href=\"${splitLinks[0]}\" rel=\"noopener noreferrer\" target=\"_blank\">${splitLinks[0]}</a> ';
        var splitLinks = _stringByIndex.split(',');
        if (_stringByIndex[_stringByIndex.length - 1] == ',') {
          _stringByIndex =
              _stringByIndex.substring(0, _stringByIndex.length - 1);

          if (regEx.hasMatch(_stringByIndex)) {
            _newContent += '$_stringByIndex, ';
          } else {
            _newContent +=
                '<a href=\"${splitLinks[0]}\" rel=\"noopener noreferrer\" target=\"_blank\">${splitLinks[0]}</a> ';
          }
        } else {
          _newContent +=
              '<a href=\"${splitLinks[0]}\" rel=\"noopener noreferrer\" target=\"_blank\">${splitLinks[0]}</a> ';
        }
      } else {
        _newContent += '$_stringByIndex ';
      }
    }

    content = _newContent;

    final obtainedMail =
        regEx.allMatches(content).map((m) => m.group(0)).join(',');

    var mentionedEmails = obtainedMail.split(',');

    List<String> _listMembersId = [];

    for (var i = 0; i < mentionedEmails.length; i += 1) {
      var filterMemberByEmail = controller.members
          .where((element) => element.email == mentionedEmails[i])
          .toList();
      if (filterMemberByEmail.length > 0) {
        MemberModel member = filterMemberByEmail[0];
        _listMembersId.add(member.sId);
        content = content.replaceFirst(mentionedEmails[i],
            '<span class=\"fr-deletable fr-tribute\" contenteditable=\"false\" data-mentioned-user-id=\"${member.sId}\" id=\"mentioned-user\" style=\"padding:1px; background-color:#e8ffff; border-radius:2px; display:inline-flex; align-items:center\"><img style=\"width:20px; height:20px; object-fit: cover; margin-right:3px; border-radius:100%;\" src=\"${member.photoUrl}\"><a href=\"/profiles/${member.sId}\">${member.fullName}</a></span>');
      }
    }

    var distinchListMembersId = _listMembersId.toSet().toList();

    final textMessage = types.CustomMessage(
        author: types.User(id: controller.logedInUserId),
        createdAt: DateTime.now().millisecondsSinceEpoch,
        id: const Uuid().v4(),
        metadata: {
          'text': content.replaceAll('\n', '<br>'),
          'mentionedUsers': distinchListMembersId
        });

    _addMessage(textMessage);
  }

  Future<bool> _onWillPop() async {
    String previousRoute = Get.previousRoute;
    if (previousRoute.contains('team-detail')) {
      TeamDetailController _teamDetailController =
          Get.put(TeamDetailController());
      _teamDetailController.selectedMenuIndex = 0;
    }

    needForUpdateMarkAssRead();
    return Future.value(true);
  }

  needForUpdateMarkAssRead() {
    List<String> checkIds = [controller.logedInUserId];
    List<Activities> filteredActivities = [];
    List<NotificationItemModel> notifForThisChatItem = _privateChatController
        .listNotifChat
        .where((element) => element.service.serviceId == controller.chatId)
        .toList();
    if (notifForThisChatItem.isNotEmpty) {
      filteredActivities = notifForThisChatItem[0]
          .activities
          .where((activity) => !activity.readBy
              .any((element) => checkIds.contains(element.reader)))
          .toList();
    }

    print('ada notif blm terbaca ${filteredActivities.length}');
    if (filteredActivities.isNotEmpty) {
      _notificationAllController
          .updateNotifItemAsRead(notifForThisChatItem[0].sId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    DefaultChatTheme defaultChatTheme = DefaultChatTheme(
      messageBorderRadius: 10.w,
      primaryColor: Color(0xffFFEEC3),
    );
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        body: Container(
          child: Column(
            children: [
              SizedBox(
                height: 2,
              ),
              Expanded(
                child: Obx(() => Column(
                      children: [
                        Expanded(
                          child: Chat(
                            showUserAvatars: true,
                            showUserNames: true,
                            theme: defaultChatTheme,
                            messages: controller.messages.length == 0
                                ? []
                                : controller.messages,
                            onAttachmentPressed: _handleAtachmentPressed,
                            onSendPressed: _handleSendPressed,
                            user: types.User(id: controller.logedInUserId),
                            onEndReached: !controller.isLoadingMore
                                ? () async {
                                    if (!controller.isLoadingMore) {
                                      if (controller.canLoadMore) {
                                        controller.limit = 10;
                                        return Future.value(false);
                                      }
                                    }
                                  }
                                : null,
                            customBottomWidget: Container(
                                margin: EdgeInsets.only(bottom: bottomPadding),
                                child: _buildInput()),
                            customMessageBuilder: (types.Message message,
                                {messageWidth: 100}) {
                              if (message.author.id ==
                                  controller.logedInUserId) {
                                return MessageRight(
                                  message: message,
                                  donwloadController: downloadController,
                                  onDeleteMessage: () {
                                    Get.back();
                                    controller.deleteMessage(message.id);
                                  },
                                  onDeleteAttachment: () {
                                    Get.back();
                                    controller.deleteAttachment(message.id);
                                  },
                                );
                              }
                              return MessageLeft(
                                donwloadController: downloadController,
                                message: message,
                                onDeleteMessage: () {
                                  Get.back();
                                  controller.deleteMessage(message.id);
                                },
                              );
                            },
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

  Container _buildInput() => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 1,
              blurRadius: 1,
              offset: Offset(0, 0), // changes position of shadow
            ),
          ],
        ),
        padding: EdgeInsets.symmetric(horizontal: 0.w, vertical: 2.5.w),
        child: Column(
          children: [
            Obx(() => controller.showMentionBox
                ? Container(
                    height: 40,
                    child: ListMemberForMention(
                      showMentionAll: false,
                      list: controller.members,
                      onSelect: (MemberModel member) {
                        print(member);
                        controller.showMentionBox = false;
                        String email = member.email;

                        final text = controller.textEditingControllerInput.text;
                        TextSelection selection =
                            controller.textEditingControllerInput.selection;

                        int _selectionStart =
                            selection.start < 0 ? 0 : selection.start;
                        int _selectionEnd =
                            selection.end < 0 ? 0 : selection.start;
                        final newText = text.replaceRange(
                            _selectionStart, _selectionEnd, email);

                        int _selectionBaseOffset =
                            selection.baseOffset < 0 ? 0 : selection.baseOffset;
                        controller.textEditingControllerInput.value =
                            TextEditingValue(
                          text: newText,
                          selection: TextSelection.collapsed(
                              offset: _selectionBaseOffset + email.length),
                        );

                        controller.text = newText;
                      },
                      onMentionAll: (List<MemberModel> members) {},
                    ),
                  )
                : Container()),
            SizedBox(
              height: 2.w,
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                SizedBox(
                  width: 5.w,
                ),
                controller.hasFocus
                    ? InkWell(
                        onTap: () {
                          controller.showMentionBox =
                              !controller.showMentionBox;
                        },
                        child: Padding(
                          padding: EdgeInsets.all(5.w),
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 7),
                            child: Icon(
                              MyFlutterApp.mdi_at,
                              color: controller.showMentionBox
                                  ? Theme.of(Get.context!).primaryColor
                                  : Colors.grey,
                              size: 20.w,
                            ),
                          ),
                        ))
                    : Container(),
                InkWell(
                    onTap: () {
                      _handleAtachmentPressed();
                    },
                    child: Padding(
                      padding: EdgeInsets.all(5.w),
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 7),
                        child: Icon(
                          Icons.attach_file_outlined,
                          color: Colors.grey,
                          size: 20.w,
                        ),
                      ),
                    )),
                SizedBox(
                  width: 5.w,
                ),
                Expanded(
                    child: Focus(
                  onFocusChange: (hasFocus) {
                    print('hasFocus $hasFocus');
                    controller.hasFocus = hasFocus;
                  },
                  child: TextField(
                    minLines: 1,
                    maxLines: 5,
                    controller: controller.textEditingControllerInput,
                    onChanged: (value) {
                      controller.text = value;
                    },
                    style: TextStyle(fontSize: 14.w),
                    decoration: InputDecoration(
                      isDense: true,
                      fillColor: Colors.white,
                      filled: true,
                      contentPadding: EdgeInsets.fromLTRB(15, 10.w, 10.w, 15),
                      hintText: "type message...",
                      hintStyle:
                          TextStyle(color: Color(0xffB5B5B5), fontSize: 12.w),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: new BorderRadius.circular(20.w),
                        borderSide:
                            BorderSide(color: Colors.grey.withOpacity(0.2)),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(20.w),
                        ),
                      ),
                    ),
                  ),
                )),
                Obx(() => controller.text == ''
                    ? SizedBox(
                        width: 10.w,
                      )
                    : Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 10.w, vertical: 7),
                        child: IconButton(
                            padding: EdgeInsets.all(4.w),
                            constraints: BoxConstraints(maxHeight: 40.w),
                            onPressed: () {
                              String text =
                                  controller.textEditingControllerInput.text;
                              _handleSendPressed(types.PartialText(text: text));
                              controller.textEditingControllerInput.text = '';
                              controller.text = '';
                            },
                            icon: Icon(Icons.send,
                                color: Theme.of(Get.context!).primaryColor)),
                      ))
              ],
            ),
          ],
        ),
      );
}
