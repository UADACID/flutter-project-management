import 'package:cicle_mobile_f3/models/cheer_item_model.dart';
import 'package:cicle_mobile_f3/models/comment_item_model.dart';
import 'package:cicle_mobile_f3/models/member_model.dart';
import 'package:cicle_mobile_f3/service/comment_service.dart';
import 'package:cicle_mobile_f3/service/doc_file_service.dart';
import 'package:cicle_mobile_f3/utils/constant.dart';
import 'package:cicle_mobile_f3/utils/helpers.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';

import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:rich_editor/rich_editor.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:image_picker/image_picker.dart' as sourceType;

class CommentController extends GetxController {
  final box = GetStorage();
  CommentService _commentService = CommentService();
  DocFileService _docFileService = DocFileService();
  // FORM ADD COMMENT
  GlobalKey<RichEditorState> keyEditor = GlobalKey();
  final ItemScrollController itemScrollController = ItemScrollController();

  /// Listener that reports the position of items when the list is scrolled.
  final ItemPositionsListener itemPositionsListener =
      ItemPositionsListener.create();

  RefreshController refreshController =
      RefreshController(initialRefresh: false);

  ScrollController tempContentAddCommentScrollController = ScrollController();

  var keyboardVisibilityController = KeyboardVisibilityController();

  // comment detail purpose
  String moduleNameParams = Get.parameters['moduleName'] ?? '';
  String moduleIdParams = Get.parameters['moduleId'] ?? '';
  String commentIdParams = Get.parameters['commentId'] ?? '';

  late String _occurenceId;
  setOccurenceId(String occurenceId) {
    _occurenceId = occurenceId;
  }

