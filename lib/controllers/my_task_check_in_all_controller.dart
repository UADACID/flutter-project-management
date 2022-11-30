import 'package:cicle_mobile_f3/models/check_in_model.dart';
import 'package:cicle_mobile_f3/models/comment_item_model.dart';

import 'package:cicle_mobile_f3/models/member_model.dart';
import 'package:cicle_mobile_f3/service/my_task_service.dart';
import 'package:cicle_mobile_f3/utils/constant.dart';
import 'package:cicle_mobile_f3/utils/helpers.dart';
import 'package:cicle_mobile_f3/utils/socket/socket_my_task_all.dart';

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'my_task_controller.dart';

class QuestionMyTask {
  final CheckInModel question;
  final CommentItemModel? lastComment;
  final String teamName;
  final String teamId;

  QuestionMyTask(this.question, this.lastComment, this.teamName, this.teamId);
}

class MyTaskCheckInAllController extends GetxController {
  MyTaskService _myTaskService = MyTaskService();
  MyTaskController _myTaskController = Get.put(MyTaskController());
  SocketMyTaskAll _socketMyTaskAll = SocketMyTaskAll();
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

  var _questions = <QuestionMyTask>[].obs;
  List<QuestionMyTask> get questions => _questions;

  set questions(List<QuestionMyTask> values) {
    _questions.value = [...values];
  }

  Future<void> getData(int nextPageArg) async {
    try {
      isLoading = true;
      errorMessage = '';
      if (nextPageArg == 1) {
        questions = [];
      }

      Map<String, dynamic> params = {
        'limit': 10,
        'page': nextPageArg,
        'sortBy': 'createdAt',
        'orderBy': 'desc',
        'filters[serviceType]': 'Question',
        'filters[complete.status]': 'false',
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
            List<QuestionMyTask> _tempList = [];
            response.data['data'].forEach((o) {
              CheckInModel question = CheckInModel.fromJson(o['service']);

              CommentItemModel? lastComment = o['lastComment'] != null
                  ? CommentItemModel.fromJson(o['lastComment'])
                  : null;

              String teamName = o['team']['name'];
              String teamId = o['team']['_id'];

              _tempList
                  .add(QuestionMyTask(question, lastComment, teamName, teamId));
            });

            questions = _tempList;
          } else {
            // load more

            List<QuestionMyTask> _tempList = [];
            response.data['data'].forEach((o) {
              CheckInModel question = CheckInModel.fromJson(o['service']);

              CommentItemModel? lastComment = o['lastComment'] != null
                  ? CommentItemModel.fromJson(o['lastComment'])
                  : null;

              String teamName = o['team']['name'];
              String teamId = o['team']['_id'];

              questions
                  .add(QuestionMyTask(question, lastComment, teamName, teamId));
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

  QuestionMyTask? _filterItem(dynamic json) {
    if (json['task'] != null) {
      if (json['task']['serviceType'] != null &&
          json['task']['serviceType'] == 'Question') {
        // parsing to model
        CheckInModel question = CheckInModel.fromJson(json['task']['service']);
        CommentItemModel? lastComment = json['task']['lastComment'] != null
            ? CommentItemModel.fromJson(json['task']['lastComment'])
            : null;

        String teamName = json['task']['team']['name'];
        String teamId = json['task']['team']['_id'];
        QuestionMyTask finalItem =
            QuestionMyTask(question, lastComment, teamName, teamId);

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

  getMore() {
    getData(nextPage);
  }

  onSocketTaskAssigned(dynamic json) {
    QuestionMyTask? item = _filterItem(json);
    if (item != null) {
      int getIndexItem = questions
          .indexWhere((element) => element.question.sId == item.question.sId);
      if (getIndexItem < 0) {
        _questions.insert(0, item);
      }
    }
  }

  onSocketTaskRemoved(dynamic json) {
    QuestionMyTask? item = _filterItem(json);
    if (item != null) {
      _questions
          .removeWhere((element) => element.question.sId == item.question.sId);
    }
  }

  onSocketTaskUpdateStatus(dynamic json) {
    QuestionMyTask? item = _filterItem(json);
    if (item != null) {
      int getIndexItem = questions
          .indexWhere((element) => element.question.sId == item.question.sId);
      if (getIndexItem >= 0) {
        bool completeStatus = json['task']?['complete']?['status'] ?? false;
        if (completeStatus == true) {
          _questions.removeAt(getIndexItem);
        } else {
          _questions[getIndexItem] = item;
        }
      }
    }
  }

  init() {
    if (questions.isEmpty) {
      getData(1);
      final userString = box.read(KeyStorage.logedInUser);
      MemberModel _templogedInUser = MemberModel.fromJson(userString);
      _socketMyTaskAll.init(
        'checkIn',
        _templogedInUser.sId,
      );
      _socketMyTaskAll.listener(
          onSocketTaskAssigned: onSocketTaskAssigned,
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

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _socketMyTaskAll.removeListenFromSocket();
  }
}
