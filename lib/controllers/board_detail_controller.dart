import 'package:cicle_mobile_f3/models/board_list_item_model.dart';
import 'package:cicle_mobile_f3/models/card_model.dart';
import 'package:cicle_mobile_f3/models/cheer_item_model.dart';
import 'package:cicle_mobile_f3/models/label_model.dart';
import 'package:cicle_mobile_f3/models/member_model.dart';

import 'package:cicle_mobile_f3/service/board_service.dart';
import 'package:cicle_mobile_f3/service/cheers_service.dart';
import 'package:cicle_mobile_f3/service/comment_service.dart';
import 'package:cicle_mobile_f3/utils/constant.dart';
import 'package:cicle_mobile_f3/utils/helpers.dart';
import 'package:cicle_mobile_f3/utils/socket/socket_board.dart';
import 'package:cicle_mobile_f3/utils/socket/socket_card_comment_cheer.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';

import 'comment_controller.dart';
import 'search_controller.dart';

class BoardDetailController extends GetxController {
  final box = GetStorage();
  CommentController commentController = Get.find<CommentController>();
  String cardId = Get.parameters['boardsId'] ?? '';
  BoardService _boardService = BoardService();
  CheersService _cheersService = CheersService();
  CommentService _commentService = CommentService();

  SocketBoard _socketBoard = SocketBoard();
  SocketCardCommentCheer _socketCardCommentCheer = SocketCardCommentCheer();

  var _logedInUser = MemberModel().obs;
  MemberModel get logedInUser => _logedInUser.value;
  set logedInUser(MemberModel value) {
    _logedInUser.value = value;
  }

  var _logedInUserId = ''.obs;
  String get logedInUserId => _logedInUserId.value;

  var _isLoading = false.obs;
  bool get isLoading => _isLoading.value;
  set isLoading(bool value) {
    _isLoading.value = value;
  }

  var _errorMessage = ''.obs;
  String get errorMessage => _errorMessage.value;

  var _showForm = false.obs;
  bool get showForm => _showForm.value;
  set showForm(bool value) {
    _showForm.value = value;
  }

  var _cardDetail = CardModel(
          archived: Archived(),
          complete: Complete(),
          creator: Creator(),
          isNotified: IsNotified())
      .obs;
  CardModel get cardDetail => _cardDetail.value;
  set cardDetail(CardModel value) {
    _cardDetail.value = value;
  }

  var _boardId = ''.obs;
  String get boardId => _boardId.value;
  set boardId(String value) {
    _boardId.value = value;
  }

  // TITLE
  TextEditingController textEditingControllerTitle = TextEditingController();
  var _title = ''.obs;

  String get title => _title.value;

  set title(String value) {
    textEditingControllerTitle.text = value;
    _title.value = value;
  }

  //is Private
  var _isPrivate = false.obs;
  bool get isPrivate => _isPrivate.value;
  set isPrivate(bool value) {
    _isPrivate.value = value;
  }

  // SUBSCRIBER

  var _teamMembers = <MemberModel>[].obs;
  var _members = <MemberModel>[].obs;
  List<MemberModel> get teamMembers => _teamMembers;
  set teamMembers(List<MemberModel> value) {
    _teamMembers.value = value;
  }

  List<MemberModel> get members => _members;
  set members(List<MemberModel> value) {
    _members.value = [...value];
  }

  addMember(MemberModel value) {
    _members.add(value);
  }

  removeMember(MemberModel value) {
    int getIndex = _members.indexWhere((element) => element.sId == value.sId);
    _members.removeAt(getIndex);
  }

  setMembers(List<MemberModel> value) {
    _members.value = [...value];
  }

  // DUEDATE
  TextEditingController textEditingControllerDueDate = TextEditingController();
  var _dueDate = ''.obs;
  String get dueDate => _dueDate.value;
  set dueDate(String value) {
    textEditingControllerDueDate.text = value;
    _dueDate.value = value;
  }

  setDueDate(String value) {
    dueDate = value;
  }

  // LABELS

  var _labelsIdInProgress = <String>[].obs;
  List<String> get labelsIdInProgress => _labelsIdInProgress;