  setBaseUrlModule(String typeAsParams, String? moduleIdAsParams) {
    moduleId = moduleIdAsParams!;

    switch (typeAsParams) {
      case 'card':
        _typeModule.value = typeAsParams;
        _baseUrlModule.value =
            '${Env.BASE_URL}/v2/cards/$moduleIdAsParams/comments';
        _baseUrlCreateModule.value =
            '${Env.BASE_URL}/api/v1/cards/$moduleIdAsParams/comments';
        _baseUrlArchiveModule.value =
            '${Env.BASE_URL}/api/v1/cards/$moduleIdAsParams/comments';
        _baseUrlAddCheerModule.value =
            '${Env.BASE_URL}/api/v1/cards/$moduleIdAsParams/comments';
        return;

      case 'blast':
        _typeModule.value = typeAsParams;
        _baseUrlModule.value =
            '${Env.BASE_URL}/v2/posts/$moduleIdAsParams/comments';
        _baseUrlCreateModule.value =
            '${Env.BASE_URL}/api/v1/posts/$moduleIdAsParams/comments';
        _baseUrlArchiveModule.value =
            '${Env.BASE_URL}/api/v1/posts/$moduleIdAsParams/comments';
        _baseUrlAddCheerModule.value =
            '${Env.BASE_URL}/api/v1/posts/$moduleIdAsParams/comments';
        return;

      case 'question':
        _typeModule.value = typeAsParams;
        _baseUrlModule.value =
            '${Env.BASE_URL}/v2/questions/$moduleIdAsParams/comments';
        _baseUrlCreateModule.value =
            '${Env.BASE_URL}/api/v1/questions/$moduleIdAsParams/comments';
        _baseUrlArchiveModule.value =
            '${Env.BASE_URL}/api/v1/questions/$moduleIdAsParams/comments';
        _baseUrlAddCheerModule.value =
            '${Env.BASE_URL}/api/v1/questions/$moduleIdAsParams/comments';
        return;

      case 'doc':
        _typeModule.value = typeAsParams;
        _baseUrlModule.value =
            '${Env.BASE_URL}/v2/docs/$moduleIdAsParams/comments';
        _baseUrlCreateModule.value =
            '${Env.BASE_URL}/api/v1/docs/$moduleIdAsParams/comments';
        _baseUrlArchiveModule.value =
            '${Env.BASE_URL}/api/v1/docs/$moduleIdAsParams/comments';
        _baseUrlAddCheerModule.value =
            '${Env.BASE_URL}/api/v1/docs/$moduleIdAsParams/comments';
        return;

      case 'file':
        _typeModule.value = typeAsParams;
        _baseUrlModule.value =
            '${Env.BASE_URL}/v2/files/$moduleIdAsParams/comments';
        _baseUrlCreateModule.value =
            '${Env.BASE_URL}/api/v1/files/$moduleIdAsParams/comments';
        _baseUrlArchiveModule.value =
            '${Env.BASE_URL}/api/v1/files/$moduleIdAsParams/comments';
        _baseUrlAddCheerModule.value =
            '${Env.BASE_URL}/api/v1/files/$moduleIdAsParams/comments';
        return;

      case 'event':
        _typeModule.value = typeAsParams;
        _baseUrlModule.value =
            '${Env.BASE_URL}/v2/events/$moduleIdAsParams/comments';
        _baseUrlCreateModule.value =
            '${Env.BASE_URL}/api/v1/events/$moduleIdAsParams/comments';
        _baseUrlArchiveModule.value =
            '${Env.BASE_URL}/api/v1/events/$moduleIdAsParams/comments';
        _baseUrlAddCheerModule.value =
            '${Env.BASE_URL}/api/v1/events/$moduleIdAsParams/comments';
        return;

      case 'occurrence':
        _typeModule.value = typeAsParams;
        _baseUrlModule.value =
            '${Env.BASE_URL}/v2/events/$moduleIdAsParams/occurrences/$_occurenceId/comments';
        _baseUrlCreateModule.value =
            '${Env.BASE_URL}/api/v1/events/$moduleIdAsParams/occurrences/$_occurenceId/comments';
        _baseUrlArchiveModule.value =
            '${Env.BASE_URL}/api/v1/events/$moduleIdAsParams/occurrences/$_occurenceId/comments';
        _baseUrlAddCheerModule.value =
            '${Env.BASE_URL}/api/v1/events/$moduleIdAsParams/occurrences/$_occurenceId/comments';
        return;

      case 'occurrenceCardDiscussion':
        _typeModule.value = 'occurrenceCardDiscussion';
        String occurrenceId = moduleIdAsParams;

        _baseUrlModule.value =
            '${Env.BASE_URL}/v2/comments/$commentIdParams/discussions';

        _baseUrlCreateModule.value =
            '${Env.BASE_URL}/api/v1/events/$moduleIdParams/occurrences/$occurrenceId/comments/$commentIdParams/discussions';

        _baseUrlArchiveModule.value =
            '${Env.BASE_URL}/api/v1/events/$moduleIdParams/occurrences/$occurrenceId/comments/$commentIdParams/discussions';

        _baseUrlAddCheerModule.value =
            '${Env.BASE_URL}/api/v1/events/$moduleIdParams/occurrences/$occurrenceId/comments/$commentIdParams/discussions';

        return;

      case 'cardDiscussion':
        _typeModule.value = typeAsParams;

        _baseUrlModule.value =
            '${Env.BASE_URL}/v2/comments/$commentIdParams/discussions';

        _baseUrlCreateModule.value =
            '${Env.BASE_URL}/api/v1/${moduleNameAdapter(moduleNameParams)}/$moduleIdParams/comments/$commentIdParams/discussions';

        _baseUrlArchiveModule.value =
            '${Env.BASE_URL}/api/v1/${moduleNameAdapter(moduleNameParams)}/$moduleIdParams/comments/$commentIdParams/discussions';

        _baseUrlAddCheerModule.value =
            '${Env.BASE_URL}/api/v1/${moduleNameAdapter(moduleNameParams)}/$moduleIdParams/comments/$commentIdParams/discussions';
        return;
      default:
        _typeModule.value = '';
        _baseUrlModule.value = '';
        _baseUrlCreateModule.value = '';
        _baseUrlArchiveModule.value = '';
        return;
    }
  }

