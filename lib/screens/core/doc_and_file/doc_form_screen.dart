import 'dart:io';

import 'package:cicle_mobile_f3/controllers/doc_form_controller.dart';

import 'package:cicle_mobile_f3/models/member_model.dart';
import 'package:cicle_mobile_f3/screens/core/blast/blast_form_screen.dart';
import 'package:cicle_mobile_f3/utils/helpers.dart';
import 'package:cicle_mobile_f3/utils/my_flutter_app_icons.dart';

import 'package:cicle_mobile_f3/widgets/bottom_sheet_add_subscriber.dart';
import 'package:cicle_mobile_f3/widgets/horizontal_list_member.dart';
import 'package:cicle_mobile_f3/widgets/setup_private.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:html_editor_enhanced/html_editor.dart';

class DocFormScreen extends StatelessWidget {
  DocFormScreen({Key? key}) : super(key: key);
  String? type = Get.parameters['type'];

  DocFormController _DocFormController = Get.put(DocFormController());

  onPressAdd() {
    Get.bottomSheet(
        BottomSheetAddSubscriber(
          listAllProjectMembers: _DocFormController.teamMembers,
          listSelectedMembers: [],
          onDone: (List<MemberModel> listSelected) {
            _DocFormController.setMembers(listSelected);
          },
        ),
        isDismissible: false,
        isScrollControlled: true);
  }

  @override
  Widget build(BuildContext context) {
    String _titleAppBar = type == null ? 'Create Doc' : 'Edit Doc';
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        _DocFormController.htmlController.editorController!.clearFocus();
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          elevation: 2,
          titleSpacing: 0,
          title: Obx(() => _DocFormController.loadingGetData
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
                      onTap: () => _DocFormController.navigateToList(),
                      child: Text(
                        '[Docs & Files] - ${_DocFormController.currentTeam.name}',
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
                    if (_DocFormController.loadingNote) {
                      return Container(
                        height: 400,
                      );
                    }
                    return _buildNote();
                  }),
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
              return _DocFormController.loadingGetData
                  ? Container(
                      color: Theme.of(Get.context!).cardColor.withOpacity(0.5),
                      height: double.infinity,
                      width: double.infinity,
                      child: Center(child: CircularProgressIndicator()),
                    )
                  : SizedBox();
            })
          ],
        ),
      ),
    );
  }

  Widget _buildSetupPrivate() {
    return Container(
      margin: EdgeInsets.only(left: 12),
      child: Obx(() => SetupPrivate(
            title: 'Is the doc for private only?',
            isPrivate: _DocFormController.isPrivate,
            onChange: (bool value) => _DocFormController.isPrivate = value,
          )),
    );
  }

  onPressAt() {
    Get.bottomSheet(ContainerMentionForm(
      members: _DocFormController.teamMembers,
      onSelect: (MemberModel member) {
        var mentionAsHtml =
            '&nbsp<span class=\"fr-deletable fr-tribute\" data-mentioned-user-id="${member.sId}" id=\"mentioned-user\" style=\"padding:1px; background-color:#e8ffff; border-radius:2px; display:inline-flex; align-items:center\"><img style=\"width:12px; height:12px; object-fit: cover; margin-right:3px; border-radius:100%;\" src=\"${getPhotoUrl(url: member.photoUrl)}"><a href=\"/profiles/${member.sId}\">${member.fullName}</a></span>&nbsp';

        _DocFormController.htmlController.insertHtml(mentionAsHtml);
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
          _DocFormController.htmlController.insertHtml(mentionAllUser);
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
      _DocFormController.loadingGetData = true;
      PlatformFile fileAdapter =
          PlatformFile(name: fileName, size: size, path: path);
      uploadFile(fileAdapter, (String url) {
        String htmlVideo = '<a href="$url">$fileName</a>';
        _DocFormController.htmlController.insertHtml(htmlVideo);
        _DocFormController.loadingGetData = false;
      });
    } else {}
  }

  Container _buildNote() {
    return Container(
      height: 398,
      child: HtmlEditor(
        controller: _DocFormController.htmlController,
        htmlEditorOptions: HtmlEditorOptions(
          hint: "Your text here...",
        ),
        otherOptions: OtherOptions(
          height: 400,
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
              _DocFormController.loadingGetData = true;
              uploadImage(file, (String url) {
                print(url);
                String htmlImage =
                    '<img src="$url" style="width: 300px;" class="fr-fic fr-dib">';

                _DocFormController.htmlController.insertHtml(htmlImage);
                _DocFormController.loadingGetData = false;
              });
            } else if (type == InsertFileType.video) {
              _DocFormController.loadingGetData = true;
              uploadVideo(file, (String url) {
                String htmlVideo =
                    '<span class="fr-video fr-dvb fr-draggable fr-active" contenteditable="false" draggable="true"><video class="fr-draggable" controls="" src="$url" style="width:${Get.width - 100}px">Your browser does not support HTML5 video.</video></span>';

                _DocFormController.htmlController.insertHtml(htmlVideo);
                _DocFormController.loadingGetData = false;
              });
            } else if (type == InsertFileType.audio) {
              _DocFormController.loadingGetData = true;
              uploadFile(file, (String url) {
                String htmlVideo = '<a href="$url">${file.name}</a>';

                _DocFormController.htmlController.insertHtml(htmlVideo);
                _DocFormController.loadingGetData = false;
              });
            }

            return false;
          },
          mediaLinkInsertInterceptor: (String url, InsertFileType type) async {
            if (type == InsertFileType.image) {
              String htmlImage =
                  '<img src="$url" style="width: 300px;" class="fr-fic fr-dib">';

              _DocFormController.htmlController.insertHtml(htmlImage);
            } else if (type == InsertFileType.video) {
              String htmlVideo =
                  '<span class="fr-video fr-dvb fr-draggable fr-active" contenteditable="false" draggable="true"><video class="fr-draggable" controls="" src="$url" style="width:${Get.width - 100}px">Your browser does not support HTML5 video.</video></span>';

              _DocFormController.htmlController.insertHtml(htmlVideo);
            } else if (type == InsertFileType.audio) {
              String htmlVideo = '<a href="$url">$url</a>';

              _DocFormController.htmlController.insertHtml(htmlVideo);
            }
            return false;
          },
          onOtherFileUpload: (PlatformFile file) {
            print('file');
          },
        ),
      ),
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
              _DocFormController.onAdd();
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
              _DocFormController.onEdit();
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

    var subsCounter = _DocFormController.members.isEmpty
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
              _DocFormController.members.length == 0
                  ? subsCounter
                  : subsLabelCounter(_DocFormController.members.length),
              _DocFormController.members.isNotEmpty
                  ? SizedBox(
                      height: 10,
                    )
                  : SizedBox(),
              Row(
                children: [
                  _DocFormController.members.isEmpty
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
                  _DocFormController.members.length == 0
                      ? label
                      : Expanded(
                          child: Container(
                            height: 25.w,
                            child: HorizontalListMember(
                              height: 25.w,
                              marginItem: EdgeInsets.only(left: 4),
                              members: _DocFormController.members,
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
        controller: _DocFormController.titleTextEditingController,
        onChanged: (String text) {
          _DocFormController.title = text;
        },
        maxLines: 3,
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
