import 'dart:convert';
import 'dart:io';

import 'package:cicle_mobile_f3/controllers/comment_controller.dart';
import 'package:cicle_mobile_f3/models/member_model.dart';
import 'package:cicle_mobile_f3/service/doc_file_service.dart';
import 'package:cicle_mobile_f3/utils/helpers.dart';
import 'package:cicle_mobile_f3/widgets/avatar_custom.dart';
import 'package:cicle_mobile_f3/widgets/default_alert.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/route_manager.dart';

import 'package:image_picker/image_picker.dart';

import 'dialog_modal_upload_type.dart';

class FroalaEditor extends StatefulWidget {
  FroalaEditor(
      {Key? key,
      required this.initialContent,
      required this.title,
      required this.onSubmit,
      required this.commentController,
      required this.members})
      : super(key: key);

  final String initialContent;
  final String title;
  final Function(String) onSubmit;
  final CommentController commentController;
  final List<MemberModel> members;

  @override
  State<FroalaEditor> createState() => _FroalaEditorState();
}

class _FroalaEditorState extends State<FroalaEditor> {
  static final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();

  double _heightEditor = 200;
  late InAppWebViewController webViewController;
  bool _useHybridComposition = false;
  bool _isLoading = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _initAction();
  }

  _initAction() async {
    if (Platform.isAndroid) {
      // for handle keyboard not show up on android version 12
      AndroidDeviceInfo _androidDeviceInfo = await deviceInfoPlugin.androidInfo;
      int _androidOsVersion =
          int.parse(_androidDeviceInfo.version.release ?? '0');

      if (_androidOsVersion >= 12) {
        setState(() {
          _useHybridComposition = true;
        });
      }
    }
  }

  onPressMention(args) async {
    String? a = await Get.bottomSheet(ContainerMention(
      members: widget.members,
    ));
    print(a);
    return a;
  }

  onPressAdd(args) async {
    String? result = await Get.bottomSheet(BottomSheetAdd(
      setLoading: (bool value) {
        setLoading(value);
      },
    ));
    if (result != null) {
      return result;
    }
  }

  setLoading(bool value) {
    setState(() {
      _isLoading = value;
    });
  }

  Future<bool> _onWillPop() async {
    if (widget.title == "Add") {
      var html = await webViewController.evaluateJavascript(
          source: "window.editor.el.innerHTML");
      widget.commentController.tempContentAddComment = html;
      Future.delayed(Duration(milliseconds: 600), () {
        widget.commentController.tempContentAddCommentScrollController
            .animateTo(12,
                duration: Duration(milliseconds: 500), curve: Curves.ease);
      });
    }

    return Future.value(true);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Stack(
        children: [
          Scaffold(
            backgroundColor: Colors.transparent,
            body: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(16.0),
                        topRight: Radius.circular(16.0),
                      ),
                    ),
                    padding: EdgeInsets.only(left: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${widget.title} comment',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        InkWell(
                            onTap: () async {
                              if (widget.title == "Add") {
                                var html =
                                    await webViewController.evaluateJavascript(
                                        source: "window.editor.el.innerHTML");
                                widget.commentController.tempContentAddComment =
                                    html;
                                Future.delayed(Duration(milliseconds: 600), () {
                                  widget.commentController
                                      .tempContentAddCommentScrollController
                                      .animateTo(12,
                                          duration: Duration(milliseconds: 500),
                                          curve: Curves.ease);
                                });
                              }
                              Get.back();
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 16),
                              child: Icon(Icons.close),
                            ))
                      ],
                    )),
                Container(
                  constraints: BoxConstraints(maxHeight: 350),
                  color: Colors.white,
                  height: _heightEditor,
                  child: InAppWebView(
                    shouldOverrideUrlLoading:
                        (controller, navigationAction) async {
                      return NavigationActionPolicy.CANCEL;
                    },
                    initialFile: "assets/froala.html",
                    initialOptions: InAppWebViewGroupOptions(
                      android: AndroidInAppWebViewOptions(
                        useHybridComposition: _useHybridComposition,
                      ),
                    ),
                    onWebViewCreated: (controller) async {
                      controller.addJavaScriptHandler(
                          handlerName: 'setInitialValue',
                          callback: (args) {
                            return widget.initialContent;
                          });
                      controller.addJavaScriptHandler(
                          handlerName: 'setMentionedUsers',
                          callback: (args) {
                            List<MemberModel> membersPhotoAdapter =
                                widget.members.map((e) {
                              e.photoUrl = getPhotoUrl(url: e.photoUrl);
                              return e;
                            }).toList();
                            membersPhotoAdapter.sort((a, b) => a.fullName
                                .toLowerCase()
                                .compareTo(b.fullName.toLowerCase()));
                            var stringMembers = jsonEncode(membersPhotoAdapter);

                            return stringMembers;
                          });
                      controller.addJavaScriptHandler(
                          handlerName: 'handlerFooWithArgs',
                          callback: (args) {
                            print(args);
                          });
                      controller.addJavaScriptHandler(
                          handlerName: 'handlerGetScrollHeight',
                          callback: (args) {
                            print('height $args');

                            setState(() {
                              double _height = args[0].toDouble();
                              _heightEditor = _height;
                            });
                          });
                      controller.addJavaScriptHandler(
                          handlerName: 'onPressMention',
                          callback: onPressMention);

                      controller.addJavaScriptHandler(
                          handlerName: 'onPressAdd', callback: onPressAdd);
                    },
                    gestureRecognizers: [
                      Factory(() =>
                          VerticalDragGestureRecognizer()..onUpdate = (_) {}),
                    ].toSet(),
                    onLoadError: (controller, url, code, e) {
                      print("error $e $code");
                    },
                    onConsoleMessage: (controller, consoleMessage) async {
                      print(
                        'WebView Message: $consoleMessage',
                      );
                    },
                    onLoadStop: (controller, uri) async {
                      webViewController = controller;
                    },
                  ),
                ),
                Container(
                  color: Colors.white,
                  padding: EdgeInsets.only(bottom: 10),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                            onPressed: () async {
                              var html =
                                  await webViewController.evaluateJavascript(
                                      source: "window.editor.el.innerHTML");

                              if (html.trim() == '' ||
                                  removeHtmlTag(html).trim() == '') {
                                showAlert(
                                    message: "comments can't be empty",
                                    messageColor: Colors.red);
                                return;
                              }
                              widget.onSubmit(html);
                              Get.back();
                            },
                            child: Text(
                              'submit',
                              style: TextStyle(color: Colors.white),
                            ))),
                  ),
                )
              ],
            ),
          ),
          _isLoading
              ? Container(
                  color: Colors.black.withOpacity(0.5),
                  child: Center(child: CircularProgressIndicator()),
                )
              : SizedBox()
        ],
      ),
    );
  }
}

