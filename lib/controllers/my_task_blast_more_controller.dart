import 'package:cicle_mobile_f3/models/comment_item_model.dart';
import 'package:cicle_mobile_f3/models/member_model.dart';
import 'package:cicle_mobile_f3/models/post_item_model.dart';
import 'package:cicle_mobile_f3/service/my_task_service.dart';
import 'package:cicle_mobile_f3/utils/constant.dart';
import 'package:cicle_mobile_f3/utils/helpers.dart';
import 'package:cicle_mobile_f3/utils/socket/socket_my_task_duesoon.dart';
import 'package:cicle_mobile_f3/utils/socket/socket_my_task_over_due.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'my_task_blast_done_controller.dart';
import 'my_task_controller.dart';

class MyTaskBlastMoreController extends GetxController {
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

  var _posts = <PostMyTask>[].obs;
  List<PostMyTask> get posts => _posts;

  set posts(List<PostMyTask> values) {
    _posts.value = [...values];
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
          'limit': 5,
          'serviceType': 'Post',
          'type': _dueType == 'Overdue' ? 'overdue' : 'dueSoon',
          'team': [
            ..._myTaskController.listHqSelected,
            ..._myTaskController.listProjectSelected,
            ..._myTaskController.listTeamSelected
          ],
          'endDate': posts.last.endDate
        };
      } else {
        params = {
          'limit': 5,
          'serviceType': 'Post',
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
            PostItemModel post = PostItemModel.fromJson(o['service']);

            CommentItemModel? lastComment = o['lastComment'] != null
                ? CommentItemModel.fromJson(o['lastComment'])
                : null;

            String teamName = o['team']['name'];
            String teamId = o['team']['_id'];
            String endDate = o['endDate'] ?? '';

            posts.add(PostMyTask(post, lastComment, teamName, endDate, teamId));
          });
        } else {
          List<PostMyTask> _tempList = [];
          response.data['data'].forEach((o) {
            PostItemModel post = PostItemModel.fromJson(o['service']);

            CommentItemModel? lastComment = o['lastComment'] != null
                ? CommentItemModel.fromJson(o['lastComment'])
                : null;

            String teamName = o['team']['name'];
            String teamId = o['team']['_id'];
            String endDate = o['endDate'] ?? '';

            _tempList
                .add(PostMyTask(post, lastComment, teamName, endDate, teamId));
          });

          posts = _tempList;
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

  getMore() {
    if (posts.isNotEmpty) {
      getData(loadMore: true);
    }
  }

  onChangeFilterSelected(List<String> value) {
    getData();
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

  onSocketTaskOverdueAssigned(dynamic json) {
    try {
      PostMyTask? item = _filterItem(json);

      if (item != null) {
        int getIndexItem =
            posts.indexWhere((element) => element.post.sId == item.post.sId);

        if (getIndexItem < 0) {
          bool completeStatus = json['task']?['complete']?['status'] ?? false;

          if (completeStatus == false) {
            List<PostMyTask> _tempList = [...posts];
            if (posts.length > 0) {
              DateTime itemEndDate = DateTime.parse(item.endDate);
              DateTime lastItemEndDateOnList =
                  DateTime.parse(posts.last.endDate);

              bool isItemEndDateBeforeLastItemEndDate =
                  itemEndDate.isBefore(lastItemEndDateOnList);

              if (!isItemEndDateBeforeLastItemEndDate) {
                _tempList.add(item);
                _tempList.sort((a, b) => DateTime.parse(b.endDate)
                    .compareTo(DateTime.parse(a.endDate)));
                posts = [..._tempList];
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
    PostMyTask? item = _filterItem(json);
    if (item != null) {
      _posts.removeWhere((element) => element.post.sId == item.post.sId);
    }
  }

  onSocketTaskOverdueUpdateStatus(dynamic json) {
    PostMyTask? item = _filterItem(json);

    if (item != null) {
      int getIndexItem =
          posts.indexWhere((element) => element.post.sId == item.post.sId);
      if (getIndexItem >= 0) {
        bool completeStatus = json['task']?['complete']?['status'] ?? false;

        if (completeStatus == true) {
          _posts.removeAt(getIndexItem);
        } else {
          _posts[getIndexItem] = item;
        }
      }
    }
  }

  @override
  void onInit() async {
    // TODO: implement onInit
    super.onInit();
    await getData();
    final userString = box.read(KeyStorage.logedInUser);
    MemberModel _templogedInUser = MemberModel.fromJson(userString);
    if (_dueType == 'Overdue') {
      _socketMyTaskOverDue.init("blast", _templogedInUser.sId, companyId);
      _socketMyTaskOverDue.listener(
          onSocketTaskAssigned: onSocketTaskOverdueAssigned,
          onSocketTaskRemoved: onSocketTaskOverdueRemoved,
          onSocketTaskUpdateStatus: onSocketTaskOverdueUpdateStatus);
    } else {
      _socketMyTaskDuesoon.init("blast", _templogedInUser.sId, companyId);
      _socketMyTaskDuesoon.listener(
          onSocketTaskAssigned: onSocketTaskOverdueAssigned,
          onSocketTaskRemoved: onSocketTaskOverdueRemoved,
          onSocketTaskUpdateStatus: onSocketTaskOverdueUpdateStatus);
    }
    ever(_myTaskController.listAllIdSelected, onChangeFilterSelected);
  }
}
