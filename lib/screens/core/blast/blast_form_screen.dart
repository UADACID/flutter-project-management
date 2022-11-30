import 'dart:io';

import 'package:cicle_mobile_f3/controllers/blast_form_controller.dart';

import 'package:cicle_mobile_f3/models/member_model.dart';
import 'package:cicle_mobile_f3/utils/helpers.dart';
import 'package:cicle_mobile_f3/utils/my_flutter_app_icons.dart';
import 'package:cicle_mobile_f3/widgets/avatar_custom.dart';
import 'package:cicle_mobile_f3/widgets/bottom_sheet_add_subscriber.dart';
import 'package:cicle_mobile_f3/widgets/horizontal_list_member.dart';
import 'package:cicle_mobile_f3/widgets/setup_private.dart';
import 'package:date_time_picker/date_time_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:html_editor_enhanced/html_editor.dart';
import 'package:intl/intl.dart';

class BlastFormScreen extends StatelessWidget {
  BlastFormScreen({Key? key}) : super(key: key);
  String? type = Get.parameters['type'];

  BlastFormController _blastFormController = Get.put(BlastFormController());

  onPressAdd() {
    Get.bottomSheet(
        BottomSheetAddSubscriber(
          listAllProjectMembers: _blastFormController.teamMembers,
          listSelectedMembers: _blastFormController.members,
          onDone: (List<MemberModel> listSelected) {
            _blastFormController.members = listSelected;
          },
        ),
        isDismissible: false,
        isScrollControlled: true);
  }

