import 'package:cicle_mobile_f3/models/member_model.dart';
import 'package:cicle_mobile_f3/utils/constant.dart';
import 'package:cicle_mobile_f3/utils/socket/socket_notification_counter.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class NotificationCounterController extends GetxController {
  final box = GetStorage();
  SocketNotificationCounter _socketNotificationCounter =
      SocketNotificationCounter();

  var _counterUnreadNonChat = 0.obs;
  int get counterUnreadNonChat => _counterUnreadNonChat.value;
  set counterUnreadNonChat(int value) {
    _counterUnreadNonChat.value = value;
  }

  var _counterUnreadChat = 0.obs;
  int get counterUnreadChat => _counterUnreadChat.value;
  set counterUnreadChat(int value) {
    _counterUnreadChat.value = value;
  }

  var _deviceId = "".obs;
  String get deviceId => _deviceId.value;
  set deviceId(String value) {
    _deviceId.value = value;
  }

  var _activeCompanyId = "".obs;
  String get activeCompanyId => _activeCompanyId.value;
  set activeCompanyId(String value) {
    _activeCompanyId.value = value;
  }

  var _logedInUserId = ''.obs;
  String get logedInUserId => _logedInUserId.value;
  set logedInUserId(String value) {
    _logedInUserId.value = value;
  }

  onSocketPostNew(data) {
    try {
      counterUnreadNonChat = data['unreadNotification'].runtimeType == int
          ? data['unreadNotification']
          : 0;
      counterUnreadChat =
          data['unreadChat'].runtimeType == int ? data['unreadChat'] : 0;
    } catch (e) {
      print(e);
    }
  }

  changeActiveCompanyById(String value) async {
    _socketNotificationCounter.removeListenFromSocket();
    await Future.delayed(Duration(seconds: 1));
    _socketNotificationCounter.init(deviceId, logedInUserId, value);
    _socketNotificationCounter.listener(onSocketPostNew, deviceId);
  }

  init() {
    final userString = box.read(KeyStorage.logedInUser);
    MemberModel _templogedInUser = MemberModel.fromJson(userString);
    logedInUserId = _templogedInUser.sId;
    deviceId = box.read(KeyStorage.deviceId);
    activeCompanyId = box.read(KeyStorage.selectedCompanyId);
    _socketNotificationCounter.init(deviceId, logedInUserId, activeCompanyId);
    _socketNotificationCounter.listener(onSocketPostNew, deviceId);
  }

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    ever(_activeCompanyId, changeActiveCompanyById);
  }
}
