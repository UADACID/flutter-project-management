import 'package:cicle_mobile_f3/controllers/company_controller.dart';
import 'package:cicle_mobile_f3/service/company_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../utils/helpers.dart';

class InvitationConteroller extends GetxController {
  CompanyService _companyService = CompanyService();
  CompanyController _companyController = Get.put(CompanyController());

  String invitationToken = Get.parameters['invitationToken'] ?? '';

  final _isLoading = true.obs;
  bool get isLoading => _isLoading.value;
  set isLoading(bool value) {
    _isLoading.value = value;
  }

  final _message = ''.obs;
  String get message => _message.value;
  set message(String value) {
    _message.value = value;
  }

  _checkInvitation() async {
    await Future.delayed(Duration(seconds: 2));
    try {
      // isLoading = true;
      final response =
          await _companyService.checkInvitationToken(invitationToken);
      // print(response);
      String targetCompanyId = response.data['companyId'] ?? '';
      if (targetCompanyId != '') {
        await _companyController.getCompanies();

        message = response.data?['message'] ??
            "We've successfully added you to the company!";
        showAlert(message: message);

        isLoading = false;
        await Future.delayed(Duration(seconds: 6));
        Get.back();
        await Future.delayed(Duration(milliseconds: 600));
        _companyController.setCompanyId(targetCompanyId);

        return;
      }

      _redirect();
    } catch (e) {
      // print(e);
      message =
          errorMessageMiddleware(e, true, 'Failed to check invitation token,');
      // showAlert(message: message, flashDuration: 8, messageColor: Colors.red);
      isLoading = false;
      await Future.delayed(Duration(seconds: 6));
      _redirect();
      // isLoading = false;
    }
  }

  _redirect() async {
    // await Future.delayed(Duration(seconds: 4));
    Get.back();
  }

  @override
  void onInit() {
    // TODO: implement onInit
    _checkInvitation();
    super.onInit();
  }
}