  var _tempContentAddComment = ''.obs;
  String get tempContentAddComment => _tempContentAddComment.value;
  set tempContentAddComment(String value) {
    _tempContentAddComment.value = value;
  }

  var _moduleId = ''.obs;
  String get moduleId => _moduleId.value;
  set moduleId(String value) {
    _moduleId.value = value;
  }

  var _typeModule = ''.obs;
  String get typeModule => _typeModule.value;
  set typeModule(String value) {
    _typeModule.value = value;
  }

  var _baseUrlModule = ''.obs;
  String get baseUrlModule => _baseUrlModule.value;
  set baseUrlModule(String value) {
    _baseUrlModule.value = value;
  }

  var _baseUrlCreateModule = ''.obs;
  String get baseUrlCreateModule => _baseUrlCreateModule.value;
  set baseUrlCreateModule(String value) {
    _baseUrlCreateModule.value = value;
  }

  var _baseUrlArchiveModule = ''.obs;
  String get baseUrlArchiveModule => _baseUrlArchiveModule.value;
  set baseUrlArchiveModule(String value) {
    _baseUrlArchiveModule.value = value;
  }

  var _baseUrlAddCheerModule = ''.obs;
  String get baseUrlAddCheerModule => _baseUrlAddCheerModule.value;
  set baseUrlAddCheerModule(String value) {
    _baseUrlAddCheerModule.value = value;
  }

  var _listMentionmembers = <MemberModel>[].obs;
  List<MemberModel> get listMentionmembers => _listMentionmembers;
  set listMentionmembers(List<MemberModel> value) {
    _listMentionmembers.value = value;
  }

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();

    final userString = box.read(KeyStorage.logedInUser);
    MemberModel logedInUser = MemberModel.fromJson(userString);

