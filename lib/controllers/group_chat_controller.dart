import 'package:cicle_mobile_f3/controllers/search_controller.dart';
import 'package:cicle_mobile_f3/models/member_model.dart';
import 'package:cicle_mobile_f3/service/group_chat_service.dart';
import 'package:cicle_mobile_f3/service/team_detail_service.dart';
import 'package:cicle_mobile_f3/utils/constant.dart';
import 'package:cicle_mobile_f3/utils/helpers.dart';
import 'package:cicle_mobile_f3/widgets/default_alert.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:easy_debounce/easy_debounce.dart';

import 'package:flutter/material.dart';

import 'package:get/get.dart';

import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:get_storage/get_storage.dart';
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';

class GroupChatController extends GetxController {
  TextEditingController textEditingControllerInput = TextEditingController();
  GroupChatService _groupChatService = GroupChatService();
  final box = GetStorage();
  TeamDetailService _teamDetailService = TeamDetailService();

  String groupChatId = Get.parameters['groupChatId'] ?? '';

  // mention
  var _showMentionBox = false.obs;
  bool get showMentionBox => _showMentionBox.value;
  set showMentionBox(bool value) {
    _showMentionBox.value = value;
  }

  var _logedInUserId = ''.obs;
  String get logedInUserId => _logedInUserId.value;
  set logedInUserId(String value) {
    _logedInUserId.value = value;
  }

  // text for text input
  var _text = ''.obs;
  String get text => _text.value;
  set text(String value) {
    _text.value = value;
  }

  var _projectId = ''.obs;
  String get projectId => _projectId.value;
  set projectId(String value) {
    _projectId.value = value;
  }

  var _projectName = ''.obs;
  String get projectName => _projectName.value;
  set projectName(String value) {
    _projectName.value = value;
  }

  var _limit = 2.obs;
  int get limit => _limit.value;
  set limit(int value) {
    _limit.value = limit + 5;
  }

  // focus text input
  var _hasFocus = false.obs;
  bool get hasFocus => _hasFocus.value;
  set hasFocus(bool value) {
    _hasFocus.value = value;
  }

  var _isLoading = false.obs;
  bool get isLoading => _isLoading.value;
  set isLoading(bool value) {
    _isLoading.value = value;
  }

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

  var _companyMembers = <MemberModel>[].obs;
  List<MemberModel> get companyMembers => _companyMembers;
  set companyMembers(List<MemberModel> value) {
    _companyMembers.value = [...value];
  }

  var _teamMembers = <MemberModel>[].obs;
  List<MemberModel> get teamMembers => _teamMembers;
  set teamMembers(List<MemberModel> value) {
    _teamMembers.value = [...value];
  }

  var _logedInUser = MemberModel().obs;
  MemberModel get logedInUser => _logedInUser.value;
  set logedInUser(MemberModel value) {
    _logedInUser.value = value;
  }

  List<String> toggleMembersTeamAdapter(
      List<MemberModel> membersFromListDialog) {
    List<MemberModel> _currentTeamMembers = [...teamMembers];
    List<String> listIdMembersFromListDialog =
        membersFromListDialog.map((e) => e.sId).toList();
    List<String> listIdCurrentTeamMembers =
        _currentTeamMembers.map((e) => e.sId).toList();
    List<String> result = [];
    listIdMembersFromListDialog.map((e) {
      if (listIdCurrentTeamMembers.contains(e)) {
      } else {
        result.add(e);
      }
    }).toList();
    listIdCurrentTeamMembers.map((e) {
      if (listIdMembersFromListDialog.contains(e)) {
      } else {
        result.add(e);
      }
    }).toList();
    result.remove(logedInUserId); // remove current user from toggle
    return result;
  }

  Future<void> addMembers(List<MemberModel> selectedMembersList) async {
    List<MemberModel> _oldListMember = [...teamMembers];
    List<String> _listIdMembers = toggleMembersTeamAdapter(selectedMembersList);
    List<MemberModel> filterCurrentUserLogedIn = selectedMembersList
        .where((element) => element.sId != logedInUserId)
        .toList();
    filterCurrentUserLogedIn.add(logedInUser);
    teamMembers = filterCurrentUserLogedIn;
    selectedMembersList.remove(logedInUserId);
    if (_listIdMembers.isEmpty) {
      return;
    }
    try {
      String teamId = Get.parameters['teamId']!;
      dynamic data = {"members": _listIdMembers};
      await _teamDetailService.addMembers(teamId, data);
    } catch (e) {
      print(e);
      teamMembers = _oldListMember;
      errorMessageMiddleware(e);
    }
  }

