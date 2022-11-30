import 'package:cicle_mobile_f3/controllers/search_controller.dart';
import 'package:cicle_mobile_f3/models/card_model.dart';
import 'package:cicle_mobile_f3/models/cheer_item_model.dart';
import 'package:cicle_mobile_f3/models/companies_model.dart';
import 'package:cicle_mobile_f3/models/doc_file_item_model.dart';
import 'package:cicle_mobile_f3/models/member_model.dart';
import 'package:cicle_mobile_f3/service/cheers_service.dart';
import 'package:cicle_mobile_f3/service/doc_file_service.dart';
import 'package:cicle_mobile_f3/utils/constant.dart';
import 'package:cicle_mobile_f3/utils/helpers.dart';
import 'package:cicle_mobile_f3/utils/socket/socket_bucket.dart';

import 'package:cicle_mobile_f3/utils/socket/socket_doc_comment_cheer.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'comment_controller.dart';

class DocDetailController extends GetxController {
  String docId = Get.parameters['docId'] ?? '';

  final box = GetStorage();
  DocFileService _docFileService = DocFileService();
  CheersService _cheersService = CheersService();
  CommentController commentController = Get.find<CommentController>();
  SocketDocCommentCheer _socketDocCommentCheer = SocketDocCommentCheer();

  SocketBucket _socketBucket = SocketBucket();

  var _logedInUserId = ''.obs;
  String get logedInUserId => _logedInUserId.value;
  set logedInUserId(String value) {
    _logedInUserId.value = value;
  }

  var _errorMessage = ''.obs;
  String get errorMessage => _errorMessage.value;
  set errorMessage(String value) {
    _errorMessage.value = value;
  }

  var _bucketId = ''.obs;
  String get bucketId => _bucketId.value;
  set bucketId(String value) {
    _bucketId.value = value;
  }

  var _isLoading = false.obs;
  bool get isLoading => _isLoading.value;
  set isLoading(bool value) {
    _isLoading.value = value;
  }

  var _docDetail = DocFileItemModel().obs;
  DocFileItemModel get docDetail => _docDetail.value;
  set docDetail(DocFileItemModel value) {
    _docDetail.value = value;
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
      String url = '/api/v1/docs/$docId/cheers';
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
      String url = '/api/v1/docs/$docId/cheers/${cheerItem.sId}';
      final response = await _cheersService.deleteCheerByModule(url);
      showAlert(message: response.data['message']);
      return Future.value(true);
    } catch (e) {
      _cheers.add(cheerItem);
      errorMessageMiddleware(e);
      return Future.value(false);
    }
  }

  Future<void> archiveDoc() async {
    try {
      final response = await _docFileService.archiveDoc(docId);
      showAlert(message: response.data['message']);
      return Future.value();
    } catch (e) {
      print(e);
      errorMessageMiddleware(e);
      return Future.value();
    }
  }

  Future<bool> getDoc() async {
    try {
      final response = await _docFileService.getDoc(docId);

      if (response.data['doc'] != null) {
        docDetail = DocFileItemModel.fromJson(response.data['doc']);
      }
      if (response.data['doc']['subscribers'] != null) {
        members = [];
        response.data['doc']['subscribers'].forEach((v) {
          members.add(MemberModel.fromJson(v));
        });
      }

      if (response.data['currentTeam']['members'] != null) {
        teamMembers = [];
        response.data['currentTeam']['members'].forEach((v) {
          _teamMembers.add(MemberModel.fromJson(v));
        });
      }

      if (response.data['currentTeam'] != null) {
        currentTeam = Teams.fromJson(response.data['currentTeam']);
      }

      if (response.data['doc']['cheers'] != null) {
        cheers = [];
        response.data['doc']['cheers'].forEach((o) {
          _cheers.add(CheerItemModel.fromJson(o));
        });
      }

      if (response.data['bucket'] != null &&
          response.data['bucket']['_id'] != null) {
        bucketId = response.data['bucket']['_id'];
      }
      errorMessage = '';
      return Future.value(true);
    } catch (e) {
      print(e);
      String message = errorMessageMiddleware(e);
      errorMessage = message;
      return Future.value(false);
    }
  }

  Future<void> toggleMembers(List<MemberModel> selectedMembersList) async {
    try {
      List<String> _listIdMembers =
          toggleMembersAdapter(selectedMembersList, members);
      members = selectedMembersList;
      if (_listIdMembers.isEmpty) {
        return Future.value(false);
      }
      dynamic body = {"members": _listIdMembers};
      final response = await _docFileService.docToggleMembers(docId, body);

      showAlert(message: response.data['message']);
    } catch (e) {
      errorMessageMiddleware(e);
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

  _createRecentlyViewed() {
    // create recently viewed
    String path = currentRoute.value;
    String companyId = Get.parameters['companyId'] ?? '';

    Get.put(SearchController()).insertListRecenlyViewed(RecentlyViewed(
        moduleName: 'doc',
        companyId: companyId,
        path: path,
        teamName: currentTeam.name == '' ? ' ' : currentTeam.name,
        title: docDetail.title ?? '',
        subtitle:
            'Home  >  ${currentTeam.name}  >  Docs & Files  >  ${docDetail.title}',
        uniqId: docDetail.sId ?? ''));
  }

  init() async {
    isLoading = true;
    await getDoc();
    _cheersService.dynamicCompanyId = _docFileService.dynamicCompanyId;
    isLoading = false;
    _createRecentlyViewed();
    commentController.setBaseUrlModule('doc', docId);

    commentController.listMentionmembers = teamMembers;

    await commentController.getData();
  }

  _callBackUpdateDoc(dynamic value) {
    DocFileItemModel item = DocFileItemModel.fromJson(value);
    Creator currentCreator = docDetail.creator!;
    if (item.sId == docDetail.sId) {
      if (item.isPublic == false) {
        init();
      }
      docDetail = item;
      docDetail.creator = currentCreator;
    }
  }

  var currentRoute = ''.obs;

  @override
  void onInit() async {
    // TODO: implement onInit
    super.onInit();
    currentRoute.value = Get.currentRoute;
    final userString = box.read(KeyStorage.logedInUser);
    MemberModel _templogedInUser = MemberModel.fromJson(userString);
    _logedInUserId.value = _templogedInUser.sId;
    await init();

    _socketBucket.init(bucketId, logedInUserId);
    _socketBucket.listener(
        (p0) => null,
        (p0) => null,
        (p0) => null,
        (p0) => null,
        _callBackUpdateDoc,
        (p0) => null,
        (p0) => null,
        (p0) => null,
        (p0) => null);

    _socketDocCommentCheer.init(docId, logedInUserId);
    _socketDocCommentCheer.listener(
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
    _socketDocCommentCheer.removeListenFromSocket();
  }
}