    _logedInUserId.value = logedInUser.sId;
    tempContentAddComment = "";
    listenKeyboardEvent();
  }

  listenKeyboardEvent() {
    // Subscribe
    keyboardVisibilityController.onChange.listen((bool visible) {
      if (!visible) {
        if (keyEditor.currentState != null) {
          keyEditor.currentState?.unFocus();
        }
      }
    });
  }

  var _logedInUserId = ''.obs;
  String get logedInUserId => _logedInUserId.value;

  var _heightOfContent = 31.obs;

  int get heightOfContent => _heightOfContent.value;

  set heightOfContent(int value) {
    _heightOfContent.value = value;
  }

  var _showForm = false.obs;
  bool get showForm => _showForm.value;
  set showForm(bool value) {
    _showForm.value = value;
  }

  // LIST COMMENTS
  var _comments = <CommentItemModel>[].obs;

  List<CommentItemModel> get comments {
    var _tempList = [..._comments];
    _tempList.sort((b, a) =>
        DateTime.parse(a.createdAt).compareTo(DateTime.parse(b.createdAt)));
    return _tempList;
  }

  addComment(CommentItemModel item) async {
    if (baseUrlCreateModule == '') {
      return;
    }
    try {
      dynamic body = {
        "content": item.content,
        "mentionedUsers": getMentionedUsers(item.content, listMentionmembers),
        "type": typeModule
      };

      loadingCreate = true;
      final response =
          await _commentService.createComment(baseUrlCreateModule, body);
      tempContentAddComment = "";

      if (typeModule == 'cardDiscussion' ||
          typeModule == 'occurrenceCardDiscussion') {
        if (response.data['discussion'] != null) {
          CommentItemModel _commentAsResponse =
              CommentItemModel.fromJson(response.data['discussion']);

          int selectedIndex = _comments
              .indexWhere((element) => element.sId == _commentAsResponse.sId);

          if (selectedIndex < 0) {
            _comments.add(_commentAsResponse);
          }

          loadingCreate = false;
          return;
        }
      }

      if (response.data['comment'] != null) {
        CommentItemModel _commentAsResponse =
            CommentItemModel.fromJson(response.data['comment']);

        int selectedIndex = _comments
            .indexWhere((element) => element.sId == _commentAsResponse.sId);

        if (selectedIndex < 0) {
          _comments.add(_commentAsResponse);
        }
        loadingCreate = false;
        return;
      }
      loadingCreate = false;
    } catch (e) {
      print(e);
      loadingCreate = false;
      errorMessageMiddleware(e);
    }
  }

  deleteComment(String id) async {
    int index = _comments.indexWhere((element) => element.sId == id);
    var _selectedComment;
    if (index >= 0) {
      _selectedComment = _comments[index];
      _comments.removeAt(index);
    }

    try {
      await _commentService.archiveComment(baseUrlArchiveModule, id);

      showAlert(message: 'your comment has been archived');
    } catch (e) {
      if (index >= 0) {
        _comments.insert(index, _selectedComment);
      }
      print(e);
    }
  }

  editComment(String id, String newContent) async {
    int index = _comments.indexWhere((element) => element.sId == id);
    if (index >= 0) {
      List<CommentItemModel> _tempList = List.from(_comments);
      _tempList[index].content = newContent;
      _comments.value = [..._tempList];
      try {
        dynamic body = {
          "content": newContent,
          "mentionedUsers": getMentionedUsers(newContent, listMentionmembers),
          "type": typeModule
        };
        await _commentService.editComment(baseUrlCreateModule, id, body);

        showAlert(message: 'your comment has been edited');
      } catch (e) {
        print(e);
        if (e is DioError) {
          showAlert(message: e.message, messageColor: Colors.red);
        }
      }
    }
  }

  set comments(List<CommentItemModel> list) {
    _comments.value = [...list];
  }

  // SELECTED FORM ADD CHEERS
  var _selectedCommentIdFormCheers = ''.obs;

  String get selectedCommentIdFormCheers => _selectedCommentIdFormCheers.value;

  set selectedCommentIdFormCheers(String id) {
    _selectedCommentIdFormCheers.value = id;

    Future.delayed(Duration(seconds: 1), () {
      keyEditor.currentState?.clear();
    });
  }

  addCheersToComment(String commentId, String content, String receiver) async {
    if (content.isEmpty) {
      return;
    }
    int index = _comments.indexWhere((element) => element.sId == commentId);

    try {
      dynamic body = {"content": content, "receiver": receiver};
      final response = await _commentService.addCheerComment(
          baseUrlAddCheerModule, commentId, body);

      CheerItemModel cheersAsResponse =
          CheerItemModel.fromJson(response.data['cheer']);

      List<CommentItemModel> _tempComments = List.from(_comments);
      List<CheerItemModel> _tempCheers = List.from(_tempComments[index].cheers);

      int isExist = _tempCheers
          .where((obj) => obj.sId == cheersAsResponse.sId)
          .toList()
          .length;
      if (isExist == 0) {
        _tempCheers.add(cheersAsResponse);
      }
      _tempComments[index].cheers = [..._tempCheers];
      _comments.value = [..._tempComments];
    } catch (e) {
      print(e);
    }
  }

  deleteCheersFromComment(String commentId, String cheersId) async {
    int index = _comments.indexWhere((element) => element.sId == commentId);

    try {
      final response = await _commentService.deleteCheersComment(
          baseUrlAddCheerModule, commentId, cheersId);

      CheerItemModel cheersAsResponse =
          CheerItemModel.fromJson(response.data['cheer']);

      List<CommentItemModel> _tempComments = List.from(_comments);
      List<CheerItemModel> _tempCheers = List.from(_tempComments[index].cheers);

      int isExist = _tempCheers
          .where((obj) => obj.sId == cheersAsResponse.sId)
          .toList()
          .length;
      if (isExist == 0) {
        _tempCheers.removeWhere((o) => o.sId == cheersAsResponse.sId);
      }
      _tempComments[index].cheers = [..._tempCheers];
      _comments.value = [..._tempComments];
    } catch (e) {
      print(e);
    }
  }

  // LOADING
  var _loading = false.obs;
  bool get loading => _loading.value;
  set loading(bool value) {
    _loading.value = value;
  }

  var _loadingCreate = false.obs;
  bool get loadingCreate => _loadingCreate.value;
  set loadingCreate(bool value) {
    _loadingCreate.value = value;
  }

  // MENTION BOX
  var _isOpenMentionBox = false.obs;
  bool get isOpenMentionBox => _isOpenMentionBox.value;

  set isOpenMentionBox(bool value) {
    _isOpenMentionBox.value = value;
  }

  Future<List<CommentItemModel>> getData() async {
    if (baseUrlModule == '') {
      return Future.value([]);
    }
    _loading.value = true;
    try {
      String dateNowAsString =
          DateFormat('yyy-MM-dd HH:mm:ss').format(DateTime.now());
      dynamic params = {"createdAt": dateNowAsString, "limit": 10};
      final response = await _commentService.getComments(baseUrlModule, params);

      _comments.value = [];
      List<CommentItemModel> _tempList = [];
      Future.delayed(Duration(milliseconds: 1000), () {
        keyEditor.currentState?.clear();
      });

      if (typeModule == 'cardDiscussion' ||
          typeModule == 'occurrenceCardDiscussion') {
        if (response.data['discussions'] != null) {
          response.data['discussions'].forEach((v) {
            _tempList.add(CommentItemModel.fromJson(v));
          });
          _comments.value = [..._tempList];
          _loading.value = false;
          return Future.value(_tempList);
        }
      }
      if (response.data['comments'] != null) {
        response.data['comments'].forEach((v) {
          _tempList.add(CommentItemModel.fromJson(v));
        });
        _comments.value = [..._tempList];
        _loading.value = false;
        return Future.value(_tempList);
      } else {
        _loading.value = false;
        return Future.value([]);
      }
    } catch (e) {
      print(e);
      _loading.value = false;
      return Future.error(e);
    }
  }

  Future<List<CommentItemModel>> getMoreData() async {
    if (comments.isEmpty) {
      refreshController.loadComplete();
      return Future.value([]);
    }
    try {
      if (isForCommentDetailScreen) {
        print('load more comment detail');
        String dateNowAsString = comments.last.createdAt;
        dynamic params = {"createdAt": dateNowAsString, "limit": 10};
        final response = await _commentService.getDiscussion(
            commentIdFromDetailCommentScreen, params);

        if (response.data['discussions'] != null) {
          response.data['discussions'].forEach((v) {
            _comments.add(CommentItemModel.fromJson(v));
          });
          refreshController.loadComplete();
          return Future.value(_comments);
        } else {
          refreshController.loadComplete();
          return Future.value([]);
        }
      }
      if (baseUrlModule == '') {
        refreshController.loadComplete();
        return Future.value([]);
      }

      String dateNowAsString = comments.last.createdAt;
      dynamic params = {"createdAt": dateNowAsString, "limit": 10};
      final response = await _commentService.getComments(baseUrlModule, params);

      if (response.data['comments'] != null) {
        response.data['comments'].forEach((v) {
          _comments.add(CommentItemModel.fromJson(v));
        });
        refreshController.loadComplete();
        return Future.value(_comments);
      } else {
        refreshController.loadComplete();
        return Future.value([]);
      }
    } catch (e) {
      print(e);
      refreshController.loadComplete();
      return Future.value([]);
    }
  }

  var _isForCommentDetailScreen = false.obs;
  bool get isForCommentDetailScreen => _isForCommentDetailScreen.value;
  set isForCommentDetailScreen(bool value) {
    _isForCommentDetailScreen.value = value;
  }

  var _commentIdFromDetailCommentScreen = ''.obs;
  String get commentIdFromDetailCommentScreen =>
      _commentIdFromDetailCommentScreen.value;
  set commentIdFromDetailCommentScreen(String value) {
    _commentIdFromDetailCommentScreen.value = value;
  }

  void handleFileSelection() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      String fileName = result.files[0].name;
      String? path = result.files[0].path ?? '';

      String onlineUrl = await uploadFile(path, fileName);

      String htmlFile = '<a href="$onlineUrl">$fileName</a>';
      keyEditor.currentState!.javascriptExecutor.insertHtml(htmlFile);
      Get.back();
    } else {
      // User canceled the picker
    }
  }

  void handleImageSelectionCamera() async {
    final result = await ImagePicker().pickImage(
      source: sourceType.ImageSource.camera,
      imageQuality: 70,
      maxWidth: 1440,
    );

    if (result != null) {
      final name = result.path.split('/').last;
      String onlineUrl = await uploadImage(result.path, name);

      double _maxWidthImage = Get.width / 1.7;
      String htmlImage =
          '''<p><img src=\"$onlineUrl" style=\"width: ${_maxWidthImage}px;\" class=\"fr-fic fr-dib\"></p>''';
      keyEditor.currentState!.javascriptExecutor.insertHtml(htmlImage);
      Get.back();
    } else {
      // User canceled the picker
    }
  }

  void handleImageSelection() async {
    final result = await ImagePicker().pickImage(
      source: sourceType.ImageSource.gallery,
      imageQuality: 70,
      maxWidth: 1440,
    );

    if (result != null) {
      final name = result.path.split('/').last;
      String onlineUrl = await uploadImage(result.path, name);

      double _maxWidthImage = Get.width / 1.7;
      String htmlImage =
          '''<p><img src=\"$onlineUrl" style=\"width: ${_maxWidthImage}px;\" class=\"fr-fic fr-dib\"></p>''';
      keyEditor.currentState!.javascriptExecutor.insertHtml(htmlImage);
      Get.back();
    } else {
      // User canceled the picker
    }
  }

  Future<String> uploadImage(String path, String name) async {
    try {
      dynamic body = {"uri": path, "name": name};
      final response = await _docFileService.uploadImageEditor(body);
      return Future.value(response.data['link']);
    } catch (e) {
      return Future.value('');
    }
  }

  Future<String> uploadFile(String path, String name) async {
    try {
      dynamic body = {"uri": path, "name": name};
      final response = await _docFileService.uploadFileEditor(body);

      return Future.value(response.data['link']);
    } catch (e) {
      return Future.value('');
    }
  }

  callBackAddComment(dynamic jsonComment) {
    CommentItemModel _commentItem = CommentItemModel.fromJson(
        jsonComment[0] != null ? jsonComment[0] : jsonComment);

    int index =
        comments.indexWhere((element) => element.sId == _commentItem.sId);
    if (index < 0) {
      _comments.add(_commentItem);
    }
  }

  callBackEditComment(dynamic jsonComment) {
    CommentItemModel _commentItem = CommentItemModel.fromJson(
        jsonComment[0] != null ? jsonComment[0] : jsonComment);

    List<CommentItemModel> _newListComments = comments.map((e) {
      if (e.sId == _commentItem.sId) {
        return _commentItem;
      } else {
        return e;
      }
    }).toList();
    comments = _newListComments;
  }

  callBackRemoveComment(dynamic jsonComment) {
    CommentItemModel _commentItem = CommentItemModel.fromJson(
        jsonComment[0] != null ? jsonComment[0] : jsonComment);
    List<CommentItemModel> _tempListComments = List.from(comments);
    _tempListComments.removeWhere((element) => element.sId == _commentItem.sId);
    comments = _tempListComments;
  }

  callBackNewCheer(dynamic jsonCheer) {
    CheerItemModel cheer = CheerItemModel.fromJson(
        jsonCheer[0] != null ? jsonCheer[0] : jsonCheer);
    String selectedCommentId = cheer.primaryParent.id;
    List<CommentItemModel> _filterCommentsById =
        comments.where((element) => element.sId == selectedCommentId).toList();
    if (_filterCommentsById.isNotEmpty) {
      CommentItemModel selectedComment = _filterCommentsById[0];
      List<CheerItemModel> _tempListCheers = selectedComment.cheers;
      int isExist =
          _tempListCheers.where((obj) => obj.sId == cheer.sId).toList().length;
      if (isExist == 0) {
        _tempListCheers.add(cheer);
      }
      selectedComment.cheers = _tempListCheers;
      int index =
          _comments.indexWhere((element) => element.sId == selectedComment.sId);

      if (index >= 0) {
        _comments[index] = selectedComment;
      }
    }
  }

  callBackDeleteCheer(dynamic jsonCheer) {
    CheerItemModel cheer = CheerItemModel.fromJson(
        jsonCheer[0] != null ? jsonCheer[0] : jsonCheer);
    String selectedCommentId = cheer.primaryParent.id;
    List<CommentItemModel> _filterCommentsById =
        comments.where((element) => element.sId == selectedCommentId).toList();
    if (_filterCommentsById.isNotEmpty) {
      CommentItemModel selectedComment = _filterCommentsById[0];
      List<CheerItemModel> _tempListCheers = selectedComment.cheers;
      _tempListCheers.removeWhere((element) => element.sId == cheer.sId);
      selectedComment.cheers = _tempListCheers;
      List<CommentItemModel> _tempComments = comments.map((element) {
        if (element.sId == selectedComment.sId) {
          return selectedComment;
        } else {
          return element;
        }
      }).toList();
      comments = _tempComments;
    }
  }

  callBackNewDiscussion(dynamic payload) {
    Discussions _discussion = Discussions.fromJson(payload['discussion']);
    String selectedCommentId = payload['commentId'] ?? '';
    List<CommentItemModel> _filterCommentsById =
        comments.where((element) => element.sId == selectedCommentId).toList();
    if (_filterCommentsById.isNotEmpty) {
      CommentItemModel selectedComment = _filterCommentsById[0];
      List<Discussions> _tempListDiscussion = selectedComment.discussions;
      int isExist = _tempListDiscussion
          .where((obj) => obj.sId == _discussion.sId)
          .toList()
          .length;
      if (isExist == 0) {
        _tempListDiscussion.add(_discussion);
      }
      selectedComment.discussions = _tempListDiscussion;
      List<CommentItemModel> _tempComments = comments.map((element) {
        if (element.sId == selectedComment.sId) {
          return selectedComment;
        } else {
          return element;
        }
      }).toList();
      comments = _tempComments;
    }
  }

  callBackDeleteDiscussion(dynamic payload) {
    Discussions _discussion = Discussions.fromJson(payload['discussion']);
    String selectedCommentId = payload['commentId'] ?? '';
    List<CommentItemModel> _filterCommentsById =
        comments.where((element) => element.sId == selectedCommentId).toList();
    if (_filterCommentsById.isNotEmpty) {
      CommentItemModel selectedComment = _filterCommentsById[0];
      List<Discussions> _tempListDiscussion = selectedComment.discussions;
      _tempListDiscussion
          .removeWhere((element) => element.sId == _discussion.sId);
      selectedComment.discussions = _tempListDiscussion;
      List<CommentItemModel> _tempComments = comments.map((element) {
        if (element.sId == selectedComment.sId) {
          return selectedComment;
        } else {
          return element;
        }
      }).toList();
      comments = _tempComments;
    }
  }
}