class ContainerMention extends StatefulWidget {
  const ContainerMention({
    Key? key,
    required this.members,
  }) : super(key: key);
  final List<MemberModel> members;

  @override
  State<ContainerMention> createState() => _ContainerMentionState();
}

class _ContainerMentionState extends State<ContainerMention> {
  _onMentionAll() {
    Get.dialog(DefaultAlert(
        onSubmit: () async {
          String _content = '';
          for (var i = 0; i < widget.members.length; i++) {
            MemberModel value = widget.members[i];
            String html =
                '&nbsp<span class="fr-deletable fr-tribute" data-mentioned-user-id="${value.sId}" id="mentioned-user" style="padding:1px; background-color:#e8ffff; border-radius:2px; display:inline-flex; align-items:center"><img style="width:12px; height:12px; object-fit: cover; margin-right:3px; border-radius:100%;" src="${getPhotoUrl(url: value.photoUrl)}"><a href="/profiles">${value.fullName}</a></span>&nbsp';
            _content += html;
          }
          Get.back();
          await Future.delayed(Duration(milliseconds: 200));
          Get.back(result: _content);
        },
        onCancel: () {
          Get.back();
        },
        title: 'Are you sure to select all user ?'));
  }

  @override
  Widget build(BuildContext context) {
    widget.members.sort((a, b) => a.fullName.compareTo(b.fullName));
    return Container(
      color: Colors.white,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Align(
            alignment: Alignment.topRight,
            child: InkWell(
              onTap: _onMentionAll,
              child: Container(
                color: Colors.white,
                padding: const EdgeInsets.all(8.0),
                child: Text('mention all',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Color(0xffFDC532))),
              ),
            ),
          ),
          Container(
            color: Colors.white,
            constraints: BoxConstraints(maxHeight: 175),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  ...widget.members
                      .asMap()
                      .map((key, value) => MapEntry(
                            key,
                            InkWell(
                              onTap: () {
                                String html =
                                    '&nbsp<span class="fr-deletable fr-tribute" data-mentioned-user-id="${value.sId}" id="mentioned-user" style="padding:1px; background-color:#e8ffff; border-radius:2px; display:inline-flex; align-items:center"><img style="width:12px; height:12px; object-fit: cover; margin-right:3px; border-radius:100%;" src="${getPhotoUrl(url: value.photoUrl)}"><a href="/profiles">${value.fullName}</a></span>&nbsp';
                                Get.back(result: html);
                              },
                              child: SizedBox(
                                height: 40,
                                child: ListTile(
                                  leading: AvatarCustom(
                                      height: 25,
                                      child: Image.network(
                                          getPhotoUrl(url: value.photoUrl),
                                          width: 25,
                                          height: 25,
                                          fit: BoxFit.cover)),
                                  title: Text(
                                    value.fullName,
                                    style: TextStyle(color: Color(0xff708FC7)),
                                  ),
                                ),
                              ),
                            ),
                          ))
                      .values
                      .toList(),
                  SizedBox(
                    height: 10,
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class BottomSheetAdd extends StatefulWidget {
  BottomSheetAdd({
    Key? key,
    required this.setLoading,
  }) : super(key: key);

  final Function setLoading;

  @override
  State<BottomSheetAdd> createState() => _BottomSheetAddState();
}

class _BottomSheetAddState extends State<BottomSheetAdd> {
  final ImagePicker _picker = ImagePicker();
  DocFileService _docFileService = DocFileService();

  var dio = Dio();
  bool _loading = false;

  _uploadImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

      if (image == null) {
        showAlert(message: 'cancel by user');
        return;
      }

      dynamic body = {"uri": image.path, "name": image.name};
      widget.setLoading(true);
      setState(() {
        _loading = true;
      });
      final response = await _docFileService.uploadImageEditor(body);

      String url = response.data["link"];
      String html =
          '''<p><img contenteditable="false" src="$url" style="width: 200px;" class="fr-fic fr-dib"></p>''';
      widget.setLoading(false);
      setState(() {
        _loading = false;
      });
      Get.back(result: html);
    } catch (e) {
      print(e);
      widget.setLoading(false);
      setState(() {
        _loading = false;
      });
      errorMessageMiddleware(e);
    }
  }

  _uploadFile() async {
    try {
      widget.setLoading(true);
      FilePickerResult? result = await FilePicker.platform.pickFiles();

      if (result != null) {
        setState(() {
          _loading = true;
        });

        String fileName = result.files[0].name;

        String? path = result.files[0].path ?? '';

        dynamic body = {"uri": path, "name": fileName};
        final response = await _docFileService.uploadFileEditor(body);

        widget.setLoading(false);
        setState(() {
          _loading = false;
        });
        String html = '<a href="${response.data['link']}">$fileName</a>';

        Get.back(result: html);
      } else {
        setState(() {
          _loading = true;
        });
        widget.setLoading(false);
      }
    } catch (e) {
      widget.setLoading(false);
      setState(() {
        _loading = false;
      });
      errorMessageMiddleware(e);
    }
  }

  _uploadVideo() async {
    try {
      final XFile? image = await _picker.pickVideo(source: ImageSource.gallery);
      print(image);
      if (image == null) {
        showAlert(message: 'cancel by user');
        return;
      }
      dynamic body = {"uri": image.path, "name": image.name};
      widget.setLoading(true);
      setState(() {
        _loading = true;
      });
      final response = await _docFileService.uploadVideoEditor(body);

      String url = response.data["link"];
      String html =
          '''<span  class="fr-video fr-dvb fr-draggable fr-active" contenteditable="false" draggable="true"><video class="fr-draggable" controls="" src="$url" style="width: 200px;">Your browser does not support HTML5 video.</video></span></p>''';
      widget.setLoading(false);
      setState(() {
        _loading = false;
      });
      Get.back(result: html);
    } catch (e) {
      print(e);
      widget.setLoading(false);
      setState(() {
        _loading = false;
      });
      errorMessageMiddleware(e);
    }
  }

  _showDialog(String type) {
    Get.dialog(DialogModalUploadType(
      title: type,
      onTapByUpload: () {
        print('by upload');
        Get.back();
        switch (type) {
          case 'image':
            _uploadImage();
            break;
          case 'file':
            _uploadFile();
            break;
          case 'video':
            _uploadVideo();
            break;
          default:
        }
      },
      onTapByUrl: (String url) async {
        String? url = await showCupertinoModalPopup(
            context: context, builder: (context) => FormInsertLink());

        RegExp exp = new RegExp(
          r'(?:(?:https?|ftp):\/\/)?[\w/\-?=%.]+\.[\w/\-?=%.]+',
        );

        if (!exp.hasMatch(url ?? '')) {
          showAlert(message: 'not valid url', messageColor: Colors.red);
          return;
        }
        print('url $url');
        Get.back();
        await Future.delayed(Duration(milliseconds: 200));

        switch (type) {
          case 'image':
            String html =
                '''<p><img contenteditable="false" src="$url" style="width: 200px;" class="fr-fic fr-dib"></p>''';

            Get.back(result: html);
            break;
          case 'file':
            String html = '<a href="$url">$url</a>';
            Get.back(result: html);
            break;
          case 'video':
            String html =
                '''<span  class="fr-video fr-dvb fr-draggable fr-active" contenteditable="false" draggable="true"><video class="fr-draggable" controls="" src="$url" style="width: 200px;">Your browser does not support HTML5 video.</video></span></p>''';

            Get.back(result: html);
            break;
          default:
        }
      },
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      color: Colors.white,
      child: Stack(
        children: [
          Container(
            // height: 50,
            // color: Colors.red,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                    onPressed: () {
                      _showDialog('image');
                    },
                    icon: Icon(Icons.image_outlined)),
                IconButton(
                    onPressed: () {
                      _showDialog('file');
                    },
                    icon: Icon(
                      Icons.insert_drive_file_outlined,
                    )),
                IconButton(
                    onPressed: () {
                      _showDialog('video');
                    },
                    icon: Icon(
                      Icons.videocam_outlined,
                    )),
                IconButton(
                    onPressed: () {
                      Get.back();
                    },
                    icon: Icon(Icons.close)),

                // InkWell(
                //   onTap: () async {

                //     try {
                //       widget.setLoading(true);
                //       FilePickerResult? result = await FilePicker.platform.pickFiles();

                //       if (result != null) {
                //         setState(() {
                //         _loading = true;
                //         });

                //         String fileName = result.files[0].name;

                //         String? path = result.files[0].path ?? '';

                //         dynamic body = {"uri": path, "name": fileName};
                //         final response = await _docFileService.uploadFileEditor(body);

                //         widget.setLoading(false);
                //         setState(() {
                //         _loading = false;
                //         });
                //         String html = '<a href="${response.data['link']}}">$fileName</a>';

                //         Get.back(result: html);
                //       }
                //     } catch (e) {
                //       widget.setLoading(false);
                //       setState(() {
                //       _loading = false;
                //       });
                //       errorMessageMiddleware(e);
                //     }

                //   },
                //   child: ListTile(
                //     leading: Icon(Icons.upload_file_outlined, color: Color(0xff708FC7),),
                //     title: Text('add file', style: TextStyle(color: Color(0xff708FC7)),),
                //   ),
                // ),
                // InkWell(
                //   onTap: () async {
                //     // Pick a video
                //     try {
                //       final XFile? image =
                //           await _picker.pickVideo(source: ImageSource.gallery);
                //       print(image);
                //       dynamic body = {"uri": image!.path, "name": image.name};
                //       widget.setLoading(true);
                //       setState(() {
                //       _loading = true;
                //       });
                //       final response = await _docFileService.uploadVideoEditor(body);

                //       String url = response.data["link"];
                //       String html =
                //           '''<span  class="fr-video fr-dvb fr-draggable fr-active" contenteditable="false" draggable="true"><video class="fr-draggable" controls="" src="$url" style="width: 200px;">Your browser does not support HTML5 video.</video></span></p>''';
                //       widget.setLoading(false);
                //       setState(() {
                //       _loading = false;
                //       });
                //       Get.back(result: html);
                //     } catch (e) {
                //       print(e);
                //       widget.setLoading(false);
                //       setState(() {
                //       _loading = false;
                //       });
                //       errorMessageMiddleware(e);
                //     }
                //   },
                //   child: ListTile(
                //     leading: Icon(Icons.video_camera_back_outlined, color: Color(0xff708FC7)),
                //     title: Text('add video from gallery', style: TextStyle(color: Color(0xff708FC7))),
                //   ),
                // ),

                // InkWell(
                //   onTap: () async {
                //     // Capture a video
                //     try {
                //       final XFile? image =
                //           await _picker.pickVideo(source: ImageSource.camera);

                //       dynamic body = {"uri": image!.path, "name": image.name};
                //       widget.setLoading(true);
                //       setState(() {
                //       _loading = true;
                //       });
                //       final response = await _docFileService.uploadVideoEditor(body);

                //       String url = response.data["link"];
                //       String html =
                //           '''<span class="fr-video fr-dvb fr-draggable fr-active" contenteditable="false" draggable="true"><video class="fr-draggable" controls="" src="$url" style="width: 200px;">Your browser does not support HTML5 video.</video></span></p>''';
                //       widget.setLoading(false);
                //       setState(() {
                //       _loading = false;
                //       });
                //       Get.back(result: html);
                //     } catch (e) {
                //       print(e);
                //       widget.setLoading(false);
                //       setState(() {
                //       _loading = false;
                //       });
                //       errorMessageMiddleware(e);
                //     }
                //   },
                //   child: ListTile(
                //     leading: Icon(Icons.video_camera_back, color: Color(0xff708FC7)),
                //     title: Text('add video from camera', style: TextStyle(color: Color(0xff708FC7)),),
                //   ),
                // ),

                // InkWell(
                //   onTap: () async {
                //     // Pick an image

                //     try {
                //       final XFile? image =
                //           await _picker.pickImage(source: ImageSource.gallery);

                //       dynamic body = {"uri": image!.path, "name": image.name};
                //       widget.setLoading(true);
                //       setState(() {
                //       _loading = true;
                //       });
                //       final response = await _docFileService.uploadImageEditor(body);

                //       String url = response.data["link"];
                //       String html =
                //           '''<p><img contenteditable="false" src="$url" style="width: 200px;" class="fr-fic fr-dib"></p>''';
                //       widget.setLoading(false);
                //       setState(() {
                //       _loading = false;
                //       });
                //       Get.back(result: html);
                //     } catch (e) {
                //       print(e);
                //       widget.setLoading(false);
                //       setState(() {
                //       _loading = false;
                //       });
                //       errorMessageMiddleware(e);
                //     }
                //   },
                //   child: ListTile(
                //     leading: Icon(Icons.image_outlined, color: Color(0xff708FC7),),
                //     title: Text('add image from gallery', style: TextStyle(color: Color(0xff708FC7)),),
                //   ),
                // ),

                // InkWell(
                //   onTap: () async {
                //     try {
                //       final XFile? image =
                //           await _picker.pickImage(source: ImageSource.camera);

                //       dynamic body = {"uri": image!.path, "name": image.name};
                //       widget.setLoading(true);
                //       setState(() {
                //       _loading = true;
                //       });
                //       final response = await _docFileService.uploadImageEditor(body);

                //       String url = response.data["link"];
                //       String html =
                //           '''<p><img contenteditable="false" src="$url" style="width: 200px;" class="fr-fic fr-dib"></p>''';
                //       widget.setLoading(false);
                //       setState(() {
                //       _loading = false;
                //       });
                //       Get.back(result: html);
                //     } catch (e) {
                //       print(e);
                //       widget.setLoading(false);
                //       setState(() {
                //       _loading = false;
                //       });
                //       errorMessageMiddleware(e);
                //     }
                //   },
                //   child: ListTile(
                //     leading: Icon(Icons.camera_alt_outlined, color: Color(0xff708FC7),),
                //     title: Text('add image from camera', style: TextStyle(color: Color(0xff708FC7)),),
                //   ),
                // )
              ],
            ),
          ),
          _loading
              ? Container(
                  height: 300,
                  width: double.infinity,
                  color: Colors.black.withOpacity(0.5))
              : SizedBox()
        ],
      ),
    );
  }
}
