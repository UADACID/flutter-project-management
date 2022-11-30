import 'package:cicle_mobile_f3/models/board_list_item_model.dart';
import 'package:cicle_mobile_f3/models/card_model.dart';
import 'package:cicle_mobile_f3/service/board_service.dart';
import 'package:cicle_mobile_f3/utils/helpers.dart';
import 'package:get/get.dart';

class MoveCardController extends GetxController {
  BoardService _boardService = BoardService();

  String teamId = Get.parameters['teamId'] ?? '';

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

  var _boardList = <BoardListItemModel>[].obs;
  List<BoardListItemModel> get boardList => _boardList;
  set boardList(List<BoardListItemModel> value) {
    _boardList.value = [...value];
  }

  var _currentList =
      BoardListItemModel(archived: Archived(), complete: Complete()).obs;
  BoardListItemModel get currentList => _currentList.value;
  set currentList(BoardListItemModel value) {
    _currentList.value = value;
  }

  var _currentSourceList =
      BoardListItemModel(archived: Archived(), complete: Complete()).obs;
  BoardListItemModel get currentSourceList => _currentSourceList.value;
  set currentSourceList(BoardListItemModel value) {
    _currentSourceList.value = value;
  }

  var _totalList = 0.obs;
  int get totalList => _totalList.value;
  set totalList(int value) {
    _totalList.value = value;
  }

  _setPlaceholder(String listId) {
    List<BoardListItemModel> filterSelectedList =
        boardList.where((element) => element.sId == listId).toList();
    currentList = filterSelectedList.length > 0
        ? filterSelectedList[0]
        : BoardListItemModel(archived: Archived(), complete: Complete());
    currentSourceList = filterSelectedList.length > 0
        ? filterSelectedList[0]
        : BoardListItemModel(archived: Archived(), complete: Complete());
  }

  _getMoreList(
      String boardId, int startIndex, String cardId, String listId) async {
    try {
      final response = await _boardService
          .getBoards(boardId, startIndex - 1, teamId, limitCard: 0);

      if (response.data['lists'] != null) {
        response.data['lists'].forEach((o) {
          _boardList.add(BoardListItemModel.fromJson(o));
        });

        bool _needGetMoreList = _boardList.length < totalList;

        if (_needGetMoreList) {
          print('get more list');
          _getMoreList(boardId, _boardList.length, cardId, listId);
        } else {
          _setPlaceholder(listId);
        }
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> getList(String boardId, String cardId, String listId) async {
    try {
      isLoading = true;

      final response =
          await _boardService.getBoards(boardId, 0, teamId, limitCard: 0);

      final list = response.data['board']['lists'] ?? [];
      List<BoardListItemModel> result = [];
      list.forEach((v) {
        result.add(BoardListItemModel.fromJson(v));
      });

      if (response.data['board']['totalList'] != null) {
        totalList = response.data['board']['totalList'];
      }

      bool _needGetMoreList = result.length < totalList;
      boardList = [...result];
      isLoading = false;
      if (_needGetMoreList) {
        print('get more list');
        _getMoreList(boardId, result.length, cardId, listId);
      } else {
        _setPlaceholder(listId);
      }

      errorMessage = '';
    } catch (e) {
      print(e);
      isLoading = false;
      String message = errorMessageMiddleware(e);
      errorMessage = message;
    }
  }
}
