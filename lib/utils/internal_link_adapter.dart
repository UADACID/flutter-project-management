// import 'package:cicle_mobile_f3/controllers/company_controller.dart';
// import 'package:cicle_mobile_f3/utils/constant.dart';
// import 'package:cicle_mobile_f3/widgets/default_alert.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../controllers/company_controller.dart';
import '../widgets/default_alert.dart';
import 'constant.dart';

_onSubmitRedirectUrl(String companyId, String url) async {
  Get.back();
  await Future.delayed(Duration(milliseconds: 150));
  CompanyController _companyController = Get.put(CompanyController());

  _companyController.setCompanyIdFromPushNotif(companyId, onSuccess: () {
    internalLinkAdapterV2(url);
  });
}

internalLinkAdapter(String url) {
  print('got url adapter $url');

  List<String> splitUrl = url.split("/");

  if (splitUrl[1] == 'companies') {
    print('got masuk url v2');
    final box = GetStorage();
    String selectedCompanyId = box.read(KeyStorage.selectedCompanyId) ?? '';
    String companyIdFromUrl = splitUrl.length >= 2 ? splitUrl[2] : '';
    if (selectedCompanyId == companyIdFromUrl) {
      internalLinkAdapterV2(url);
    } else {
      Get.dialog(DefaultAlert(
          onSubmit: () => _onSubmitRedirectUrl(companyIdFromUrl, url),
          onCancel: () => Get.back(),
          title:
              'the redirected url is a different company, are you sure you want to navigate to it?'));
    }

    return;
  }

  print('got url lama');

  String _teamId = Get.parameters['teamId'] ?? '';
  String _companyId = Get.parameters['companyId'] ?? '';
  switch (splitUrl[1]) {
    case "group-chats":
      String _moduleId = splitUrl[2];
      Get.toNamed(RouteName.groupChatScreen(_companyId, _teamId, _moduleId));
      break;
    case "teams":
      String _moduleId = splitUrl[2];
      Get.toNamed('${RouteName.teamDetailScreen(_companyId)}/$_moduleId');
      break;

    case "cards":
      String _moduleId = splitUrl[2];
      if (splitUrl.length > 4 && splitUrl[3] == 'comments') {
        Get.toNamed(RouteName.commentDetailScreen(
            _companyId, _teamId, splitUrl[1], _moduleId, splitUrl[4]));
      } else {
        Get.toNamed(
            RouteName.boardDetailScreen(_companyId, _teamId, _moduleId));
      }

      break;
    case "posts":
      String _moduleId = splitUrl[2];

      if (splitUrl.length > 4 && splitUrl[3] == 'comments') {
        Get.toNamed(RouteName.commentDetailScreen(
            _companyId, _teamId, splitUrl[1], _moduleId, splitUrl[4]));
      } else {
        Get.toNamed(
            RouteName.blastDetailScreen(_companyId, _teamId, _moduleId));
      }

      break;
    case "questions":
      String _moduleId = splitUrl[2];
      if (splitUrl.length > 4 && splitUrl[3] == 'comments') {
        Get.toNamed(RouteName.commentDetailScreen(
            _companyId, _teamId, splitUrl[1], _moduleId, splitUrl[4]));
      } else {
        Get.toNamed(
            RouteName.checkInDetailScreen(_companyId, _teamId, _moduleId));
      }

      break;

    case "docs":
      String _moduleId = splitUrl[2];
      if (splitUrl.length > 4 && splitUrl[3] == 'comments') {
        Get.toNamed(RouteName.commentDetailScreen(
            _companyId, _teamId, splitUrl[1], _moduleId, splitUrl[4]));
      } else {
        Get.toNamed(RouteName.docDetailScreen(_companyId, _teamId, _moduleId));
      }

      break;

    case "files":
      String _moduleId = splitUrl[2];
      if (splitUrl.length > 4 && splitUrl[3] == 'comments') {
        Get.toNamed(RouteName.commentDetailScreen(
            _companyId, _teamId, splitUrl[1], _moduleId, splitUrl[4]));
      } else {
        Get.toNamed(RouteName.fileDetailScreen(_companyId, _teamId, _moduleId));
      }

      break;

    case "events":
      String _moduleId = splitUrl[2];
      if (splitUrl.length > 6 &&
          splitUrl[3] == 'occurrences' &&
          splitUrl[5] == 'comments') {
        // occurrence comment detail
        String _commentId = splitUrl[6].split('?')[0];
        Get.toNamed(
            '${RouteName.commentDetailScreen(_companyId, _teamId, 'occurrence', _moduleId, _commentId)}?occurrenceId=${splitUrl[4]}');
      } else if (splitUrl.length > 4 && splitUrl[3] == 'occurrences') {
        // occurrence detail
        Get.toNamed(RouteName.occurenceDetailScreen(
            _companyId, _teamId, _moduleId, splitUrl[4]));
      } else if (splitUrl.length > 4 && splitUrl[3] == 'comments') {
        // event comment detail
        Get.toNamed(RouteName.commentDetailScreen(
            _companyId, _teamId, splitUrl[1], _moduleId, splitUrl[4]));
      } else {
        // event detail
        Get.toNamed(
            RouteName.scheduleDetailScreen(_companyId, _teamId, _moduleId));
      }
      break;
    default:
      return;
  }
}