  Future<void> getMessages() async {
    try {
      isLoading = true;
      dynamic queryParams = {"limit": 1};
      final response =
          await _groupChatService.getMessages(groupChatId, queryParams);

      if (response.data['currentTeam']['members'] != null) {
        teamMembers = [];
        response.data['currentTeam']['members'].forEach((v) {
          teamMembers..add(MemberModel.fromJson(v));
        });
        teamMembers.sort((a, b) =>
            a.fullName.toLowerCase().compareTo(b.fullName.toLowerCase()));
        _teamMembers.value = [...teamMembers];
      }

      if (response.data['currentTeam']['name'] != null) {
        projectId = response.data['currentTeam']['_id'];
        projectName = response.data['currentTeam']['name'];
      }

      if (response.data['currentTeam']['members'] != null) {
        companyMembers = [];
        response.data['currentTeam']['members'].forEach((v) {
          _companyMembers.add(MemberModel.fromJson(v));
        });
      }

      isLoading = false;
    } catch (e) {
      print(e);
      isLoading = false;
      errorMessageMiddleware(e);
    }
  }

  void addMessage(types.Message message) async {
    _messages.insert(0, message);
    try {
      dynamic body = {
        "content": message.metadata!['text'],
        "mentionedUsers": message.metadata!['mentionedUsers']
      };
      final response = await _groupChatService.createMessage(groupChatId, body);
      print(response);
    } catch (e) {
      print(e);
      errorMessageMiddleware(e);
    }
  }

  void deleteMessage(String messageId) async {
    try {
      final response =
          await _groupChatService.deleteMessage(groupChatId, messageId);
      showAlert(message: response.data['message']);
    } catch (e) {
      errorMessageMiddleware(e);
    }
  }

  void deleteAttachment(String messageId) async {
    try {
      final response =
          await _groupChatService.deleteAttachment(groupChatId, messageId);
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
    Get.dialog(DefaultAlert(
        onSubmit: () {
          EasyDebounce.debounce(
              'submit-add-check-in', // <-- An ID for this particular debouncer
              Duration(milliseconds: 300), // <-- The debounce duration
              () {
            Get.back();
            cancelUploadFileToken
                .cancel('file upload has been canceled by user');
          } // <-- The target method
              );
        },
        onCancel: () {},
        title: 'are you sure you want to cancel upload ?'));
    // cancelUploadFileToken.cancel('file upload has been canceled by user');
  }

  void addAttachment(types.Message message) async {
    String mimeType = lookupMimeType(message.metadata!['text'])!;
    var splitMimeType = mimeType.split('/');
    try {
      showOverlay = true;
      uploadProgress = 0.0;
      dynamic body = {
        "uri": message.metadata!['path'],
        "name": message.metadata!['text'],
        "ext": MediaType(splitMimeType[0], splitMimeType[1])
      };
      await _groupChatService.addAttachment(
          groupChatId, body, setUploadProgress, getTokenCancelUpload);
      showOverlay = false;
      uploadProgress = 0.0;
    } catch (e) {
      print(e);
      showOverlay = false;
      uploadProgress = 0.0;
      errorMessageMiddleware(e);
    }
  }

  _createRecentlyViewed() {
    // create recently viewed

    String companyId = Get.parameters['companyId'] ?? '';
    String teamId = Get.parameters['teamId'] ?? '';
    String path =
        '${RouteName.teamDetailScreen(companyId)}/$teamId?destinationIndex=4';
    Get.put(SearchController()).insertListRecenlyViewed(RecentlyViewed(
        moduleName: 'group-chat',
        companyId: companyId,
        path: path,
        teamName: projectName,
        title: 'Group Chat',
        subtitle: 'Home  >  $projectName  >  Group Chat',
        uniqId: projectId + groupChatId));
  }

  init() async {
    await getMessages();
    _createRecentlyViewed();
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

  changeLimitMessage(int limitAsParams) async {
    try {
      isLoadingMore = true;
      FirebaseFirestore.instance
          .collection('groupChats')
          .doc(groupChatId)
          .collection("messages")
          .limit(limitAsParams)
          .orderBy('lastMessage.createdAt', descending: true)
          .snapshots()
          .listen((event) {
        List<types.Message> tempList = [];
        event.docs.forEach((doc) {
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
            String? mime = a['lastMessage']['mimeType'];
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
        showAlert(message: e.toString());
      });
    } catch (e) {
      showAlert(message: e.toString());
    }
  }

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    init();
    ever(_limit, changeLimitMessage);
    _limit.value = 10;
    final userString = box.read(KeyStorage.logedInUser);
    MemberModel _templogedInUser = MemberModel.fromJson(userString);
    logedInUserId = _templogedInUser.sId;
    logedInUser = _templogedInUser;
  }
}
