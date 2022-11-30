import 'package:cicle_mobile_f3/service/doc_file_service.dart';
import 'package:cicle_mobile_f3/utils/helpers.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FormNewBucketController extends GetxController {
  TextEditingController textEditingController = TextEditingController();
  DocFileService _docFileService = DocFileService();

  var _text = ''.obs;
  String get text => _text.value;
  set text(String value) {
    _text.value = value;
  }

  var _loading = false.obs;
  bool get loading => _loading.value;
  set loading(bool value) {
    _loading.value = value;
  }

  Future<bool> create(String folderId) async {
    if (loading) {
      return Future.value(false);
    }

    if (text.isEmpty) {
      showAlert(message: 'Folder name must be filled');
      return Future.value(false);
    }
    try {
      loading = true;

      String teamId = Get.parameters['teamId'] ?? '';
      dynamic body = {
        "data": {"isPublic": true, "title": text},
        "selector": {"localParentBucketId": folderId, "teamId": teamId}
      };

      final response = await _docFileService.createBucket(body, folderId);
      loading = false;
      showAlert(message: response.data['message']);
      return Future.value(true);
    } catch (e) {
      print(e);
      loading = false;
      errorMessageMiddleware(e);
      return Future.value(true);
    }
  }
}