  @override
  Widget build(BuildContext context) {
    String _titleAppBar = type == null ? 'Create Post' : 'Edit Post';
    return WillPopScope(
      onWillPop: () async {
        _blastFormController.loadingNote = true;
        await Future.delayed(Duration(milliseconds: 300));
        return Future.value(true);
      },
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
          _blastFormController.htmlController.editorController!.clearFocus();
        },
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            elevation: 2,
            titleSpacing: 0,
            title: Obx(() => _blastFormController.loadingGetData
                ? SizedBox()
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _titleAppBar,
                        maxLines: 1,
                        style: TextStyle(fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                      ),
                      InkWell(
                        onTap: () => _blastFormController.navigateToList(),
                        child: Text(
                          '[Blast] - ${_blastFormController.currentTeam.name}',
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
                      height: 24,
                    ),
                    _buildTitle(),
                    SizedBox(
                      height: 20,
                    ),
                    Obx(() {
                      if (_blastFormController.loadingNote) {
                        return Container(
                          height: 400,
                        );
                      }
                      return _buildNote(context);
                    }),
                    _buildDueDate(),
                    Container(
                      height: 1,
                      width: double.infinity,
                      color: Color(0xffF5F5F5),
                    ),
                    _buildMembers(),
                    Container(
                      height: 2,
                      width: double.infinity,
                      color: Color(0xffF5F5F5),
                    ),
                    _buildSetupPrivate(),
                    Container(
                      height: 2,
                      width: double.infinity,
                      color: Color(0xffF5F5F5),
                    ),
                    SizedBox(
                      height: 18,
                    ),
                    type == null
                        ? _buildButtonSubmit(context)
                        : _buildButtonEdit(context)
                  ],
                ),
              ),
              Obx(() {
                return _blastFormController.loadingGetData
                    ? Container(
                        color:
                            Theme.of(Get.context!).cardColor.withOpacity(0.5),
                        height: double.infinity,
                        width: double.infinity,
                        child: Center(child: CircularProgressIndicator()),
                      )
                    : SizedBox();
              })
            ],
          ),
        ),
      ),
    );
  }

  Container _buildDueDate() {
    return Container(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            SizedBox(
              height: 10,
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Text('Due date',
                  style: TextStyle(fontSize: 12, color: Color(0xff979797))),
            ),
            SizedBox(
              height: 4,
            ),
            Stack(
              children: [
                ElevatedButton(
                  onPressed: () {},
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
                          Icons.timelapse_outlined,
                          color: Colors.white,
                        ),
                        Obx(() {
                          String finalDate = DateFormat('dd MMM yyyy hh.mm a')
                              .format(
                                  DateTime.parse(_blastFormController.dueDate));
                          return Padding(
                            padding:
                                const EdgeInsets.only(left: 16.0, right: 16),
                            child: Text(
                              finalDate,
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.normal),
                            ),
                          );
                        })
                      ],
                    ),
                  ),
                ),
                Obx(() => _blastFormController.loadingGetData
                    ? SizedBox()
                    : DateTimePicker(
                        controller:
                            _blastFormController.textEditingControllerDueDate,
                        locale: Locale('en', 'US'),
                        use24HourFormat: false,
                        textAlign: TextAlign.center,
                        type: DateTimePickerType.dateTime,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.only(
                              left: 15, bottom: 17, top: 12, right: 15),
                        ),
                        style: TextStyle(
                            color: Colors.transparent,
                            fontWeight: FontWeight.normal,
                            fontSize: 11),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                        dateLabelText: '',
                        onChanged: (val) {
                          DateTime toDate = DateTime.parse(val);
                          _blastFormController.dueDate = toDate.toString();
                        },
                      ))
              ],
            ),
            SizedBox(
              height: 10,
            ),
          ],
        ));
  }

  Widget _buildSetupPrivate() {
    return Container(
      margin: EdgeInsets.only(left: 12),
      child: Obx(() => SetupPrivate(
            title: 'Is the post for private only?',
            isPrivate: _blastFormController.isPrivate,
            onChange: (bool value) => _blastFormController.isPrivate = value,
          )),
    );
  }

  onPressAt() {
    Get.bottomSheet(ContainerMentionForm(
      members: _blastFormController.teamMembers,
      onSelect: (MemberModel member) {
        var mentionAsHtml =
            '&nbsp<span class=\"fr-deletable fr-tribute\" data-mentioned-user-id="${member.sId}" id=\"mentioned-user\" style=\"padding:1px; background-color:#e8ffff; border-radius:2px; display:inline-flex; align-items:center\"><img style=\"width:12px; height:12px; object-fit: cover; margin-right:3px; border-radius:100%;\" src=\"${getPhotoUrl(url: member.photoUrl)}"><a href=\"/profiles/${member.sId}\">${member.fullName}</a></span>&nbsp';

        _blastFormController.htmlController.insertHtml(mentionAsHtml);
        Get.back();
      },
      onMentionAll: (List<MemberModel> values) {
        if (values.isNotEmpty) {
          var mentionAllUser = '';
          for (var i = 0; i < values.length; i++) {
            MemberModel member = values[i];
            var mentionAsHtml =
                '&nbsp<span class=\"fr-deletable fr-tribute\" data-mentioned-user-id="${member.sId}" id=\"mentioned-user\" style=\"padding:1px; background-color:#e8ffff; border-radius:2px; display:inline-flex; align-items:center\"><img style=\"width:12px; height:12px; object-fit: cover; margin-right:3px; border-radius:100%;\" src=\"${getPhotoUrl(url: member.photoUrl)}"><a href=\"/profiles/${member.sId}\">${member.fullName}</a></span>&nbsp';
            mentionAllUser += mentionAsHtml;
          }
          _blastFormController.htmlController.insertHtml(mentionAllUser);
          Get.back();
        } else {
          Get.back();
        }
      },
    ));
  }

  onPressAttachment() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      File file = File(result.files.single.path!);
      print(file);
      String fileName = result.files[0].name;

      int size = result.files[0].size;
      String? path = result.files[0].path ?? '';
      _blastFormController.loadingGetData = true;
      PlatformFile fileAdapter =
          PlatformFile(name: fileName, size: size, path: path);
      uploadFile(fileAdapter, (String url) {
        String htmlVideo = '<a href="$url">$fileName</a>';
        _blastFormController.htmlController.insertHtml(htmlVideo);
        _blastFormController.loadingGetData = false;
      });
    } else {}
  }

  Container _buildNote(BuildContext context) {
    return Container(
      height: Get.height - 340,
      child: HtmlEditor(
          controller: _blastFormController.htmlController,
          htmlEditorOptions: HtmlEditorOptions(
            hint: "Your text here...",
          ),
          otherOptions: OtherOptions(
            height: Get.height - 340,
          ),
          htmlToolbarOptions: HtmlToolbarOptions(
            defaultToolbarButtons: [
              FontButtons(subscript: false, superscript: false),
              InsertButtons(),
              OtherButtons(),
              FontSettingButtons(fontName: false, fontSizeUnit: false),
              StyleButtons(),
              ColorButtons(),
              ListButtons(),
              ParagraphButtons(),
            ],
            customToolbarButtons: [
              InkWell(onTap: onPressAt, child: Icon(MyFlutterApp.mdi_at)),
              InkWell(
                  onTap: onPressAttachment,
                  child: Icon(Icons.attach_file_outlined)),
            ],
            customToolbarInsertionIndices: [0, 3],
            mediaUploadInterceptor:
                (PlatformFile file, InsertFileType type) async {
              if (type == InsertFileType.image) {
                _blastFormController.loadingGetData = true;
                uploadImage(file, (String url) {
                  print(url);
                  String htmlImage =
                      '<img src="$url" style="width: 300px;" class="fr-fic fr-dib">';

                  _blastFormController.htmlController.insertHtml(htmlImage);
                  _blastFormController.loadingGetData = false;
                });
              } else if (type == InsertFileType.video) {
                _blastFormController.loadingGetData = true;
                uploadVideo(file, (String url) {
                  String htmlVideo =
                      '<span class="fr-video fr-dvb fr-draggable fr-active" contenteditable="false" draggable="true"><video class="fr-draggable" controls="" src="$url" style="width:${Get.width - 100}px">Your browser does not support HTML5 video.</video></span>';

                  _blastFormController.htmlController.insertHtml(htmlVideo);
                  _blastFormController.loadingGetData = false;
                });
              } else if (type == InsertFileType.audio) {
                _blastFormController.loadingGetData = true;
                uploadFile(file, (String url) {
                  String htmlVideo = '<a href="$url">${file.name}</a>';

                  _blastFormController.htmlController.insertHtml(htmlVideo);
                  _blastFormController.loadingGetData = false;
                });
              }

              return false;
            },
            mediaLinkInsertInterceptor:
                (String url, InsertFileType type) async {
              if (type == InsertFileType.image) {
                String htmlImage =
                    '<img src="$url" style="width: 300px;" class="fr-fic fr-dib">';

                _blastFormController.htmlController.insertHtml(htmlImage);
              } else if (type == InsertFileType.video) {
                String htmlVideo =
                    '<span class="fr-video fr-dvb fr-draggable fr-active" contenteditable="false" draggable="true"><video class="fr-draggable" controls="" src="$url" style="width:${Get.width - 100}px">Your browser does not support HTML5 video.</video></span>';

                _blastFormController.htmlController.insertHtml(htmlVideo);
              } else if (type == InsertFileType.audio) {
                String htmlVideo = '<a href="$url">$url</a>';

                _blastFormController.htmlController.insertHtml(htmlVideo);
              }
              return false;
            },
            onOtherFileUpload: (PlatformFile file) {
              print('file');
            },
          ),
          callbacks: Callbacks(onNavigationRequestMobile: (String url) {
            print(url);

            return NavigationActionPolicy.CANCEL;
          }, onFocus: () async {
            FocusScope.of(context).unfocus();
          })),
    );
  }

  Align _buildButtonSubmit(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Padding(
        padding: const EdgeInsets.only(right: 24.0),
        child: ElevatedButton(
            style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(
                    Theme.of(context).primaryColor),
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50.0),
                ))),
            onPressed: () {
              _blastFormController.onAdd();
            },
            child: Text(
              'Publish',
              style: TextStyle(color: Colors.white),
            )),
      ),
    );
  }

  Align _buildButtonEdit(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Padding(
        padding: const EdgeInsets.only(right: 24.0),
        child: ElevatedButton(
            style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(
                    Theme.of(context).primaryColor),
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50.0),
                ))),
            onPressed: () {
              _blastFormController.onEdit();
            },
            child: Text(
              'Publish changes',
              style: TextStyle(color: Colors.white),
            )),
      ),
    );
  }

  Container _buildMembers() {
    var label = InkWell(
      onTap: onPressAdd,
      child: Row(
        children: [
          Icon(
            Icons.person_add_outlined,
            color: Color(0xff979797),
            size: 24,
          ),
          SizedBox(
            width: 7,
          ),
          Text('Who do you wanna be notified?',
              style: TextStyle(fontSize: 12, color: Color(0xff979797)))
        ],
      ),
    );

    var subsCounter = _blastFormController.members.isEmpty
        ? SizedBox()
        : Text(
            '0 subscriber',
            style: TextStyle(fontSize: 12, color: Color(0xff7A7A7A)),
          );

    subsLabelCounter([int subsLength = 0]) => Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            label,
            Text(
              '$subsLength subscriber',
              style: TextStyle(fontSize: 12, color: Color(0xff708FC7)),
            )
          ],
        );
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 21, vertical: 10),
      child: Obx(() => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _blastFormController.members.length == 0
                  ? subsCounter
                  : subsLabelCounter(_blastFormController.members.length),
              _blastFormController.members.isNotEmpty
                  ? SizedBox(
                      height: 10,
                    )
                  : SizedBox(),
              Row(
                children: [
                  _blastFormController.members.isEmpty
                      ? SizedBox()
                      : GestureDetector(
                          onTap: onPressAdd,
                          child: Container(
                              height: 25.w,
                              width: 25.w,
                              decoration: BoxDecoration(
                                  color: Color(0xff708FC7),
                                  shape: BoxShape.circle),
                              child: Center(
                                child: Icon(
                                  Icons.add,
                                  color: Colors.white,
                                ),
                              )),
                        ),
                  _blastFormController.members.length == 0
                      ? label
                      : Expanded(
                          child: Container(
                            height: 25.w,
                            child: HorizontalListMember(
                              height: 25.w,
                              marginItem: EdgeInsets.only(left: 4),
                              members: _blastFormController.members,
                            ),
                          ),
                        )
                ],
              ),
            ],
          )),
    );
  }

  Container _buildTitle() {
    return Container(
      padding: EdgeInsets.only(left: 23, right: 23),
      child: TextField(
        controller: _blastFormController.titleTextEditingController,
        onChanged: (String text) {
          _blastFormController.title = text;
        },
        maxLines: 2,
        minLines: 1,
        style: TextStyle(
            fontSize: 24,
            color: Color(0xff393E46),
            fontWeight: FontWeight.w600),
        decoration: InputDecoration(
            errorText: null,
            enabledBorder: InputBorder.none,
            hintStyle: TextStyle(
                fontSize: 24,
                color: Color(0xffB5B5B5),
                fontWeight: FontWeight.w600),
            hintText: 'Type a title'),
      ),
    );
  }
}

