import 'dart:async';

import 'package:cicle_mobile_f3/service/doc_file_service.dart';
import 'package:cicle_mobile_f3/utils/helpers.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:get/get.dart';
import 'package:html_editor_enhanced/html_editor.dart';

class FormAddNoteController extends GetxController {
  DocFileService _docFileService = DocFileService();

  late StreamSubscription<bool> keyboardSubscription;
  HtmlEditorController controller = HtmlEditorController();

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    setFullScreen();
    var keyboardVisibilityController = KeyboardVisibilityController();

    keyboardSubscription =
        keyboardVisibilityController.onChange.listen((bool visible) {
      print('Keyboard visibility update. Is visible: $visible');
      controller.setFullScreen();
    });
  }

  setFullScreen() async {
    await Future.delayed(Duration(seconds: 1));
    print('Keyboard visibility update. hmmmm');
    controller.setFullScreen();
  }

  var _isLoading = false.obs;
  bool get isLoading => _isLoading.value;
  set isLoading(bool value) {
    _isLoading.value = value;
  }

  Future<String> uploadImage(PlatformFile file, Function onSuccess) async {
    isLoading = true;
    try {
      dynamic body = {"uri": file.path, "name": file.name};
      final response = await _docFileService.uploadImageEditor(body);
      isLoading = false;
      onSuccess(response.data['link']);
      return Future.value(response.data['link']);
    } catch (e) {
      print(e);
      isLoading = false;
      errorMessageMiddleware(e);
      return Future.value('');
    }
  }

  Future<String> uploadVideo(PlatformFile file, Function onSuccess) async {
    try {
      isLoading = true;
      dynamic body = {"uri": file.path, "name": file.name};
      final response = await _docFileService.uploadVideoEditor(body);
      isLoading = false;
      onSuccess(response.data['link']);
      return Future.value(response.data['link']);
    } catch (e) {
      print(e);
      isLoading = false;
      errorMessageMiddleware(e);
      return Future.value('');
    }
  }

  Future<String> uploadFile(PlatformFile file, Function onSuccess) async {
    try {
      isLoading = true;
      dynamic body = {"uri": file.path, "name": file.name};
      final response = await _docFileService.uploadFileEditor(body);
      isLoading = false;
      onSuccess(response.data['link']);
      return Future.value(response.data['link']);
    } catch (e) {
      print(e);
      isLoading = false;
      errorMessageMiddleware(e);
      return Future.value('');
    }
  }

  @override
  void onClose() {
    // TODO: implement onClose
    super.onClose();
    keyboardSubscription.cancel();
  }
}
