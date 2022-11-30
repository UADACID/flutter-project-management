import 'dart:io';

import 'package:cicle_mobile_f3/controllers/form_add_note_controller.dart';
import 'package:cicle_mobile_f3/models/member_model.dart';
import 'package:cicle_mobile_f3/screens/core/blast/blast_form_screen.dart';
import 'package:cicle_mobile_f3/utils/helpers.dart';
import 'package:cicle_mobile_f3/utils/my_flutter_app_icons.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:html_editor_enhanced/html_editor.dart';

class FormAddNote extends StatelessWidget {
  FormAddNote({
    Key? key,
    required this.onSubmit,
    required this.initialData,
    this.title = 'Notes',
    this.textSubmit = 'Publish',
    required this.members,
  }) : super(key: key);

  final Function(String?) onSubmit;
  final String initialData;
  final String title;
  final String textSubmit;
  final List<MemberModel> members;

  onPressAt(FormAddNoteController formController) {
    Get.bottomSheet(ContainerMentionForm(
      members: members,
      onSelect: (MemberModel member) {
        var mentionAsHtml =
            '&nbsp<span class=\"fr-deletable fr-tribute\" data-mentioned-user-id="${member.sId}" id=\"mentioned-user\" style=\"padding:1px; background-color:#e8ffff; border-radius:2px; display:inline-flex; align-items:center\"><img style=\"width:12px; height:12px; object-fit: cover; margin-right:3px; border-radius:100%;\" src=\"${getPhotoUrl(url: member.photoUrl)}"><a href=\"/profiles/${member.sId}\">${member.fullName}</a></span>&nbsp';

        formController.controller.insertHtml(mentionAsHtml);
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
          formController.controller.insertHtml(mentionAllUser);
          Get.back();
        } else {
          Get.back();
        }
      },
    ));
  }

  onPressAttachment(FormAddNoteController formController) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles();

      if (result != null) {
        File file = File(result.files.single.path!);
        print(file);
        String fileName = result.files[0].name;
        int size = result.files[0].size;
        String? path = result.files[0].path ?? '';

        PlatformFile fileAdapter =
            PlatformFile(name: fileName, size: size, path: path);
        uploadFile(fileAdapter, (String url) {
          String htmlVideo = '<a href="$url">$fileName</a>';
          formController.controller.insertHtml(htmlVideo);
        });
      } else {
        // User canceled the picker
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: GetX<FormAddNoteController>(
          init: FormAddNoteController(),
          builder: (formController) {
            return Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(5)),
                  margin:
                      EdgeInsets.only(top: 30, left: 16, right: 16, bottom: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12.0, vertical: 19),
                            child: Text(
                              title,
                              style: TextStyle(fontSize: 18),
                            ),
                          ),
                          IconButton(
                              onPressed: () {
                                Get.back();
                              },
                              icon: Icon(Icons.close))
                        ],
                      ),
                      Expanded(
                        child: HtmlEditor(
                          controller: formController.controller, //required
                          htmlEditorOptions: HtmlEditorOptions(
                            hint: "Your text here...",
                            initialText: initialData,
                          ),
                          otherOptions: OtherOptions(),
                          htmlToolbarOptions: HtmlToolbarOptions(
                              defaultToolbarButtons: [
                                FontButtons(),
                                ColorButtons(),
                                ListButtons(),
                                ParagraphButtons(),
                                InsertButtons(),
                                OtherButtons(),
                                StyleButtons(),
                                FontSettingButtons(),
                              ],
                              customToolbarButtons: [
                                //your widgets here
                                InkWell(
                                    onTap: () => onPressAt(formController),
                                    child: Icon(MyFlutterApp.mdi_at)),
                                InkWell(
                                    onTap: () =>
                                        onPressAttachment(formController),
                                    child: Icon(Icons.attach_file_outlined)),
                              ],
                              customToolbarInsertionIndices: [
                                0,
                                3
                              ],
                              mediaUploadInterceptor: (PlatformFile file,
                                  InsertFileType type) async {
                                formController.isLoading = true;

                                if (type == InsertFileType.image) {
                                  formController.uploadImage(file,
                                      (String url) {
                                    String htmlImage =
                                        '<img src="$url" style="width: 300px;" class="fr-fic fr-dib">';

                                    formController.controller
                                        .insertHtml(htmlImage);
                                  });
                                } else if (type == InsertFileType.video) {
                                  formController.uploadVideo(file,
                                      (String url) {
                                    String htmlVideo =
                                        '<span class="fr-video fr-dvb fr-draggable fr-active" contenteditable="false" draggable="true"><video class="fr-draggable" controls="" src="$url" style="width:${Get.width - 100}px">Your browser does not support HTML5 video.</video></span>';

                                    formController.controller
                                        .insertHtml(htmlVideo);
                                  });
                                } else if (type == InsertFileType.audio) {
                                  formController.uploadFile(file, (String url) {
                                    String htmlVideo =
                                        '<a href="$url">${file.name}</a>';

                                    formController.controller
                                        .insertHtml(htmlVideo);
                                  });
                                }

                                return false;
                              },
                              mediaLinkInsertInterceptor:
                                  (String url, InsertFileType type) async {
                                if (type == InsertFileType.image) {
                                  String htmlImage =
                                      '<img src="$url" style="width: 300px;" class="fr-fic fr-dib">';

                                  formController.controller
                                      .insertHtml(htmlImage);
                                } else if (type == InsertFileType.video) {
                                  String htmlVideo =
                                      '<span class="fr-video fr-dvb fr-draggable fr-active" contenteditable="false" draggable="true"><video class="fr-draggable" controls="" src="$url" style="width:${Get.width - 100}px">Your browser does not support HTML5 video.</video></span>';

                                  formController.controller
                                      .insertHtml(htmlVideo);
                                } else if (type == InsertFileType.audio) {
                                  String htmlVideo = '<a href="$url">$url</a>';

                                  formController.controller
                                      .insertHtml(htmlVideo);
                                }
                                return false;
                              },
                              onOtherFileUpload: (PlatformFile file) {
                                print('file');
                              }),
                        ),
                      ),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: Padding(
                          padding: const EdgeInsets.only(
                              right: 17, bottom: 21, top: 18),
                          child: ElevatedButton(
                            style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.all<Color>(
                                        Theme.of(context).primaryColor),
                                shape: MaterialStateProperty.all<
                                        RoundedRectangleBorder>(
                                    RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15.0),
                                ))),
                            onPressed: () async {
                              String text =
                                  await formController.controller.getText();
                              onSubmit(text);
                            },
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Text(
                                textSubmit,
                                style: TextStyle(color: Color(0xffEBF4F8)),
                              ),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                formController.isLoading
                    ? Container(
                        height: double.infinity,
                        width: double.infinity,
                        color: Colors.black.withOpacity(0.25),
                        child: Center(
                          child: CircularProgressIndicator(),
                        ),
                      )
                    : SizedBox()
              ],
            );
          }),
    );
  }
}
