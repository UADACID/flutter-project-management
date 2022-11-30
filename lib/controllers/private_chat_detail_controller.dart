import 'dart:async';

import 'package:cicle_mobile_f3/controllers/company_controller.dart';
import 'package:cicle_mobile_f3/models/member_model.dart';
import 'package:cicle_mobile_f3/service/private_chat_service.dart';
import 'package:cicle_mobile_f3/utils/constant.dart';
import 'package:cicle_mobile_f3/utils/helpers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';

import 'search_controller.dart';

class PrivateChatDetailController extends GetxController {
  final box = GetStorage();

  TextEditingController textEditingControllerInput = TextEditingController();
  PrivateChatService _privateChatService = PrivateChatService();

  String chatId = Get.parameters['chatId'] ?? '';

  // text for text input
  var _text = ''.obs;
  String get text => _text.value;
  set text(String value) {
    _text.value = value;
  }

  var _companyName = ''.obs;
  String get companyName => _companyName.value;
  set companyName(String value) {
    _companyName.value = value;
  }

  // focus text input
  var _hasFocus = false.obs;
  bool get hasFocus => _hasFocus.value;
  set hasFocus(bool value) {
    _hasFocus.value = value;
  }

  var _errorMessage = ''.obs;
  String get errorMessage => _errorMessage.value;
  set errorMessage(String value) {
    _errorMessage.value = value;
  }

  var _logedInUserId = ''.obs;
  String get logedInUserId => _logedInUserId.value;
  set logedInUserId(String value) {
    _logedInUserId.value = value;
  }

  var _limit = 2.obs;
  int get limit => _limit.value;
  set limit(int value) {
    _limit.value = limit + 5;
  }

  var _isLoading = false.obs;
  bool get isLoading => _isLoading.value;

  var _isLoadingMore = false.obs;
  bool get isLoadingMore => _isLoadingMore.value;
  set isLoadingMore(bool value) {
    _isLoadingMore.value = value;
  }

  var _messages = <types.Message>[].obs;

  List<types.Message> get messages => _messages;

  insertMessage(types.Message value) {
    _messages.add(value);
  }

  var _title = ''.obs;
  String get title => _title.value;
  set title(String value) {
    _title.value = value;
  }

  var _teamMembers = <MemberModel>[].obs;
  List<MemberModel> get members => _teamMembers;
  set members(List<MemberModel> value) {
    _teamMembers.value = [...value];
  }

  var _lastMessageId = ''.obs;
  String get lastMessageId => _lastMessageId.value;
  set lastMessageId(String value) {
    _lastMessageId.value = value;
  }

  var _canLoadMore = true.obs;
  bool get canLoadMore => _canLoadMore.value;
  set canLoadMore(bool value) {
    _canLoadMore.value = value;
  }

  // mention
  var _showMentionBox = false.obs;
  bool get showMentionBox => _showMentionBox.value;
  set showMentionBox(bool value) {
    _showMentionBox.value = value;
  }

  void addMessage(types.Message message) async {
    _messages.insert(0, message);
    try {
      dynamic body = {
        "content": message.metadata!['text'],
        "mentionedUsers": message.metadata!['mentionedUsers']
      };
      await _privateChatService.createMessage(chatId, body);
    } catch (e) {
      print(e);
      errorMessageMiddleware(e);
    }
  }

  void deleteMessage(String messageId) async {
    try {
      final response =
          await _privateChatService.deleteMessage(chatId, messageId);
      showAlert(message: response.data['message']);
    } catch (e) {
      errorMessageMiddleware(e);
    }
  }

  void deleteAttachment(String messageId) async {
    try {
      final response =
          await _privateChatService.deleteAttachment(chatId, messageId);
      showAlert(message: response.data['message']);
    } catch (e) {
      errorMessageMiddleware(e);
    }
  }

  var _uploadProgress = 0.0.obs;
  double get uploadProgress => _uploadProgress.value;
  set uploadProgress(double value) {
    _uploadProgress.value = value;
  }

  var _showOverlay = false.obs;
  bool get showOverlay => _showOverlay.value;
  set showOverlay(bool value) {
    _showOverlay.value = value;
  }

  var _cancelUploadFileToken = CancelToken().obs;
  CancelToken get cancelUploadFileToken => _cancelUploadFileToken.value;
  set cancelUploadFileToken(CancelToken value) {
    _cancelUploadFileToken.value = value;
  }

  setUploadProgress(double value) {
    uploadProgress = value;
  }

  getTokenCancelUpload(CancelToken token) {
    cancelUploadFileToken = token;
  }

  cancelUploadFile() {
    cancelUploadFileToken.cancel('file upload has been canceled by user');
  }

  void addAttachment(types.Message message) async {
    try {
      String? mimeType = lookupMimeType(message.metadata!['text']);

      if (mimeType == null) {
        showAlert(
            message: 'file must be have exstention', messageColor: Colors.red);
        return;
      }
      var splitMimeType = mimeType.split('/');

      showOverlay = true;
      uploadProgress = 0.0;
      dynamic body = {
        "uri": message.metadata!['path'],
        "name": message.metadata!['text'],
        "ext": MediaType(splitMimeType[0], splitMimeType[1])
      };
      await _privateChatService.addAttachment(
          chatId, body, setUploadProgress, getTokenCancelUpload);
      showOverlay = false;
      uploadProgress = 0.0;
    } catch (e) {
      print(e);
      showOverlay = false;
      uploadProgress = 0.0;
      errorMessageMiddleware(e);
    }
  }

