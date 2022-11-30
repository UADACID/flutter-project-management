import 'package:cicle_mobile_f3/controllers/company_controller.dart';
import 'package:cicle_mobile_f3/models/companies_model.dart';
import 'package:cicle_mobile_f3/models/member_model.dart';
import 'package:cicle_mobile_f3/utils/constant.dart';
import 'package:cicle_mobile_f3/utils/socket/socket_notification_counter_unread_by_teams.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class TabNotifItem {
  final String id;
  final String name;

  TabNotifItem({required this.id, required this.name});
}

class TeamWithCounter {
  final String id;
  final String name;
  late int unreadNotification;
  TeamWithCounter(
      {required this.id, required this.name, required this.unreadNotification});
}

enum DefaultNotificationView { allUnread, byGroup }

class NotificationController extends GetxController {
  final box = GetStorage();
  SocketNotificationCounterUnreadByTeams
      _socketNotificationCounterUnreadByTeams =
      SocketNotificationCounterUnreadByTeams();

  ScrollController listTabsScrollController = ScrollController();

  var _isLoading = false.obs;
  bool get isLoading => _isLoading.value;
  set isLoading(bool value) {
    _isLoading.value = value;
  }

  var _activeCompanyId = "".obs;
  String get activeCompanyId => _activeCompanyId.value;
  set activeCompanyId(String value) {
    _activeCompanyId.value = value;
  }

  var _activeTabIndex = 1.obs; // 0 = all, 1 = unread
  int get activeTabIndex => _activeTabIndex.value;
  var activeTabId = 'all_unread'.obs;

  setIndex(int value, String id) {
    _activeTabIndex.value = value;
    activeTabId.value = id;
  }

  var _listTeamWithCounter = <TeamWithCounter>[].obs;
  List<TeamWithCounter> get listTeamWithCounter => _listTeamWithCounter;
  set listTeamWithCounter(List<TeamWithCounter> value) {
    _listTeamWithCounter.value = [...value];
  }

  var _listTabItem = <TabNotifItem>[
    TabNotifItem(id: 'all', name: "All"),
    TabNotifItem(id: 'all_unread', name: "All Unread"),
  ].obs;
  List<TabNotifItem> get listTabItem => _listTabItem;
  set listTabItem(List<TabNotifItem> value) {
    _listTabItem.value = [...value];
  }

  // FILTER

  var defaultNotificationView = DefaultNotificationView.allUnread.obs;

  TextEditingController searchKeyFilterController = TextEditingController();

  var _searchKeyFilter = "".obs;
  String get searchKeyFilter => _searchKeyFilter.value;
  set searchKeyFilter(String value) {
    _searchKeyFilter.value = value;
  }

  resetFilter() {
    defaultNotificationView.value = DefaultNotificationView.allUnread;
    searchKeyFilterController.text = "";
    searchKeyFilter = '';

    listTabsScrollController.animateTo(0,
        duration: const Duration(seconds: 2), curve: Curves.linear);
  }

  handleSelectTeamFromHome(String teamId) {
    if (defaultNotificationView.value == DefaultNotificationView.byGroup) {
      activeTabId.value = teamId;
    }
  }

  onChangeDefaultNotificationView(DefaultNotificationView value) {
    if (value == DefaultNotificationView.allUnread) {
      activeTabId.value = 'all_unread';
      resetFilter();
    }
  }

  onChangeActiveTabId(String value) {
    String teamId = value;
    int getIndex = listTabItem.indexWhere((element) => element.id == teamId);
    if (getIndex >= 0) {
      _activeTabIndex.value = getIndex;
    }
  }

  // END FILTER

  _onFirstGetData(data) {
    try {
      if (data['teams'] != null) {
        _listTeamWithCounter.value = [];
        data['teams'].forEach((o) {
          String id = o['team']['_id'];
          String name = o['team']['name'];
          int unreadNotification = o['unreadNotification'];
          _listTeamWithCounter.add(TeamWithCounter(
              id: id, name: name, unreadNotification: unreadNotification));
        });
      }
    } catch (e) {
      print(e);
    }
  }

  _onUpdateCounterTeams(data) {
    try {
      if (data['teamId'] != null && data['unreadNotification'] != null) {
        String teamId = data['teamId'];
        int unreadNotification = data['unreadNotification'];

        // update unread by teamId
        var _tempList = <TeamWithCounter>[];
        listTeamWithCounter.forEach((e) {
          if (e.id == teamId) {
            e.unreadNotification = unreadNotification;
          }
          _tempList.add(e);
        });

        listTeamWithCounter = _tempList;
      }
    } catch (e) {
      print(e);
    }
  }

  initData(CompanyController _companyController) async {
    String companyId = _companyController.selectedCompanyId;
    final userString = box.read(KeyStorage.logedInUser);
    MemberModel _templogedInUser = MemberModel.fromJson(userString);

    _socketNotificationCounterUnreadByTeams.init(
        _templogedInUser.sId, companyId);
    _socketNotificationCounterUnreadByTeams.listener(
        onFirstGetData: _onFirstGetData,
        onUpdateCounterTeams: _onUpdateCounterTeams);
    activeCompanyId = _companyController.selectedCompanyId;

    isLoading = true;

    _listTabItem.value = [];
    _listTabItem.add(
      TabNotifItem(id: 'all', name: "All"),
    );
    _listTabItem.add(
      TabNotifItem(id: 'all_unread', name: "All Unread"),
    );
    for (var i = 0; i < _companyController.teams.length; i++) {
      Teams _team = _companyController.teams[i];
      _listTabItem.add(TabNotifItem(id: _team.sId, name: _team.name));
    }

    setIndex(1, 'all_unread');

    await Future.delayed(Duration(seconds: 2));
    isLoading = false;
  }

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    ever(defaultNotificationView, onChangeDefaultNotificationView);
    ever(activeTabId, onChangeActiveTabId);
  }
}
