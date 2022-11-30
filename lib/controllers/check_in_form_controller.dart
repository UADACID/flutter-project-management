import 'package:cicle_mobile_f3/controllers/team_detail_controller.dart';
import 'package:cicle_mobile_f3/models/card_model.dart';

import 'package:cicle_mobile_f3/models/companies_model.dart';
import 'package:cicle_mobile_f3/models/member_model.dart';
import 'package:cicle_mobile_f3/service/check_in_service.dart';
import 'package:cicle_mobile_f3/utils/constant.dart';
import 'package:cicle_mobile_f3/utils/helpers.dart';
import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class CheckInFormController extends GetxController {
  String? typeForm = Get.parameters['type'];
  String companyId = Get.parameters['companyId'] ?? '';
  CheckInService _checkInService = CheckInService();

  TextEditingController questionTextEditingController = TextEditingController();
  TextEditingController timeEditingController = TextEditingController();

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    init();
  }

  var _loadingGetData = false.obs;
  bool get loadingGetData => _loadingGetData.value;
  set loadingGetData(bool value) {
    _loadingGetData.value = value;
  }

  init() async {
    if (typeForm == null || typeForm == 'create') {
      // create
      teamMembers = Get.put(TeamDetailController()).teamMembers;
      currentTeam = Teams(
          archived: Archived(),
          sId: Get.put(TeamDetailController()).teamId,
          name: Get.put(TeamDetailController()).teamName);
      members = teamMembers;
      initTime = "09:00";
    } else {
      // edit
      try {
        loadingGetData = true;
        await Future.delayed(Duration(milliseconds: 600));

        await getDetail();
        loadingGetData = false;
      } catch (e) {
        loadingGetData = false;
      }
    }
  }

  var _currentTeam = Teams(sId: '', archived: Archived()).obs;
  Teams get currentTeam => _currentTeam.value;
  set currentTeam(Teams value) {
    _currentTeam.value = value;
  }

  var _teamMembers = <MemberModel>[].obs;
  List<MemberModel> get teamMembers => _teamMembers;
  set teamMembers(List<MemberModel> value) {
    _teamMembers.value = value;
  }

  //QUESTION
  var _question = ''.obs;
  String get question => _question.value;

  set question(value) {
    _question.value = value;
  }

  //DAYS
  var _listOfSelectedDays = <String>[].obs;

  List<String> get listOfSelectedDays => _listOfSelectedDays;
  set listOfSelectedDays(List<String> value) {
    _listOfSelectedDays.value = value;
  }

  set addDay(String day) {
    _listOfSelectedDays.add(day);
  }

  removeDay(String day) {
    List<String> _tempList =
        _listOfSelectedDays.where((i) => i != day).toList();
    _listOfSelectedDays.value = [..._tempList];
  }

  //TIME

  var _initTime = ''.obs;
  String get initTime => _initTime.value;

  set initTime(String value) {
    _initTime.value = value;
  }

  var _initEditTime = TimeOfDay(hour: 9, minute: 0).obs;
  TimeOfDay get initEditTime => _initEditTime.value;

  set initEditTime(TimeOfDay value) {
    print(value);
    _initEditTime.value = value;
  }

  var _time = ''.obs;
  String get time => _time.value;

  set time(value) {
    _time.value = value;
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

  //is Private
  var _isPrivate = false.obs;
  bool get isPrivate => _isPrivate.value;
  set isPrivate(bool value) {
    _isPrivate.value = value;
  }

  getDetail() async {
    try {
      String questionId = Get.parameters['checkInId'] ?? '';
      final response = await _checkInService.getQuestion(questionId);

      if (response.data['question'] != null) {
        question = response.data['question']['title'] ?? '';
        questionTextEditingController.text =
            response.data['question']['title'] ?? '';
        listOfSelectedDays = [];
        if (response.data['question']['schedule']['days'] != null) {
          response.data['question']['schedule']['days'].forEach((v) {
            _listOfSelectedDays.add(v);
          });
        }
        DateTime today = DateTime.now().toUtc();
        var utcHour = response.data['question']['schedule']['hour'] ?? 0;
        var utcMinute = response.data['question']['schedule']['minute'] ?? 0;
        DateTime baseDate = DateTime.utc(
                today.year, today.month, today.day, utcHour, utcMinute, 0)
            .toLocal();
        initEditTime = TimeOfDay(hour: baseDate.hour, minute: baseDate.minute);
        timeEditingController.text = DateFormat('hh:mm').format(baseDate);
        time = DateFormat('hh:mm').format(baseDate);
        initTime = DateFormat('hh:mm').format(baseDate);
        isPrivate = response.data['question']['isPublic'] != null
            ? !response.data['question']['isPublic']
            : false;

        members = [];
        if (response.data['currentTeam'] != null) {
          currentTeam = Teams.fromJson(response.data['currentTeam']);
        }
        response.data['question']['subscribers'].forEach((v) {
          _members.add(MemberModel.fromJson(v));
        });
        teamMembers = [];
        response.data['currentTeam']['members'].forEach((v) {
          _teamMembers.add(MemberModel.fromJson(v));
        });
      }
      loadingGetData = false;
    } catch (e) {
      loadingGetData = false;
      print(e);
      errorMessageMiddleware(e);
    }
  }

  //SUBMIT FORM
  submit() {
    EasyDebounce.debounce(
        'submit-add-check-in', // <-- An ID for this particular debouncer
        Duration(milliseconds: 600), // <-- The debounce duration
        () => save() // <-- The target method
        );
  }

  save() async {
    if (loadingGetData) {
      return;
    }
    if (validate(
        titleValue: _question.value,
        daysValue: _listOfSelectedDays,
        timeValue: _time.value)) {
      var hourUtc = DateFormat("hh:mm:ss").parse("$_time:00").toUtc().hour;
      var minuteUtc = DateFormat("hh:mm:ss").parse("$_time:00").toUtc().minute;
      try {
        loadingGetData = true;
        String checkInId = Get.parameters['checkInId'] ?? '';
        dynamic body = {
          "isPublic": !isPrivate,
          "schedule": {
            "days": _listOfSelectedDays,
            "hour": hourUtc,
            "minute": minuteUtc
          },
          "subscribers": subcriberAdapter(members),
          "title": _question.value
        };
        final response = await _checkInService.createQuestion(checkInId, body);

        showAlert(
            message: response.data['message'] ?? 'Create Question successful');
        loadingGetData = false;
        Get.back();
      } catch (e) {
        print(e);
        loadingGetData = false;
        errorMessageMiddleware(e);
      }
    }
  }

  bool validate(
      {required String titleValue,
      required List<String> daysValue,
      required String timeValue}) {
    if (titleValue == '') {
      showAlert(message: 'question must be filled', messageColor: Colors.red);
      return false;
    }

    if (daysValue.length == 0) {
      showAlert(
          message: 'how often the question is asked to be filled in',
          messageColor: Colors.red);
      return false;
    }

    if (timeValue == '') {
      showAlert(message: 'time must be filled', messageColor: Colors.red);
      return false;
    }

    return true;
  }

  submitEdit() async {
    if (loadingGetData) {
      return;
    }
    if (validate(
        titleValue: _question.value,
        daysValue: _listOfSelectedDays,
        timeValue: _time.value)) {
      var hourUtc = DateFormat("hh:mm:ss").parse("$_time:00").toUtc().hour;
      var minuteUtc = DateFormat("hh:mm:ss").parse("$_time:00").toUtc().minute;
      try {
        loadingGetData = true;
        String checkInId = Get.parameters['checkInId'] ?? '';
        dynamic body = {
          "isPublic": !isPrivate,
          "schedule": {
            "days": _listOfSelectedDays,
            "hour": hourUtc,
            "minute": minuteUtc
          },
          "subscribers": subcriberAdapter(members),
          "title": _question.value
        };
        final response = await _checkInService.updateQuestion(checkInId, body);

        showAlert(
            message: response.data['message'] ?? 'Update Question successful');
        loadingGetData = false;
        Get.back();
      } catch (e) {
        print(e);
        loadingGetData = false;
        errorMessageMiddleware(e);
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
          '${RouteName.teamDetailScreen(companyId)}/${currentTeam.sId}?destinationIndex=6');
    }
  }
}
