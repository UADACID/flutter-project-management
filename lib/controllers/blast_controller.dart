// import 'package:cicle_mobile_f3/controllers/company_controller.dart';
// import 'package:cicle_mobile_f3/controllers/team_detail_controller.dart';
// import 'package:cicle_mobile_f3/models/member_model.dart';
// import 'package:cicle_mobile_f3/models/post_item_model.dart';
// import 'package:cicle_mobile_f3/service/blast_service.dart';
// import 'package:cicle_mobile_f3/utils/constant.dart';
// import 'package:cicle_mobile_f3/utils/helpers.dart';
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:socket_io_client/socket_io_client.dart';

import '../models/member_model.dart';
import '../models/post_item_model.dart';
import '../service/blast_service.dart';
import '../utils/constant.dart';
import '../utils/helpers.dart';
import 'company_controller.dart';
import 'team_detail_controller.dart';

class BlastController extends GetxController {
  final box = GetStorage();
  BlastService _blastService = BlastService();
  TeamDetailController _teamDetailController = Get.find();

  Socket localSocket = io('${Env.BASE_URL}/blast');

  var _logedInUserId = ''.obs;
  String get logedInUserId => _logedInUserId.value;

  var _isLoading = false.obs;
  bool get isLoading => _isLoading.value;
  set isLoading(bool value) {
    _isLoading.value = value;
  }

  var _posts = <PostItemModel>[].obs;
  List<PostItemModel> get posts => _posts;
  set posts(List<PostItemModel> value) {
    _posts.value = [...value];
  }

  var _listPostIdInProgress = <String>[].obs;
  List<String> get listPostIdInProgress => _listPostIdInProgress;

  addListPostIdInProgress(String id) {
    _listPostIdInProgress.add(id);
  }

  removeListPostIdInProgress(String id) {
    _listPostIdInProgress.remove(id);
  }

  Future<List<PostItemModel>> getPosts() async {
    try {
      if (_teamDetailController.blastId == '') {
        await _teamDetailController.getTeam();
      }
      final response =
          await _blastService.getPosts(_teamDetailController.blastId);

      if (response.data['blasts'] != null) {
        posts = [];

        response.data['blasts'].forEach((v) {
          _posts.add(PostItemModel.fromJson(v));
        });
      }
      return Future.value(_posts);
    } catch (e) {
      print(e);
      if (e is DioError) {
        showAlert(message: e.response!.statusCode.toString());
      }
      return Future.value([]);
    }
  }

  Future<List<PostItemModel>> getMorePosts() async {
    if (_posts.length == 0) {
      return Future.value([]);
    }
    String blastId = _teamDetailController.blastId;
    try {
      String lastCreatedAt = posts.last.createdAt;
      dynamic queryParams = {"limit": 10, "createdAt": lastCreatedAt};
      final response = await _blastService.getMorePosts(blastId, queryParams);
      if (response.data['blasts'] != null) {
        response.data['blasts'].forEach((v) {
          _posts.add(PostItemModel.fromJson(v));
        });
      }

      return Future.value(_posts);
    } catch (e) {
      print(e);
      return Future.value([]);
    }
  }

  Future<PostItemModel> archivePost(String postId) async {
    final response = await _blastService.archivePost(postId);

    PostItemModel _post = PostItemModel.fromJson(response.data['post']);
    return Future.value(_post);
  }

  Future<List<PostItemModel>> createPost(String blastId, dynamic body) async {
    try {
      final response = await _blastService.createPost(blastId, body);
      List<PostItemModel> _postList = [];
      if (response.data['blast']['posts'] != null) {
        response.data['blast']['posts'].forEach((v) {
          _postList.add(PostItemModel.fromJson(v));
        });
        return Future.value(_postList);
      } else {
        return Future.value(_postList);
      }
    } catch (e) {
      print(e);
      return Future.value([]);
    }
  }

  listenFromSocket() {
    String blastId = _teamDetailController.blastId;
    String socketURi =
        '${Env.BASE_URL_SOCKET}/socket/blasts/$blastId?userId=$logedInUserId';

    localSocket = io(
        socketURi,
        OptionBuilder()
            .setTransports(['websocket']) // for Flutter or Dart VM
            .disableAutoConnect() // disable auto-connection/ optional
            .build());
    localSocket.connect();
    socketStatus();
    localSocket.on('post-new-$blastId', onSocketPostNew);
    localSocket.on('post-update-$blastId', onSocketPostUpdate);
    localSocket.on('post-archive-$blastId', onSocketPostArchive);
  }

  onSocketPostNew(data) {
    PostItemModel _post = PostItemModel.fromJson(data);
    int isPostExist = _posts.indexWhere((element) => element.sId == _post.sId);
    if (isPostExist < 0) {
      _posts.insert(0, _post);
    }
  }

  onSocketPostUpdate(data) {
    PostItemModel _post = PostItemModel.fromJson(data);
    int index = _posts.indexWhere((element) => element.sId == _post.sId);
    CompanyController _companyController = Get.find();
    List<MemberModel> admins = _companyController.currentCompany.admins ?? [];
    var isLogedInUserIdAdmin =
        admins.where((element) => element.sId == logedInUserId).length;
    if (index >= 0) {
      // check apakah current userid adalah admin
      // check apakah current userid adalah members
      // check apakah current userid adalah creator
      // check apakah post itu public

      if (isLogedInUserIdAdmin == 0) {
        // bukan admin
        if (_post.isPublic) {
          _posts[index] = _post;
        } else {
          var isLogedInUserMember = _post.subscribers
              .where((element) => element.sId == logedInUserId)
              .length;
          var isLogedInUserCreator = _post.creator.sId == logedInUserId;
          if (isLogedInUserCreator == true || isLogedInUserMember > 0) {
            _posts[index] = _post;
          } else {
            _posts.removeWhere((element) => element.sId == _post.sId);
          }
        }
      } else {
        _posts[index] = _post;
      }
    } else {
      if (isLogedInUserIdAdmin == 0) {
        // bukan admin
        if (_post.isPublic) {
          _posts.insert(0, _post);
        } else {
          var isLogedInUserMember = _post.subscribers
              .where((element) => element.sId == logedInUserId)
              .length;
          var isLogedInUserCreator = _post.creator.sId == logedInUserId;
          if (isLogedInUserCreator == true || isLogedInUserMember > 0) {
            _posts.insert(0, _post);
          }
        }
      } else {
        _posts.insert(0, _post);
      }
    }
  }

  onSocketPostArchive(data) {
    PostItemModel _post = PostItemModel.fromJson(data);
    int index = _posts.indexWhere((element) => element.sId == _post.sId);
    if (index >= 0) {
      _posts.removeAt(index);
    }
  }

  socketStatus() {
    localSocket.onConnect((data) => print('on connect socket blast'));
    localSocket.onDisconnect((data) {
      print('disconnect blast');
      localSocket.connect();
    });
    localSocket.onConnectError((data) {
      print('onConnectError blast');
    });

    localSocket.onConnectTimeout((data) {
      print('onConnectTimeout blast');
    });
  }

  removeListenFromSocket() {
    String blastId = _teamDetailController.blastId;
    localSocket.off('post-new-$blastId');
    localSocket.off('post-update-$blastId');
    localSocket.off('post-archive-$blastId');
  }

  init() async {
    if (posts.isEmpty) {
      isLoading = true;
      await getPosts();
      isLoading = false;
      listenFromSocket();
    }
  }

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
    removeListenFromSocket();
  }
}
