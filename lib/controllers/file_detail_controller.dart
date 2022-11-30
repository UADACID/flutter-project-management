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
import 'package:cicle_mobile_f3/utils/socket/socket_file_comment_cheer.dart';

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'comment_controller.dart';

class FileDetailController extends GetxController {
  String fileId = Get.parameters['fileId'] ?? '';

  final box = GetStorage();
  DocFileService _docFileService = DocFileService();
  CheersService _cheersService = CheersService();
  CommentController commentController = Get.find<CommentController>();
  SocketFileCommentCheer _socketFileCommentCheer = SocketFileCommentCheer();
  SocketBucket _socketBucket = SocketBucket();

  var _bucketId = ''.obs;
  String get bucketId => _bucketId.value;
  set bucketId(String value) {
    _bucketId.value = value;
  }

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

  var _isLoading = false.obs;
  bool get isLoading => _isLoading.value;
  set isLoading(bool value) {
    _isLoading.value = value;
  }

  var _isOverflowLoading = false.obs;
  bool get isOverflowLoading => _isOverflowLoading.value;
  set isOverflowLoading(bool value) {
    _isOverflowLoading.value = value;
  }

  var _isPrivate = false.obs;
  bool get isPrivate => _isPrivate.value;
  set isPrivate(bool value) {
    _isPrivate.value = value;
  }

  var _fileDetail = DocFileItemModel().obs;
  DocFileItemModel get fileDetail => _fileDetail.value;
  set fileDetail(DocFileItemModel value) {
    _fileDetail.value = value;
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
      String url = '/api/v1/files/$fileId/cheers';
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
      String url = '/api/v1/files/$fileId/cheers/${cheerItem.sId}';
      final response = await _cheersService.deleteCheerByModule(url);
      showAlert(message: response.data['message']);
      return Future.value(true);
    } catch (e) {
      _cheers.add(cheerItem);
      errorMessageMiddleware(e);
      return Future.value(false);
    }
  }

  Future<bool> getFile() async {
    try {
      final response = await _docFileService.getFile(fileId);

      if (response.data['file'] != null) {
        fileDetail = DocFileItemModel.fromJson(response.data['file']);
      }
      if (response.data['file']['subscribers'] != null) {
        members = [];
        response.data['file']['subscribers'].forEach((v) {
          members.add(MemberModel.fromJson(v));
        });
      }

      isPrivate = response.data['file']['isPublic'] != null
          ? !response.data['file']['isPublic']
          : false;

      if (response.data['currentTeam']['members'] != null) {
        teamMembers = [];
        response.data['currentTeam']['members'].forEach((v) {
          _teamMembers.add(MemberModel.fromJson(v));
        });
      }

      if (response.data['currentTeam'] != null) {
        currentTeam = Teams.fromJson(response.data['currentTeam']);
      }

      if (response.data['file']['cheers'] != null) {
        cheers = [];
        response.data['file']['cheers'].forEach((o) {
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

  Future<void> archiveFile() async {
    try {
      await _docFileService.archiveFile(fileId);
      showAlert(message: 'Succesfuly archive this file');
      return Future.value();
    } catch (e) {
      print(e);
      errorMessageMiddleware(e);
      return Future.value();
    }
  }

  Future<void> updatePrivateStatus() async {
    try {
      isOverflowLoading = true;
      dynamic body = {
        "subscribers": ["6017a93b8d09e8bdeb6ef612"],
        "isPublic": !isPrivate
      };
      final response = await _docFileService.updateFile(fileId, body);

      showAlert(message: response.data['message']);
      isOverflowLoading = false;

      return Future.value();
    } catch (e) {
      print(e);
      isOverflowLoading = false;
      errorMessageMiddleware(e);
      return Future.value();
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
      final response = await _docFileService.fileToggleMembers(fileId, body);

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
        moduleName: 'file',
        companyId: companyId,
        path: path,
        teamName: currentTeam.name == '' ? ' ' : currentTeam.name,
        title: fileDetail.title ?? '',
        subtitle:
            'Home  >  ${currentTeam.name}  >  Docs & Files  >  ${fileDetail.title}',
        uniqId: fileDetail.sId ?? ''));
  }

  init() async {
    isLoading = true;
    await getFile();
    _cheersService.dynamicCompanyId = _docFileService.dynamicCompanyId;
    isLoading = false;

    commentController.setBaseUrlModule('file', fileId);

    commentController.listMentionmembers = teamMembers;

    await commentController.getData();
    _createRecentlyViewed();
  }

  _callBackUpdateFile(dynamic value) {
    DocFileItemModel item = DocFileItemModel.fromJson(value);
    Creator currentCreator = fileDetail.creator!;
    if (item.sId == fileDetail.sId) {
      if (item.isPublic == false) {
        init();
      }
      fileDetail = item;
      fileDetail.creator = currentCreator;
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
        (p0) => null,
        (p0) => null,
        (p0) => null,
        _callBackUpdateFile,
        (p0) => null);
    _socketFileCommentCheer.init(fileId, logedInUserId);
    _socketFileCommentCheer.listener(
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
    _socketFileCommentCheer.removeListenFromSocket();
  }
}
