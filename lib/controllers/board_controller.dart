import 'package:boardview/boardview_controller.dart';
import 'package:cicle_mobile_f3/controllers/team_detail_controller.dart';
import 'package:cicle_mobile_f3/models/board_list_item_model.dart';
import 'package:cicle_mobile_f3/models/card_model.dart';
import 'package:cicle_mobile_f3/models/comment_item_model.dart';
import 'package:cicle_mobile_f3/models/label_model.dart';
import 'package:cicle_mobile_f3/models/member_model.dart';

import 'package:cicle_mobile_f3/service/board_service.dart';
import 'package:cicle_mobile_f3/utils/constant.dart';
import 'package:cicle_mobile_f3/utils/helpers.dart';
import 'package:cicle_mobile_f3/utils/socket/socket_board.dart';
import 'package:darq/src/extensions/distinct.dart';

import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class DrafNewCard {
  final String listId;
  final String title;
  final bool isPrivate;

  DrafNewCard(
      {required this.listId, required this.title, required this.isPrivate});
}

class BoardController extends GetxController {
  final box = GetStorage();
  TeamDetailController _teamDetailController = Get.find();
  BoardService _boardService = BoardService();
  BoardViewController boardViewController = new BoardViewController();
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<ScaffoldState> scaffoldKeyArchived =
      GlobalKey<ScaffoldState>();

  SocketBoard _socketBoard = SocketBoard();

  String _teamId = Get.parameters['teamId'] ?? '';

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    final userString = box.read(KeyStorage.logedInUser);

