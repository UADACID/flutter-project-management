import 'dart:io';

import 'package:cicle_mobile_f3/controllers/download_controller.dart';
import 'package:cicle_mobile_f3/controllers/group_chat_controller.dart';
import 'package:cicle_mobile_f3/controllers/tab_main_controller.dart';
import 'package:cicle_mobile_f3/controllers/team_detail_controller.dart';
import 'package:cicle_mobile_f3/models/member_model.dart';
import 'package:cicle_mobile_f3/screens/core/overview/overview_screen.dart';
import 'package:cicle_mobile_f3/utils/helpers.dart';
import 'package:cicle_mobile_f3/utils/my_flutter_app_icons.dart';
import 'package:cicle_mobile_f3/widgets/animation_fade_and_slide.dart';

import 'package:cicle_mobile_f3/widgets/bottom_sheet_attachment.dart';
import 'package:cicle_mobile_f3/widgets/horizontal_list_avatar_with_more.dart';

import 'package:cicle_mobile_f3/widgets/members_mention_container.dart';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;

import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_picker/image_picker.dart' as sourceType;

import 'package:uuid/uuid.dart';

import '../../team_detail.dart';
import 'message_left.dart';
import 'message_right.dart';

class GroupChatScreen extends StatelessWidget {
  GroupChatScreen({Key? key}) : super(key: key);
  String? teamId = Get.parameters['teamId'];
  TabMainController _tabMainController = Get.find();
  GroupChatController _groupChatController = Get.find();
  DownloadController _downloadController = Get.put(DownloadController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Obx(() => Text(
              '${_groupChatController.projectName}',
              style: TextStyle(fontSize: 16),
            )),
        elevation: 0.0,
        actions: [
          SizedBox(
            width: 10,
          ),
          Get.previousRoute.contains('group-chats') &&
                  Get.currentRoute.contains('group-chats')
              ? SizedBox()
              : Obx(() => _tabMainController.selectedIndex == 1
                  ? SizedBox()
                  : ActionsAppBarTeamDetail(
                      showSetting: false,
                    ))
        ],
      ),
      body: Obx(() {
        if (_groupChatController.isLoading) {
          return Center(child: CircularProgressIndicator());
        }
        return Stack(
          children: [
            BodyGroupChat(
                controller: _groupChatController,
                downloadController: _downloadController),
            Obx(() => _groupChatController.showOverlay
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
                                '${_groupChatController.uploadProgress.ceil()} %',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 11),
                              ),
                            ],
                          ))),
                      Align(
                        alignment: Alignment.topRight,
                        child: IconButton(
                            onPressed: _groupChatController.cancelUploadFile,
                            icon: Icon(Icons.close, color: Colors.white)),
                      )
                    ],
                  )
                : SizedBox())
          ],
        );
      }),
    );
  }
}

class BodyGroupChat extends StatelessWidget {
  BodyGroupChat(
      {Key? key, required this.controller, required this.downloadController})
      : super(key: key);

  final GroupChatController controller;

  final DownloadController downloadController;

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
      print(file);
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

      print(message);

