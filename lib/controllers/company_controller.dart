import 'dart:io';

import 'package:cicle_mobile_f3/controllers/notification_controller.dart';
import 'package:cicle_mobile_f3/controllers/notification_counter_controller.dart';
import 'package:cicle_mobile_f3/controllers/notification_unread_controller.dart';
import 'package:cicle_mobile_f3/controllers/private_chat_controller.dart';
import 'package:cicle_mobile_f3/controllers/search_controller.dart';
import 'package:cicle_mobile_f3/models/companies_model.dart';
import 'package:cicle_mobile_f3/models/member_model.dart';
import 'package:cicle_mobile_f3/models/notification_item_model.dart';
import 'package:cicle_mobile_f3/models/user_model.dart';

import 'package:cicle_mobile_f3/service/company_service.dart';
import 'package:cicle_mobile_f3/utils/constant.dart';
import 'package:cicle_mobile_f3/utils/helpers.dart';
import 'package:cicle_mobile_f3/utils/internal_link_adapter.dart';
import 'package:cicle_mobile_f3/utils/notification_type_adapter.dart';
import 'package:cicle_mobile_f3/utils/socket/socket_companies_counter.dart';
import 'package:cicle_mobile_f3/utils/socket/socket_company.dart';
import 'package:cicle_mobile_f3/widgets/default_alert.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:uni_links/uni_links.dart';

import 'notification_all_controller.dart';

var initialUriIsHandled = false;

class CompanyController extends GetxController {
  final box = GetStorage();
  CompanyService _companyService = CompanyService();
  NotificationAllController _notificationAllController =
      Get.put(NotificationAllController());
  NotificationUnreadController _notificationUnreadController =
      Get.put(NotificationUnreadController());
  NotificationCounterController _notificationCounterController =
      Get.put(NotificationCounterController());

  NotificationController _notificationController =
      Get.put(NotificationController());

  PrivateChatController _privateChatController =
      Get.put(PrivateChatController());

  String companyId = Get.parameters['companyId'] ?? '';
  SocketCompany _socketCompany = SocketCompany();
  SocketCompaniesCounter _socketCompaniesCounter = SocketCompaniesCounter();

  var scaffoldKey = GlobalKey<ScaffoldState>();

  // LOADING

  var _isLoading = false.obs;
  bool get isLoading => _isLoading.value;

  var _listCompaniesCollapse = true.obs;
  bool get listCompaniesCollapse => _listCompaniesCollapse.value;
  set listCompaniesCollapse(bool value) {
    _listCompaniesCollapse.value = value;
  }

  // EXPIRED SELECTED COMPANY
  var _curentCompanyIsExpired = false.obs;
  bool get curentCompanyIsExpired => _curentCompanyIsExpired.value;

  // INVITATION TOKEN
  final _invitationTokenValue = ''.obs;
  String get invitationTokenValue => _invitationTokenValue.value;
  set invitationTokenValue(String value) {
    _invitationTokenValue.value = value;
  }

  // COMPANIES
  var _companies = <Companies>[].obs;
  List<Companies> get companies {
    return _companies;
  }

  // SELECTED COMPANY ID
  var _selectedCompanyId = ''.obs;
  String get selectedCompanyId {
    return _selectedCompanyId.value;
  }

  var _errorGetData = ''.obs;
  String get errorGetData => _errorGetData.value;
  set errorGetData(String value) {
    _errorGetData.value = value;
  }

  void setCompanyId(String id) async {
    try {
      _selectedCompanyId.value = id;
      String? checkSubscriptionResult = await checkSubscription(id);
      await Future.delayed(Duration(milliseconds: 500));
      if (checkSubscriptionResult != null &&
          checkSubscriptionResult == Constants.companyActive) {
        _curentCompanyIsExpired.value = false;
      } else {
        _curentCompanyIsExpired.value = true;
      }
      Get.back();
      await Future.delayed(Duration(milliseconds: 500));
      Get.back();
    } catch (e) {
      print(e);
    }
  }

