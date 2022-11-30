import 'package:cicle_mobile_f3/controllers/search_controller.dart';
import 'package:cicle_mobile_f3/models/card_model.dart';
import 'package:cicle_mobile_f3/models/cheer_item_model.dart';
import 'package:cicle_mobile_f3/models/companies_model.dart';
import 'package:cicle_mobile_f3/models/event_item_model.dart';
import 'package:cicle_mobile_f3/models/member_model.dart';
import 'package:cicle_mobile_f3/service/cheers_service.dart';
import 'package:cicle_mobile_f3/service/schedule_service.dart';
import 'package:cicle_mobile_f3/utils/constant.dart';
import 'package:cicle_mobile_f3/utils/helpers.dart';
import 'package:cicle_mobile_f3/utils/socket/socket_event_comment_cheer.dart';
import 'package:cicle_mobile_f3/utils/socket/socket_schedule.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'comment_controller.dart';

class EventDetailController extends GetxController {
  String eventId = Get.parameters['scheduleId'] ?? '';

  final box = GetStorage();
  ScheduleService _scheduleService = ScheduleService();
  CheersService _cheersService = CheersService();

  CommentController commentController = Get.find<CommentController>();

  SocketEventCommentCheer _socketEventCommentCheer = SocketEventCommentCheer();

  SocketSchedule _socketSchedule = SocketSchedule();

  var _scheduleId = ''.obs;
  String get scheduleId => _scheduleId.value;
  set scheduleId(String value) {
    _scheduleId.value = value;
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

  var _errorMessage = ''.obs;
  String get errorMessage => _errorMessage.value;
  set errorMessage(String value) {
    _errorMessage.value = value;
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

  var _eventDetail = EventItemModel(title: '', content: '').obs;
  EventItemModel get eventDetail => _eventDetail.value;
  set eventDetail(EventItemModel value) {
    _eventDetail.value = value;
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
      String url = '/api/v1/events/$eventId/cheers';
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
      String url = '/api/v1/events/$eventId/cheers/${cheerItem.sId}';
      final response = await _cheersService.deleteCheerByModule(url);
      showAlert(message: response.data['message']);
      return Future.value(true);
    } catch (e) {
      _cheers.add(cheerItem);
      errorMessageMiddleware(e);
      return Future.value(false);
    }
  }

  Future<void> getEvent() async {
    try {
      final response = await _scheduleService.getEvent(eventId);

      if (response.data['event'] != null) {
        eventDetail = EventItemModel.fromJson(response.data['event']);
      }
      if (response.data['event']['subscribers'] != null) {
        members = [];
        response.data['event']['subscribers'].forEach((v) {
          members.add(MemberModel.fromJson(v));
        });
      }
      if (response.data['currentTeam'] != null) {
        currentTeam = Teams.fromJson(response.data['currentTeam']);
      }
      if (response.data['currentTeam']['members'] != null) {
        teamMembers = [];
        response.data['currentTeam']['members'].forEach((v) {
          _teamMembers.add(MemberModel.fromJson(v));
        });
      }

      if (response.data['event']['cheers'] != null) {
        cheers = [];
        response.data['event']['cheers'].forEach((o) {
          _cheers.add(CheerItemModel.fromJson(o));
        });
      }

      if (response.data['schedule'] != null) {
        scheduleId = response.data['schedule']['_id'] ?? '';
      }

      errorMessage = '';
      return Future.value();
    } catch (e) {
      print(e);
      String message = errorMessageMiddleware(e);
      errorMessage = message;
      return Future.value();
    }
  }

  Future<void> archiveEvent() async {
    try {
      final response = await _scheduleService.archiveEvent(eventId);

      showAlert(message: response.data['message']);
      return Future.value(true);
    } catch (e) {
      print(e);
      errorMessageMiddleware(e);
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
      final response = await _scheduleService.toggleMembers(eventId, body);

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
        moduleName: 'event',
        companyId: companyId,
        path: path,
        teamName: currentTeam.name == '' ? ' ' : currentTeam.name,
        title: eventDetail.title ?? '',
        subtitle:
            'Home  >  ${currentTeam.name}  >  Schedule  >  ${eventDetail.title}',
        uniqId: eventDetail.sId!));
  }

  init() async {
    isLoading = true;
    await getEvent();
    _cheersService.dynamicCompanyId = _scheduleService.dynamicCompanyId;
    isLoading = false;
    commentController.setBaseUrlModule('event', eventId);

    commentController.listMentionmembers = teamMembers;

    await commentController.getData();
    _createRecentlyViewed();
  }

  _onSocketEventUpdate(value) {
    EventItemModel item = EventItemModel.fromJson(value);
    if (item.sId == eventDetail.sId) {
      if (item.isPublic == false) {
        init();
      }
      eventDetail = item;
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
    _socketSchedule.init(scheduleId, logedInUserId);
    _socketSchedule.listener((p0) => null, _onSocketEventUpdate, (p0) => null,
        (p0) => null, (p0) => null, (p0) => null);
    _socketEventCommentCheer.init(eventId, logedInUserId);
    _socketEventCommentCheer.listener(
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
    _socketEventCommentCheer.removeListenFromSocket();
  }
}
