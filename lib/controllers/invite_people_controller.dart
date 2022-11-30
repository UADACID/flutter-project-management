import 'package:cicle_mobile_f3/controllers/company_controller.dart';
import 'package:cicle_mobile_f3/utils/helpers.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class InvitePeopleController extends GetxController {
  TextEditingController emailEditingController = TextEditingController();
  CompanyController _companyController = Get.find();

  var _errorMessage = ''.obs;

  String get errorMessage => _errorMessage.value;

  sendInvitation() async {
    _errorMessage.value = '';
    await Future.delayed(Duration(milliseconds: 300));

    String _email = emailEditingController.text;
    if (validateEmail(_email)) {
      Get.back();
      _companyController.inviteMember(emailEditingController.text);
    } else {
      _errorMessage.value = 'email is not valid';
    }
  }
}