    MemberModel logedInUser = MemberModel.fromJson(userString);
    _logedInUserId.value = logedInUser.sId;
  }

  @override
  void onClose() {
    // TODO: implement onClose
    super.onClose();
    _socketBoard.removeListenFromSocket();
  }

  init(String boardId) {
    _socketBoard.init(boardId);
    _socketBoard.listener(
        callbackLabelNew: callbackLabelNew,
        callbackLabelUpdate: callbackLabelUpdate,
        callbackLabelDelete: callbackLabelDelete,
        callbacklistNew: callBackListNew,
        callbacklistArchive: _callbacklistArchive,
        callbacklistUpdate: _callbacklistUpdate,
        callbackCardNew: _callbackCardNew,
        callbackCardUpdate: _callbackCardUpdate,
        callBackCardArchive: _callBackCardArchive,
        callBackCardUnarchive: _callBackCardUnarchive,
        callBackCardsArchive: _callBackCardsArchive,
        callBackListUnarchive: _callBackListUnarchive,
        callBackCardMove: _callBackCardMove,
        callBackListMove: _callBackListMove);
  }

  callbackLabelNew(dynamic json) {
    // enhance payload to object done
    if (json['currentLabel']['_id'] != null) {
      LabelModel item = LabelModel.fromJson(json['currentLabel']);

      var filterById = _allLabels.where((e) => e.sId == item.sId).toList();
      if (filterById.isEmpty) {
        _allLabels.insert(0, item);
      }
    }
  }

  callbackLabelUpdate(dynamic json) {
    // enhance payload to object done
    if (json['currentLabel']['_id'] != null) {
      LabelModel item = LabelModel.fromJson(json['currentLabel']);

      _allLabels.value = _allLabels.map((element) {
        if (element.sId == item.sId) {
          return item;
        }
        return element;
      }).toList();
    }
  }

  callbackLabelDelete(dynamic json) {
    // enhance payload to object done
    if (json['currentLabel']['_id'] != null) {
      LabelModel item = LabelModel.fromJson(json['currentLabel']);
      _allLabels.removeWhere((e) => e.sId == item.sId);
    }
  }

  callBackListNew(dynamic objJsonListItem) {
    if (objJsonListItem['_id'] != null) {
      BoardListItemModel item = BoardListItemModel.fromJson(objJsonListItem);
      int getIndex = boardList.indexWhere((element) => element.sId == item.sId);

      if (getIndex < 0) {
        _boardList.add(item);
      }
    }
  }

  _callbacklistArchive(dynamic json) {
    if (json['archivedList'] != null) {
      BoardListItemModel item =
          BoardListItemModel.fromJson(json['archivedList']);
      _boardList.removeWhere((element) => element.sId == item.sId);
    }
  }

  _callbacklistUpdate(dynamic json) {
    if (json['currentList'] != null) {
      BoardListItemModel item =
          BoardListItemModel.fromJson(json['currentList']);

      int getIndex =
          _boardList.indexWhere((element) => element.sId == item.sId);
      if (getIndex >= 0) {
        List<CardModel> _previousListCardOnThisListItem = [
          ..._boardList[getIndex].cards
        ];
        item.cards = [..._previousListCardOnThisListItem];
        _boardList[getIndex] = item;
      }
    }
  }

  _callbackCardNew(dynamic json) {
    String _listId = json['listId'] ?? '';
    CardModel item = CardModel.fromJson(json['card']);

    int getIndexList =
        _boardList.indexWhere((element) => element.sId == _listId);

    if (getIndexList >= 0) {
      BoardListItemModel _selectedLIst = _boardList[getIndexList];

      List<CardModel> _previousListCard = [..._selectedLIst.cards];
      int _isCardExistOnList =
          _previousListCard.indexWhere((element) => element.sId == item.sId);
      if (_isCardExistOnList < 0) {
        _previousListCard.insert(0, item);
        _selectedLIst.cards = [..._previousListCard];
        _boardList[getIndexList] = _selectedLIst;
      }
    }
  }

  _callbackCardUpdate(dynamic json) {
    try {
      String? _listId = json['listId'] ?? '';
      if (json['currentCard'] != null || json['card'] != null) {
        CardModel item = json['currentCard'] != null
            ? CardModel.fromJson(json['currentCard'])
            : CardModel.fromJson(json['card']);

        int getIndexList =
            _boardList.indexWhere((element) => element.sId == _listId);

        if (getIndexList >= 0) {
          BoardListItemModel _selectedLIst = _boardList[getIndexList];

          List<CardModel> _previousListCard = [..._selectedLIst.cards];

          int cardIndex = _previousListCard
              .indexWhere((element) => element.sId == item.sId);

          _previousListCard[cardIndex] = item;

          _selectedLIst.cards = [..._previousListCard];

          _boardList[getIndexList] = _selectedLIst;
        }
      }
    } catch (e) {
      print(e);
    }
  }

  _callBackCardArchive(dynamic json) {
    String _listId = json['listId'] ?? '';
    CardModel item = CardModel.fromJson(json['card']);

    int getIndexList =
        _boardList.indexWhere((element) => element.sId == _listId);

    if (getIndexList >= 0) {
      BoardListItemModel _selectedLIst = _boardList[getIndexList];

      List<CardModel> _previousListCard = [..._selectedLIst.cards];

      _previousListCard.removeWhere((element) => element.sId == item.sId);
      _selectedLIst.cards = [..._previousListCard];

      _boardList[getIndexList] = _selectedLIst;
    }
  }

  _callBackCardUnarchive(dynamic json) {
    String _listId = json['listId'] ?? '';
    if (json['card'] == null) {
      showAlert(message: 'callback socket object card not found');
      return;
    }
    CardModel item = CardModel.fromJson(json['card']);
    int getIndexList =
        _boardList.indexWhere((element) => element.sId == _listId);

    if (getIndexList >= 0) {
      BoardListItemModel _selectedLIst = _boardList[getIndexList];

      List<CardModel> _previousListCard = [..._selectedLIst.cards];

      int _isCardExistOnList =
          _previousListCard.indexWhere((element) => element.sId == item.sId);
      if (_isCardExistOnList < 0) {
        _previousListCard.insert(0, item);
        _selectedLIst.cards = [..._previousListCard];
        _boardList[getIndexList] = _selectedLIst;
      }
    }
  }

  _callBackCardsArchive(dynamic json) {
    if (json['currentList'] != null && json['currentList']['_id'] != null) {
      String _listId = json['currentList']['_id'] ?? '';
      int getIndexList =
          _boardList.indexWhere((element) => element.sId == _listId);
      if (getIndexList >= 0) {
        BoardListItemModel _selectedLIst = _boardList[getIndexList];
        _selectedLIst.cards = [];
        _boardList[getIndexList] = _selectedLIst;
      }
    }
  }

  _callBackListUnarchive(dynamic json) {
    if (json['currentList'] != null && json['currentList']['_id'] != null) {
      BoardListItemModel currentList =
          BoardListItemModel.fromJson(json['currentList']);
      int destinationIndex = json['destinationIndex'] ?? 0;

      int getIndex =
          _boardList.indexWhere((element) => element.sId == currentList.sId);
      destinationIndex =
          destinationIndex > 0 ? destinationIndex - 1 : destinationIndex;
      if (getIndex < 0) {
        _boardList.insert(destinationIndex, currentList);

        // check total cards compare with cards length
        int cardsLength = currentList.cards.length;
        int? totalCard = json['currentList']['totalCard'];

        if (totalCard == null) {
          return;
        }
        if (cardsLength < totalCard) {
          // request more cards
          print('request more card after unarchive list');
          _getMoreCardsEachList(
              currentList.sId, cardsLength > 0 ? cardsLength - 1 : cardsLength);
        }
      }
    }
  }

  _callBackCardMove(dynamic json) {
    try {
      String destinationListId =
          json['data']?['destination']?['droppableId'] ?? '';
      int destinationIndex = json['data']?['destination']?['index'] ?? 9999999;
      String cardId = json['data']?['draggableId'] ?? '';
      String sourceListId = json['data']?['source']?['droppableId'] ?? '';
      if (destinationListId == '' ||
          destinationIndex == 9999999 ||
          cardId == '' ||
          sourceListId == '') {
        print('error payload from socket move');
      } else {
        List<CardModel> tempListOfCards = [];
        _boardList.forEach((element) {
          tempListOfCards.addAll(element.cards);
        });

        List<CardModel> filterByCardId =
            tempListOfCards.where((element) => element.sId == cardId).toList();

        if (filterByCardId.isNotEmpty) {
          CardModel selectedCard = filterByCardId[0];
          if (destinationListId != sourceListId) {
            // tambahkan counter comment
            selectedCard.comments
                .add(CommentItemModel(creator: Creator(fullName: ''), sId: ''));
          }

          // remove card from sourceList
          int getIndexList =
              _boardList.indexWhere((element) => element.sId == sourceListId);

          if (getIndexList >= 0) {
            BoardListItemModel _selectedLIst = _boardList[getIndexList];

            List<CardModel> _previousListCard = [..._selectedLIst.cards];

            _previousListCard
                .removeWhere((element) => element.sId == selectedCard.sId);
            _selectedLIst.cards = [..._previousListCard];

            _boardList[getIndexList] = _selectedLIst;
          }

          // remove card on targetList
          int getIndexListTarget = _boardList
              .indexWhere((element) => element.sId == destinationListId);

          if (getIndexListTarget >= 0) {
            BoardListItemModel _selectedLIst = _boardList[getIndexListTarget];

            List<CardModel> _previousListCard = [..._selectedLIst.cards];

            _previousListCard
                .removeWhere((element) => element.sId == selectedCard.sId);
            _selectedLIst.cards = [..._previousListCard];
            // insert card on target list with destinationIndex
            _previousListCard.insert(destinationIndex, selectedCard);
            _selectedLIst.cards = [..._previousListCard];

            _boardList[getIndexListTarget] = _selectedLIst;
          }
        } else {
          print('card not found');
        }
      }
    } catch (e) {
      print(e);
    }
  }

  _callBackListMove(dynamic json) {
    String listId = json['data']?['draggableId'] ?? '';
    int destinationIndex = json['data']?['destination']?['index'] ?? 9999999;
    if (listId != "" && destinationIndex != 9999999) {
      List<BoardListItemModel> filterListByListId =
          _boardList.where((element) => element.sId == listId).toList();

      if (filterListByListId.isNotEmpty) {
        BoardListItemModel selectedList = filterListByListId[0];
        _boardList.removeWhere((element) => element.sId == selectedList.sId);
        _boardList.insert(destinationIndex, selectedList);
        print('success callback moveList');
      }
    }
  }

  var _totalList = 0.obs;
  int get totalList => _totalList.value;
  set totalList(int value) {
    _totalList.value = value;
  }

  var _isEndDrawerOpen = false.obs;
  bool get isEndDrawerOpen => _isEndDrawerOpen.value;
  set isEndDrawerOpen(bool value) {
    _isEndDrawerOpen.value = value;
  }

  var _logedInUserId = ''.obs;
  String get logedInUserId => _logedInUserId.value;

  var _loading = false.obs;
  bool get loading => _loading.value;

  set loading(bool value) {
    _loading.value = value;
  }

  var _overlay = false.obs;
  bool get overlay => _overlay.value;

  set overlay(bool value) {
    _overlay.value = value;
  }

  var _loadingCreateList = false.obs;
  bool get loadingCreateList => _loadingCreateList.value;

  set loadingCreateList(bool value) {
    _loadingCreateList.value = value;
  }

  // card name for filter
  var _filteredName = "".obs;
  String get filteredName => _filteredName.value;

  set filteredName(String value) {
    _filteredName.value = value;
  }

  // LABELS FOR FILTER
  var _allLabels = <LabelModel>[].obs;
  List<LabelModel> get allLabels => _allLabels;

  var _selectedLabels = <LabelModel>[].obs;
  List<LabelModel> get selectedLabels => _selectedLabels;

  updateSeletedlabels(List<LabelModel> value) {
    _selectedLabels.clear();
    _selectedLabels.value = [...value];
  }

  // MEMBERS
  var _allTeamMember = <MemberModel>[].obs;

  List<MemberModel> get allTeamMember => _allTeamMember;

  var _selectedMembers = <MemberModel>[].obs;

  List<MemberModel> get selectedMembers => _selectedMembers;

  updateSeletedMembers(List<MemberModel> value) {
    _selectedMembers.clear();
    _selectedMembers.value = [...value];
  }

  // Due
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

  // BOARDS LIST

  // FOR CHANGE LIST NAME
  var _selectedListIdForChangeName = ''.obs;
  String get selectedListIdForChangeName => _selectedListIdForChangeName.value;
  set selectedListIdForChangeName(String id) {
    _selectedListIdForChangeName.value = id;
    _selectedListIdForAddNewCard.value = '';
  }

  var _selectedListIdForAddNewCard = ''.obs;
  String get selectedListIdForAddNewCard => _selectedListIdForAddNewCard.value;
  set selectedListIdForAddNewCard(String id) {
    _selectedListIdForAddNewCard.value = id;
    _selectedListIdForChangeName.value = '';
  }

  changeListTitle(String title, String listId) async {
    try {
      // update local state
      int destionationIndex =
          _boardList.indexWhere((element) => element.sId == listId);
      List<BoardListItemModel> _tempList = List.from(_boardList);
      _tempList[destionationIndex].name = title;
      _boardList.value = [..._tempList];

      // update remote state
      String _boardId = _teamDetailController.boardId;
      dynamic data = {
        "data": {
          "name": title,
        },
        "selector": {"boardId": _boardId}
      };
      await _boardService.updateListName(listId, data);
    } catch (e) {
      print(e);
      errorMessageMiddleware(e);
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
      errorMessageMiddleware(e);
      return Future.value([]);
    }
  }

  var _boardList = <BoardListItemModel>[].obs;

  List<BoardListItemModel> get boardList => _boardList;
  set boardList(List<BoardListItemModel> value) {
    _boardList.value = [...value];
  }

  _getMoreList(int startIndex) async {
    try {
      final response = await _boardService.getBoards(
          _teamDetailController.boardId, startIndex - 1, _teamId);

      if (response.data['lists'] != null) {
        response.data['lists'].forEach((o) {
          _boardList.add(BoardListItemModel.fromJson(o));
        });

        bool _needGetMoreList = _boardList.length < totalList;

        if (_needGetMoreList) {
          print('get more list');
          _getMoreList(_boardList.length);
        } else {
          // start to load more card on each list item
          _boardList.forEach((element) {
            // check cards length compare with totalCard
            if (element.cards.length < element.totalCard) {
              _getMoreCardsEachList(
                  element.sId,
                  element.cards.length > 0
                      ? element.cards.length - 1
                      : element.cards.length);
            }
          });
        }
      }
    } catch (e) {
      print(e);
    }
  }

  _getMoreCardsEachList(
    String argListId,
    int argStartIndex,
  ) async {
    print('zzz argListId $argListId');
    print('zzz argStartIndex $argStartIndex');
    try {
      final response =
          await _boardService.getCardEachList(argListId, argStartIndex);

      int _totalCardOnList = response.data['totalCard'];
      // if (_totalCardOnList > 10) {
      //   print('argListId $argListId');
      // }
      List<BoardListItemModel> _tempList = [...boardList];
      int getIndex =
          _tempList.indexWhere((element) => element.sId == argListId);
      if (getIndex >= 0) {
        List<CardModel> _previousCards = _tempList[getIndex].cards;
        List<CardModel> _newCards = [];
        response.data['cards'].forEach((o) {
          _newCards.add(CardModel.fromJson(o));
        });
        List<CardModel> _finalCards = [..._previousCards, ..._newCards];
        // .distinct((d) => d.sId).toList();
        _tempList[getIndex].cards = _finalCards;
        boardList = _tempList;
        print('zzz -------------- zzz');
        print('zzz _finalCards.length ${_finalCards.length}');
        print('zzz _totalCardOnList $_totalCardOnList');

        if (_finalCards.length < _totalCardOnList) {
          // get more card
          print('zzz get more card');
          _getMoreCardsEachList(argListId, _finalCards.length - 1);
        }
      }
    } catch (e) {
      print(e);
    }
  }

  Future<List<BoardListItemModel>> getBoard() async {
    try {
      if (_teamDetailController.boardId == '') {
        await _teamDetailController.getTeam();
      }
      _loading.value = true;
      List<BoardListItemModel> result = await fetchWithCompute(
          _teamDetailController.boardId, _boardService, 0);
      _boardList.value = [...result];
      bool _needGetMoreList = result.length < totalList;
      _loading.value = false;
      if (_needGetMoreList) {
        print('get more list');
        _getMoreList(result.length);
      } else {
        // start to load more card on each list item

        _boardList.forEach((element) {
          // check cards length compare with totalCard
          if (element.cards.length < element.totalCard) {
            _getMoreCardsEachList(
                element.sId,
                element.cards.length > 0
                    ? element.cards.length - 1
                    : element.cards.length);
          }
        });
      }
      await Future.delayed(Duration(seconds: 1));

      init(_teamDetailController.boardId);
      return _boardList;
    } catch (e) {
      print(e);
      _loading.value = false;

      errorMessageMiddleware(e);
      return Future.error(e);
    }
  }

  List<BoardListItemModel> parseBoardList(responBody) {
    final boardLists = responBody.data['board']['lists'] ?? [];
    List<BoardListItemModel> result = [];
    boardLists.forEach((v) {
      result.add(BoardListItemModel.fromJson(v));
    });

    return result;
  }

  Future<List<BoardListItemModel>> fetchWithCompute(
      String boardId, BoardService _service, int lastListIndex) async {
    final response = await _service.getBoards(boardId, lastListIndex, _teamId);

    var _tempLabels = [];
    if (response.data['board']['labels'] != null) {
      final labelList = response.data['board']['labels'] ?? [];
      labelList.forEach((v) {
        _tempLabels.add(LabelModel.fromJson(v));
      });
    }

    if (response.data['board']['totalList'] != null) {
      totalList = response.data['board']['totalList'];
    }

    _allLabels.value = [..._tempLabels];

    return parseBoardList(response);
  }

  Future<void> addNewList({String name = ''}) async {
    // check parse list
    try {
      loadingCreateList = true;
      String _boardId = _teamDetailController.boardId;
      dynamic data = {
        "data": {
          "name": name,
        },
        "selector": {"boardId": _boardId}
      };
      await _boardService.createBoardList(_boardId, data);
      await Future.delayed(Duration(milliseconds: 300));
      boardViewController.animateTo(boardList.length,
          duration: Duration(milliseconds: 600), curve: Curves.ease);
      loadingCreateList = false;
      Get.back();
    } catch (e) {
      print(e);
      showAlert(message: 'Error Create New list', messageColor: Colors.red);
      errorMessageMiddleware(e);
      loadingCreateList = false;
    }
  }

  Future<bool> addNewCard(
      {required String name,
      required String listId,
      required bool isPrivate}) async {
    String _randomId = getRandomString(20);
    try {
      String _boardId = _teamDetailController.boardId;
      dynamic data = {
        "data": {"name": name, "isPublic": !isPrivate},
        "selector": {"boardId": _boardId, "listId": listId}
      };

      await _boardService.createCard(_boardId, data);

      return Future.value(true);
    } catch (e) {
      showAlert(message: 'Error create new card', messageColor: Colors.red);

      // remove card if failed to add on server
      int destionationIndex =
          _boardList.indexWhere((element) => element.sId == listId);
      List<BoardListItemModel> _tempList = List.from(_boardList);
      List<CardModel> _tempCards =
          List.from(_tempList[destionationIndex].cards);

      int cardIndex =
          _tempCards.indexWhere((element) => element.sId == _randomId);
      _tempCards.removeAt(cardIndex);
      _tempList[destionationIndex].cards = _tempCards;
      _boardList.value = [..._tempList];
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

  archiveList({required String listId}) async {
    // check parse list
    try {
      // remove local state
      List<BoardListItemModel> _tempList =
          _boardList.where((element) => element.sId != listId).toList();

      _boardList.value = [..._tempList];

      String _boardId = _teamDetailController.boardId;
      dynamic data = {
        "boardId": _boardId,
        "cards": [],
        "selector": {"boardId": _boardId}
      };
      await _boardService.archiveList(listId, data);
    } catch (e) {
      print(e);
      showAlert(message: 'Invalid to archived list', messageColor: Colors.red);
      errorMessageMiddleware(e);
    }
  }

  archiveAllCardOnList(
      {required String listId, required List<String> cards}) async {
    try {
      // check parse list
      // set all card to archive on local state
      List<BoardListItemModel> _tempList = [];
      _boardList.forEach((element) {
        BoardListItemModel _boardListItem = element;
        if (element.sId == listId) {
          List<CardModel> _tempCards = [];
          _boardListItem.cards.forEach((element) {
            element.archived.status = true;
            _tempCards.add(element);
          });
          _boardListItem.cards = _tempCards;
        }
        _tempList.add(_boardListItem);
      });

      _boardList.value = [..._tempList];

      // set all card to archive on remote state
      String _boardId = _teamDetailController.boardId;
      dynamic data = {
        "boardId": _boardId,
        "cards": cards,
        "listId": listId,
        "selector": {"boardId": _boardId}
      };
      await _boardService.archiveAllCardOnList(data);
    } catch (e) {
      showAlert(
          message: 'Invalid to archived all card on list',
          messageColor: Colors.red);
      errorMessageMiddleware(e);
    }
  }

  Future<List<BoardListItemModel>> archiveCard({required String cardId}) async {
    print('cardId $cardId');
    try {
      // check parse list
      // set all card to archive on local state
      List<BoardListItemModel> _tempList = [];
      _boardList.forEach((element) {
        BoardListItemModel _boardListItem = element;
        List<CardModel> _tempCards = [];
        _boardListItem.cards.forEach((card) {
          if (card.sId == cardId) {
            card.isProgressToArchived = true;
          }
          _tempCards.add(card);
        });
        _boardListItem.cards = [..._tempCards];
        _tempList.add(_boardListItem);
      });
      _boardList.value = [..._tempList];
      // set all card to archive on remote state
      final response = await _boardService.archiveCard(cardId);

      showAlert(message: response.data['message']);
      return Future.value([]);
    } catch (e) {
      showAlert(
          message: 'Invalid to archived all card on list',
          messageColor: Colors.red);
      // set all card to archive on local state
      List<BoardListItemModel> _tempList = [];
      _boardList.forEach((element) {
        BoardListItemModel _boardListItem = element;
        List<CardModel> _tempCards = [];
        _boardListItem.cards.forEach((card) {
          if (card.sId == cardId) {
            card.isProgressToArchived = false;
          }
          _tempCards.add(card);
        });
        _boardListItem.cards = [..._tempCards];
        _tempList.add(_boardListItem);
      });
      _boardList.value = [..._tempList];
      errorMessageMiddleware(e);
      return Future.value([]);
    }
  }

  // MOVING CARD ITEM
  onDropCard({
    required int oldListIndex,
    required int oldItemIndex,
    required int listIndex,
    required int itemIndex,
  }) async {
    try {
      List<BoardListItemModel> _listWithFilterByArchived = _boardList
          .where((element) => element.archived.status == false)
          .toList();

      List<BoardListItemModel> _listData = [..._boardList];

      var objOldList = _listWithFilterByArchived[oldListIndex];
      var realIndexOldList =
          _listData.indexWhere((element) => element.sId == objOldList.sId);

      var objDestinationList = _listWithFilterByArchived[listIndex];
      var realIndexDestinationList = _listData
          .indexWhere((element) => element.sId == objDestinationList.sId);

      var item = _listData[realIndexOldList].cards[oldItemIndex];
      _listData[realIndexOldList].cards.removeAt(oldItemIndex);
      _listData[realIndexDestinationList].cards.insert(itemIndex, item);
      _boardList.value = [..._listData];

      // // set remote state
      String _boardId = _teamDetailController.boardId;

      List<BoardListItemModel> response = await moveCard(item.sId,
          objOldList.sId, objDestinationList.sId, _boardId, itemIndex);
    } catch (e) {
      print(e);
      errorMessageMiddleware(e);
    }
  }

  // MOVING LIST ITEM
  onDropListItem({
    required int oldListIndex,
    required int listIndex,
  }) async {
    try {
      String _boardId = _teamDetailController.boardId;

      List<BoardListItemModel> _listData = [..._boardList];

      var objOldList = _boardList[oldListIndex];
      var realIndexOldList =
          _listData.indexWhere((element) => element.sId == objOldList.sId);

      var objDestinationList = _boardList[listIndex];
      var realIndexDestinationList = _listData
          .indexWhere((element) => element.sId == objDestinationList.sId);

      var list = _listData[realIndexOldList];

      dynamic data = {
        "data": {
          "combine": null,
          "destination": {
            "droppableId": "all-lists",
            "index": realIndexDestinationList
          },
          "draggableId": list.sId,
          "mode": "FLUID",
          "reason": "DROP",
          "source": {"index": realIndexOldList, "droppableId": "all-lists"},
          "type": "list"
        },
        "selector": {"boardId": _boardId}
      };
      final response = await _boardService.moveList(data);
      _socketBoard.localSocket.emit('listMove', data);
      print('listMove ');

      showAlert(message: response.data['message']);
    } catch (e) {
      errorMessageMiddleware(e);
      print(e);
    }
  }

  Future<void> setListAsComplete(String listId) async {
    try {
      overlay = true;
      String _boardId = _teamDetailController.boardId;
      dynamic data = {"boardId": _boardId};
      final response = await _boardService.setListAsComplete(listId, data);

      showAlert(message: response.data['message']);
      overlay = false;
    } catch (e) {
      print(e);
      overlay = false;
      errorMessageMiddleware(e);
    }
  }

  Future<void> unSetListAsComplete(String listId) async {
    try {
      overlay = true;
      String _boardId = _teamDetailController.boardId;
      final response =
          await _boardService.unSetListAsComplete(listId, _boardId);

      showAlert(message: response.data['message']);
      overlay = false;
    } catch (e) {
      print(e);
      overlay = false;
      errorMessageMiddleware(e);
    }
  }

  Future<void> toggleListAsComplete(String listId, String listType) async {
    try {
      overlay = true;
      String _boardId = _teamDetailController.boardId;
      dynamic data = {"boardId": _boardId, "completeType": listType};

      final response = await _boardService.updateListAsComplete(listId, data);

      showAlert(message: response.data['message']);
      overlay = false;
    } catch (e) {
      print(e);
      overlay = false;
      errorMessageMiddleware(e);
    }
  }
}
