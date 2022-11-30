import 'package:cicle_mobile_f3/controllers/team_detail_controller.dart';
import 'package:cicle_mobile_f3/models/card_model.dart';
import 'package:cicle_mobile_f3/models/companies_model.dart';
import 'package:cicle_mobile_f3/models/member_model.dart';

import 'package:cicle_mobile_f3/service/blast_service.dart';
import 'package:cicle_mobile_f3/utils/constant.dart';
import 'package:cicle_mobile_f3/utils/helpers.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:html_editor_enhanced/html_editor.dart';

class BlastFormController extends GetxController {
  TextEditingController titleTextEditingController = TextEditingController();
  TextEditingController textEditingControllerDueDate = TextEditingController();
  HtmlEditorController htmlController = HtmlEditorController();
  BlastService _blastService = BlastService();
  String? typeForm = Get.parameters['type'];
  String? teamId = Get.parameters['teamId'];
  String? postId = Get.parameters['blastId'];
  String companyId = Get.parameters['companyId'] ?? '';

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    init();
  }

  init() async {
    if (typeForm == null) {
      // create
      DateTime now = DateTime.now();
      DateTime initialDateForDueDate =
          DateTime(now.year, now.month, now.day + 7, now.hour, now.minute);
      dueDate = initialDateForDueDate.toString();
      textEditingControllerDueDate.text = initialDateForDueDate.toString();

      await Future.delayed(Duration(milliseconds: 600));
      loadingNote = false;
      teamMembers = Get.put(TeamDetailController()).teamMembers;
      members = teamMembers;

      currentTeam = Teams(
          archived: Archived(),
          sId: Get.put(TeamDetailController()).teamId,
          name: Get.put(TeamDetailController()).teamName);
      await Future.delayed(Duration(milliseconds: 1000));
      htmlController.setFullScreen();
    } else {
      // edit
      try {
        loadingGetData = true;
        dueDate = DateTime.now().toString();
        await Future.delayed(Duration(milliseconds: 600));
        loadingNote = false;
        await getDetail();
        await Future.delayed(Duration(milliseconds: 1000));
        htmlController.setFullScreen();
        loadingGetData = false;
      } catch (e) {
        loadingGetData = false;
      }
    }
  }

  var _loadingNote = true.obs;
  bool get loadingNote => _loadingNote.value;
  set loadingNote(bool value) {
    _loadingNote.value = value;
  }

  var _loadingGetData = false.obs;
  bool get loadingGetData => _loadingGetData.value;
  set loadingGetData(bool value) {
    _loadingGetData.value = value;
  }

  var _loading = false.obs;
  bool get loading => _loading.value;
  set loading(bool value) {
    _loading.value = value;
  }

  //Title
  var _title = ''.obs;
  String get title => _title.value;
  set title(String value) {
    _title.value = value;
  }

  //due date
  var _dueDate = ''.obs;
  String get dueDate => _dueDate.value;
  set dueDate(String value) {
    _dueDate.value = value;
  }

  //is Private
  var _isPrivate = false.obs;
  bool get isPrivate => _isPrivate.value;
  set isPrivate(bool value) {
    _isPrivate.value = value;
  }

  //MEMBERS
  var _members = <MemberModel>[].obs;
  List<MemberModel> get members => _members;
  set members(List<MemberModel> value) {
    _members.value = value;
  }

  addMember(MemberModel value) {
    _members.add(value);
  }

  removeMember(MemberModel value) {
    int getIndex = _members.indexWhere((element) => element.sId == value.sId);
    _members.removeAt(getIndex);
  }

  setMembers(List<MemberModel> value) {
    _members.value = [...value];
  }

  //MEMBERS
  var _teamMembers = <MemberModel>[].obs;
  List<MemberModel> get teamMembers => _teamMembers;
  set teamMembers(List<MemberModel> value) {
    _teamMembers.value = value;
  }

  var _currentTeam = Teams(sId: '', archived: Archived()).obs;
  Teams get currentTeam => _currentTeam.value;
  set currentTeam(Teams value) {
    _currentTeam.value = value;
  }

  makeMentionRemovable([String content = '']) {
    return content.replaceAll('contenteditable=\"false\"', "");
  }

  getDetail() async {
    try {
      final response = await _blastService.getPost(postId!);

      if (response.data['post'] != null) {
        title = response.data['post']['title'];
        titleTextEditingController.text = response.data['post']['title'];

        members = [];
        response.data['post']['subscribers'].forEach((v) {
          _members.add(MemberModel.fromJson(v));
        });
        if (response.data['currentTeam'] != null) {
          currentTeam = Teams.fromJson(response.data['currentTeam']);
        }
        teamMembers = [];
        response.data['currentTeam']['members'].forEach((v) {
          _teamMembers.add(MemberModel.fromJson(v));
        });

        if (response.data['post']['dueDate'] != null) {
          String textDateToLocal =
              DateTime.parse(response.data['post']['dueDate'])
                  .toLocal()
                  .toString();
          dueDate = textDateToLocal;

          textEditingControllerDueDate =
              TextEditingController(text: textDateToLocal);
        } else {
          dueDate = DateTime.now().toString();
        }

        isPrivate = response.data['post']['isPublic'] != null
            ? !response.data['post']['isPublic']
            : false;
        await Future.delayed(Duration(milliseconds: 200));
        htmlController
            .setText(makeMentionRemovable(response.data['post']['content']));
      }
      loadingGetData = false;
    } catch (e) {
      loadingGetData = false;
      print(e);
    }
  }

  subscriberAdapter(List<MemberModel> value) {
    return value.map((e) => e.sId).toList();
  }

  Future<bool> validate() async {
    String content = await htmlController.getText();
    if (title != '' && content != '' && content != "<p></p>") {
      return true;
    } else if (title == '') {
      showAlert(message: 'Title must be filled', messageColor: Colors.red);
      return false;
    } else if (content == '' || content == "<p></p>") {
      showAlert(
          message: 'Description must be filled', messageColor: Colors.red);
      return false;
    }
    return false;
  }

  //ACTION

  onAdd() async {
    if (loading) {
      return;
    }
    if (await validate() == false) {
      print('error validate');
      return;
    }

    try {
      loading = true;
      loadingGetData = true;
      String blastId = Get.put(TeamDetailController()).blastId;
      String content = await htmlController.getText();
      DateTime time = DateTime.now();
      dynamic body = {
        "content": content,
        "dueDate": DateTime.parse(dueDate).toUtc().toString(),
        "isPublic": !isPrivate,
        "mentionedUsers": getMentionedUsers(content, teamMembers),
        "subscribers": subscriberAdapter(members),
        "title": title
      };

      final response = await _blastService.createPost(blastId, body);
      String message = response.data['message'] ?? 'succes create your post';
      showAlert(message: message);
      loading = false;
      loadingGetData = false;
      loadingNote = true;
      await Future.delayed(Duration(milliseconds: 300));
      Get.back();
    } catch (e) {
      print(e);
      loading = false;
      loadingGetData = false;
      if (e is DioError) {
        String message = e.message;
        showAlert(message: message);
      } else {
        showAlert(message: 'error internal server');
      }
    }
  }

  onEdit() async {
    if (loading) {
      return;
    }
    if (await validate() == false) {
      print('error validate');
      return;
    }

    try {
      loadingGetData = true;
      loading = true;
      String? postId = Get.parameters['blastId'];
      String content = await htmlController.getText();

      dynamic body = {
        "content": content,
        "dueDate": DateTime.parse(dueDate).toUtc().toString(),
        "isPublic": !isPrivate,
        "mentionedUsers": getMentionedUsers(content, teamMembers),
        "subscribers": subscriberAdapter(members),
        "title": title
      };
      final response = await _blastService.updatePost(postId!, body);
      String message = response.data['message'] ?? 'succes update your post';
      showAlert(message: message);
      loading = false;
      loadingGetData = false;
      loadingNote = true;
      await Future.delayed(Duration(milliseconds: 300));
      Get.back();
    } catch (e) {
      print(e);
      loadingGetData = false;
      loading = false;
      if (e is DioError) {
        String message = e.response?.statusMessage ?? e.message;
        showAlert(message: message);
      } else {
        showAlert(message: 'error internal server');
      }
    }
  }

  navigateToList() async {
    if (typeForm == null || typeForm == 'create') {
      // create
      Get.back();
    } else {
      // edit
      Get.reset();
      await Future.delayed(Duration(milliseconds: 300));
      Get.offAllNamed(RouteName.dashboardScreen(companyId));
      await Future.delayed(Duration(milliseconds: 300));
      Get.toNamed(
          '${RouteName.teamDetailScreen(companyId)}/${currentTeam.sId}?destinationIndex=1');
    }
  }
}