  var _labels = <LabelModel>[].obs;
  List<LabelModel> get labels => _labels;
  set labels(List<LabelModel> value) {
    _labels.value = [...value];
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
      String url = '/api/v1/cards/$cardId/cheers';
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
      String url = '/api/v1/cards/$cardId/cheers/${cheerItem.sId}';
      final response = await _cheersService.deleteCheerByModule(url);
      showAlert(message: response.data['message']);
      return Future.value(true);
    } catch (e) {
      _cheers.add(cheerItem);
      errorMessageMiddleware(e);
      return Future.value(false);
    }
  }

  Future<void> updatePrivateCard(String cardId, bool valueIsPrivate) async {
    try {
      dynamic data = {"isPublic": !valueIsPrivate};

      final response = await _boardService.updateCard(cardId, data);

      if (response.data['message'] != null) {
        showAlert(message: response.data['message']);
      }
    } catch (e) {
      errorMessageMiddleware(e);
    }
  }

  Future<String> addNewLabel(LabelModel value) async {
    _labels.add(value);
    if (_allLabels.length == 0) {
      _allLabels.add(value);
    }

    try {
      _labelsIdInProgress.add(value.sId);
      final response = await _boardService.toggleLabel(cardId, value.sId);

      if (response.data['message'] != null) {
        _labelsIdInProgress.remove(value.sId);
        showAlert(message: response.data['message']);
        return Future.value(response.data['message']);
      }
      _labelsIdInProgress.remove(value.sId);
      return Future.value('');
    } catch (e) {
      print(e);
      _labelsIdInProgress.remove(value.sId);
      if (e is DioError) {
        String message = e.response!.data['message'] ?? e.message;
        showAlert(message: message, messageColor: Colors.red);
      }
      return Future.value('');
    }
  }

  Future<String> removeLabel(LabelModel value) async {
    int getIndex = _labels.indexWhere((element) => element.sId == value.sId);
    _labels.removeAt(getIndex);

    try {
      _labelsIdInProgress.add(value.sId);
      final response = await _boardService.toggleLabel(cardId, value.sId);

      if (response.data['message'] != null) {
        _labelsIdInProgress.remove(value.sId);
        showAlert(message: response.data['message']);
        return Future.value(response.data['message']);
      }
      _labelsIdInProgress.remove(value.sId);
      return Future.value('');
    } catch (e) {
      print(e);
      _labelsIdInProgress.remove(value.sId);
      if (e is DioError) {
        String message = e.response!.data['message'] ?? e.message;
        showAlert(message: message, messageColor: Colors.red);
      }
      return Future.value('');
    }
  }

  var _allLabels = <LabelModel>[].obs;
  List<LabelModel> get allLabels => _allLabels;

  addAllLabel(LabelModel value) async {
    try {
      dynamic data = {
        "data": {"color": value.color.sId, "name": value.name},
        "selector": {"cardId": cardId}
      };
      final response = await _boardService.createLabel(data);
      if (response.data['board']['labels'] != null) {
        List<LabelModel> _tempLabels = [];
        response.data['board']['labels'].forEach((v) {
          _tempLabels.add(LabelModel.fromJson(v));
        });
        _allLabels.value = [..._tempLabels];
      }

      if (response.data['message'] != null) {
        showAlert(message: response.data['message']);
      }
    } catch (e) {
      print(e);
      if (e is DioError) {
        String message = e.response!.data['message'] ?? e.message;
        showAlert(message: message, messageColor: Colors.red);
      }
    }
  }

  removeLabelOnAllLabel(LabelModel value) async {
    int getIndexOnAll =
        _allLabels.indexWhere((element) => element.sId == value.sId);
    _allLabels.removeAt(getIndexOnAll);
    int getIndexCardLabel =
        _labels.indexWhere((element) => element.sId == value.sId);

    if (getIndexCardLabel >= 0) {
      _labels.removeAt(getIndexCardLabel);
    }

    try {
      dynamic data = {
        "selector": {"cardId": cardId}
      };
      final response = await _boardService.removeLabel(value.sId, data);

      if (response.data['message'] != null) {
        showAlert(message: 'Label has been archived');
      }
    } catch (e) {
      print(e);
      if (e is DioError) {
        String message = e.response!.data['message'] ?? e.message;
        showAlert(message: message, messageColor: Colors.red);
      }
    }
  }

  // NOTES

  var _showFullNote = false.obs;
  bool get showFullNote => _showFullNote.value;
  set showFullNote(bool value) {
    _showFullNote.value = value;
  }

  var _maxHeightShowMore = 0.obs;
  int get maxHeightShowMore => _maxHeightShowMore.value;
  set maxHeightShowMore(int value) {
    _maxHeightShowMore.value = value;
  }

  var _notes = 'Add detailed notes here...'.obs;

  String get notes => _notes.value;

  set notes(String value) {
    _notes.value = value;
  }

  // ATTACHMENT

  TextEditingController textEditingControllerAttachmentName =
      TextEditingController();
  var _attachments = <Attachments>[].obs;
  List<Attachments> get attachments => _attachments;

  set attachments(List<Attachments> value) {
    _attachments.value = [...value];
  }

  addNewAttachment(Attachments value) {
    _attachments.insert(0, value);
  }

  removeAttachmentItem(Attachments value) {
    _attachments.remove(value);
  }

  var _listItem =
      BoardListItemModel(archived: Archived(), complete: Complete()).obs;
  BoardListItemModel get listItem => _listItem.value;
  set listItem(BoardListItemModel value) {
    _listItem.value = value;
  }

  Future<CardModel> getCardDetail() async {
    try {
      final response = await _boardService.getCardDetail(cardId);
      // print(response);
      CardModel _card = CardModel.fromJson(response.data['card']);

      _cardDetail.value = _card;
      if (response.data['boardId'] != null) {
        boardId = response.data['boardId'] ?? '';
        _socketBoard.init(response.data['boardId'] ?? '');

        _labelsAdapter();
      } else {
        showAlert(message: 'board id not found on response');
      }

      isPrivate = response.data['card']['isPublic'] != null
          ? !response.data['card']['isPublic']
          : false;

      if (response.data['card']['cheers'] != null) {
        cheers = [];
        response.data['card']['cheers'].forEach((o) {
          _cheers.add(CheerItemModel.fromJson(o));
        });
      }

      return Future.value(_card);
    } catch (e) {
      print(e);
      return Future.error(e);
    }
  }

  var _teamName = ''.obs;
  String get teamName => _teamName.value;
  set teamName(String value) {
    _teamName.value = value;
  }

  var _teamId = ''.obs;
  String get teamId => _teamId.value;
  set teamId(String value) {
    _teamId.value = value;
  }

  boardListAdapter(response) {
    if (response.data != null && response.data['list'] != null) {
      listItem = BoardListItemModel.fromJson(response.data['list']);
    }
  }

  _labelsAdapter() async {
    try {
      String teamIdAsParam = Get.parameters['teamId'] ?? '';
      final response = await _boardService.getBoards(boardId, 0, teamIdAsParam);

      if (response.data['board']['labels'] != null) {
        _allLabels.value = [];
        response.data['board']['labels'].forEach((v) {
          _allLabels.add(LabelModel.fromJson(v));
        });
      }
      if (response.data['currentTeam'] != null) {
        print('mlebu kene');
        teamName = response.data['currentTeam']?['name'] ?? '';
        teamId = response.data['currentTeam']?['_id'] ?? '';
        _createRecentlyViewed();
      }
    } catch (e) {
      errorMessageMiddleware(e);
    }
  }

  Future<void> updateTitle(String titleAsParams) async {
    showForm = false;
    if (title == titleAsParams) {
      return;
    }
    title = titleAsParams;
    try {
      String cardId = _cardDetail.value.sId;
      dynamic data = {"name": titleAsParams};
      final response = await _boardService.updateCard(cardId, data);
      if (response.data['message'] != null) {
        showAlert(message: "update title success");
      }
    } catch (e) {
      print(e);
      if (e is DioError) {
        String message = e.response!.data['message'] ?? e.message;
        showAlert(message: message, messageColor: Colors.red);
      }
    }
  }

  Future<void> updateDesc(String descAsParams) async {
    if (notes == descAsParams) {
      return;
    }
    notes = descAsParams;
    try {
      String cardId = _cardDetail.value.sId;
      dynamic data = {"desc": descAsParams};

      final response = await _boardService.updateCard(cardId, data);

      if (response.data['message'] != null) {
        showAlert(message: "update notes success");
      }
    } catch (e) {
      print(e);
      if (e is DioError) {
        String message = e.response!.data['message'] ?? e.message;
        showAlert(message: message, messageColor: Colors.red);
      }
    }
  }

  Future<void> updateDueDate(String dueDateAsParams) async {
    if (dueDate == dueDateAsParams) {
      return;
    }
    dueDate = dueDateAsParams;
    try {
      String cardId = _cardDetail.value.sId;
      dynamic data = {
        "dueDate": DateFormat("yyyy-MM-dd HH:mm:ss")
            .format(DateTime.parse(dueDateAsParams).toUtc()),
        "isNotified.dueOneDay": false,
        "isNotified.dueOneHour": false
      };

      final response = await _boardService.updateCard(cardId, data);

      if (response.data['message'] != null) {
        showAlert(message: 'update due date success');
      }
    } catch (e) {
      print(e);
      if (e is DioError) {
        String message = e.response!.data['message'] ?? e.message;
        showAlert(message: message, messageColor: Colors.red);
      }
    }
  }

  Future<void> removeDueDate(String dueDateAsParams) async {
    String oldDueDate = dueDate;
    textEditingControllerDueDate.text = '';
    dueDate = '';
    try {
      String cardId = _cardDetail.value.sId;
      dynamic data = {
        "\$unset": {
          "dueDate": DateFormat("yyyy-MM-dd HH:mm:ss")
              .format(DateTime.parse(dueDateAsParams).toUtc()),
        },
        "isNotified.dueOneDay": false,
        "isNotified.dueOneHour": false
      };

      final response = await _boardService.updateCard(cardId, data);

      if (response.data['message'] != null) {
        showAlert(message: "remove due date success");
      }
    } catch (e) {
      print(e);
      textEditingControllerDueDate.text = oldDueDate;
      dueDate = oldDueDate;
      if (e is DioError) {
        String message = e.response!.data['message'] ?? e.message;
        showAlert(message: message, messageColor: Colors.red);
      }
    }
  }

  Future<CardModel> addAttachments(List<Attachments> items) async {
    try {
      items.forEach((item) {
        addNewAttachment(item);
      });

      final response = await _boardService.addAttachments(cardId, items);

      if (response.data['card'] != null) {
        CardModel _card = CardModel.fromJson(response.data['card']);
        _attachments.value = [..._card.attachments];
        showAlert(message: response.data['message']);
        return Future.value(_card);
      }

      return Future.value(null);
    } catch (e) {
      print(e);
      items.forEach((item) {
        removeAttachmentItem(item);
      });
      if (e is DioError) {
        String message = e.response!.data['message'] ?? e.message;
        showAlert(message: message, messageColor: Colors.red);
      }
      return Future.error(e);
    }
  }

  Future<void> deleteAttachment(Attachments item) async {
    int index = _attachments.indexOf(item);
    _attachments.remove(item);
    try {
      final response = await _boardService.deleteAttachment(cardId, item.sId);
      if (response.data['message'] != null) {
        showAlert(message: response.data['message']);
      }
    } catch (e) {
      _attachments.insert(index, item);
      if (e is DioError) {
        String message = e.response!.data['message'] ?? e.message;
        showAlert(message: message, messageColor: Colors.red);
      }
    }
  }

  Future<bool> updateAttachmentName(Attachments item, String newName) async {
    int index = _attachments.indexOf(item);

    List<Attachments> _tempList = List.from(_attachments);
    _tempList[index].name = newName;
    _attachments.value = [..._tempList];

    try {
      dynamic body = {"name": newName};
      final response =
          await _boardService.updateAttachment(cardId, item.sId, body);
      if (response.data['message'] != null) {
        showAlert(message: response.data['message']);
      }

      return Future.value(true);
    } catch (e) {
      List<Attachments> _tempList = List.from(_attachments);
      _tempList[index].name = item.name;
      _attachments.value = [..._tempList];
      if (e is DioError) {
        String message = e.response!.data['message'] ?? e.message;
        showAlert(message: message, messageColor: Colors.red);
      }
      return Future.value(false);
    }
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

  var loadingToggleMember = false.obs;

  Future<void> addMembers(List<MemberModel> selectedMembersList) async {
    List<String> _listIdMembers = toggleMembersAdapter(selectedMembersList);

    if (_listIdMembers.isEmpty) {
      return;
    }
    try {
      loadingToggleMember.value = true;
      dynamic data = {"members": _listIdMembers};
      final response = await _boardService.updateMembers(cardId, data);

      loadingToggleMember.value = false;
      showAlert(message: response.data['message']);
    } catch (e) {
      print(e);
      loadingToggleMember.value = false;

      if (e is DioError) {
        String errorMessage = e.response!.data['message'] ?? e.message;
        String statusCode = e.response!.data['statusCode'] ?? '500';
        showAlert(
            message: '$errorMessage error status code $statusCode',
            messageColor: Colors.red);
      }
    }
  }

  Future<List<BoardListItemModel>> moveCard(String cardId, String sourceListId,
      String destinationListId, String _boardId, int? destinationIndex) async {
    try {
      dynamic data = {
        "data": {
          "destination": {
            "droppableId": destinationListId,
            "index": destinationIndex
          },
          "draggableId": cardId,
          "source": {"droppableId": sourceListId}
        },
        "selector": {"boardId": _boardId}
      };
      final response = await _boardService.moveCard(data);
      _socketBoard.localSocket.emit('cardMove', data);

      showAlert(message: response.data['message']);
      return Future.value([]);
    } catch (e) {
      print(e);
      return Future.value([]);
    }
  }

  Future<List<BoardListItemModel>> archiveCard({required String cardId}) async {
    try {
      // set all card to archive on remote state
      final response = await _boardService.archiveCard(cardId);

      showAlert(message: response.data['message']);
      return Future.value([]);
    } catch (e) {
      print(e);
      errorMessageMiddleware(e);
      return Future.value([]);
    }
  }

  Future<void> getListAndCards(String boardIdAsParams) async {
    try {
      String teamIdAsParam = Get.parameters['teamId'] ?? '';

      await _boardService.getAllListAndCard(boardIdAsParams, teamIdAsParam);
    } catch (e) {
      print(e);
      errorMessageMiddleware(e);
    }
  }

  var loadingGetTeamMembers = true.obs;

  Future<List<MemberModel>> getTeamMembers() async {
    List<MemberModel> _listMember = [];
    loadingGetTeamMembers.value = true;
    try {
      String teamIdAsParam = Get.parameters['teamId'] ?? '';
      final response = await _commentService.getTeamMembers(teamIdAsParam);
      if (response.data['members'] != null) {
        response.data['members'].forEach((v) {
          _listMember.add(MemberModel.fromJson(v));
        });
        teamMembers = _listMember;
        loadingGetTeamMembers.value = false;
        return Future.value(_listMember);
      }
      loadingGetTeamMembers.value = false;
      return _listMember;
    } catch (e) {
      loadingGetTeamMembers.value = false;
      errorMessageMiddleware(e);
      return _listMember;
    }
  }

  getBoardListItem() async {
    try {
      final response = await _boardService.getListItemByCardId(cardId);

      if (response.data['list'] != null) {
        listItem = BoardListItemModel.fromJson(response.data['list']);
      } else {
        showAlert(message: "Data List Item not found on response");
      }
    } catch (e) {
      errorMessageMiddleware(e);
    }
  }

  _createRecentlyViewed() {
    // create recently viewed
    String path = currentRoute.value;
    String companyId = Get.parameters['companyId'] ?? '';

    Get.put(SearchController()).insertListRecenlyViewed(RecentlyViewed(
        moduleName: 'card',
        companyId: companyId,
        path: path,
        teamName: teamName == '' ? ' ' : teamName,
        title: cardDetail.name,
        subtitle: 'Home  >  $teamName  >  Board  >  ${cardDetail.name}',
        uniqId: cardDetail.sId));
  }

  init() async {
    try {
      _isLoading.value = true;
      CardModel _card = await getCardDetail();

      _cheersService.dynamicCompanyId = _boardService.dynamicCompanyId;

      cardDetail = _card;

      getTeamMembers();
      getBoardListItem();
      title = _card.name;
      if (_card.dueDate != '') {
        dueDate = DateFormat("yyyy-MM-dd HH:mm:ss")
            .format(DateTime.parse(_card.dueDate).toLocal());
      }

      _members.value = [..._card.members];
      _attachments.value = [..._card.attachments];
      _notes.value = _card.desc;

      _labels.value = _card.labels;
      _isLoading.value = false;
      _errorMessage.value = '';
      commentController.setBaseUrlModule('card', _card.sId);
      commentController.listMentionmembers = teamMembers;

      await commentController.getData();
    } catch (e) {
      print(e);
      _isLoading.value = false;
      if (e is DioError) {
        String message = e.response!.data['message'] ?? e.message;
        _errorMessage.value = message;
        showAlert(message: message, messageColor: Colors.red);
      } else {
        _errorMessage.value = e.toString();
      }
    }
  }

  var currentRoute = ''.obs;

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    currentRoute.value = Get.currentRoute;
    init();
    final userString = box.read(KeyStorage.logedInUser);
    MemberModel _templogedInUser = MemberModel.fromJson(userString);
    _logedInUserId.value = _templogedInUser.sId;
    logedInUser = _templogedInUser;

    _socketCardCommentCheer.init(cardId, logedInUserId);
    _socketCardCommentCheer.listener(
        _callbackUpdateCard,
        _callbackArchiveCard,
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

  _callbackUpdateCard(dynamic data) {
    if (data['currentCard'] != null) {
      try {
        CardModel _card = CardModel.fromJson(data['currentCard']);
        if (_card.isPublic == false && cardDetail.isPublic == true) {
          init();
        }
        cardDetail = _card;
        title = _card.name;
        members = _card.members;
        isPrivate = !_card.isPublic;
        if (_card.dueDate != '') {
          dueDate = DateFormat("yyyy-MM-dd HH:mm:ss")
              .format(DateTime.parse(_card.dueDate).toLocal());
        }
        labels = _card.labels;
        notes = _card.desc;
        attachments = _card.attachments;
      } catch (e) {
        print(e);
      }
    }
  }

  _callbackArchiveCard(dynamic data) {
    if (data['currentCard'] != null) {
      try {
        CardModel _card = CardModel.fromJson(data['currentCard']);
        if (_card.isPublic == false && cardDetail.isPublic == true) {
          init();
        }
        cardDetail = _card;
        title = _card.name;
        members = _card.members;
        isPrivate = !_card.isPublic;
        if (_card.dueDate != '') {
          dueDate = DateFormat("yyyy-MM-dd HH:mm:ss")
              .format(DateTime.parse(_card.dueDate).toLocal());
        }
        labels = _card.labels;
        notes = _card.desc;
        attachments = _card.attachments;
      } catch (e) {
        print(e);
      }
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
    if (comment['currentComment'] != null) {
      commentController.callBackAddComment(comment['currentComment']);
    }
  }

  callbackUpdateComment(dynamic comment) {
    if (comment['currentComment'] != null) {
      commentController.callBackEditComment(comment['currentComment']);
    }
  }

  callbackDeleteComment(dynamic comment) {
    if (comment['currentComment'] != null) {
      commentController.callBackRemoveComment(comment['currentComment']);
    }
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

  @override
  void onClose() {
    // TODO: implement onClose
    super.onClose();
    _socketCardCommentCheer.removeListenFromSocket();
  }
}
