import 'package:cicle_mobile_f3/controllers/team_detail_controller.dart';
import 'package:cicle_mobile_f3/models/board_list_item_model.dart';
import 'package:cicle_mobile_f3/models/card_model.dart';
import 'package:cicle_mobile_f3/models/label_model.dart';
import 'package:cicle_mobile_f3/models/member_model.dart';
import 'package:cicle_mobile_f3/service/board_service.dart';
import 'package:cicle_mobile_f3/utils/constant.dart';
import 'package:cicle_mobile_f3/utils/helpers.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

enum viewType { CARDS, LISTS }

class BoardArchivedController extends GetxController {
  final box = GetStorage();
  BoardService _boardService = BoardService();
  TeamDetailController _teamDetailController = Get.find();
  TextEditingController textEditingControllerSearch = TextEditingController();
  TextEditingController textEditingControllerSearchList =
      TextEditingController();

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    final userString = box.read(KeyStorage.logedInUser);

    MemberModel logedInUser = MemberModel.fromJson(userString);
    _logedInUserId.value = logedInUser.sId;
    init();
  }

  init() async {
    _isLoading.value = true;
    List<BoardListItemModel> list = await getArchivedBoards();
    var _temListCard = <CardModel>[];
    list.forEach((element) {
      element.cards.forEach((card) {
        if (card.archived.status == true) {
          _temListCard.add(card);
        }
      });
    });
    _temListCard.sort((a, b) =>
        DateTime.parse(b.updatedAt).compareTo(DateTime.parse(a.updatedAt)));
    _cards.value = [..._temListCard];
    _isLoading.value = false;
  }

  var _mode = viewType.CARDS.obs;
  viewType get mode => _mode.value;
  set mode(viewType value) {
    _mode.value = value;
  }

  var _logedInUserId = ''.obs;
  String get logedInUserId => _logedInUserId.value;

  var _isLoading = false.obs;
  bool get isLoading => _isLoading.value;

  var _searchKey = ''.obs;
  String get searchKey => _searchKey.value;
  set searchKey(String value) {
    _searchKey.value = value;
  }

  var _searchKeyList = ''.obs;
  String get searchKeyList => _searchKeyList.value;
  set searchKeyList(String value) {
    _searchKeyList.value = value;
  }

  var _selectedLabels = <LabelModel>[].obs;
  List<LabelModel> get selectedLabels => _selectedLabels;
  set selectedLabels(List<LabelModel> value) {
    _selectedLabels.value = [...value];
  }

  var _selectedMembers = <MemberModel>[].obs;

  List<MemberModel> get selectedMembers => _selectedMembers;
  set selectedMembers(List<MemberModel> value) {
    _selectedMembers.value = [...value];
  }

  var _isDueToday = false.obs;
  bool get isDueToday => _isDueToday.value;
  set isDueToday(bool value) {
    _isDueToday.value = value;
  }

  var _isDueSoon = false.obs;
  bool get isDueSoon => _isDueSoon.value;
  set isDueSoon(bool value) {
    _isDueSoon.value = value;
  }

  var _isOverDue = false.obs;
  bool get isOverDue => _isOverDue.value;
  set isOverDue(bool value) {
    _isOverDue.value = value;
  }

  var _boardList = <BoardListItemModel>[].obs;
  List<BoardListItemModel> get boardList => _boardList;
  set boardList(List<BoardListItemModel> value) {
    _boardList.value = [...value];
  }

  var _cards = <CardModel>[].obs;
  List<CardModel> get cards => _cards;

  Future<List<BoardListItemModel>> getArchivedBoards() async {
    try {
      String _boardId = _teamDetailController.boardId;
      final response = await _boardService.getArchivedBoards(_boardId);
      var parseResponse = parse(response);
      _boardList.value = [...parseResponse];
      return Future.value(parseResponse);
    } catch (e) {
      print(e);
      return Future.value([]);
    }
  }

  List<BoardListItemModel> parse(response) {
    List<BoardListItemModel> _list = [];

    if (response.data['board']['lists'] != null) {
      response.data['board']['lists'].forEach((v) {
        _list.add(BoardListItemModel.fromJson(v));
      });
    }
    return _list;
  }

  Future<void> unArchiveCard(String cardId) async {
    CardModel selectedCard =
        cards.firstWhere((element) => element.sId == cardId);
    try {
      BoardListItemModel destinationList =
          _boardList.firstWhere((element) => element.archived.status == false);

      String _boardId = _teamDetailController.boardId;
      String listSourceId = _boardList
          .firstWhere((element) => element.cards.any((e) => e.sId == cardId))
          .sId;

      dynamic data = {
        "boardId": _boardId,
        "listDestId": destinationList.sId,
        "listDestPos": "0",
        "listSourceId": listSourceId,
      };
      _cards.remove(selectedCard);
      final response = await _boardService.unArchiveCard(cardId, data);

      if (response.data['message'] != null) {
        showAlert(message: response.data['message']);
      }
      return Future.value(true);
    } catch (e) {
      var _tempList = [..._cards];
      _tempList.insert(0, selectedCard);
      _tempList.sort((a, b) =>
          DateTime.parse(b.updatedAt).compareTo(DateTime.parse(a.updatedAt)));
      _cards..value = [..._tempList];

      if (e is DioError) {
        showAlert(message: e.message);
      }
      return Future.value(false);
    }
  }

  Future<void> unArchiveList(String listId) async {
    BoardListItemModel listItem =
        boardList.firstWhere((element) => element.sId == listId);
    try {
      String _boardId = _teamDetailController.boardId;

      dynamic data = {
        "boardId": _boardId,
      };
      _boardList.remove(listItem);
      final response = await _boardService.unArchiveList(listId, data);

      if (response.data['message'] != null) {
        showAlert(message: response.data['message']);
      }
      return Future.value(true);
    } catch (e) {
      var _tempList = [..._boardList];
      _tempList.insert(0, listItem);
      _tempList.sort((a, b) =>
          DateTime.parse(b.updatedAt).compareTo(DateTime.parse(a.updatedAt)));
      _boardList..value = [..._tempList];

      if (e is DioError) {
        showAlert(message: e.message);
      } else {
        showAlert(message: 'error unexpected');
      }
      return Future.value(false);
    }
  }
}