  late StreamSubscription<QuerySnapshot> streamSub;

  changeLimitMessage(int limitAsParams) async {
    isLoadingMore = true;
    streamSub = FirebaseFirestore.instance
        .collection('chats')
        .doc(chatId)
        .collection("messages")
        .limit(limitAsParams)
        .orderBy('lastMessage.createdAt', descending: true)
        .snapshots()
        .listen((event) {
      List<types.Message> tempList = [];
      event.docs.forEach((doc) {
        try {
          Map<String, dynamic> a = doc.data();

          var x = {
            "author": {
              "firstName": a['lastMessage']['creator']['fullName'],
              "id": a['lastMessage']['creator']['_id'],
              "imageUrl":
                  getPhotoUrl(url: a['lastMessage']['creator']['photoUrl'])
            },
            "createdAt": a['lastMessage']['createdAt'],
            "id": a['lastMessage']['_id'],
            "status": "seen",
            "text": 'content',
            "type": "custom"
          };
          Map _tempObj = {...x};

          if (a['lastMessage']['type'] == 'attachment') {
            String? mime = a['lastMessage']['mimeType'] ?? '';
            if (mime == null) {
              _tempObj['type'] = 'custom';
              _tempObj['metadata'] = {
                "text": a['lastMessage']['name'],
              };
            } else if (mime.contains('image')) {
              _tempObj['type'] = 'custom';
              _tempObj['metadata'] = {
                "text": a['lastMessage']['name'],
                "size": 0,
                "path": getPhotoUrl(url: a['lastMessage']['url']),
                "width": 0,
                "height": 0,
                "type": "image"
              };
            } else if (mime == '') {
              _tempObj['type'] = 'custom';
              _tempObj['metadata'] = {
                "text": a['lastMessage']['name'],
              };
            } else {
              _tempObj['type'] = 'custom';
              _tempObj['metadata'] = {
                "text": a['lastMessage']['name'],
                'extension': mime,
                'size': 0,
                'path': a['lastMessage']['url'],
                'type': 'file'
              };
            }
          } else {
            _tempObj['type'] = 'custom';
            _tempObj['metadata'] = {"text": a['lastMessage']['content']};
          }
          var b = types.Message.fromJson(Map.from(_tempObj));

          tempList.add(b);
        } catch (e) {
          print(e);
        }
      });
      isLoadingMore = false;

      if (tempList.isNotEmpty) {
        String lastId = tempList.last.id;
        if (lastId != lastMessageId) {
          lastMessageId = lastId;
          canLoadMore = true;
          print('bisa load more');
        } else {
          canLoadMore = false;
        }
      } else {
        canLoadMore = false;
      }

      _messages.value = tempList;
    }, onError: (e) {
      print(e);
    });
  }

  Future<void> getMessages() async {
    try {
      dynamic queryParams = {"limit": 1};
      final response =
          await _privateChatService.getMessage(chatId, queryParams);

      errorMessage = '';
      if (response.data['members'] != null) {
        members = [];
        CompanyController _companyController = Get.find();
        companyName = response.data['currentCompany']['name'] ?? '';

        List<MemberModel> _tempMembers = [];
        response.data['members'].forEach((v) {
          _tempMembers.add(MemberModel.fromJson(v));
        });

        MemberModel targetChatMember =
            _tempMembers.firstWhere((element) => element.sId != logedInUserId);

        List<MemberModel> filterByUserId = [
          ..._companyController.companyMembers
        ].where((element) => element.sId == targetChatMember.sId).toList();
        bool isTargetMemberOnThisCompany =
            filterByUserId.isEmpty ? false : true;

        if (isTargetMemberOnThisCompany) {
          title = targetChatMember.fullName;
          members = [targetChatMember];
        } else {
          title = targetChatMember.fullName;
          errorMessage = 'user is not a member of this company';
          showAlert(message: errorMessage, messageColor: Colors.red);
        }
      }
    } catch (e) {
      print(e);

      errorMessage = errorMessageMiddleware(e);
    }
  }

  _createRecentlyViewed() {
    // create recently viewed
    String path = currentRoute.value;
    String companyId = Get.parameters['companyId'] ?? '';

    Get.put(SearchController()).insertListRecenlyViewed(RecentlyViewed(
        moduleName: 'private-chat-detail',
        companyId: companyId,
        path: path,
        teamName: ' ',
        title: title,
        subtitle: 'Home  >  Menu  >  Inbox  >  $title',
        uniqId: chatId));
  }

  init() async {
    await getMessages();
    _createRecentlyViewed();
  }

  var currentRoute = ''.obs;

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    currentRoute.value = Get.currentRoute;
    init();
    ever(_limit, changeLimitMessage);
    _limit.value = 10;
    final userString = box.read(KeyStorage.logedInUser);
    MemberModel _templogedInUser = MemberModel.fromJson(userString);
    logedInUserId = _templogedInUser.sId;
  }

  @override
  void onClose() {
    // TODO: implement onClose
    super.onClose();
    streamSub.cancel();
  }
}
