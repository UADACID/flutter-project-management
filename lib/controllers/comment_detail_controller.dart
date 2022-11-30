import 'package:cicle_mobile_f3/controllers/comment_controller.dart';
import 'package:cicle_mobile_f3/models/card_model.dart';
import 'package:cicle_mobile_f3/models/cheer_item_model.dart';
import 'package:cicle_mobile_f3/models/comment_item_model.dart';
import 'package:cicle_mobile_f3/models/member_model.dart';
import 'package:cicle_mobile_f3/service/cheers_service.dart';
import 'package:cicle_mobile_f3/service/comment_service.dart';
import 'package:cicle_mobile_f3/utils/constant.dart';
import 'package:cicle_mobile_f3/utils/helpers.dart';
import 'package:cicle_mobile_f3/utils/socket/socket_comment_detail.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class CommentDetailController extends GetxController {
  final box = GetStorage();

  CommentService _commentService = CommentService();
  CheersService _cheersService = CheersService();
  CommentController commentController = Get.find<CommentController>();

  String moduleName = Get.parameters['moduleName'] ?? '';
  String moduleId = Get.parameters['moduleId'] ?? '';
  String commentId = Get.parameters['commentId'] ?? '';
  String occurrenceId = Get.parameters['occurrenceId'] ?? '';
  String companyId = Get.parameters['companyId'] ?? '';
  SocketCommentDetail _socketCommentDetail = SocketCommentDetail();

  var _isLoading = false.obs;
  bool get isLoading => _isLoading.value;
  set isLoading(bool value) {
    _isLoading.value = value;
  }

  var _isLoadingTitle = true.obs;
  bool get isLoadingTitle => _isLoadingTitle.value;
  set isLoadingTitle(bool value) {
    _isLoadingTitle.value = value;
  }

  var _logedInUserId = ''.obs;
  String get logedInUserId => _logedInUserId.value;

  var _comment = CommentItemModel(creator: Creator(), sId: '').obs;
  CommentItemModel get comment => _comment.value;
  set comment(CommentItemModel value) {
    _comment.value = value;
  }

  var _teamMembers = <MemberModel>[].obs;
  List<MemberModel> get teamMembers => _teamMembers;
  set teamMembers(List<MemberModel> value) {
    _teamMembers.value = value;
  }

  var _teamId = ''.obs;
  String get teamId => _teamId.value;
  set teamId(String value) {
    _teamId.value = value;
  }

  var _teamName = ''.obs;
  String get teamName => _teamName.value;
  set teamName(String value) {
    _teamName.value = value;
  }

  var _parentTitle = ''.obs;
  String get parentTitle => _parentTitle.value;
  set parentTitle(String value) {
    _parentTitle.value = value;
  }

  String _getParentBaseUrl(key) {
    switch (key) {
      case 'questions':
      case 'check-ins':
        return '/api/v1/questions/$moduleId';
      case 'check-in':
        return '/api/v1/questions/$moduleId';
      case 'question':
        return '/api/v1/questions/$moduleId';
      case 'blasts':
        return '/api/v1/posts/$moduleId';
      case 'blast':
        return '/api/v1/posts/$moduleId';
      case 'posts':
        return '/api/v1/posts/$moduleId';
      case 'boards':
      case 'cards':
        return '/v2/cards/$moduleId';
      case 'card':
        return '/v2/cards/$moduleId';
      case 'docs':
        return '/api/v1/docs/$moduleId';
      case 'doc':
        return '/api/v1/docs/$moduleId';
      case 'files':
        return '/api/v1/files/$moduleId';
      case 'file':
        return '/api/v1/files/$moduleId';
      case 'event':
      case 'events':
        return '/v2/events/$moduleId';
      case 'schedules':
        return '/v2/events/$moduleId';
      case 'occurrence':
      case 'occurrences':
        String occurrenceId = Get.parameters['occurrenceId'] ?? '';
        return '/v2/events/$moduleId/occurrences/$occurrenceId';
      default:
        return '';
    }
  }

  String _getParentBaseUrlForCheers(key) {
    switch (key) {
      case 'check-ins':
      case 'questions':
        return '/api/v1/questions/$moduleId';
      case 'check-in':
        return '/api/v1/questions/$moduleId';
      case 'question':
        return '/api/v1/questions/$moduleId';
      case 'blasts':
        return '/api/v1/posts/$moduleId';
      case 'blast':
        return '/api/v1/posts/$moduleId';
      case 'posts':
        return '/api/v1/posts/$moduleId';
      case 'boards':
      case 'cards':
        return '/api/v1/cards/$moduleId';
      case 'card':
        return '/api/v1/cards/$moduleId';
      case 'docs':
        return '/api/v1/docs/$moduleId';
      case 'doc':
        return '/api/v1/docs/$moduleId';
      case 'files':
        return '/api/v1/files/$moduleId';
      case 'file':
        return '/api/v1/files/$moduleId';
      case 'event':
      case 'events':
        return '/api/v1/events/$moduleId';
      case 'schedules':
        return '/api/v1/events/$moduleId';
      case 'occurrence':
      case 'occurrences':
        String occurrenceId = Get.parameters['occurrenceId'] ?? '';
        return '/api/v1/events/$moduleId/occurrences/$occurrenceId';
      default:
        return '';
    }
  }

  String titleAdapter(key) {
    switch (key) {
      case 'check-ins':
      case 'questions':
      case 'check-in':
        return 'check-in';
      case 'question':
        return 'check-in';
      case 'blasts':
      case 'blast':
      case 'posts':
        return 'blast';
      case 'boards':
      case 'cards':
      case 'card':
        return 'board';
      case 'docs':
      case 'doc':
        return 'doc';
      case 'files':
      case 'file':
        return 'file';
      case 'event':
      case 'events':
      case 'schedules':
      case 'occurrence':
      case 'occurrences':
        return 'schedule';
      default:
        return 'overview';
    }
  }

  handlePressTitle() async {
    teamId = Get.parameters['teamId'] ?? '';
    Get.reset();
    await Future.delayed(Duration(milliseconds: 300));
    Get.offAllNamed(RouteName.dashboardScreen(companyId));
    await Future.delayed(Duration(milliseconds: 300));
    switch (moduleName) {
      case 'question':
      case 'questions':
      case 'check-ins':
      case 'check-in':
        Get.toNamed(
            '${RouteName.teamDetailScreen(companyId)}/$teamId?destinationIndex=6');
        await Future.delayed(Duration(milliseconds: 300));
        Get.toNamed(RouteName.checkInDetailScreen(companyId, teamId, moduleId));
        return;
      case 'blasts':
      case 'blast':
      case 'posts':
        Get.toNamed(
            '${RouteName.teamDetailScreen(companyId)}/$teamId?destinationIndex=1');
        await Future.delayed(Duration(milliseconds: 300));
        Get.toNamed(RouteName.blastDetailScreen(companyId, teamId, moduleId));
        return;
      case 'boards':
      case 'cards':
      case 'card':
        Get.toNamed(
            '${RouteName.teamDetailScreen(companyId)}/$teamId?destinationIndex=2');
        await Future.delayed(Duration(milliseconds: 300));
        Get.toNamed(RouteName.boardDetailScreen(companyId, teamId, moduleId));
        return;
      case 'docs':
      case 'doc':
        Get.toNamed(
            '${RouteName.teamDetailScreen(companyId)}/$teamId?destinationIndex=3');
        await Future.delayed(Duration(milliseconds: 300));
        Get.toNamed(RouteName.docDetailScreen(companyId, teamId, moduleId));
        return;
      case 'files':
      case 'file':
        Get.toNamed(
            '${RouteName.teamDetailScreen(companyId)}/$teamId?destinationIndex=3');
        await Future.delayed(Duration(milliseconds: 300));
        Get.toNamed(RouteName.fileDetailScreen(companyId, teamId, moduleId));
        return;
      case 'event':
      case 'events':
      case 'schedules':
        Get.toNamed(
            '${RouteName.teamDetailScreen(companyId)}/$teamId?destinationIndex=5');
        await Future.delayed(Duration(milliseconds: 300));
        Get.toNamed(
            RouteName.scheduleDetailScreen(companyId, teamId, moduleId));
        return;
      case 'occurrence':
      case 'occurrences':
        Get.toNamed(
            '${RouteName.teamDetailScreen(companyId)}/$teamId?destinationIndex=5');
        await Future.delayed(Duration(milliseconds: 300));
        Get.toNamed(RouteName.occurenceDetailScreen(
            companyId, teamId, moduleId, occurrenceId));
        return;
      default:
        Get.toNamed(
            '${RouteName.teamDetailScreen(companyId)}/$teamId?destinationIndex=0');
        return;
    }
  }

  handlePressSubtitle() async {
    teamId = Get.parameters['teamId'] ?? '';
    Get.reset();
    await Future.delayed(Duration(milliseconds: 300));
    Get.offAllNamed(RouteName.dashboardScreen(companyId));
    await Future.delayed(Duration(milliseconds: 300));
    switch (moduleName) {
      case 'check-ins':
      case 'question':
      case 'questions':
      case 'check-in':
        Get.toNamed(
            '${RouteName.teamDetailScreen(companyId)}/$teamId?destinationIndex=6');
        return;
      case 'blasts':
      case 'blast':
      case 'posts':
        Get.toNamed(
            '${RouteName.teamDetailScreen(companyId)}/$teamId?destinationIndex=1');
        return;
      case 'boards':
      case 'cards':
      case 'card':
        Get.toNamed(
            '${RouteName.teamDetailScreen(companyId)}/$teamId?destinationIndex=2');
        return;
      case 'docs':
      case 'doc':
        Get.toNamed(
            '${RouteName.teamDetailScreen(companyId)}/$teamId?destinationIndex=3');
        return;
      case 'files':
      case 'file':
        Get.toNamed(
            '${RouteName.teamDetailScreen(companyId)}/$teamId?destinationIndex=3');
        return;
      case 'event':
      case 'events':
      case 'schedules':
        Get.toNamed(
            '${RouteName.teamDetailScreen(companyId)}/$teamId?destinationIndex=5');
        return;
      case 'occurrence':
      case 'occurrences':
        Get.toNamed(
            '${RouteName.teamDetailScreen(companyId)}/$teamId?destinationIndex=5');
        return;
      default:
        Get.toNamed(
            '${RouteName.teamDetailScreen(companyId)}/$teamId?destinationIndex=0');
        return;
    }
  }

  var _cheersRx = <CheerItemModel>[].obs;
  List<CheerItemModel> get cheersRx => _cheersRx;
  set cheersRx(List<CheerItemModel> value) {
    _cheersRx.value = value;
  }

  var _showFormCheers = false.obs;
  bool get showFormCheers => _showFormCheers.value;
  set showFormCheers(bool value) {
    _showFormCheers.value = value;
  }

  Future<bool> addCheer(String cheerContent) async {
    try {
      dynamic body = {"content": cheerContent, "receiver": logedInUserId};
      String fullUrl =
          '${_getParentBaseUrlForCheers(moduleName)}/comments/$commentId/cheers';
      final response = await _cheersService.addCheerByModule(fullUrl, body);
      showAlert(message: response.data['message']);
      return Future.value(true);
    } catch (e) {
      print(e);
      errorMessageMiddleware(e);
      return Future.value(false);
    }
  }

  Future<bool> deleteCheer(CheerItemModel cheerItem) async {
    try {
      _cheersRx.removeWhere((element) => element.sId == cheerItem.sId);
      String fullUrl =
          '${_getParentBaseUrlForCheers(moduleName)}/comments/$commentId/cheers/${cheerItem.sId}';
      final response = await _cheersService.deleteCheerByModule(fullUrl);
      showAlert(message: response.data['message']);
      return Future.value(true);
    } catch (e) {
      print(e);
      _cheersRx.add(cheerItem);
      errorMessageMiddleware(e);
      return Future.value(false);
    }
  }

  Future<List<CommentItemModel>> getComment() async {
    try {
      final response = await _commentService.getComment(commentId, teamId);

      if (response.data['team'] != null) {
        teamName = response.data['team']['name'];
        teamId = response.data['team']['_id'];
      }
      if (response.data['comment'] != null) {
        comment = CommentItemModel.fromJson(response.data['comment']);
        List<CommentItemModel> _listComments = [];
        response.data['comment']['discussions'].forEach((v) {
          _listComments.add(CommentItemModel.fromJson(v));
        });

        if (response.data['comment']['cheers'] != null) {
          cheersRx = [];
          response.data['comment']['cheers'].forEach((o) {
            cheersRx.add(CheerItemModel.fromJson(o));
          });
        }

        return Future.value(_listComments);
      }

      return Future.value([]);
    } catch (e) {
      print(e);
      return Future.value([]);
    }
  }

  Future<List<MemberModel>> getTeamMembers() async {
    try {
      String? teamId = Get.parameters['teamId'] ?? '';
      final response = await _commentService.getTeamMembers(teamId);

      List<MemberModel> _listMember = [];

      if (response.data['members'] != null) {
        response.data['members'].forEach((v) {
          _listMember.add(MemberModel.fromJson(v));
        });
        teamMembers = _listMember;

        return Future.value(_listMember);
      }
      return Future.value([]);
    } catch (e) {
      return Future.value([]);
    }
  }

  parentDataResponseAdapter(dynamic data) {
    String title = '...';
    if (data['file'] != null) {
      title = data['file']['title'] ?? 'title file';
    }

    if (data['doc'] != null) {
      title = data['doc']['title'] ?? 'title doc';
    }

    if (data['card'] != null) {
      title = data['card']['name'] ?? 'title card';
    }

    if (data['post'] != null) {
      title = data['post']['title'] ?? 'title post';
    }

    if (data['question'] != null) {
      title = data['question']['title'] ?? 'title question';
    }

    if (data['event'] != null) {
      title = data['event']['title'] ?? 'title event';
    }

    if (data['occurrence'] != null) {
      title = data['occurrence']['title'] ?? 'title event';
    }

    parentTitle = title;
  }

  Future<bool> getParentData() async {
    String url = _getParentBaseUrl(moduleName);

    try {
      isLoadingTitle = true;
      final response = await _commentService.getParentData(url);

      if (response.data['currentTeam'] != null) {
        teamId = response.data['currentTeam']['_id'];
        teamName = response.data['currentTeam']['name'];
      }
      parentDataResponseAdapter(response.data);
      isLoadingTitle = false;
      return Future.value(true);
    } catch (e) {
      isLoadingTitle = false;
      errorMessageMiddleware(e);
      return Future.value(false);
    }
  }

  init() async {
    isLoading = true;
    List<MemberModel> _listMember = await getTeamMembers();

    await getParentData();
    await getComment();
    _cheersService.dynamicCompanyId = _commentService.dynamicCompanyId;

    isLoading = false;

    if (moduleName == 'occurrence') {
      String occurrenceId = Get.parameters['occurrenceId'] ?? '';

      commentController.setBaseUrlModule(
          'occurrenceCardDiscussion', occurrenceId);
    } else {
      commentController.setBaseUrlModule('cardDiscussion', '');
    }

    commentController.commentIdFromDetailCommentScreen = commentId;
    commentController.isForCommentDetailScreen = true;
    commentController.listMentionmembers = _listMember;
    commentController.getData();
  }

  callbackNewCheer(dynamic cheer) {
    CheerItemModel cheerItem = CheerItemModel.fromJson(cheer);
    if (cheerItem.primaryParent.id == commentId) {
      int index =
          cheersRx.indexWhere((element) => element.sId == cheerItem.sId);
      if (index < 0) {
        cheersRx.add(cheerItem);
      }
    } else {
      CommentItemModel _tempComment = comment;
      List<CheerItemModel> _cheers = _tempComment.cheers;
      _cheers.add(cheerItem);
      _tempComment.cheers = _cheers;

      _comment.value = _tempComment;
    }
  }

  callbackDeleteCheer(dynamic cheer) {
    CheerItemModel cheerItem = CheerItemModel.fromJson(cheer);
    if (cheerItem.primaryParent.id == commentId) {
      _cheersRx.removeWhere((element) => element.sId == cheerItem.sId);
    } else {
      CommentItemModel _tempComment = comment;
      List<CheerItemModel> _cheers = _tempComment.cheers;
      var deletedCheer = cheerItem;
      _cheers.removeWhere((element) => element.sId == deletedCheer.sId);
      _tempComment.cheers = _cheers;

      _comment.value = _tempComment;
    }
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

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    init();
    final userString = box.read(KeyStorage.logedInUser);
    MemberModel _templogedInUser = MemberModel.fromJson(userString);
    _logedInUserId.value = _templogedInUser.sId;
    _socketCommentDetail.init(commentId, logedInUserId);
    _socketCommentDetail.listener(
        callbackNewCheer,
        callbackDeleteCheer,
        callbackNewComment,
        callbackUpdateComment,
        callbackDeleteComment,
        callbackNewCheerComment,
        callbackDeleteCheerComment);
  }

  @override
  void onClose() {
    // TODO: implement onClose
    super.onClose();
    _socketCommentDetail.removeListenFromSocket();
  }
}
