import 'package:cicle_mobile_f3/utils/constant.dart';
// import 'package:cicle_mobile_f3/utils/helpers.dart';
// import 'package:cicle_mobile_f3/utils/internal_link_adapter.dart';
// import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
// import 'package:uni_links/uni_links.dart';

class SplashController extends GetxController {
  final box = GetStorage();

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    redirect();
  }

  redirect() async {
    await Future.delayed(Duration(milliseconds: 2000));
    Get.offNamed('/splash-end');
    await Future.delayed(Duration(milliseconds: 1500));
    var token = box.read('token');

    if (token == null) {
      var _showIntro = box.read('show_intro');

      if (_showIntro == null) {
        box.write('show_intro', true);
        return Get.offNamed(RouteName.introScreen);
      } else if (_showIntro) {
        return Get.offNamed(RouteName.introScreen);
      } else {
        return Get.offNamed(RouteName.signInScreen);
      }
    } else {
      String companyId = box.read(KeyStorage.selectedCompanyId);
      Get.offNamed(RouteName.dashboardScreen(companyId));
    }
  }
}
