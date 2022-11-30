import 'dart:async';

import 'package:cicle_mobile_f3/controllers/search_controller.dart';
import 'package:cicle_mobile_f3/models/card_model.dart';
import 'package:cicle_mobile_f3/models/member_model.dart';
import 'package:cicle_mobile_f3/models/message_item_model.dart';
import 'package:cicle_mobile_f3/models/notification_item_model.dart';
import 'package:cicle_mobile_f3/service/private_chat_service.dart';
import 'package:cicle_mobile_f3/utils/constant.dart';
import 'package:cicle_mobile_f3/utils/helpers.dart';

import 'package:cicle_mobile_f3/utils/socket/socket_notification_chat.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:faker/faker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class PrivateChatController extends GetxController {
  final faker = Faker(provider: FakerDataProvider());
  final box = GetStorage();

  TextEditingController textEditingControllerSearch = TextEditingController();

  PrivateChatService _privateChatService = PrivateChatService();

  SocketNotificationChat _socketNotificationChat = SocketNotificationChat();

  var _isLoading = false.obs;
  bool get isLoading => _isLoading.value;
  set isLoading(bool value) {
    _isLoading.value = value;
  }

  var _searchKey = ''.obs;
  String get searchKey => _searchKey.value;
  set searchKey(String value) {
    _searchKey.value = value;
  }

  var _logedInUserId = ''.obs;
  String get logedInUserId => _logedInUserId.value;
  set logedInUserId(String value) {
    _logedInUserId.value = value;
  }

  var _listRecentMessage = <DummyChatItemModel>[].obs;
  List<DummyChatItemModel> get listRecentMessage => _listRecentMessage;
  set listRecentMessage(List<DummyChatItemModel> value) {
    _listRecentMessage.value = value;
  }

  var _listNotifChat = <NotificationItemModel>[].obs;
  List<NotificationItemModel> get listNotifChat => _listNotifChat;
  set listNotifChat(List<NotificationItemModel> value) {
    _listNotifChat.value = value;
  }

  Future<String> createNewChat(String memberId) async {
    List<DummyChatItemModel> filterListByMemberId = _listRecentMessage
        .where((e) => e.members.any((element) => element.sId == memberId))
        .toList();
    if (filterListByMemberId.isNotEmpty) {
      return filterListByMemberId[0].id;
    }

    dynamic body = {"memberId": memberId};
    final response = await _privateChatService.createNewChat(body);
    return response.data['chatId'] ?? '';
  }

  late StreamSubscription<QuerySnapshot> streamSub;
  bool _isStreamInit = false;

  createRecentlyViewed() {
    String teamId = Get.parameters['teamId'] ?? '';
    String companyId = Get.parameters['companyId'] ?? '';
    String path = '${RouteName.privateChatScreen(companyId)}?teamId=$teamId';

    Get.put(SearchController()).insertListRecenlyViewed(RecentlyViewed(
        moduleName: 'inbox',
        companyId: companyId,
        path: path,
        teamName: ' ',
        title: 'Inbox',
        subtitle: 'Home  >  Menu  >  Inbox',
        uniqId: 'inbox'));
  }

  listenData(String currentCompanyId) async {
    final _deviceId = box.read(KeyStorage.deviceId);
    _socketNotificationChat.init(_deviceId, logedInUserId, currentCompanyId);
    _socketNotificationChat.listener(onSocketPostNew, _deviceId);
    isLoading = true;

    _isStreamInit = true;
    streamSub = FirebaseFirestore.instance
        .collection('chats')
        .where('name', isEqualTo: "")
        .where('company', isEqualTo: currentCompanyId)
        .where('memberIds', arrayContains: logedInUserId)
        .orderBy('lastMessage.updatedAt', descending: true)
        .snapshots()
        .listen((event) {
      List<DummyChatItemModel> _tempList = [];

      event.docs.forEach((doc) {
        Map<String, dynamic> a = doc.data();
        // print(a);

        String _company = a['company'] ?? '';
        List<MemberModel> _members = [];
        if (a['members'] != null) {
          a['members'].forEach((v) {
            _members.add(MemberModel.fromJson(v));
          });
        }

        String _content =
            a['lastMessage']['content'] ?? a['lastMessage']['name'] ?? '';
        Creator _creator = Creator.fromJson(a['lastMessage']['creator']);
        String _messageId = a['lastMessage']['_id'] ?? '';
        String _type = a['lastMessage']['type'] ?? '';
        _tempList.add(DummyChatItemModel(
            id: doc.id,
            company: _company,
            members: _members,
            lastMessage: MessageItemModel(
                content: _content,
                createdAt: '',
                creator: _creator,
                sId: _messageId,
                type: _type,
                updatedAt: '')));
      });
      isLoading = false;
      listRecentMessage = _tempList;
    }, onError: (e) {
      print(e);
      showAlert(message: e.toString());
    });
  }

  onSocketPostNew(data) {
    List<NotificationItemModel> _list = [];
    data.forEach((v) {
      if (v['_id'] != null) {
        _list.add(NotificationItemModel.fromJson(v));
      }
    });
    List<NotificationItemModel> _filterUserRead = _list.where((item) {
      String _userId = logedInUserId;
      List<String> checkIds = [_userId];
      List<Activities> filteredActivities = item.activities
          .where((activity) => !activity.readBy
              .any((element) => checkIds.contains(element.reader)))
          .toList();
      bool isSelfNotif = item.sender.sId == _userId;
      bool isRead = isSelfNotif ? true : filteredActivities.length <= 0;

      if (isRead) {
        return false;
      }
      return true;
    }).toList();

    listNotifChat = _filterUserRead;
  }

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();

    final userString = box.read(KeyStorage.logedInUser);

    MemberModel _templogedInUser = MemberModel.fromJson(userString);
    logedInUserId = _templogedInUser.sId;
  }

  @override
  void onClose() {
    // TODO: implement onClose
    super.onClose();

    if (_isStreamInit) {
      streamSub.cancel();
    }

    _socketNotificationChat.removeListenFromSocket();
  }
}

class DummyChatItemModel {
  late String id;
  late String company;
  late List<MemberModel> members;
  late MessageItemModel lastMessage;

  DummyChatItemModel(
      {required this.company,
      required this.id,
      this.members = const [],
      required this.lastMessage});

  DummyChatItemModel.fromJson(Map<String, dynamic> json) {
    company = json['company'];
    if (json['members'] != null) {
      members = <MemberModel>[];
      json['members'].forEach((v) {
        if (v is String) {
        } else {
          members.add(new MemberModel.fromJson(v));
        }
      });
    }
    lastMessage = MessageItemModel.fromJson(json['lastMessage']);
  }
}
