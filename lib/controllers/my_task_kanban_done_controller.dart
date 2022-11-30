import 'package:cicle_mobile_f3/models/card_model.dart';

import 'package:cicle_mobile_f3/models/comment_item_model.dart';
import 'package:cicle_mobile_f3/models/member_model.dart';

import 'package:cicle_mobile_f3/service/my_task_service.dart';
import 'package:cicle_mobile_f3/utils/constant.dart';
import 'package:cicle_mobile_f3/utils/helpers.dart';
import 'package:cicle_mobile_f3/utils/socket/socket_my_task_complete.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'my_task_controller.dart';

class CardMyTask {
  final CardModel card;
  final CommentItemModel? lastComment;
  final String teamName;
  final String teamId;
  final String endDate;

  CardMyTask(
      this.card, this.lastComment, this.teamName, this.teamId, this.endDate);
}

class MyTaskKanbanDoneController extends GetxController {
  MyTaskService _myTaskService = MyTaskService();
  MyTaskController _myTaskController = Get.put(MyTaskController());

  final box = GetStorage();
  SocketMyTaskComplete _socketMyTaskComplete = SocketMyTaskComplete();

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

  var _total = 0.obs;
  int get total => _total.value;
  set total(int value) {
    _total.value = value;
  }

  var _nextPage = 1.obs;
  int get nextPage => _nextPage.value;
  set nextPage(int value) {
    _nextPage.value = value;
  }

  var _lastPage = 0.obs;
  int get lastPage => _lastPage.value;
  set lastPage(int value) {
    _lastPage.value = value;
  }

  var _cards = <CardMyTask>[].obs;
  List<CardMyTask> get cards => _cards;

  set cards(List<CardMyTask> values) {
    _cards.value = [...values];
  }

  Future<void> getData(int nextPageArg) async {
    try {
      isLoading = true;
      errorMessage = '';
      if (nextPageArg == 1) {
        cards = [];
      }

      Map<String, dynamic> params = {
        'limit': 10,
        'page': nextPageArg,
        'sortBy': 'createdAt',
        'orderBy': 'desc',
        'filters[serviceType]': 'Card',
        'filters[complete.status]': 'true',
        'type': 'all',
        'filters[team]': [
          ..._myTaskController.listHqSelected,
          ..._myTaskController.listProjectSelected,
          ..._myTaskController.listTeamSelected
        ]
      };
      final response = await _myTaskService.getList(params);

      if (response.statusCode == 200) {
        lastPage = response.data['lastPage'] ?? 0;

        if (nextPageArg == 1) {
          nextPage = 2;
        } else if (lastPage < nextPageArg) {
          // end of loadmore
          // nextPage = nextPageArg + 1;
        } else {
          nextPage = nextPageArg + 1;
        }

        if (response.data['data'] != null) {
          if (nextPageArg == 1) {
            List<CardMyTask> _tempList = [];
            response.data['data'].forEach((o) {
              CardModel card = CardModel.fromJson(o['service']);

              CommentItemModel? lastComment = o['lastComment'] != null
                  ? CommentItemModel.fromJson(o['lastComment'])
                  : null;

              String teamName = o['team']['name'];
              String teamId = o['team']['_id'];
              String endDate = o['endDate'] ?? '';

              _tempList.add(
                  CardMyTask(card, lastComment, teamName, teamId, endDate));
            });

            cards = _tempList;
          } else {
            // load more

            response.data['data'].forEach((o) {
              CardModel card = CardModel.fromJson(o['service']);

              CommentItemModel? lastComment = o['lastComment'] != null
                  ? CommentItemModel.fromJson(o['lastComment'])
                  : null;

              String teamName = o['team']['name'];
              String teamId = o['team']['_id'];
              String endDate = o['endDate'] ?? '';

              cards.add(
                  CardMyTask(card, lastComment, teamName, teamId, endDate));
            });
          }
        } else {
          // data array null
        }
      } else {
        // response selain 200
      }
      isLoading = false;
      return Future.value(true);
    } catch (e) {
      print(e);
      isLoading = false;
      errorMessage = errorMessageMiddleware(e);
      return Future.value(false);
    }
  }

  getMore() {
    getData(nextPage);
  }

  CardMyTask? _filterItem(dynamic json) {
    if (json['task'] != null) {
      if (json['task']['serviceType'] != null &&
          json['task']['serviceType'] == 'Card') {
        // parsing to model
        CardModel post = CardModel.fromJson(json['task']['service']);
        CommentItemModel? lastComment = json['task']['lastComment'] != null
            ? CommentItemModel.fromJson(json['task']['lastComment'])
            : null;

        String teamName = json['task']['team']['name'];
        String teamId = json['task']['team']['_id'];
        String endDate = json['task']['endDate'] ?? '';
        CardMyTask finalItem =
            CardMyTask(post, lastComment, teamName, teamId, endDate);

        List<String> _activeProjectFilter = [
          ..._myTaskController.listHqSelected,
          ..._myTaskController.listProjectSelected,
          ..._myTaskController.listTeamSelected
        ];

        // check is project filter active
        if (_activeProjectFilter.isEmpty) {
          return finalItem;
        } else {
          // check is final iteam team id exist on filter
          List<String> checkItemTeamIdonFilter = _activeProjectFilter
              .where((element) => element == finalItem.teamId)
              .toList();
          if (checkItemTeamIdonFilter.isNotEmpty) {
            return finalItem;
          }
          return null;
        }
      }

      return null;
    }

    return null;
  }

  onSocketTaskRemoved(dynamic json) {
    CardMyTask? item = _filterItem(json);
    if (item != null) {
      _cards.removeWhere((element) => element.card.sId == item.card.sId);
    }
  }

  onSocketTaskComplete(dynamic json) {
    CardMyTask? item = _filterItem(json);
    if (item != null) {
      int getIndexItem =
          cards.indexWhere((element) => element.card.sId == item.card.sId);

      if (getIndexItem < 0) {
        bool completeStatus = json['task']?['complete']?['status'] ?? false;

        if (completeStatus == true) {
          _cards.insert(0, item);
        }
      }
    }
  }

  onSocketTaskUpdateStatus(dynamic json) {
    CardMyTask? item = _filterItem(json);
    if (item != null) {
      int getIndexItem =
          cards.indexWhere((element) => element.card.sId == item.card.sId);
      if (getIndexItem >= 0) {
        bool completeStatus = json['task']?['complete']?['status'] ?? false;

        if (completeStatus == false) {
          _cards.removeAt(getIndexItem);
        } else {
          _cards[getIndexItem] = item;
        }
      } else {}
    }
  }

  init() {
    if (cards.isEmpty) {
      getData(1);
      final userString = box.read(KeyStorage.logedInUser);
      MemberModel _templogedInUser = MemberModel.fromJson(userString);
      _socketMyTaskComplete.init('board', _templogedInUser.sId);
      _socketMyTaskComplete.listener(
          onSocketTaskComplete: onSocketTaskComplete,
          onSocketTaskRemoved: onSocketTaskRemoved,
          onSocketTaskUpdateStatus: onSocketTaskUpdateStatus);
    }
  }

  onChangeFilterSelected(List<String> value) {
    getData(1);
  }

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    ever(_myTaskController.listAllIdSelected, onChangeFilterSelected);
  }
}