  defaultAction() {}

  void setCompanyIdFromPushNotif(String id,
      {GestureTapCallback? onSuccess}) async {
    try {
      // check id is exist on list company
      List<Companies> filterLocalCompaniesById =
          _companies.where((o) => o.sId == id).toList();

      if (filterLocalCompaniesById.isEmpty) {
        print(' company tidak ketemu');
        // not found itu bisa karena aplikasi terforce close
        // maka harus query ulang list company
        if (_companies.isEmpty) {
          // get list companies

          List<Companies> _tempList = await getCompanies();
          List<Companies> newFilterLocalCompaniesById =
              _tempList.where((o) => o.sId == id).toList();

          if (newFilterLocalCompaniesById.isEmpty) {
            showAlert(message: "Company not found on this user");
          } else {
            print('beda id company');
            _selectedCompanyId.value = id;
            // check subscribtion
            String? checkSubscriptionResult = await checkSubscription(id);
            await Future.delayed(Duration(milliseconds: 500));
            if (checkSubscriptionResult != null &&
                checkSubscriptionResult == Constants.companyActive) {
              String _currentRouteName = Get.currentRoute;

              if (!_currentRouteName.contains('dashboard')) {
                Get.reset();
                await Future.delayed(Duration(milliseconds: 300));
                Get.offAllNamed(RouteName.dashboardScreen(companyId));
              }

              onSuccess != null ? onSuccess() : defaultAction();
              _curentCompanyIsExpired.value = false;
              return;
            } else {
              _curentCompanyIsExpired.value = true;
            }
            Get.back();
            await Future.delayed(Duration(milliseconds: 500));
            Get.back();
          }
        } else {
          showAlert(message: "Company not found on this user");
        }
      } else {
        // check id is current companyId
        if (id == _selectedCompanyId.value) {
          onSuccess != null ? onSuccess() : defaultAction();
          return;
        }
        print('beda id company');
        _selectedCompanyId.value = id;
        // check subscribtion
        String? checkSubscriptionResult = await checkSubscription(id);
        await Future.delayed(Duration(milliseconds: 500));
        if (checkSubscriptionResult != null &&
            checkSubscriptionResult == Constants.companyActive) {
          // String _currentRouteName = Get.currentRoute;
          print('mlebu rene 1');
          // if (!_currentRouteName.contains('dashboard')) {
          print('mlebu rene');
          Get.reset();
          await Future.delayed(Duration(milliseconds: 300));
          Get.offAllNamed(RouteName.dashboardScreen(companyId));
          await Future.delayed(Duration(milliseconds: 300));
          // }

          onSuccess != null ? onSuccess() : defaultAction();
          _curentCompanyIsExpired.value = false;
          return;
        } else {
          _curentCompanyIsExpired.value = true;
        }
        Get.back();
        await Future.delayed(Duration(milliseconds: 500));
        Get.back();
      }
    } catch (e) {
      print(e);
    }
  }

  // SELECTED COMPANY

  // CURRENT COMPANY -----

  var _currentCompany = Companies(sId: getRandomString(20)).obs;

  Companies get currentCompany => _currentCompany.value;

  var _companyMembers = <MemberModel>[].obs;

  // MEMBERS

  Future<void> inviteMember(String email) async {
    try {
      final userString = box.read(KeyStorage.logedInUser);
      MemberModel logedInUser = MemberModel.fromJson(userString);
      dynamic payload = {"emailReceiver": email, "senderId": logedInUser.sId};
      final response = await _companyService.inviteMember(
          _currentCompany.value.sId, payload);

      showAlert(message: response.data['message']);
    } catch (e) {
      print(e);
      errorMessageMiddleware(e, false, 'Failed to invite member,');
    }
  }

  List<MemberModel> get companyMembers {
    // _companyMembers.sort((a, b) => a.fullName.compareTo(b.fullName));
    return _companyMembers;
  }

