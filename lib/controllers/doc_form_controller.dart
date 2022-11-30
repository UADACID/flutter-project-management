import 'package:cicle_mobile_f3/controllers/team_detail_controller.dart';
import 'package:cicle_mobile_f3/models/card_model.dart';
import 'package:cicle_mobile_f3/models/companies_model.dart';
import 'package:cicle_mobile_f3/models/member_model.dart';
import 'package:cicle_mobile_f3/service/doc_file_service.dart';
import 'package:cicle_mobile_f3/utils/constant.dart';
import 'package:cicle_mobile_f3/utils/helpers.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:html_editor_enhanced/html_editor.dart';
import 'package:intl/intl.dart';

class DocFormController extends GetxController {
  TextEditingController titleTextEditingController = TextEditingController();
  HtmlEditorController htmlController = HtmlEditorController();
  String? typeForm = Get.parameters['type'];
  String companyId = Get.parameters['companyId'] ?? '';
  DocFileService _docFileService = DocFileService();

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    init();
  }

  init() async {
    if (typeForm == null) {
      // create
      currentTeam = Teams(
          archived: Archived(),
          sId: Get.put(TeamDetailController()).teamId,
          name: Get.put(TeamDetailController()).teamName);
      await Future.delayed(Duration(milliseconds: 600));
      loadingNote = false;
      teamMembers = Get.put(TeamDetailController()).teamMembers;

      members = teamMembers;
    } else {
      // edit
      try {
        loadingGetData = true;
        await Future.delayed(Duration(milliseconds: 600));
        loadingNote = false;
        await getDetail();
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

  //Content
  var _content = ''.obs;
  String get content => _content.value;
  set content(String value) {
    _content.value = value;
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

  //is Private
  var _isPrivate = false.obs;
  bool get isPrivate => _isPrivate.value;
  set isPrivate(bool value) {
    _isPrivate.value = value;
  }

  var _currentTeam = Teams(sId: '', archived: Archived()).obs;
  Teams get currentTeam => _currentTeam.value;
  set currentTeam(Teams value) {
    _currentTeam.value = value;
  }

  getDetail() async {
    try {
      String docId = Get.parameters['docId'] ?? '';
      final response = await _docFileService.getDoc(docId);

      if (response.data['doc'] != null) {
        title = response.data['doc']['title'];
        titleTextEditingController.text = response.data['doc']['title'];
        htmlController.insertHtml(response.data['doc']['content']);
        members = [];
        response.data['doc']['subscribers'].forEach((v) {
          _members.add(MemberModel.fromJson(v));
        });
        isPrivate = response.data['doc']['isPublic'] != null
            ? !response.data['doc']['isPublic']
            : false;
        teamMembers = [];
        response.data['currentTeam']['members'].forEach((v) {
          _teamMembers.add(MemberModel.fromJson(v));
        });

        if (response.data['currentTeam'] != null) {
          currentTeam = Teams.fromJson(response.data['currentTeam']);
        }
      }
      loadingGetData = false;
    } catch (e) {
      loadingGetData = false;
      print(e);
      errorMessageMiddleware(e);
    }
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

  subscriberAdapter(List<MemberModel> value) {
    return value.map((e) => e.sId).toList();
  }

  //ACTION

  onAdd() async {
    if (loading) {
      return;
    }
    if (await validate() == false) {
      return;
    }

    try {
      loading = true;
      loadingGetData = true;
      String? folderId = Get.parameters['folderId'];
      String content = await htmlController.getText();
      DateTime time = DateTime.now();
      dynamic body = {
        "content": content,
        "dueDate": DateFormat().format(time.toUtc()),
        "isPublic": !isPrivate,
        "mentionedUsers": [],
        "subscribers": subscriberAdapter(members),
        "title": title
      };

      final response = await _docFileService.createDoc(folderId!, body);

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
      errorMessageMiddleware(e);
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
      String docId = Get.parameters['docId'] ?? '';
      String content = await htmlController.getText();
      DateTime time = DateTime.now();
      dynamic body = {
        "content": content,
        "dueDate": DateFormat().format(time.toUtc()),
        "isPublic": !isPrivate,
        "mentionedUsers": [],
        "subscribers": subscriberAdapter(members),
        "title": title
      };

      final response = await _docFileService.updateDoc(docId, body);
      String message = response.data['message'] ?? 'succes update your doc';
      showAlert(message: message);
      loading = false;
      loadingGetData = false;
      loadingNote = true;
      await Future.delayed(Duration(milliseconds: 300));
      Get.back(result: true);
    } catch (e) {
      loadingGetData = false;
      loading = false;
      errorMessageMiddleware(e);
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
          '${RouteName.teamDetailScreen(companyId)}/${currentTeam.sId}?destinationIndex=3');
    }
  }
}
