import 'package:cicle_mobile_f3/models/comment_item_model.dart';
import 'package:cicle_mobile_f3/models/member_model.dart';
import 'package:cicle_mobile_f3/models/post_item_model.dart';

import 'package:cicle_mobile_f3/service/my_task_service.dart';
import 'package:cicle_mobile_f3/utils/constant.dart';
import 'package:cicle_mobile_f3/utils/helpers.dart';
import 'package:cicle_mobile_f3/utils/socket/socket_my_task_complete.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'my_task_controller.dart';

class PostMyTask {
  final PostItemModel post;
  final CommentItemModel? lastComment;
  final String teamName;
  final String teamId;
  final String endDate;

  PostMyTask(
      this.post, this.lastComment, this.teamName, this.endDate, this.teamId);
}

class MyTaskBlastDoneController extends GetxController {
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

  var _posts = <PostMyTask>[].obs;
  List<PostMyTask> get posts => _posts;

  set posts(List<PostMyTask> values) {
    _posts.value = [...values];
  }

  Future<void> getData(int nextPageArg) async {
    try {
      isLoading = true;
      errorMessage = '';
      if (nextPageArg == 1) {
        posts = [];
      }

      Map<String, dynamic> params = {
        'limit': 5,
        'page': nextPageArg,
        'sortBy': 'createdAt',
        'orderBy': 'desc',
        'filters[serviceType]': 'Post',
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
            List<PostMyTask> _tempList = [];
            response.data['data'].forEach((o) {
              PostItemModel post = PostItemModel.fromJson(o['service']);

              CommentItemModel? lastComment = o['lastComment'] != null
                  ? CommentItemModel.fromJson(o['lastComment'])
                  : null;

              String teamName = o['team']['name'];
              String teamId = o['team']['_id'];
              String endDate = o['endDate'] ?? '';

              _tempList.add(
                  PostMyTask(post, lastComment, teamName, endDate, teamId));
            });

            posts = _tempList;
          } else {
            // load more

            response.data['data'].forEach((o) {
              PostItemModel post = PostItemModel.fromJson(o['service']);

              CommentItemModel? lastComment = o['lastComment'] != null
                  ? CommentItemModel.fromJson(o['lastComment'])
                  : null;

              String teamName = o['team']['name'];
              String teamId = o['team']['_id'];
              String endDate = o['endDate'] ?? '';

              posts.add(
                  PostMyTask(post, lastComment, teamName, endDate, teamId));
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

  PostMyTask? _filterItem(dynamic json) {
    if (json['task'] != null) {
      if (json['task']['serviceType'] != null &&
          json['task']['serviceType'] == 'Post') {
        // parsing to model
        PostItemModel post = PostItemModel.fromJson(json['task']['service']);
        CommentItemModel? lastComment = json['task']['lastComment'] != null
            ? CommentItemModel.fromJson(json['task']['lastComment'])
            : null;

        String teamName = json['task']['team']['name'];
        String teamId = json['task']['team']['_id'];
        String endDate = json['task']['endDate'] ?? '';
        PostMyTask finalItem =
            PostMyTask(post, lastComment, teamName, endDate, teamId);

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
    PostMyTask? item = _filterItem(json);
    if (item != null) {
      _posts.removeWhere((element) => element.post.sId == item.post.sId);
    }
  }

  onSocketTaskComplete(dynamic json) {
    // rechive new task
    PostMyTask? item = _filterItem(json);
    if (item != null) {
      int getIndexItem =
          posts.indexWhere((element) => element.post.sId == item.post.sId);

      if (getIndexItem < 0) {
        bool completeStatus = json['task']?['complete']?['status'] ?? false;

        if (completeStatus == true) {
          _posts.insert(0, item);
        }
      }
    }
  }

  onSocketTaskUpdateStatus(dynamic json) {
    // remove from done

    PostMyTask? item = _filterItem(json);
    if (item != null) {
      int getIndexItem =
          posts.indexWhere((element) => element.post.sId == item.post.sId);
      if (getIndexItem >= 0) {
        bool completeStatus = json['task']?['complete']?['status'] ?? false;

        if (completeStatus == false) {
          _posts.removeAt(getIndexItem);
        } else {
          _posts[getIndexItem] = item;
        }
      }
    }
  }

  init() {
    if (posts.isEmpty) {
      getData(1);
      final userString = box.read(KeyStorage.logedInUser);
      MemberModel _templogedInUser = MemberModel.fromJson(userString);
      _socketMyTaskComplete.init('blast', _templogedInUser.sId);
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

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _socketMyTaskComplete.removeListenFromSocket();
  }
}