  // // TEAMS
  Future<void> createTeam(
      {required String name,
      required String desc,
      required String type}) async {
    try {
      showLoadingOverlay();
      dynamic payload = {
        "data": {"name": name, "desc": desc, "type": type},
        "selector": {"companyId": _currentCompany.value.sId}
      };
      final response = await _companyService.createTeam(payload);

      Teams _newTeam = Teams.fromJson(response.data['newTeam']);
      final userString = box.read(KeyStorage
          .logedInUser); // set team with current member with logedin user
      MemberModel logedInUser = MemberModel.fromJson(userString);
      _newTeam.members.add(logedInUser);
      _teams.add(_newTeam);
      _notificationController.initData(this);
      Get.back(); // hide overlay
      await Future.delayed(Duration(milliseconds: 200));
      Get.back(); // hide form
      await Future.delayed(Duration(milliseconds: 200));
      Get.back(); // hide bottomsheet
      return Future.value(true);
    } catch (e) {
      // print(e);
      errorMessageMiddleware(e, false, 'Failed to create new $type,');
      Get.back(); // hide overlay
      return Future.value(false);
    }
  }

  var _teams = <Teams>[].obs;
  List<Teams> get teams => _teams;

  Future<void> createCompany(
      {required String name, required String desc}) async {
    try {
      showLoadingOverlay();
      dynamic payload = {"name": name, "desc": desc};
      final response = await _companyService.createCompanies(payload);
      if (!Get.currentRoute.contains('dashboard')) {
        // handle create company from team detail
        Get.back();
      }
      Companies _newCompany = Companies.fromJson(response.data['newCompany']);
      _companies.add(_newCompany);
      await getCompanies();
      _selectedCompanyId.value = _newCompany.sId;
      showAlert(message: response.data['message']);
      Get.back(); // hide overlay
      await Future.delayed(Duration(milliseconds: 200));
      Get.back(); // hide form
      await Future.delayed(Duration(milliseconds: 200));
      Get.back(); // hide drawer
    } catch (e) {
      errorMessageMiddleware(e, false, 'Failed to create new company,');
      Get.back(); // hide overlay
      _isLoading.value = false;
    }
  }

  Future<List<Companies>> getCompanies() async {
    try {
      final response = await _companyService.getCompanies();
      final userString = box.read(KeyStorage.logedInUser);
      MemberModel logedInUser = MemberModel.fromJson(userString);
      box.write('companies-user-${logedInUser.sId}', response.data);
      var list = CompaniesModel.fromJson(response.data);
      list.companies
          .sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
      _companies.value = [...list.companies];

      return _companies;
    } catch (e) {
      errorMessageMiddleware(e, false, 'Failed to get list of companies,');
      return Future.error(e);
    }
  }

  Future<String?> checkSubscription(String companyId) async {
    try {
      final response = await _companyService.checkSubscription(companyId);
      if (response.statusCode == 200) {
        return Future.value(Constants.companyActive);
      }
      return Future.value(null);
    } catch (e) {
      errorMessageMiddleware(e, false, 'Failed to check subscription, ');
      return Future.value(null);
    }
  }

  _debug(List<Companies> list) async {
    await Future.delayed(Duration(seconds: 3));
    String _tempSelectedCompanyId =
        box.read(KeyStorage.selectedCompanyId) ?? '';
    final userString = box.read(KeyStorage.logedInUser);
    MemberModel logedInUser = MemberModel.fromJson(userString);

    if (list.isEmpty && _tempSelectedCompanyId == 'new-user') {
      showAlert(
          flashDuration: 60,
          message:
              'you are a new user on this device and you have not joined any company, please create a new company or join another company');
      //  showAlert(
      //   flashDuration: 30,
      //   message:
      //       "logedInUserEmail: ${logedInUser.email},_tempSelectedCompanyId: $_tempSelectedCompanyId, _companyListCounter: ${list.length}");

    }
  }

