import 'package:get/get.dart';

class TabTopNotificationController extends GetxController {
  var _activeTabType = 1.obs; // 0 = all, 1 = unread
  int get activeTabType => _activeTabType.value;

  setIndex(int value) {
    _activeTabType.value = value;
  }
}
