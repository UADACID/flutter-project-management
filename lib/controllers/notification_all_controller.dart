import 'dart:convert';

import 'package:cicle_mobile_f3/models/member_model.dart';
import 'package:cicle_mobile_f3/models/notification_item_model.dart';
import 'package:cicle_mobile_f3/service/notification_service.dart';
import 'package:cicle_mobile_f3/utils/constant.dart';
import 'package:cicle_mobile_f3/utils/helpers.dart';
import 'package:cicle_mobile_f3/utils/socket/socket_notification_all.dart';
import 'package:flutter/foundation.dart';

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class NotificationAllController extends GetxController {
  final box = GetStorage();
  SocketNotificationAll _socketNotificationAll = SocketNotificationAll();

  NotificationService _notificationService = NotificationService();

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

  var _isLoading = false.obs;
  bool get isLoading => _isLoading.value;

  var _canSelect = false.obs;
  bool get canSelect => _canSelect.value;

  set canSelect(bool value) {
    _canSelect.value = value;
  }

  var _limit = 10.obs;
  int get limit => _limit.value;
  set limit(int value) {
    _limit.value = value;
  }

  var _notificationList = <NotificationItemModel>[].obs;
  List<NotificationItemModel> get notificationList => _notificationList;
  set notificationList(List<NotificationItemModel> value) {
    _notificationList.value = value;
  }

  Future<List<NotificationItemModel>> getNotifications() async {
    return Future.value([]);
  }

  Future<void> loadMore() async {
    print('load more');

    int nextLimit = limit + 10;

    limit = nextLimit;
    _socketNotificationAll.localSocket.emit(deviceId, {"limit": nextLimit});
    return Future.value(true);
  }

  Future<void> refresh() async {
    _limit.value = 10;
    _socketNotificationAll.localSocket.emit(deviceId, {"limit": 10});
    return Future.value(true);
  }

  Future<void> updateNotifItemAsRead(String notificationId) async {
    try {
      await _notificationService.updateNotifItemAsRead(notificationId);
      _socketNotificationAll.emitEvent(() =>
          _socketNotificationAll.localSocket.emit(deviceId, {"limit": limit}));
      return Future.value(true);
    } catch (e) {
      print(e);
      errorMessageMiddleware(e);
      return Future.value(false);
    }
  }

  onSocketPostNew(data) {
    try {
      List<NotificationItemModel> tempList = [];
      data.forEach((v) {
        tempList.add(NotificationItemModel.fromJson(v));
      });
      notificationList = [...tempList];
    } catch (e) {
      print(e);
    }
  }

  init() async {
    final userString = box.read(KeyStorage.logedInUser);
    MemberModel _templogedInUser = MemberModel.fromJson(userString);
    logedInUserId = _templogedInUser.sId;
    deviceId = box.read(KeyStorage.deviceId);
    getNotifications();
    _socketNotificationAll.init(deviceId, logedInUserId, activeCompanyId);
    _socketNotificationAll.listener(onSocketPostNew, deviceId);
  }

  changeActiveCompanyById(String value) {
    activeCompanyId = value;
    _socketNotificationAll.init(deviceId, logedInUserId, value);
    _socketNotificationAll.listener(onSocketPostNew, deviceId);
  }

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    ever(_activeCompanyId, changeActiveCompanyById);
  }
}

Future<List<NotificationItemModel>> parseNotificationList(
    String responBody) async {
  final data = await json.decode(responBody);
  final notiflist = data['data'];
  List<NotificationItemModel> result = [];
  notiflist.forEach((v) {
    result.add(NotificationItemModel.fromJson(v));
  });
  return result;
}

Future<List<NotificationItemModel>> fetchWithCompute(String dataJson) async {
  return compute(parseNotificationList, dataJson);
}