class ContainerMentionForm extends StatelessWidget {
  const ContainerMentionForm({
    Key? key,
    required this.members,
    required this.onSelect,
    required this.onMentionAll,
  }) : super(key: key);

  final List<MemberModel> members;
  final Function(MemberModel) onSelect;
  final Function(List<MemberModel>) onMentionAll;

  _onMentionAll() {
    onMentionAll(members);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: Alignment.topRight,
              child: InkWell(
                onTap: _onMentionAll,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'mention all',
                    style: TextStyle(color: Color(0xffFDC532)),
                  ),
                ),
              ),
            ),
            Flexible(
              child: Container(
                color: Colors.white,
                constraints: BoxConstraints(maxHeight: 200),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: members
                        .asMap()
                        .map((key, value) => MapEntry(
                            key,
                            InkWell(
                                onTap: () => onSelect(value),
                                child: _renderItem(value))))
                        .values
                        .toList(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Column _renderItem(MemberModel member) {
    String name = member.fullName;
    String photo = member.photoUrl;
    return Column(
      children: [
        Container(
          margin: EdgeInsets.only(bottom: 1),
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              AvatarCustom(
                  height: 24,
                  child: Image.network(
                    getPhotoUrl(url: photo),
                    height: 24,
                    width: 24,
                    fit: BoxFit.cover,
                  )),
              SizedBox(
                width: 10,
              ),
              Text(name)
            ],
          ),
        ),
        SizedBox(height: 1, child: Divider())
      ],
    );
  }
}
