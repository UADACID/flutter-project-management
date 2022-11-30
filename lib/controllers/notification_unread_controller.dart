import 'dart:convert';

import 'package:cicle_mobile_f3/controllers/notification_counter_controller.dart';
import 'package:cicle_mobile_f3/models/member_model.dart';
import 'package:cicle_mobile_f3/models/notification_item_model.dart';
import 'package:cicle_mobile_f3/service/notification_service.dart';
import 'package:cicle_mobile_f3/utils/constant.dart';
import 'package:cicle_mobile_f3/utils/helpers.dart';

import 'package:cicle_mobile_f3/utils/socket/socket_notification_unread.dart';
import 'package:flutter/foundation.dart';

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class NotificationUnreadController extends GetxController {
  final box = GetStorage();
  SocketNotificationUnread _socketNotificationUnread =
      SocketNotificationUnread();

  NotificationService _notificationService = NotificationService();
  NotificationCounterController _notificationCounterController =
      Get.put(NotificationCounterController());

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
  set isLoading(bool value) {
    _isLoading.value = value;
  }

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

  var _selectedNotifItem = <String>[].obs;
  List<String> get selectedNotifItem => _selectedNotifItem;
  set selectedNotifItem(List<String> value) {
    _selectedNotifItem.value = value;
  }

  var _canSelectNotif = false.obs;
  bool get canSelectNotif => _canSelectNotif.value;
  set canSelectNotif(bool value) {
    _canSelectNotif.value = value;
    if (value == false) {
      _selectedNotifItem.clear();
    }
  }

  onPressWhenSelectNotifOn(String notifId) {
    List<String> filterSelectedNotifItemByNotifId =
        selectedNotifItem.where((element) => element == notifId).toList();
    if (filterSelectedNotifItemByNotifId.isEmpty) {
      _selectedNotifItem.add(notifId);
    } else {
      _selectedNotifItem.removeWhere((element) => element == notifId);
    }
  }

  Future<List<NotificationItemModel>> getNotifications() async {
    return Future.value([]);
  }

  Future<void> loadMore() async {
    print('load more');
    int nextLimit = limit + 10;

    limit = nextLimit;
    _socketNotificationUnread.localSocket
        .emit('$deviceId-unread', {"limit": nextLimit, "filter": 'unread'});
    return Future.value(true);
  }

  Future<void> refresh() async {
    print('refresh');
    _limit.value = 10;
    _socketNotificationUnread.localSocket
        .emit('$deviceId-unread', {"limit": 10, "filter": 'unread'});
    return Future.value(true);
  }

  Future<void> updateNotifItemAsRead(String notificationId) async {
    try {
      await _notificationService.updateNotifItemAsRead(notificationId);

      _socketNotificationUnread.localSocket
          .emit('$deviceId-unread', {"limit": limit, "filter": 'unread'});
      _notificationCounterController.init();
      return Future.value(true);
    } catch (e) {
      print(e);
      _socketNotificationUnread.localSocket
          .emit('$deviceId-unread', {"limit": limit, "filter": 'unread'});
      errorMessageMiddleware(e);
      return Future.value(false);
    }
  }

  var isSelectAll = false.obs;
  toogleSelectAll() {
    if (isSelectAll.value == false) {
      isSelectAll.value = true;
      List<String> _tempList = [];
      _notificationList.forEach((element) {
        _tempList.add(element.sId);
      });
      _selectedNotifItem.value = [..._tempList];
    } else {
      isSelectAll.value = false;
      _selectedNotifItem.clear();
    }
  }

  Future<void> markAllSelectionAsRead() async {
    try {
      isLoading = true;
      List<String> selectedNotificationIds = [...selectedNotifItem];
      List<String> notificationIds =
          notificationList.map((e) => e.sId).toList();
      if (notificationIds.isEmpty) {
        return;
      }
      dynamic body = {
        "companyId": activeCompanyId,
        "notificationIds": selectedNotificationIds
      };
      final response = await _notificationService.markAllAsRead(body);
      _notificationCounterController.init();

      isLoading = false;
      _selectedNotifItem.clear();
      canSelectNotif = false;
      _socketNotificationUnread.localSocket
          .emit('$deviceId-unread', {"limit": limit, "filter": 'unread'});
      showAlert(message: response.data['message']);
    } catch (e) {
      isLoading = false;
      _socketNotificationUnread.localSocket
          .emit('$deviceId-unread', {"limit": limit, "filter": 'unread'});
      print(e);
      errorMessageMiddleware(e);
    }
  }

  Future<void> markAllAsRead() async {
    try {
      isLoading = true;
      List<String> selectedNotificationIds = [...selectedNotifItem];
      List<String> notificationIds =
          notificationList.map((e) => e.sId).toList();
      if (notificationIds.isEmpty) {
        return;
      }
      dynamic body = {
        "companyId": activeCompanyId,
        "notificationIds": selectedNotificationIds.isNotEmpty
            ? selectedNotificationIds
            : notificationIds
      };
      await _notificationService.markAllAsRead(body);
      _notificationCounterController.init();

      isLoading = false;

      if (selectedNotificationIds.isNotEmpty) {
        selectedNotificationIds.forEach((element) {
          _selectedNotifItem.remove(element);
        });
      }

      _socketNotificationUnread.localSocket
          .emit('$deviceId-unread', {"limit": limit, "filter": 'unread'});
      showAlert(message: 'successfully marked all notifications as read');
    } catch (e) {
      isLoading = false;
      _socketNotificationUnread.localSocket
          .emit('$deviceId-unread', {"limit": limit, "filter": 'unread'});
      print(e);
      errorMessageMiddleware(e);
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

    _socketNotificationUnread.init(deviceId, logedInUserId, activeCompanyId);
    _socketNotificationUnread.listener(onSocketPostNew, deviceId);
  }

  changeActiveCompanyById(String value) {
    activeCompanyId = value;
    _socketNotificationUnread.init(deviceId, logedInUserId, value);
    _socketNotificationUnread.listener(onSocketPostNew, deviceId);
  }

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    ever(_activeCompanyId, changeActiveCompanyById);
    ever(_selectedNotifItem, (List<String> value) {
      if (value.isEmpty) {
        isSelectAll.value = false;
      }
    });
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
