import 'package:cicle_mobile_f3/controllers/team_detail_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class EditTeamController extends GetxController {
  TeamDetailController _teamDetailController = Get.find();
  TextEditingController teamNameEditingController = TextEditingController();
  TextEditingController teamDescriptionEditingController =
      TextEditingController();

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    init();
  }

  init() {
    if (_teamDetailController.teamName != null) {
      String tempName = _teamDetailController.teamName;
      teamNameEditingController.text = tempName;
      _teamName.value = tempName;

      teamDescriptionEditingController.text = _teamDetailController.teamDesc;
      _teamDescription.value = _teamDetailController.teamDesc;
    }
  }

  // team name
  var _teamName = ''.obs;
  String get teamName => _teamName.value;
  set teamName(String value) {
    _teamName.value = value;
  }

  // team descriptions
  var _teamDescription = ''.obs;
  String get teamDescription => _teamDescription.value;
  set teamDescription(String value) {
    _teamDescription.value = value;
  }
}
