import 'package:cicle_mobile_f3/controllers/company_controller.dart';
import 'package:cicle_mobile_f3/models/member_model.dart';
import 'package:cicle_mobile_f3/utils/constant.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class FormCreateChatController extends GetxController {
  final box = GetStorage();
  TextEditingController textEditingControllerSearchKey =
      TextEditingController();

  var _searchKey = ''.obs;
  String get searchKey => _searchKey.value;
  set searchKey(String value) {
    _searchKey.value = value;
  }

  var _companyMembers = <MemberModel>[].obs;

  List<MemberModel> get companyMembers => _companyMembers;

  void init() {
    CompanyController _companyController = Get.find();

    final userString = box.read(KeyStorage.logedInUser);
    MemberModel _templogedInUser = MemberModel.fromJson(userString);
    List<MemberModel> _members = _companyController.companyMembers
        .where((element) => element.sId != _templogedInUser.sId)
        .toList();
    _companyMembers.value = [..._members];
  }

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    init();
  }
}
