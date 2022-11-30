import 'package:cicle_mobile_f3/models/card_model.dart';
import 'package:cicle_mobile_f3/models/comment_item_model.dart';
import 'package:cicle_mobile_f3/models/member_model.dart';

import 'package:cicle_mobile_f3/service/my_task_service.dart';
import 'package:cicle_mobile_f3/utils/constant.dart';
import 'package:cicle_mobile_f3/utils/helpers.dart';
import 'package:cicle_mobile_f3/utils/socket/socket_my_task_duesoon.dart';
import 'package:cicle_mobile_f3/utils/socket/socket_my_task_over_due.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'my_task_controller.dart';
import 'my_task_kanban_done_controller.dart';

class MyTaskKanbanMoreController extends GetxController {
  MyTaskService _myTaskService = MyTaskService();
  MyTaskController _myTaskController = Get.put(MyTaskController());
  String _dueType = Get.parameters['dueType'] ?? '';
  String companyId = Get.parameters['companyId'] ?? '';
  SocketMyTaskOverDue _socketMyTaskOverDue = SocketMyTaskOverDue();
  SocketMyTaskDuesoon _socketMyTaskDuesoon = SocketMyTaskDuesoon();

  final box = GetStorage();

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

  var _cards = <CardMyTask>[].obs;
  List<CardMyTask> get cards => _cards;

  set cards(List<CardMyTask> values) {
    _cards.value = [...values];
  }

  Future<void> getData({loadMore = false}) async {
    try {
      if (loadMore) {
        if (isLoading) {
          return Future.value(false);
        }
      }
      isLoading = true;
      errorMessage = '';
      Map<String, dynamic> params = {};
      if (loadMore) {
        params = {
          'limit': 10,
          'serviceType': 'Card',
          'type': _dueType == 'Overdue' ? 'overdue' : 'dueSoon',
          'team': [
            ..._myTaskController.listHqSelected,
            ..._myTaskController.listProjectSelected,
            ..._myTaskController.listTeamSelected
          ],
          'endDate': cards.last.endDate
        };
      } else {
        params = {
          'limit': 10,
          'serviceType': 'Card',
          'type': _dueType == 'Overdue' ? 'overdue' : 'dueSoon',
          'team': [
            ..._myTaskController.listHqSelected,
            ..._myTaskController.listProjectSelected,
            ..._myTaskController.listTeamSelected
          ]
        };
      }
      final response = await _myTaskService.getDueList(params);

      if (response.statusCode == 200) {
        if (loadMore) {
          response.data['data'].forEach((o) {
            CardModel card = CardModel.fromJson(o['service']);

            CommentItemModel? lastComment = o['lastComment'] != null
                ? CommentItemModel.fromJson(o['lastComment'])
                : null;

            String teamName = o['team']['name'];
            String teamId = o['team']['_id'];
            String endDate = o['endDate'] ?? '';

            cards.add(CardMyTask(card, lastComment, teamName, teamId, endDate));
          });
        } else {
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
                (CardMyTask(card, lastComment, teamName, teamId, endDate)));
          });

          cards = _tempList;
        }
      } else {
        // response selain 200
        showAlert(message: response.statusCode.toString());
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

  onSocketTaskOverdueAssigned(dynamic json) {
    try {
      CardMyTask? item = _filterItem(json);

      if (item != null) {
        int getIndexItem =
            cards.indexWhere((element) => element.card.sId == item.card.sId);

        if (getIndexItem < 0) {
          bool completeStatus = json['task']?['complete']?['status'] ?? false;

          if (completeStatus == false) {
            List<CardMyTask> _tempList = [...cards];
            if (cards.length > 0) {
              DateTime itemEndDate = DateTime.parse(item.endDate);
              DateTime lastItemEndDateOnList =
                  DateTime.parse(cards.last.endDate);

              bool isItemEndDateBeforeLastItemEndDate =
                  itemEndDate.isBefore(lastItemEndDateOnList);

              if (!isItemEndDateBeforeLastItemEndDate) {
                _tempList.add(item);
                _tempList.sort((a, b) => DateTime.parse(b.endDate)
                    .compareTo(DateTime.parse(a.endDate)));

                cards = [..._tempList];
              }
            } else {
              _tempList.add(item);
            }
          }
        }
      }
    } catch (e) {
      print(e);
    }
  }

  onSocketTaskOverdueRemoved(dynamic json) {
    CardMyTask? item = _filterItem(json);
    if (item != null) {
      _cards.removeWhere((element) => element.card.sId == item.card.sId);
    }
  }

  onSocketTaskOverdueUpdateStatus(dynamic json) {
    CardMyTask? item = _filterItem(json);

    if (item != null) {
      int getIndexItem =
          cards.indexWhere((element) => element.card.sId == item.card.sId);
      if (getIndexItem >= 0) {
        bool completeStatus = json['task']?['complete']?['status'] ?? false;

        if (completeStatus == true) {
          _cards.removeAt(getIndexItem);
        } else {
          _cards[getIndexItem] = item;
        }
      }
    }
  }

  getMore() {
    if (cards.isNotEmpty) {
      getData(loadMore: true);
    }
  }

  onChangeFilterSelected(List<String> value) {
    getData();
  }

  @override
  void onInit() async {
    // TODO: implement onInit
    super.onInit();
    await getData();
    final userString = box.read(KeyStorage.logedInUser);
    MemberModel _templogedInUser = MemberModel.fromJson(userString);
    if (_dueType == 'Overdue') {
      _socketMyTaskOverDue.init("board", _templogedInUser.sId, companyId);
      _socketMyTaskOverDue.listener(
          onSocketTaskAssigned: onSocketTaskOverdueAssigned,
          onSocketTaskRemoved: onSocketTaskOverdueRemoved,
          onSocketTaskUpdateStatus: onSocketTaskOverdueUpdateStatus);
    } else {
      _socketMyTaskDuesoon.init("board", _templogedInUser.sId, companyId);
      _socketMyTaskDuesoon.listener(
          onSocketTaskAssigned: onSocketTaskOverdueAssigned,
          onSocketTaskRemoved: onSocketTaskOverdueRemoved,
          onSocketTaskUpdateStatus: onSocketTaskOverdueUpdateStatus);
    }

    ever(_myTaskController.listAllIdSelected, onChangeFilterSelected);
  }
}
