import 'package:cicle_mobile_f3/controllers/my_task_controller.dart';
import 'package:cicle_mobile_f3/models/card_model.dart';
import 'package:cicle_mobile_f3/models/comment_item_model.dart';
import 'package:cicle_mobile_f3/models/member_model.dart';

import 'package:cicle_mobile_f3/service/my_task_service.dart';
import 'package:cicle_mobile_f3/utils/constant.dart';
import 'package:cicle_mobile_f3/utils/helpers.dart';
import 'package:cicle_mobile_f3/utils/socket/socket_my_task_duesoon.dart';
import 'package:cicle_mobile_f3/utils/socket/socket_my_task_over_due.dart';
import 'package:easy_debounce/easy_debounce.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'my_task_kanban_done_controller.dart';

class MyTaskKanbanAllController extends GetxController {
  MyTaskService _myTaskService = MyTaskService();
  MyTaskController _myTaskController = Get.put(MyTaskController());
  final box = GetStorage();
  SocketMyTaskOverDue _socketMyTaskOverDue = SocketMyTaskOverDue();
  SocketMyTaskDuesoon _socketMyTaskDuesoon = SocketMyTaskDuesoon();

  String companyId = Get.parameters['companyId'] ?? '';

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

  var _cardsOverdue = <CardMyTask>[].obs;
  List<CardMyTask> get cardsOverdue => _cardsOverdue;

  set cardsOverdue(List<CardMyTask> values) {
    _cardsOverdue.value = [...values];
  }

  var overDueMore = 0.obs;

  var _cardsDueSoon = <CardMyTask>[].obs;
  List<CardMyTask> get cardsDueSoon => _cardsDueSoon;

  set cardsDueSoon(List<CardMyTask> values) {
    _cardsDueSoon.value = [...values];
  }

  var dueSoonMore = 0.obs;

  Future<void> getData({needLoading = true}) async {
    try {
      if (needLoading) {
        isLoading = true;
      }

      errorMessage = '';

      Map<String, dynamic> params = {
        'limit': 2,
        'serviceType': 'Card',
        // 'team': '61bac289f975c4fff8730a45',
        // 'team': '5f96aca4fda1b79882cfda16'
        'team': [
          ..._myTaskController.listHqSelected,
          ..._myTaskController.listProjectSelected,
          ..._myTaskController.listTeamSelected
        ]
      };
      final response = await _myTaskService.getDueList(params);

      if (response.statusCode == 200) {
        // field overdue
        List<CardMyTask> _tempListOverdue = [];
        List<CardMyTask> _tempListDueSoon = [];
        if (response.data['data'] != null &&
            response.data['data']['overdue'] != null &&
            response.data['data']['overdue']['data'] != null) {
          response.data['data']["overdue"]['data'].forEach((o) {
            CardModel card = CardModel.fromJson(o['service']);

            CommentItemModel? lastComment = o['lastComment'] != null
                ? CommentItemModel.fromJson(o['lastComment'])
                : null;

            String teamName = o['team']['name'];
            String teamId = o['team']['_id'];
            String endDate = o['endDate'] ?? '';

            _tempListOverdue
                .add(CardMyTask(card, lastComment, teamName, teamId, endDate));
          });

          overDueMore.value =
              response.data['data']['overdue']['totalMore'] ?? 0;
        }
        cardsOverdue = [..._tempListOverdue];

        if (response.data['data'] != null &&
            response.data['data']['dueSoon'] != null &&
            response.data['data']['dueSoon']['data'] != null) {
          response.data['data']["dueSoon"]['data'].forEach((o) {
            CardModel card = CardModel.fromJson(o['service']);

            CommentItemModel? lastComment = o['lastComment'] != null
                ? CommentItemModel.fromJson(o['lastComment'])
                : null;

            String teamName = o['team']['name'];
            String teamId = o['team']['_id'];
            String endDate = o['endDate'] ?? '';

            _tempListDueSoon
                .add(CardMyTask(card, lastComment, teamName, teamId, endDate));
          });

          dueSoonMore.value =
              response.data['data']["dueSoon"]['totalMore'] ?? 0;
        }
        cardsDueSoon = [..._tempListDueSoon];
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
    CardMyTask? item = _filterItem(json);
    if (item != null) {
      _getDataForSocket();
    }
  }

  onSocketTaskOverdueRemoved(dynamic json) {
    CardMyTask? item = _filterItem(json);
    if (item != null) {
      _getDataForSocket();
      print('get data on task removed');
    }
  }

  onSocketTaskOverdueUpdateStatus(dynamic json) {
    CardMyTask? item = _filterItem(json);
    if (item != null) {
      _getDataForSocket();
    }
  }

  onSocketTaskDueSoonAssigned(dynamic json) {
    CardMyTask? item = _filterItem(json);
    if (item != null) {
      _getDataForSocket();
    }
  }

  onSocketTaskDueSoonRemoved(dynamic json) {
    CardMyTask? item = _filterItem(json);
    if (item != null) {
      _getDataForSocket();
    }
  }

  onSocketTaskDueSoonUpdateStatus(dynamic json) {
    CardMyTask? item = _filterItem(json);
    if (item != null) {
      _getDataForSocket();
    }
  }

  _getDataForSocket() {
    EasyDebounce.debounce(
        'submit-add-check-in', // <-- An ID for this particular debouncer
        Duration(milliseconds: 300), // <-- The debounce duration
        () => getData(needLoading: false) // <-- The target method
        );
  }

  init() async {
    if (cardsOverdue.isEmpty && cardsDueSoon.isEmpty) {
      await getData();
      final userString = box.read(KeyStorage.logedInUser);
      MemberModel _templogedInUser = MemberModel.fromJson(userString);
      _socketMyTaskOverDue.init("board", _templogedInUser.sId, companyId);
      _socketMyTaskOverDue.listener(
          onSocketTaskAssigned: onSocketTaskOverdueAssigned,
          onSocketTaskRemoved: onSocketTaskOverdueRemoved,
          onSocketTaskUpdateStatus: onSocketTaskOverdueUpdateStatus);

      _socketMyTaskDuesoon.init("board", _templogedInUser.sId, companyId);
      _socketMyTaskDuesoon.listener(
          onSocketTaskAssigned: onSocketTaskDueSoonAssigned,
          onSocketTaskRemoved: onSocketTaskDueSoonRemoved,
          onSocketTaskUpdateStatus: onSocketTaskDueSoonUpdateStatus);
    }
  }

  onChangeFilterSelected(List<String> value) {
    getData();
  }

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    ever(_myTaskController.listAllIdSelected, onChangeFilterSelected);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _socketMyTaskOverDue.removeListenFromSocket();
    _socketMyTaskDuesoon.removeListenFromSocket();
  }
}