      controller.addAttachment(message);
      Get.back();
    } else {}
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
    } else {}
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
    } else {}
  }

  void _handleMessageTap(types.Message message) async {
    if (message is types.FileMessage) {}
  }

  void _handleSendPressed(types.PartialText message) {
    var content = message.text;
    final mailPattern = r"\b[\w\.-]+@[\w\.-]+\.\w{2,4}\b";
    final regEx = RegExp(mailPattern, multiLine: true);

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
        // print(_stringByIndex);
        var splitLinks = _stringByIndex.split(',');
        final regExpCheckSymbols = RegExp(
            r'[\^$*.\[\]{}()?\-"!@#%&/\,><:;_~`+=' // <-- Notice the escaped symbols
            "'" // <-- ' is added to the expression
            ']');
        if (regExpCheckSymbols
            .hasMatch(_stringByIndex[_stringByIndex.length - 1])) {
          String lastSymbol = _stringByIndex[_stringByIndex.length - 1];
          _stringByIndex =
              _stringByIndex.substring(0, _stringByIndex.length - 1);

          if (regEx.hasMatch(_stringByIndex)) {
            _newContent += '$_stringByIndex $lastSymbol ';
          } else {
            print(splitLinks);
            _newContent += splitLinks[0];
            // '<a href=\"${splitLinks[0]}\" rel=\"noopener noreferrer\" target=\"_blank\">${splitLinks[0]}</a> ';
          }
        } else {
          print(splitLinks);
          _newContent +=
              '<a href=\"${splitLinks[0]}\" rel=\"noopener noreferrer\" target=\"_blank\">${splitLinks[0]}</a> ';
        }
      } else {
        _newContent += '$_stringByIndex ';
      }
    }

    // print(_newContent);

    content = _newContent;

    final obtainedMail =
        regEx.allMatches(content).map((m) => m.group(0)).join(',');

    var mentionedEmails = obtainedMail.split(',');

    List<String> _listMembersId = [];

    for (var i = 0; i < mentionedEmails.length; i += 1) {
      var filterMemberByEmail = controller.teamMembers
          .where((element) => element.email == mentionedEmails[i])
          .toList();
      if (filterMemberByEmail.length > 0) {
        MemberModel member = filterMemberByEmail[0];
        _listMembersId.add(member.sId);
        content = content.replaceFirst(mentionedEmails[i],
            '<span class=\"fr-deletable fr-tribute\" contenteditable=\"false\" data-mentioned-user-id=\"${member.sId}\" id=\"mentioned-user\" style=\"padding:1px; background-color:#e8ffff; border-radius:2px; display:inline-flex; align-items:center\"><img style=\"width:20px; height:20px; object-fit: cover; margin-right:3px; border-radius:100%;\" src=\"${getPhotoUrl(url: member.photoUrl)}\"><a href=\"/profiles/${member.sId}\">${member.fullName}</a></span>');
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
    // print('text $textMessage');
    _addMessage(textMessage);
  }

  Future<bool> _onWillPop() async {
    String previousRoute = Get.previousRoute;
    if (previousRoute.contains('team-detail')) {
      TeamDetailController _teamDetailController =
          Get.put(TeamDetailController());
      _teamDetailController.selectedMenuIndex = 0;
    }
    return Future.value(true);
  }

  onPressAdd() {
    Get.dialog(
        AnimationFadeAndSlide(
            child: DialogAddSubscriber(
              title: controller.projectName,
              listAllMembers: controller.companyMembers,
              listSelectedMembers: controller.teamMembers,
              onCLose: (List<MemberModel> listSelected) {
                print(listSelected);

                controller.addMembers(listSelected);
                Get.back();
              },
            ),
            duration: 50.milliseconds,
            delay: 50.milliseconds),
        barrierDismissible: false,
        name: 'dialog-team-add-subscriber');
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
              Container(
                color: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 13),
                child: Obx(() => HorizontalListAvatarWithMore(
                      numberDisplayed: 11,
                      showButtonAdd: false,
                      heightItem: 25.w,
                      onPressAdd: onPressAdd,
                      members: controller.teamMembers.length == 0
                          ? []
                          : controller.teamMembers,
                    )),
              ),
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
                            // customMessageBuilder: (__, { messageWidth: 200}) {
                            //   return Text('data');
                            // }
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
              offset: Offset(0, 0),
            ),
          ],
        ),
        padding: EdgeInsets.symmetric(horizontal: 0.w, vertical: 2.5.w),
        child: Column(
          children: [
            Obx(() => controller.showMentionBox
                ? ListMemberForMention(
                    list: controller.teamMembers,
                    onSelect: (MemberModel member) {
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
                    onMentionAll: (List<MemberModel> members) {
                      controller.showMentionBox = false;
                      if (members.isNotEmpty) {
                        String _emailsAsString = '';
                        for (var i = 0; i < members.length; i++) {
                          MemberModel member = members[i];
                          String email = member.email;
                          _emailsAsString += ' $email ';
                        }
                        final text = controller.textEditingControllerInput.text;
                        TextSelection selection =
                            controller.textEditingControllerInput.selection;

                        int _selectionStart =
                            selection.start < 0 ? 0 : selection.start;
                        int _selectionEnd =
                            selection.end < 0 ? 0 : selection.start;
                        final newText = text.replaceRange(
                            _selectionStart, _selectionEnd, _emailsAsString);

                        int _selectionBaseOffset =
                            selection.baseOffset < 0 ? 0 : selection.baseOffset;
                        controller.textEditingControllerInput.value =
                            TextEditingValue(
                          text: newText,
                          selection: TextSelection.collapsed(
                              offset: _selectionBaseOffset +
                                  _emailsAsString.length),
                        );

                        controller.text = newText;
                      } else {}
                    },
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

String contentHtml = '''
      <p>hello gaes, can you check kanban card about connection API to Backend ? <span class=\"fr-deletable fr-tribute\" contenteditable=\"false\" data-mentioned-user-id=\"6017a93b8d09e8bdeb6ef612\" id=\"mentioned-user\" style=\"padding:1px; background-color:#e8ffff; border-radius:2px; display:inline-flex; align-items:center\"><img style=\"width:20px; height:20px; object-fit: cover; margin-right:3px; border-radius:100%;\" src=\"https:
      '''
    .replaceAll("'", "\'");
