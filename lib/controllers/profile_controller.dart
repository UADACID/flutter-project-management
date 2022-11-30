import 'package:cicle_mobile_f3/models/member_model.dart';
import 'package:cicle_mobile_f3/service/profile_service.dart';
import 'package:cicle_mobile_f3/utils/constant.dart';
import 'package:cicle_mobile_f3/utils/helpers.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_picker/image_picker.dart' as sourceType;

class ProfileController extends GetxController {
  TextEditingController nameInputController = TextEditingController();
  TextEditingController titleInputController = TextEditingController();
  TextEditingController aboutInputController = TextEditingController();

  final box = GetStorage();
  ProfileService _profileService = ProfileService();

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    setInitialValue();
  }

  void setInitialValue([self = false]) async {
    String? paramId = Get.parameters['id'];
    String? paramName = Get.parameters['name'] ?? '';

    if (paramId != null && self == false) {
      getData(paramId);
      nameInputController.text = paramName;
      titleInputController.text = 'Software Engineersssss';
      aboutInputController.text = 'loremipsum dolorsitssssss';
    } else {
      final userString = box.read(KeyStorage.logedInUser);

      MemberModel logedInUser = MemberModel.fromJson(userString);
      _logedInUserId.value = logedInUser.sId;
      getData(logedInUser.sId);
      nameInputController.text = logedInUser.fullName;
      _name.value = logedInUser.fullName;
      titleInputController.text = logedInUser.status;
      _title.value = logedInUser.status;
      aboutInputController.text = logedInUser.bio;
      _about.value = logedInUser.bio;
      _photoUrl.value = logedInUser.photoUrl;
    }
  }

  var _errorMessage = ''.obs;
  String get errorMessage => _errorMessage.value;
  set errorMessage(String value) {
    _errorMessage.value = value;
  }

  var _logedInUserId = ''.obs;
  String get logedInUserId => _logedInUserId.value;

  var _isLoading = false.obs;
  bool get isLoading => _isLoading.value;

  var _isEdit = false.obs;

  bool get isEdit => _isEdit.value;
  set isEdit(bool value) {
    _isEdit.value = value;
    if (value == true) {
      setInitialValue();
    }
  }

  var _photoUrl = ''.obs;

  String get photoUrl => _photoUrl.value;
  set photoUrl(String value) {
    _photoUrl.value = value;
  }

  // NAME
  var _name = ''.obs;

  String get name => _name.value;
  set name(String value) {
    _name.value = value;
  }

  // TITLE
  var _title = ''.obs;

  String get title => _title.value;
  set title(String value) {
    _title.value = value;
  }

  // ABOUT
  var _about = ''.obs;

  String get about => _about.value;
  set about(String value) {
    _about.value = value;
  }

  var _canEdit = false.obs;
  bool get canEdit => _canEdit.value;

  Future<void> getData(String userId) async {
    try {
      _isLoading.value = true;
      final result = await _profileService.getUser(userId);

      final userString = box.read(KeyStorage.logedInUser);

      MemberModel logedInUser = MemberModel.fromJson(userString);
      if (userId == logedInUser.sId) {
        box.write(KeyStorage.logedInUser, result.data['user']);
        _canEdit.value = true;
      } else {
        _canEdit.value = false;
      }

      MemberModel userResult = MemberModel.fromJson(result.data['user']);
      _name.value = userResult.fullName;
      _title.value = userResult.status;
      _about.value = userResult.bio;
      _photoUrl.value = userResult.photoUrl;
      _isLoading.value = false;
      return Future.value(true);
    } catch (e) {
      // print(e);
      _isLoading.value = false;
      errorMessage =
          errorMessageMiddleware(e, false, 'Failed to get user profile,');
      return Future.value(false);
    }
  }

  Future<void> updateProfile() async {
    String previousName = _name.value;
    String previousTitle = _title.value;
    String previousAbout = _about.value;
    try {
      _isLoading.value = true;
      final userString = box.read(KeyStorage.logedInUser);
      MemberModel logedInUser = MemberModel.fromJson(userString);
      dynamic body = {
        "status": titleInputController.text,
        "fullName": nameInputController.text,
        "bio": aboutInputController.text
      };
      _name.value = nameInputController.text;
      _title.value = titleInputController.text;
      _about.value = aboutInputController.text;
      final result = await _profileService.updateUser(logedInUser.sId, body);
      MemberModel userResult = MemberModel.fromJson(result.data['user']);
      box.write(KeyStorage.logedInUser, result.data['user']);
      _name.value = userResult.fullName;
      _title.value = userResult.status;
      _about.value = userResult.bio;
      _photoUrl.value = userResult.photoUrl;
      _isLoading.value = false;
    } catch (e) {
      _isLoading.value = false;
      _isEdit.value = !_isEdit.value;
      _name.value = previousName;
      _title.value = previousTitle;
      _about.value = previousAbout;
      errorMessageMiddleware(e, false, 'Failed to update profile,');
    }
  }

  openImagePicker() async {
    final result = await ImagePicker().pickImage(
      source: sourceType.ImageSource.gallery,
      imageQuality: 70,
      maxWidth: 1440,
    );

    String previousPhotoUrl = _photoUrl.value;

    if (result != null) {
      try {
        final name = result.path.split('/').last;
        _photoUrl.value = result.path;
        _isEdit.value = false;
        await Future.delayed(Duration(seconds: 3));
        final userString = box.read(KeyStorage.logedInUser);
        MemberModel logedInUser = MemberModel.fromJson(userString);
        dynamic body = {
          "name": name,
          "type": result.mimeType,
          "uri": result.path
        };
        final uploadResult =
            await _profileService.uploadAvatar(logedInUser.sId, body);
        MemberModel userResult =
            MemberModel.fromJson(uploadResult.data['user']);
        box.write(KeyStorage.logedInUser, uploadResult.data['user']);
        _name.value = userResult.fullName;
        _title.value = userResult.status;
        _about.value = userResult.bio;
        _photoUrl.value = userResult.photoUrl;

        showAlert(message: 'Successfully changing avatar');
      } catch (e) {
        // print(e);
        _photoUrl.value = previousPhotoUrl;
        errorMessageMiddleware(e, false, 'Failed to upload avatar,');
      }
    } else {
      // User canceled the picker
    }
  }
}