  // _showDrawerAndAlertSelectCompany() async {
  //   await Future.delayed(Duration(milliseconds: 1500));
  //   scaffoldKey.currentState?.openEndDrawer();
  //   // await Future.delayed(Duration(milliseconds: 600));
  //   // Get.dialog(
  //   //     DefaultAlert(
  //   //       onSubmit: () {
  //   //         Get.back();
  //   //       },
  //   //       onCancel: () {},
  //   //       title: 'Info',
  //   //       showDescription: true,
  //   //       description:
  //   //           'Please select a company on the list or create a new company',
  //   //       hideCancel: true,
  //   //     ),
  //   //     transitionDuration: Duration(milliseconds: 600));
  // }

  _handleGetCompaniesFromLocalStorage() {}

  Future<bool> init() async {
    try {
      _isLoading.value = true;
      List<Companies> _tempList = [];
      // handle get companies from local storage
      final userString = box.read(KeyStorage.logedInUser);
      MemberModel logedInUser = MemberModel.fromJson(userString);
      dynamic listCompanyAsString =
          box.read('companies-user-${logedInUser.sId}');

      if (listCompanyAsString != null &&
          listCompanyAsString['companies'] != null &&
          listCompanyAsString['companies'] is List) {
        var list = CompaniesModel.fromJson(listCompanyAsString);
        list.companies.sort(
            (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

        if (list.companies.isNotEmpty) {
          _companies.value = [...list.companies];
          _tempList = [...list.companies];
          _isLoading.value = false;
        }
      }
      // end of handle get companies from local storage

      if (_companies.isNotEmpty) {
        getCompanies();
      } else {
        _tempList = await getCompanies();
      }

      errorGetData = '';
      String _tempSelectedCompanyId =
          box.read(KeyStorage.selectedCompanyId) ?? '';
      _debug(_tempList);

      if (_tempSelectedCompanyId == 'new-user' && _tempList.isEmpty) {
        // new user on this device with empty companies
        // print('logesss new user on this device with empty companies');

        _isLoading.value = false;
        showAlert(message: "you don't own or join a company");
        return Future.value(true);
      } else if (_tempSelectedCompanyId == 'new-user' && _tempList.isNotEmpty) {
        // new user on this device with not empty companies
        // print('logesss new user on this device with not empty companies');
        _isLoading.value = false;
        _curentCompanyIsExpired.value = true;
        // _showDrawerAndAlertSelectCompany();
        return Future.value(true);
      } else {
        // user have logedin and select default company for this device
        // print(
        //     'logesss user have logedin and select default company for this device');
        _selectedCompanyId.value = _tempSelectedCompanyId;
        String? checkSubscriptionResult =
            await checkSubscription(_selectedCompanyId.value);
        if (checkSubscriptionResult == Constants.companyActive) {
          _curentCompanyIsExpired.value = false;
        } else {
          _curentCompanyIsExpired.value = true;
        }
        Companies _tempCompany = _tempList
            .firstWhere((element) => element.sId == _selectedCompanyId.value);
        _teams.value = _tempCompany.teams;
        Get.put(SearchController()).teams = [..._tempCompany.teams];
        _currentCompany.value = _tempCompany;
        _companyMembers.value = [..._tempCompany.members];
        _isLoading.value = false;
        return Future.value(true);
      }
    } catch (e) {
      print(e);
      _isLoading.value = false;

      errorGetData = errorMessageMiddleware(e);
      return Future.value(false);
    }
  }

  onCompanyAdd(dynamic item) {}
  onCompanyUpdate(dynamic item) {}

  onMemberAdd(dynamic jsonMember) {
    MemberModel item = MemberModel.fromJson(jsonMember);
    int getIndex =
        _companyMembers.indexWhere((element) => element.sId == item.sId);
    if (getIndex < 0) {
      _companyMembers.add(item);
    }
  }

  onMemberRemove(dynamic jsonMember) {
    MemberModel item = MemberModel.fromJson(jsonMember);
    _companyMembers.removeWhere((element) => element.sId == item.sId);
  }

  onMemberUpdate(dynamic jsonMember) {
    MemberModel item = MemberModel.fromJson(jsonMember);
    final userString = box.read(KeyStorage.logedInUser);
    MemberModel _templogedInUser = MemberModel.fromJson(userString);

    if (item.sId == _templogedInUser.sId) {
      // ONLY FOR HACK, need better logic soon
      init();
      _notificationAllController.refresh();
      _notificationUnreadController.refresh();
    }

    List<MemberModel> _tempMembers = _companyMembers.map((e) {
      if (e.sId == item.sId) {
        return item;
      }

      return e;
    }).toList();
    _companyMembers.value = _tempMembers;
  }

  onTeamAdd(dynamic item) {
    try {
      if (item['_id'] != null) {
        Teams newTeam = Teams.fromJson(item);
        int getIndex =
            _teams.indexWhere((element) => element.sId == newTeam.sId);
        if (getIndex < 0) {
          // check new is logedin user is member on team
          final userString = box.read(KeyStorage.logedInUser);
          MemberModel logedInUser = MemberModel.fromJson(userString);
          String userId = logedInUser.sId;

          List<MemberModel> isLogedInUserOnThisTeam = newTeam.members
              .where((element) => element.sId == userId)
              .toList();

          if (isLogedInUserOnThisTeam.isNotEmpty) {
            _notificationController.initData(this);
            _teams.add(newTeam);
          }
        }
      }
    } catch (e) {
      // print(e);
    }
  }

  onTeamArchive(dynamic item) {
    try {
      if (item['_id'] != null) {
        Teams newTeam = Teams.fromJson(item);
        _teams.removeWhere((element) => element.sId == newTeam.sId);
        _notificationController.initData(this);
      }
    } catch (e) {
      // print(e);
    }
  }

  onTeamUpdate(dynamic item) {
    try {
      if (item['_id'] != null) {
        Teams newTeam = Teams.fromJson(item);
        int getIndex =
            _teams.indexWhere((element) => element.sId == newTeam.sId);
        if (getIndex < 0) {
          // check new is logedin user is member on team
          final userString = box.read(KeyStorage.logedInUser);
          MemberModel logedInUser = MemberModel.fromJson(userString);
          String userId = logedInUser.sId;

          List<MemberModel> isLogedInUserOnThisTeam = newTeam.members
              .where((element) => element.sId == userId)
              .toList();

          if (isLogedInUserOnThisTeam.isNotEmpty) {
            _notificationController.initData(this);
            _teams.add(newTeam);
          }
        } else {
          // team sudah ada di list tinggal di update
          _teams[getIndex] = newTeam;
        }
      }
    } catch (e) {
      // print(e);
    }
  }

  // all company counter

  var _listCompanyCounter = <NotifCompanyCounterItem>[].obs;
  List<NotifCompanyCounterItem> get listCompanyCounter => _listCompanyCounter;
  set listCompanyCounter(List<NotifCompanyCounterItem> value) {
    _listCompanyCounter.value = [...value];
  }

  _onCounterCompanyUpdate(json) {
    var _tempList = json['companies'] ?? [];
    _listCompanyCounter.clear();
    _tempList.forEach((o) {
      String companyId = o?['company']?['_id'] ?? '';
      int unreadNotification = o?['unreadNotification'] ?? 0;
      int unreadChat = o?['unreadChat'] ?? 0;
      _listCompanyCounter.add(
          NotifCompanyCounterItem(companyId, unreadNotification, unreadChat));
    });
  }

  changeActiveCompanyById(value) async {
    try {
      box.write(KeyStorage.selectedCompanyId, value);
      Companies _tempCompany =
          _companies.firstWhere((element) => element.sId == value);
      // handle current company
      _currentCompany.value = _tempCompany;
      // handle company members
      _companyMembers.value = [..._tempCompany.members];
      // handle team HQ
      _teams.value = _tempCompany.teams;
      Get.parameters['companyId'] = value;

      final userString = box.read(KeyStorage.logedInUser);
      MemberModel logedInUser = MemberModel.fromJson(userString);

      _socketCompaniesCounter.init(logedInUser.sId);
      _socketCompaniesCounter.listener(
          onCounterUpdate: _onCounterCompanyUpdate);

      _notificationCounterController.activeCompanyId = value;
      _notificationController.initData(this);
      _curentCompanyIsExpired.value = false;
      _notificationAllController.activeCompanyId = value;
      _notificationUnreadController.activeCompanyId = value;

      _privateChatController.listenData(value);

      _socketCompany.init(value);
      _socketCompany.listener(
          onCompanyAdd: onCompanyAdd,
          onCompanyUpdate: onCompanyUpdate,
          onMemberRemove: onMemberRemove,
          onMemberUpdate: onMemberUpdate,
          onTeamAdd: onTeamAdd,
          onTeamArchive: onTeamArchive,
          onTeamUpdate: onTeamUpdate,
          onMemberAdd: onMemberAdd);
    } catch (e) {
      print(e);
    }
  }

  initPushNotif() async {
    //Remove this method to stop OneSignal Debugging
    final userString = box.read(KeyStorage.logedInUser);
    MemberModel logedInUser = MemberModel.fromJson(userString);
    if (Platform.isIOS) {
      await OneSignal.shared
          .promptUserForPushNotificationPermission(fallbackToSettings: true);
    }

    OneSignal.shared.setLogLevel(OSLogLevel.verbose, OSLogLevel.none);

    OneSignal.shared.setAppId(Env.ONE_SIGNAL_APP_ID);

    OneSignal.shared.setExternalUserId(logedInUser.sId);

    OneSignal.shared.setNotificationWillShowInForegroundHandler(
        (OSNotificationReceivedEvent event) {
      // Will be called whenever a notification is received in foreground
      // Display Notification, pass null param for not displaying the notification

      print('setNotificationWillShowInForegroundHandler');
      var a = Get.currentRoute;

      Map<String, dynamic>? additionalData = event.notification.additionalData;
      if (additionalData != null) {
        final Map<String, dynamic> mapAdditionalData =
            new Map<String, dynamic>();
        additionalData.forEach((k, v) {
          return mapAdditionalData['$k'] = v;
        });
        var cloneAdditionalData = Map<String, dynamic>.from(mapAdditionalData);
        var notification = NotificationItemModel.fromJson(cloneAdditionalData);

        NotifAdapterModel itemAdapter =
            NotificationTypeAdapter.init(notification);

        var b = itemAdapter.fullRoute;

        // set conditional for private chat & group chat
        if (b.contains('private-chats-detail')) {
          if (a.contains(b)) {
            event.complete(null);
            print(
                'current route sedang ada di halaman private chat, tidak muncul push notif');
          } else {
            event.complete(event.notification);
          }
        } else if (b.contains('group-chats')) {
          if (a.contains(b)) {
            event.complete(null);
            print(
                'current route sedang ada di halaman group chat, tidak muncul push notif');
          } else {
            event.complete(event.notification);
          }
        } else {
          event.complete(event.notification);
        }
      } else {
        event.complete(null);
      }

      // event.complete(null);
    });

    OneSignal.shared.setNotificationOpenedHandler(onTapPushNotif);

    OneSignal.shared.setPermissionObserver((OSPermissionStateChanges changes) {
      // Will be called whenever the permission changes
      // (ie. user taps Allow on the permission prompt in iOS)
      print('setPermissionObserver');
    });
  }

  onTapPushNotif(OSNotificationOpenedResult result) {
// Will be called whenever a notification is opened/button pressed.
    print('setNotificationOpenedHandler');

    try {
      Map<String, dynamic>? additionalData = result.notification.additionalData;

      if (additionalData != null) {
        final Map<String, dynamic> mapAdditionalData =
            new Map<String, dynamic>();
        additionalData.forEach((k, v) {
          return mapAdditionalData['$k'] = v;
        });
        var cloneAdditionalData = Map<String, dynamic>.from(mapAdditionalData);

        var notification = NotificationItemModel.fromJson(cloneAdditionalData);

        NotifAdapterModel itemAdapter =
            NotificationTypeAdapter.init(notification);

        setCompanyIdFromPushNotif(cloneAdditionalData['company']?['_id'] ?? '',
            onSuccess: () async {
          itemAdapter.redirect();
          _notificationAllController.updateNotifItemAsRead(notification.sId);
        });
      } else {
        print('data from push notif null');
      }
    } catch (e) {
      print(e);
      errorMessageMiddleware(e, false, 'Failed on tap pushnotif,');
    }
  }

  onTeamsChange(List<Teams> value) {
    Get.put(SearchController()).teams = [...value];
  }

  @override
  void onInit() async {
    // TODO: implement onInit
    super.onInit();
    ever(_selectedCompanyId, changeActiveCompanyById);
    initPushNotif();
    bool success = await init();
    if (success) {
      _handleInitialUri();
      _notificationAllController.activeCompanyId = _currentCompany.value.sId;
      _notificationAllController.init();
      _notificationUnreadController.activeCompanyId = _currentCompany.value.sId;
      _notificationUnreadController.init();

      _notificationCounterController.activeCompanyId =
          _currentCompany.value.sId;
      _notificationCounterController.init();

      _notificationController.initData(this);

      final userString = box.read(KeyStorage.logedInUser);
      MemberModel logedInUser = MemberModel.fromJson(userString);

      _socketCompaniesCounter.init(logedInUser.sId);
      _socketCompaniesCounter.listener(
          onCounterUpdate: _onCounterCompanyUpdate);

      ever(_teams, onTeamsChange);
    }
  }

  /// We handle all exceptions, since it is called from initState.
  Future<void> _handleInitialUri() async {
    print('fullUrl masuk handle initial URL');
    // In this example app this is an almost useless guard, but it is here to
    // show we are not going to call getInitialUri multiple times, even if this
    // was a weidget that will be disposed of (ex. a navigation route change).
    await Future.delayed(Duration(milliseconds: 1500));
    print('fullUrl _initialUriIsHandled $initialUriIsHandled');
    if (!initialUriIsHandled) {
      initialUriIsHandled = true;
      // _showSnackBar('_handleInitialUri called');
      try {
        final uri = await getInitialUri();
        if (uri == null) {
          print('fullUrl no initial uri');
        } else {
          // check is login

          var token = box.read('token');
          if (token == null || token == '') {
            return;
          }
          // check exsiting selected companyId
          // String fullUrl = uri!.path + uri.origin;
          String fullUrl = uri.path;
          print('fullUrl $fullUrl');

          checkIsUrlHaveInvitationToken(fullUrl, false);
          // if (invitationToken != '') {
          //   // show invitation page
          //   print('invitationToken $invitationToken');
          //   invitationTokenValue = invitationToken;
          // }
          // print('got full url $fullUrl');
          internalLinkAdapter(fullUrl);
        }
        // if (!mounted) return;
        // setState(() => _initialUri = uri);
      } on PlatformException {
        // Platform messages may fail but we ignore the exception
        print('falied to get initial uri');
        print('fullUrl masuk failed initial URL platform exception');
      } on FormatException catch (err) {
        print('fullUrl masuk failed initial URL FormatException');
        showAlert(message: err.toString());
        // if (!mounted) return;
        // print('malformed initial uri');
        // setState(() => _err = err);
      } catch (e) {
        print(e);
        print('fullUrl masuk failed catch');
        errorMessageMiddleware(e, false, 'Failed on open deeplink,');
      }
    }
  }
}

class NotifCompanyCounterItem {
  final String companyId;
  final int unreadNotification;
  final int unreadChat;

  NotifCompanyCounterItem(
      this.companyId, this.unreadNotification, this.unreadChat);
}
