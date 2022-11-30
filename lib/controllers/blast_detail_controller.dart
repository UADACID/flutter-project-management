import 'package:cicle_mobile_f3/controllers/comment_controller.dart';
import 'package:cicle_mobile_f3/controllers/search_controller.dart';
import 'package:cicle_mobile_f3/models/card_model.dart';
import 'package:cicle_mobile_f3/models/cheer_item_model.dart';
import 'package:cicle_mobile_f3/models/companies_model.dart';
import 'package:cicle_mobile_f3/models/member_model.dart';
import 'package:cicle_mobile_f3/models/post_item_model.dart';
import 'package:cicle_mobile_f3/service/blast_service.dart';
import 'package:cicle_mobile_f3/service/cheers_service.dart';
import 'package:cicle_mobile_f3/utils/constant.dart';
import 'package:cicle_mobile_f3/utils/helpers.dart';
import 'package:cicle_mobile_f3/utils/socket/socket_blast.dart';
import 'package:cicle_mobile_f3/utils/socket/socket_post_comment_cheer.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class BlastDetailController extends GetxController {
  BlastService _blastService = BlastService();
  CheersService _cheersService = CheersService();
  final box = GetStorage();
  String postId = Get.parameters['blastId'] ?? 'unknown';
  CommentController commentController = Get.find<CommentController>();

  SocketBlast _socketBlast = SocketBlast();
  SocketPostCommentCheer _socketPostCommentCheer = SocketPostCommentCheer();

  String currentBlastId = '';

  var _blastId = ''.obs;
  String get blastId => _blastId.value;
  set blastId(String value) {
    _blastId.value = value;
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

  var _isLoading = false.obs;
  bool get isLoading => _isLoading.value;
  set isLoading(bool value) {
    _isLoading.value = value;
  }

  var _post = PostItemModel(
          content: '',
          creator: Creator(),
          sId: '',
          title: '',
          archived: Archived())
      .obs;
  PostItemModel get post => _post.value;
  set post(PostItemModel value) {
    _post.value = value;

    List<MemberModel> _tempMembers = [];
    value.subscribers.forEach((element) {
      _tempMembers.add(element);
    });
    _members.value = _tempMembers;
  }

  var _isComplete = false.obs;
  bool get isComplete => _isComplete.value;
  set isComplete(bool value) {
    _isComplete.value = value;
  }

  var _dueDate = ''.obs;
  String get dueDate => _dueDate.value;
  set dueDate(String value) {
    _dueDate.value = value;
  }

  var _members = <MemberModel>[].obs;
  List<MemberModel> get members => _members;
  set members(List<MemberModel> value) {
    _members.value = [...value];
  }

  var _teamMembers = <MemberModel>[].obs;
  List<MemberModel> get teamMembers => _teamMembers;
  set teamMembers(List<MemberModel> value) {
    _teamMembers.value = [...value];
  }

  var _currentTeam = Teams(sId: '', archived: Archived()).obs;
  Teams get currentTeam => _currentTeam.value;
  set currentTeam(Teams value) {
    _currentTeam.value = value;
  }

  var _cheers = <CheerItemModel>[].obs;
  List<CheerItemModel> get cheers => _cheers;
  set cheers(List<CheerItemModel> value) {
    _cheers.value = value;
  }

  var _showFormCheers = false.obs;
  bool get showFormCheers => _showFormCheers.value;
  set showFormCheers(bool value) {
    _showFormCheers.value = value;
  }

  Future<bool> addCheer(String cheerContent) async {
    try {
      dynamic body = {"content": cheerContent, "receiver": logedInUserId};
      String url = '/api/v1/posts/$postId/cheers';
      final response = await _cheersService.addCheerByModule(url, body);
      showAlert(message: response.data['message']);
      return Future.value(true);
    } catch (e) {
      errorMessageMiddleware(e);
      return Future.value(false);
    }
  }

  Future<bool> deleteCheer(CheerItemModel cheerItem) async {
    try {
      _cheers.removeWhere((element) => element.sId == cheerItem.sId);
      String url = '/api/v1/posts/$postId/cheers/${cheerItem.sId}';
      final response = await _cheersService.deleteCheerByModule(url);
      showAlert(message: response.data['message']);
      return Future.value(true);
    } catch (e) {
      _cheers.add(cheerItem);
      errorMessageMiddleware(e);
      return Future.value(false);
    }
  }

  Future<PostItemModel> archivePost(String postId) async {
    final response = await _blastService.archivePost(postId);

    PostItemModel _post = PostItemModel.fromJson(response.data['post']);
    return Future.value(_post);
  }

  List<String> toggleMembersAdapter(List<MemberModel> membersFromListDialog) {
    List<MemberModel> _currentModuleMembers = [...members];
    List<String> listIdMembersFromListDialog =
        membersFromListDialog.map((e) => e.sId).toList();
    List<String> listIdCurrentTeamMembers =
        _currentModuleMembers.map((e) => e.sId).toList();
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
    return result.toSet().toList();
  }

  Future<void> toggleMembers(List<MemberModel> selectedMembersList) async {
    try {
      List<String> _listIdMembers = toggleMembersAdapter(selectedMembersList);
      members = selectedMembersList;
      if (_listIdMembers.isEmpty) {
        return Future.value(false);
      }
      dynamic body = {"members": _listIdMembers};

      final response = await _blastService.toggleMembers(postId, body);

      showAlert(message: response.data['message']);
    } catch (e) {
      print(e);
      errorMessageMiddleware(e);
    }
  }

  Future<void> updateCompleteStatus(bool value) async {
    try {
      dynamic body = {"isComplete": value};

      final response = await _blastService.updateCompleteStatus(postId, body);

      showAlert(message: response.data['message']);
    } catch (e) {
      print(e);
      errorMessageMiddleware(e);
    }
  }

  Future<PostItemModel> getPost() async {
    try {
      final response = await _blastService.getPost(postId);

      teamMembers = [];
      if (response.data['currentTeam'] != null) {
        currentTeam = Teams.fromJson(response.data['currentTeam']);
      }
      if (response.data['post']['complete']['status'] != null) {
        isComplete = response.data['post']['complete']['status'];
      }
      if (response.data['post']['dueDate'] != null) {
        dueDate = response.data['post']['dueDate'];
      }
      if (response.data['currentTeam']['members'] != null) {
        response.data['currentTeam']['members'].forEach((v) {
          _teamMembers.add(MemberModel.fromJson(v));
        });
      }

      if (response.data['blast']['_id'] != null) {
        blastId = response.data['blast']['_id'];
      }

      if (response.data['post']['cheers'] != null) {
        cheers = [];
        response.data['post']['cheers'].forEach((o) {
          _cheers.add(CheerItemModel.fromJson(o));
        });
      }
      errorMessage = '';
      return Future.value(PostItemModel.fromJson(response.data['post']));
    } catch (e) {
      print(e);
      isLoading = false;
      if (e is DioError) {
        String message = e.response!.data['message'] ??
            e.response?.statusMessage ??
            e.message;
        errorMessage = message;
        showAlert(message: message, messageColor: Colors.red);
      } else {
        errorMessage = 'Internal Server Error';
      }

      return Future.error(e);
    }
  }

  _createRecentlyViewed() {
    // create recently viewed
    String path = currentRoute.value;
    String companyId = Get.parameters['companyId'] ?? '';
    Get.put(SearchController()).insertListRecenlyViewed(RecentlyViewed(
        moduleName: 'post',
        companyId: companyId,
        path: path,
        teamName: currentTeam.name == '' ? ' ' : currentTeam.name,
        title: post.title,
        subtitle: 'Home  >  ${currentTeam.name}  >  Blast  >  ${post.title}',
        uniqId: post.sId));
  }

  init() async {
    isLoading = true;
    try {
      await Future.delayed(Duration(seconds: 2));
      PostItemModel _postItem = await getPost();
      post = _postItem;

      _cheersService.dynamicCompanyId = _blastService.dynamicCompanyId;
      commentController.setBaseUrlModule('blast', postId);

      commentController.listMentionmembers = teamMembers;

      await commentController.getData();
      _createRecentlyViewed();

      isLoading = false;
    } catch (e) {
      isLoading = false;
      errorMessage = errorMessageMiddleware(e);
    }
  }

  onSocketPostUpdate(data) {
    PostItemModel postData = PostItemModel.fromJson(data);
    var checkIsCurrentUserLogedInIsMember = postData.subscribers
        .where((element) => element.sId == logedInUserId)
        .toList();

    if (postData.isPublic == false &&
        post.isPublic == false &&
        checkIsCurrentUserLogedInIsMember.isEmpty) {
      init();
    }
    if (postId == postData.sId) {
      post = postData;
      if (data['complete']['status'] != null) {
        isComplete = data['complete']['status'];
      }
    }
  }

  onSocketPostArchive(data) {
    PostItemModel postData = PostItemModel.fromJson(data);
    if (postId == postData.sId) {
      post = postData;
    }
  }

  callbackNewCheer(dynamic jsonCheer) {
    CheerItemModel cheerItem = CheerItemModel.fromJson(jsonCheer);

    int index = cheers.indexWhere((element) => element.sId == cheerItem.sId);
    if (index < 0) {
      _cheers.add(cheerItem);
    }
  }

  callbackDeleteCheer(dynamic jsonCheer) {
    CheerItemModel cheerItem = CheerItemModel.fromJson(jsonCheer);

    _cheers.removeWhere((element) => element.sId == cheerItem.sId);
  }

  callbackNewComment(dynamic comment) {
    commentController.callBackAddComment(comment);
  }

  callbackUpdateComment(dynamic comment) {
    commentController.callBackEditComment(comment);
  }

  callbackDeleteComment(dynamic comment) {
    commentController.callBackRemoveComment(comment);
  }

  callbackNewCheerComment(dynamic cheer) {
    commentController.callBackNewCheer(cheer);
  }

  callbackDeleteCheerComment(dynamic cheer) {
    commentController.callBackDeleteCheer(cheer);
  }

  callbackNewDiscussion(dynamic payload) {
    commentController.callBackNewDiscussion(payload);
  }

  callbackDeleteDiscussion(dynamic payload) {
    commentController.callBackDeleteDiscussion(payload);
  }

  var currentRoute = ''.obs;

  @override
  void onInit() async {
    // TODO: implement onInit
    super.onInit();
    currentRoute.value = Get.currentRoute;
    await init();
    final userString = box.read(KeyStorage.logedInUser);
    MemberModel _templogedInUser = MemberModel.fromJson(userString);
    _logedInUserId.value = _templogedInUser.sId;
    _socketBlast.init(blastId, logedInUserId);
    _socketBlast.listener(onSocketPostUpdate, onSocketPostArchive);
    _socketPostCommentCheer.init(postId, logedInUserId);
    _socketPostCommentCheer.listener(
        callbackNewCheer,
        callbackDeleteCheer,
        callbackNewComment,
        callbackUpdateComment,
        callbackDeleteComment,
        callbackNewCheerComment,
        callbackDeleteCheerComment,
        callbackNewDiscussion,
        callbackDeleteDiscussion);
  }

  @override
  void onClose() {
    // TODO: implement onClose
    super.onClose();
    _socketBlast.removeListenFromSocket(blastId);
    _socketPostCommentCheer.removeListenFromSocket();
  }
}