internalLinkAdapterV2(String url) async {
  print('got v2 url $url');
  List<String> splitUrl = url.split('/');
  print(splitUrl);
  String _moduleName = splitUrl.length > 5 ? splitUrl[5] : splitUrl[3];
  String _companyId = splitUrl.length > 2 ? splitUrl[2] : '';
  String _teamId = splitUrl.length > 4 ? splitUrl[4] : '';
  print('got module name $_moduleName');
  String path = '';
  switch (_moduleName) {
    case "teams":
      print('got masuk team');
      Get.reset();
      await Future.delayed(Duration(milliseconds: 300));
      Get.offAllNamed(RouteName.dashboardScreen(_companyId));
      await Future.delayed(Duration(milliseconds: 300));
      Get.toNamed('${RouteName.teamDetailScreen(_companyId)}/$_teamId');
      break;
    case "group-chats":
      String _moduleId = splitUrl.length > 6 ? splitUrl[6] : '';
      Get.toNamed(RouteName.groupChatScreen(_companyId, _teamId, _moduleId));
      break;

    case 'blasts':
      path =
          '${RouteName.teamDetailScreen(_companyId)}/$_teamId?destinationIndex=1';
      Get.reset();
      await Future.delayed(Duration(milliseconds: 300));
      Get.offAllNamed(RouteName.dashboardScreen(_companyId));
      await Future.delayed(Duration(milliseconds: 300));
      Get.toNamed(path);
      break;

    case 'schedules':
      path =
          '${RouteName.teamDetailScreen(_companyId)}/$_teamId?destinationIndex=5';
      Get.reset();
      await Future.delayed(Duration(milliseconds: 300));
      Get.offAllNamed(RouteName.dashboardScreen(_companyId));
      await Future.delayed(Duration(milliseconds: 300));
      Get.toNamed(path);
      break;

    case 'boards':
      path =
          '${RouteName.teamDetailScreen(_companyId)}/$_teamId?destinationIndex=2';
      Get.reset();
      await Future.delayed(Duration(milliseconds: 300));
      Get.offAllNamed(RouteName.dashboardScreen(_companyId));
      await Future.delayed(Duration(milliseconds: 300));
      Get.toNamed(path);
      break;

    case 'check-ins':
      path =
          '${RouteName.teamDetailScreen(_companyId)}/$_teamId?destinationIndex=6';
      Get.reset();
      await Future.delayed(Duration(milliseconds: 300));
      Get.offAllNamed(RouteName.dashboardScreen(_companyId));
      await Future.delayed(Duration(milliseconds: 300));
      Get.toNamed(path);
      break;

    case 'buckets':
      path =
          '${RouteName.teamDetailScreen(_companyId)}/$_teamId?destinationIndex=3';
      Get.reset();
      await Future.delayed(Duration(milliseconds: 300));
      Get.offAllNamed(RouteName.dashboardScreen(_companyId));
      await Future.delayed(Duration(milliseconds: 300));
      Get.toNamed(path);
      break;

    case "cards":
      String _moduleId = splitUrl.length > 6 ? splitUrl[6] : '';
      if (splitUrl.length > 8 && splitUrl[7] == 'comments') {
        String _commentId = splitUrl[8];
        Get.toNamed(RouteName.commentDetailScreen(
            _companyId, _teamId, _moduleName, _moduleId, _commentId));
      } else {
        Get.toNamed(
            RouteName.boardDetailScreen(_companyId, _teamId, _moduleId));
      }
      break;
    case "posts":
      String _moduleId = splitUrl.length > 6 ? splitUrl[6] : '';
      if (splitUrl.length > 8 && splitUrl[7] == 'comments') {
        String _commentId = splitUrl[8];
        Get.toNamed(RouteName.commentDetailScreen(
            _companyId, _teamId, _moduleName, _moduleId, _commentId));
      } else {
        Get.toNamed(
            RouteName.blastDetailScreen(_companyId, _teamId, _moduleId));
      }
      break;
    case "questions":
      String _moduleId = splitUrl.length > 6 ? splitUrl[6] : '';
      if (splitUrl.length > 8 && splitUrl[7] == 'comments') {
        String _commentId = splitUrl[8];
        Get.toNamed(RouteName.commentDetailScreen(
            _companyId, _teamId, _moduleName, _moduleId, _commentId));
      } else {
        Get.toNamed(
            RouteName.checkInDetailScreen(_companyId, _teamId, _moduleId));
      }
      break;
    case "docs":
      String _moduleId = splitUrl.length > 6 ? splitUrl[6] : '';
      if (splitUrl.length > 8 && splitUrl[7] == 'comments') {
        String _commentId = splitUrl[8];
        Get.toNamed(RouteName.commentDetailScreen(
            _companyId, _teamId, _moduleName, _moduleId, _commentId));
      } else {
        Get.toNamed(RouteName.docDetailScreen(_companyId, _teamId, _moduleId));
      }

      break;
    case "files":
      String _moduleId = splitUrl.length > 6 ? splitUrl[6] : '';
      if (splitUrl.length > 8 && splitUrl[7] == 'comments') {
        String _commentId = splitUrl[8];
        Get.toNamed(RouteName.commentDetailScreen(
            _companyId, _teamId, _moduleName, _moduleId, _commentId));
      } else {
        Get.toNamed(RouteName.fileDetailScreen(_companyId, _teamId, _moduleId));
      }

      break;

    case "events":
      String _moduleId = splitUrl.length > 6 ? splitUrl[6] : '';
      if (splitUrl.length > 10 &&
          splitUrl[7] == 'occurrences' &&
          splitUrl[9] == 'comments') {
        // occurrence comment detail
        String _occurrenceId = splitUrl[8];
        String _commentId = splitUrl[10].split('?')[0];
        Get.toNamed(
            '${RouteName.commentDetailScreen(_companyId, _teamId, 'occurrence', _moduleId, _commentId)}?occurrenceId=$_occurrenceId');
      } else if (splitUrl.length > 8 && splitUrl[7] == 'occurrences') {
        // occurrence detail
        String _occurrenceId = splitUrl[8];
        Get.toNamed(RouteName.occurenceDetailScreen(
            _companyId, _teamId, _moduleId, _occurrenceId));
      } else if (splitUrl.length > 8 && splitUrl[7] == 'comments') {
        // event comment detail
        String _commentId = splitUrl[8].split('?')[0];
        Get.toNamed(RouteName.commentDetailScreen(
            _companyId, _teamId, _moduleName, _moduleId, _commentId));
      } else {
        // event detail
        Get.toNamed(
            RouteName.scheduleDetailScreen(_companyId, _teamId, _moduleId));
      }
      break;

    case "profiles":
      String _userId = splitUrl[4];
      Get.toNamed(
          '${RouteName.profileScreen(_companyId)}?id=$_userId&&teamId=$_teamId');
      break;

    case "chats":
      String chatId = splitUrl[4];
      Get.toNamed(
          // '${RouteName.c(_companyId)}?id=$_userId&&teamId=$_teamId');
          // '${RouteName.privateChatDetailScreen(_companyId, chatId)}');
          '${RouteName.privateChatDetailScreen(_companyId, chatId)}?teamId=$_teamId');
      break;

    default:
  }
}
