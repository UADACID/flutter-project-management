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

import 'package:cicle_mobile_f3/utils/socket/socket_event_occurence_comment.dart';
import 'package:cicle_mobile_f3/utils/socket/socket_event_occurence_comment_cheer.dart';
import 'package:cicle_mobile_f3/utils/socket/socket_schedule.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'comment_controller.dart';

class EventOccurenceDetailController extends GetxController {
  String eventId = Get.parameters['scheduleId'] ?? '';
  String occurenceId = Get.parameters['occurenceId'] ?? '';

  final box = GetStorage();
  ScheduleService _scheduleService = ScheduleService();
  CheersService _cheersService = CheersService();

  CommentController commentController = Get.find<CommentController>();

  SocketEventOccurenceComment _socketEventOccurenceComment =
      SocketEventOccurenceComment();
  SocketEventOccurenceCommentCheer _socketEventOccurenceCommentCheer =
      SocketEventOccurenceCommentCheer();

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

  var _errorMessage = ''.obs;
  String get errorMessage => _errorMessage.value;
  set errorMessage(String value) {
    _errorMessage.value = value;
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
      String url = '/api/v1/events/$eventId/occurrences/$occurenceId/cheers';
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
      String url =
          '/api/v1/events/$eventId/occurrences/$occurenceId/cheers/${cheerItem.sId}';
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
      final response =
          await _scheduleService.getEventOccurence(eventId, occurenceId);

      if (response.data['schedule'] != null) {
        scheduleId = response.data['schedule']['_id'] ?? '';
      }
      if (response.data['occurrence'] != null) {
        eventDetail = EventItemModel.fromJson(response.data['occurrence']);
      }
      if (response.data['occurrence']['subscribers'] != null) {
        members = [];
        response.data['occurrence']['subscribers'].forEach((v) {
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

      if (response.data['occurrence']['cheers'] != null) {
        cheers = [];
        response.data['occurrence']['cheers'].forEach((o) {
          _cheers.add(CheerItemModel.fromJson(o));
        });
      }
      return Future.value();
    } catch (e) {
      print(e);
      errorMessage = errorMessageMiddleware(e);
      return Future.value();
    }
  }

  // waiting API
  toggleMembers(List<MemberModel> selectedMembersList) async {
    try {
      List<String> _listIdMembers =
          toggleMembersAdapter(selectedMembersList, members);
      members = selectedMembersList;
      if (_listIdMembers.isEmpty) {
        return Future.value(false);
      }
      dynamic body = {"members": _listIdMembers};

      await _scheduleService.toggleMembersOccurrence(eventId, body);
      showAlert(message: 'Toggle members successful');
    } catch (e) {
      print(e);
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
        moduleName: 'occurrence',
        companyId: companyId,
        path: path,
        teamName: currentTeam.name == '' ? ' ' : currentTeam.name,
        title: eventDetail.title ?? '',
        subtitle:
            'Home  >  ${currentTeam.name}  >  Schedule  >  ${eventDetail.title}',
        uniqId: eventDetail.sId!));
  }

  init() async {
    try {
      isLoading = true;
      await getEvent();
      _createRecentlyViewed();
      _cheersService.dynamicCompanyId = _scheduleService.dynamicCompanyId;
      isLoading = false;
      commentController.setOccurenceId(occurenceId);
      commentController.setBaseUrlModule('occurrence', eventId);

      commentController.listMentionmembers = teamMembers;

      await commentController.getData();
    } catch (e) {
      print(e);
      errorMessageMiddleware(e);
    }
  }

  _onSocketEventOccurrenceUpdate(value) {
    try {
      Creator _currentCreator = eventDetail.creator!;
      value.forEach((jsonEvent) {
        if (jsonEvent['_id'] != null && jsonEvent['_id'] == occurenceId) {
          print('mlebu kene');
          EventItemModel item = EventItemModel.fromJson(jsonEvent);
          if (item.isPublic == false) {
            init();
          }
          eventDetail = item;
          eventDetail.creator = _currentCreator;
        }
      });
    } catch (e) {
      print(e);
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
    _socketSchedule.listener((p0) => null, (p0) => null, (p0) => null,
        (p0) => null, _onSocketEventOccurrenceUpdate, (p0) => null);
    _socketEventOccurenceComment.init(occurenceId, logedInUserId, eventId);

    _socketEventOccurenceComment.listener(
      callbackNewComment,
      callbackUpdateComment,
      callbackDeleteComment,
    );
    _socketEventOccurenceCommentCheer.init(occurenceId, logedInUserId);
    _socketEventOccurenceCommentCheer.listener(
        callbackNewCheer,
        callbackDeleteCheer,
        callbackNewCheerComment,
        callbackDeleteCheerComment,
        callbackNewDiscussion,
        callbackDeleteDiscussion);
  }

  @override
  void onClose() {
    // TODO: implement onClose
    super.onClose();
    _socketEventOccurenceComment.removeListenFromSocket();
    _socketEventOccurenceCommentCheer.removeListenFromSocket();
  }
}
