import 'package:cicle_mobile_f3/controllers/comment_controller.dart';
import 'package:cicle_mobile_f3/controllers/search_controller.dart';
import 'package:cicle_mobile_f3/models/card_model.dart';
import 'package:cicle_mobile_f3/models/companies_model.dart';

import 'package:cicle_mobile_f3/models/member_model.dart';
import 'package:cicle_mobile_f3/models/questionItemModel.dart';
import 'package:cicle_mobile_f3/service/check_in_service.dart';
import 'package:cicle_mobile_f3/utils/helpers.dart';
import 'package:cicle_mobile_f3/utils/socket/scoket_check_in.dart';
import 'package:cicle_mobile_f3/utils/socket/socket_question_comment_cheer.dart';
import 'package:get/get.dart';

class CheckInDetailController extends GetxController {
  CommentController commentController = Get.find<CommentController>();

  CheckInService _checkInService = CheckInService();

  SocketCheckIn _socketCheckIn = SocketCheckIn();
  SocketQuestionCommentCheer _socketQuestionCommentCheer =
      SocketQuestionCommentCheer();

  String questionId = Get.parameters['checkInId'] ?? '';

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

  var _checkInId = ''.obs;
  String get checkInId => _checkInId.value;
  set checkInId(String value) {
    _checkInId.value = value;
  }

  var _currentTeam = Teams(sId: '', archived: Archived()).obs;
  Teams get currentTeam => _currentTeam.value;
  set currentTeam(Teams value) {
    _currentTeam.value = value;
  }

  var _questionDetail = QuestionItemModel(
          creator: Creator(),
          sId: '',
          archived: Archived(),
          schedule: Schedule())
      .obs;
  QuestionItemModel get questionDetail => _questionDetail.value;
  set questionDetail(QuestionItemModel value) {
    _questionDetail.value = value;
  }

  var _teamMembers = <MemberModel>[].obs;

  List<MemberModel> get teamMembers => _teamMembers;
  set teamMembers(List<MemberModel> value) {
    _teamMembers.value = [...value];
  }

  Future<void> archiveQuestion() async {
    try {
      await _checkInService.archiveQuestion(questionId);
    } catch (e) {
      print(e);
      errorMessageMiddleware(e);
    }
  }

  Future<bool> getQuestion() async {
    try {
      final response = await _checkInService.getQuestion(questionId);

      if (response.data['question'] != null) {
        questionDetail = QuestionItemModel.fromJson(response.data['question']);
      }

      if (response.data['currentTeam'] != null) {
        currentTeam = Teams.fromJson(response.data['currentTeam']);
      }
      if (response.data['currentTeam']['checkIn']['_id'] != null) {
        checkInId = response.data['currentTeam']['checkIn']['_id'];
      }
      if (response.data['currentTeam']['members'] != null) {
        teamMembers = [];
        response.data['currentTeam']['members'].forEach((v) {
          _teamMembers.add(MemberModel.fromJson(v));
        });
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

  onSocketPostUpdate(data) {
    QuestionItemModel item = QuestionItemModel.fromJson(data);
    if (item.isPublic == false) {
      init();
    }
    questionDetail = item;
  }

  onSocketPostArchive(data) {
    questionDetail = QuestionItemModel.fromJson(data);
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
        moduleName: 'question',
        companyId: companyId,
        path: path,
        teamName: currentTeam.name == '' ? ' ' : currentTeam.name,
        title: questionDetail.title,
        subtitle:
            'Home  >  ${currentTeam.name}  >  Check-Ins  >  ${questionDetail.title}',
        uniqId: questionDetail.sId));
  }

  init() async {
    isLoading = true;
    await getQuestion();
    isLoading = false;
    commentController.setBaseUrlModule('question', questionId);
    commentController.listMentionmembers = teamMembers;

    await commentController.getData();
    _createRecentlyViewed();
  }

  var currentRoute = ''.obs;

  @override
  void onInit() async {
    // TODO: implement onInit
    super.onInit();
    currentRoute.value = Get.currentRoute;
    await init();

    _socketCheckIn.init(checkInId, logedInUserId);
    _socketCheckIn.listener(
        (data) => null, onSocketPostUpdate, onSocketPostArchive);

    _socketQuestionCommentCheer.init(questionId, logedInUserId);
    _socketQuestionCommentCheer.listener(
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
    _socketQuestionCommentCheer.removeListenFromSocket();
  }
}
