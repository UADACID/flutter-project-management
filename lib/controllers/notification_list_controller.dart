import 'package:cicle_mobile_f3/controllers/company_controller.dart';
import 'package:cicle_mobile_f3/controllers/notification_counter_controller.dart';
import 'package:cicle_mobile_f3/models/member_model.dart';
import 'package:cicle_mobile_f3/models/notification_item_model.dart';
import 'package:cicle_mobile_f3/service/notification_service.dart';
import 'package:cicle_mobile_f3/utils/constant.dart';
import 'package:cicle_mobile_f3/utils/helpers.dart';
import 'package:cicle_mobile_f3/utils/socket/socket_notification_all.dart';
import 'package:cicle_mobile_f3/utils/socket/socket_notification_list.dart';
import 'package:cicle_mobile_f3/utils/socket/socket_notification_unread.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class NotificationListController extends GetxController {
  final box = GetStorage();
  SocketNotificationAll _socketNotificationAll = SocketNotificationAll();
  SocketNotificationUnread _socketNotificationUnread =
      SocketNotificationUnread();

  NotificationCounterController _notificationCounterController =
      Get.put(NotificationCounterController());

  SocketNotificationList _socketNotificationList = SocketNotificationList();

  NotificationService _notificationService = NotificationService();

  // CompanyController _companyController = Get.find();

  var _id = ''.obs;
  String get id => _id.value;
  set id(String value) {
    _id.value = value;
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

  var _isCheckListOpen = false.obs;
  bool get isCheckListOpen => _isCheckListOpen.value;
  set isCheckListOpen(bool value) {
    _isCheckListOpen.value = value;
  }

  var _isCheckAll = false.obs;
  bool get isCheckAll => _isCheckAll.value;
  set isCheckAll(bool value) {
    _isCheckAll.value = value;
  }

  var _listSelectedItem = <String>[].obs;
  List<String> get listSelectedItem => _listSelectedItem;
  set listSelectedItem(value) {
    _listSelectedItem.value = [...value];
  }

  var _isLoading = false.obs;
  bool get isLoading => _isLoading.value;
  set isLoading(bool value) {
    _isLoading.value = value;
  }

  var _isLoadingOverlay = false.obs;
  bool get isLoadingOverlay => _isLoadingOverlay.value;
  set isLoadingOverlay(bool value) {
    _isLoadingOverlay.value = value;
  }

  var _canMarkAll = false.obs;
  bool get canMarkAll => _canMarkAll.value;
  set canMarkAll(bool value) {
    _canMarkAll.value = value;
  }

  var _notificationList = <NotificationItemModel>[].obs;
  List<NotificationItemModel> get notificationList => _notificationList;
  set notificationList(List<NotificationItemModel> value) {
    _notificationList.value = [...value];
  }

  var _limit = 10.obs;
  int get limit => _limit.value;
  set limit(int value) {
    _limit.value = value;
  }

  Future<void> loadMore() async {
    print('load more');

    int nextLimit = limit + 10;

    limit = nextLimit;

    if (id == 'all') {
      _socketNotificationAll.emit(nextLimit);
    } else if (id == 'all_unread') {
      _socketNotificationUnread.emit(nextLimit);
    } else {
      _socketNotificationList.emit(nextLimit);
    }

    return Future.value(true);
  }

  Future<void> refresh() async {
    int initLimitValue = 10;
    _limit.value = initLimitValue;

    if (id == 'all') {
      _socketNotificationAll.emit(initLimitValue);
    } else if (id == 'all_unread') {
      _socketNotificationUnread.emit(initLimitValue);
    } else {
      _socketNotificationList.emit(initLimitValue);
    }

    return Future.value(true);
  }

  _onSocketPostNew(data) {
    isLoading = false;

    try {
      List<NotificationItemModel> tempList = [];
      data.forEach((v) {
        tempList.add(NotificationItemModel.fromJson(v));
      });

      // String activeCompanyId = _companyController.selectedCompanyId;
      // // print('_activeCompanyId $_activeCompanyId');
      box.write('notification-tab-$id-$activeCompanyId', data);
      notificationList = [...tempList];
    } catch (e) {
      print(e);
    }
  }

  getData(String paramId, String paramCompanyId) async {
    id = paramId;

    activeCompanyId = paramCompanyId;
    final userString = box.read(KeyStorage.logedInUser);
    MemberModel _templogedInUser = MemberModel.fromJson(userString);
    logedInUserId = _templogedInUser.sId;
    deviceId = box.read(KeyStorage.deviceId);

    if (paramCompanyId == '') {
      isLoading = false;
      return;
    }

    getDataFromLocal(paramCompanyId);
    // init socket on here
    if (paramId == 'all') {
      _socketNotificationAll.init(deviceId, logedInUserId, paramCompanyId);
      _socketNotificationAll.listener(_onSocketPostNew, deviceId);
    } else if (paramId == 'all_unread') {
      _socketNotificationUnread.init(deviceId, logedInUserId, paramCompanyId);
      _socketNotificationUnread.listener(_onSocketPostNew, deviceId);
    } else {
      _socketNotificationList.init(paramId, logedInUserId, paramCompanyId);
      _socketNotificationList.listener(_onSocketPostNew);
    }
  }

  getDataFromLocal(String paramsActiveCompanyId) async {
    // String activeCompanyId = _companyController.selectedCompanyId;
    await Future.delayed(Duration(milliseconds: 150));
    var notificationListFromLocal =
        box.read('notification-tab-$id-$paramsActiveCompanyId');
    if (notificationListFromLocal is List) {
      List<NotificationItemModel> tempList = [];
      for (var v in notificationListFromLocal) {
        tempList.add(NotificationItemModel.fromJson(v));
      }
      notificationList = [...tempList];

      if (tempList.isEmpty) {
        isLoading = true;
      }
    } else {
      isLoading = true;
    }
  }

  toggleCheckAll(bool value) {
    if (value) {
      // kosongkan dulu list selected
      _listSelectedItem.value = [];
      List<NotificationItemModel> unreadNotificationList =
          _filterUnreadNotif(_notificationList);
      for (var i = 0; i < unreadNotificationList.length; i++) {
        NotificationItemModel _item = unreadNotificationList[i];
        _listSelectedItem.add(_item.sId);
      }
    } else {
      // kosongkan list
      _listSelectedItem.value = [];
    }
  }

  toggleCheckBoxItem(String id) {
    int getIndexItem = listSelectedItem.indexWhere((element) => element == id);
    if (getIndexItem >= 0) {
      // ada item di list selected
      _listSelectedItem.removeAt(getIndexItem);
    } else {
      // tidak ada item terpilih di list selected
      _listSelectedItem.add(id);
    }
  }

  Future<void> updateNotifItemAsRead(String notificationId) async {
    try {
      await _notificationService.updateNotifItemAsRead(notificationId);

      _notificationCounterController.init();
      await Future.delayed(Duration(seconds: 2));
      if (id == 'all') {
        _socketNotificationAll.emit(limit);
      } else if (id == 'all_unread') {
        _socketNotificationUnread.emit(limit);
      } else {
        _socketNotificationList.emit(limit);
      }
      return Future.value(true);
    } catch (e) {
      return Future.value(false);
    }
  }

  Future<void> markAllSelectionAsRead() async {
    try {
      if (listSelectedItem.isEmpty) {
        showAlert(message: 'there is no unread notification that you selected');
        return;
      }
      isLoadingOverlay = true;
      List<String> selectedNotificationIds = [...listSelectedItem];

      dynamic body = {
        "companyId": activeCompanyId,
        "notificationIds": selectedNotificationIds
      };
      final response = await _notificationService.markAllAsRead(body);
      _notificationCounterController.init();
      isLoadingOverlay = false;
      isCheckListOpen = false;
      _listSelectedItem.clear();

      showAlert(message: response.data['message']);
    } catch (e) {
      print(e);
      isLoadingOverlay = false;

      errorMessageMiddleware(e);
    }
  }

  List<NotificationItemModel> _filterUnreadNotif(
      List<NotificationItemModel> list) {
    List<NotificationItemModel> unreadNotificationList = list.where((item) {
      List<String> checkIds = [logedInUserId];
      bool isSelfNotif = item.sender.sId == logedInUserId;
      List<Activities> filteredActivities = item.activities
          .where((activity) => !activity.readBy
              .any((element) => checkIds.contains(element.reader)))
          .toList();
      bool isRead = isSelfNotif ? true : filteredActivities.length <= 0;

      return !isRead;
    }).toList();

    return unreadNotificationList;
  }

  _onChangeListSelectedItem(List<String> value) {
    List<NotificationItemModel> unreadNotificationList =
        _filterUnreadNotif(_notificationList);

    if (unreadNotificationList.length == listSelectedItem.length) {
      isCheckAll = true;
    } else {
      isCheckAll = false;
    }
  }

  _onChangeCheckListOpen(bool value) {
    if (!value) {
      _listSelectedItem.value = [];
    }
  }

  _onChangeNotificationList(List<NotificationItemModel> value) {
    bool listHasUnreadItem = _filterUnreadNotif(_notificationList).isNotEmpty;
    if (listHasUnreadItem) {
      canMarkAll = true;
    } else {
      canMarkAll = false;
    }
  }

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    ever(_listSelectedItem, _onChangeListSelectedItem);
    ever(_isCheckListOpen, _onChangeCheckListOpen);
    ever(_notificationList, _onChangeNotificationList);
  }
}
