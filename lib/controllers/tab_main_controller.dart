import 'package:cicle_mobile_f3/service/auth_service.dart';

import 'package:cicle_mobile_f3/widgets/companies_list.dart';

import 'package:cicle_mobile_f3/widgets/tab_menu_bottomsheet.dart';

import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:socket_io_client/socket_io_client.dart';

class TabMainController extends GetxController {
  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    initPackageInfo();
    socketClient.connect();
    listenSocket();
  }

  var packageInfo = PackageInfo(
    appName: 'Unknown',
    packageName: 'Unknown',
    version: 'Unknown',
    buildNumber: 'Unknown',
    buildSignature: 'Unknown',
  ).obs;

  initPackageInfo() async {
    try {
      final info = await PackageInfo.fromPlatform();
      packageInfo.value = info;
    } catch (e) {
      print(e);
    }
  }

  var isTabHide = false.obs;

  listenSocket() {
    socketClient.onConnectError((data) {
      print('socketClient connect error $data');
    });
    socketClient.onConnect((_) {
      print('socketClient connect');
    });
    socketClient.onDisconnect((_) => print('disconnect'));
  }

  var _selectedIndex = 0.obs;

  int get selectedIndex => _selectedIndex.value;

  set selectedIndex(int index) {
    _selectedIndex.value = index;
  }

  showMenuBottomSheet() {
    String? teamId = Get.parameters['teamId'];
    String companyId = Get.parameters['companyId'] ?? '';
    Get.bottomSheet(
        TabMenuBottomSheet(
          teamId: teamId,
          companyId: companyId,
        ),
        isScrollControlled: true);
  }

  showCompaniesBottomSheet() {
    Get.bottomSheet(CompaniesList(), isScrollControlled: true);
  }
}
