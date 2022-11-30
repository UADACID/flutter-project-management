import 'package:cicle_mobile_f3/controllers/team_detail_controller.dart';
import 'package:cicle_mobile_f3/models/card_model.dart';
import 'package:cicle_mobile_f3/models/companies_model.dart';
import 'package:cicle_mobile_f3/models/event_item_model.dart';
import 'package:cicle_mobile_f3/models/member_model.dart';
import 'package:cicle_mobile_f3/models/repeat_model.dart';
import 'package:cicle_mobile_f3/screens/core/schedule/schedule_dialog_confirm.dart';
import 'package:cicle_mobile_f3/service/schedule_service.dart';
import 'package:cicle_mobile_f3/utils/constant.dart';
import 'package:cicle_mobile_f3/utils/helpers.dart';
import 'package:cicle_mobile_f3/widgets/default_alert.dart';
import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

enum RepeatType { forever, Until }

class ScheduleFormController extends GetxController {
  String? typeForm = Get.parameters['type'];

  ScheduleService _scheduleService = ScheduleService();

  TextEditingController titleTextEditingController = TextEditingController();
  TextEditingController repeatTextEditingController = TextEditingController();

  late TextEditingController endDateEditingController;
  late TextEditingController startDateEditingController;

  late TextEditingController repeatUntilTextEditingController;
  String teamId = Get.parameters['teamId'] ?? '';
  String? occurrenceId = Get.parameters['occurrenceId'];
  String? eventId = Get.parameters['scheduleId'];
  String companyId = Get.parameters['companyId'] ?? '';

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    init();

    _selectedAdditionalRepeat.listen((value) {
      if (value != RepeatType.Until) {
        repeatUntilTextEditingController.text = '';
      } else {
        final String formattedInitDate =
            DateFormat('yyyy-MM-dd').format(DateTime.now());
        setRepeatUnitlValue(formattedInitDate);
      }
    });
  }

  setRepeatUnitlValue(String value) {
    repeatUntilTextEditingController.text = value;
  }

  init() async {
    if (typeForm == null) {
      // create
      teamMembers = Get.put(TeamDetailController()).teamMembers;
      currentTeam = Teams(
          archived: Archived(),
          sId: Get.put(TeamDetailController()).teamId,
          name: Get.put(TeamDetailController()).teamName);
      DateTime dateTime = DateTime.now();
      DateTime initTime = DateTime(
          dateTime.year, dateTime.month, dateTime.day, dateTime.hour + 1, 0);
      DateTime initEndTime = DateTime(
          dateTime.year, dateTime.month, dateTime.day, dateTime.hour + 2, 0);

      initStartDate = initTime.toString();
      repeatUntilTextEditingController =
          TextEditingController(text: initTime.toString());
      startDateEditingController =
          TextEditingController(text: initTime.toString());
      endDateEditingController =
          TextEditingController(text: initEndTime.toString());
    } else {
      // edit
      try {
        loadingGetData = true;
        repeatUntilTextEditingController = TextEditingController(text: "");
        endDateEditingController = TextEditingController(text: "");
        await Future.delayed(Duration(milliseconds: 600));
        if (occurrenceId == null) {
          await getDetailEvent();
        } else {
          await getDetailEventOccurrence();
        }

        loadingGetData = false;
      } catch (e) {
        loadingGetData = false;
      }
    }
  }

  var _loadingGetData = false.obs;
  bool get loadingGetData => _loadingGetData.value;
  set loadingGetData(bool value) {
    _loadingGetData.value = value;
  }

  var _errorMessage = ''.obs;
  String get errorMessage => _errorMessage.value;
  set errorMessage(String value) {
    _errorMessage.value = value;
  }

// TITLE
  var _title = ''.obs;
  String get title => _title.value;
  set title(String value) {
    _title.value = value;
  }

// DATE
  var _date = ''.obs;
  String get date => _date.value;
  set date(String value) {
    print(value);
    _date.value = value;
  }

  // INITIAL START DATE
  var _initStartDate = ''.obs;
  String get initStartDate => _initStartDate.value;
  set initStartDate(String value) {
    _initStartDate.value = value;
  }

// START DATE
  var _startDate = ''.obs;
  String get startDate => _startDate.value;
  set startDate(String value) {
    _startDate.value = value;
    DateTime _startDateAdapter = DateTime.parse(value);
    String newEndDate = DateTime(
            _startDateAdapter.year,
            _startDateAdapter.month,
            _startDateAdapter.day,
            _startDateAdapter.hour + 1,
            _startDateAdapter.minute)
        .toString();
    initEndDate = newEndDate;
    endDate = newEndDate;
    selectedAdditionalRepeat = RepeatType.forever;
  }

  // INITIAL End DATE
  var _initEndDate = ''.obs;
  String get initEndDate => _initEndDate.value;
  set initEndDate(String value) {
    _initEndDate.value = value;
  }

// END DATE
  var _endDate = ''.obs;
  String get endDate => _endDate.value;
  set endDate(String value) {
    selectedAdditionalRepeat = RepeatType.forever;
    DateTime _startDateAdapter = DateTime.parse(startDate);
    DateTime _endDateAdapter = DateTime.parse(value);
    if (_endDateAdapter.isBefore(_startDateAdapter) ||
        _endDateAdapter.isAtSameMomentAs(_startDateAdapter)) {
      DateTime newEndDate = DateTime(
          _startDateAdapter.year,
          _startDateAdapter.month,
          _startDateAdapter.day,
          _startDateAdapter.hour + 1,
          _startDateAdapter.minute);

      _endDate.value = newEndDate.toString();
      endDateEditingController.text = newEndDate.toString();
    } else {
      _endDate.value = value;
      endDateEditingController.text = value;
    }
  }

  // REPEAT
  var _repeats = <RepeatModel>[
    RepeatModel(name: "Don't repeat", code: 1, alias: ''),
    RepeatModel(name: "Every day", code: 2, alias: 'DAILY'),
    RepeatModel(name: "Every week", code: 3, alias: 'WEEKLY'),
    RepeatModel(name: "Every quarter", code: 4, alias: 'QUARTERLY'),
    RepeatModel(name: "Every year", code: 5, alias: 'YEARLY'),
    RepeatModel(
        name: "Every weekdays (Mon - Fri)", code: 6, alias: 'WEEKLY_WEEKDAYS'),
    RepeatModel(
        name: "Every month (on the 3rd Monday)", code: 7, alias: 'MONTHLY'),
  ].obs;
  List<RepeatModel> get repeats => _repeats;
  set repeats(List<RepeatModel> value) {
    _repeats.value = value;
  }

  var _selectedRepeat =
      RepeatModel(name: "Don't repeat", code: 1, alias: '').obs;
  RepeatModel get selectedRepeat => _selectedRepeat.value;
  set selectedRepeat(RepeatModel value) {
    _selectedRepeat.value = value;
  }

  var _selectedAdditionalRepeat = RepeatType.forever.obs;
  RepeatType get selectedAdditionalRepeat => _selectedAdditionalRepeat.value;
  set selectedAdditionalRepeat(RepeatType value) {
    _selectedAdditionalRepeat.value = value;
  }

  var _repeatUntilValue = ''.obs;
  String get repeatUntilValue => _repeatUntilValue.value;

  //MEMBERS
  var _members = <MemberModel>[].obs;
  List<MemberModel> get members => _members;
  set members(List<MemberModel> value) {
    _members.value = [...value];
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

  var _teamMembers = <MemberModel>[].obs;
  List<MemberModel> get teamMembers => _teamMembers;
  set teamMembers(List<MemberModel> value) {
    _teamMembers.value = [...value];
  }

// NOTES
  var _notes = ''.obs;
  String get notes => _notes.value;
  set notes(String value) {
    _notes.value = value;
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

// ACTIONS

  String localDateAdapter(String value) {
    return DateFormat("yyyy-MM-dd HH:mm:ss")
        .format(DateTime.parse(value).toLocal());
  }

  Future<void> getDetailEvent() async {
    try {
      final response = await _scheduleService.getEvent(eventId!);

      if (response.data['event'] != null) {
        EventItemModel eventDetail =
            EventItemModel.fromJson(response.data['event']);

        title = eventDetail.title ?? '';
        titleTextEditingController.text = eventDetail.title ?? '';
        String textStartDateToLocal =
            DateTime.parse(response.data['event']['startDate'])
                .toLocal()
                .toString();
        startDate = localDateAdapter(eventDetail.startDate!);

        startDateEditingController =
            TextEditingController(text: textStartDateToLocal);

        endDate = localDateAdapter(eventDetail.endDate!);
        String textEndDateToLocal =
            DateTime.parse(response.data['event']['endDate'])
                .toLocal()
                .toString();

        endDateEditingController =
            TextEditingController(text: textEndDateToLocal);
        notes = eventDetail.content ?? '';
      }
      isPrivate = response.data['event']['isPublic'] != null
          ? !response.data['event']['isPublic']
          : false;
      if (response.data['event']['subscribers'] != null) {
        members = [];
        response.data['event']['subscribers'].forEach((v) {
          members.add(MemberModel.fromJson(v));
        });
      }

      if (response.data['currentTeam'] != null) {
        currentTeam = Teams.fromJson(response.data['currentTeam']);
      }

      if (response.data['currentTeam']['members'] != null) {
        teamMembers = [];
        response.data['currentTeam']['members'].forEach((v) {
          _teamMembers.add(MemberModel.fromJson(v));
        });
      }

      errorMessage = '';
      return Future.value();
    } catch (e) {
      print(e);
      String message = errorMessageMiddleware(e);
      errorMessage = message;
      return Future.value();
    }
  }

  getDetailEventOccurrence() async {
    try {
      final response =
          await _scheduleService.getEventOccurence(eventId!, occurrenceId!);

      if (response.data['occurrence'] != null) {
        EventItemModel eventDetail =
            EventItemModel.fromJson(response.data['occurrence']);
        title = eventDetail.title ?? '';
        titleTextEditingController.text = eventDetail.title ?? '';
        startDate = localDateAdapter(eventDetail.startDate!);
        endDate = localDateAdapter(eventDetail.endDate!);
        notes = eventDetail.content ?? '';
        // selectedRepeat
        if (eventDetail.originalStartPattern!.code != null &&
            eventDetail.originalStartPattern!.code != '') {
          List<RepeatModel> filterRepeat = repeats
              .where((element) =>
                  element.alias == eventDetail.originalStartPattern!.code)
              .toList();
          if (filterRepeat.isNotEmpty) {
            selectedRepeat = filterRepeat[0];
          }
        }

        if (eventDetail.originalStartPattern!.endDate == "") {
          selectedAdditionalRepeat = RepeatType.forever;
        } else {
          selectedAdditionalRepeat = RepeatType.Until;
          repeatUntilTextEditingController.text =
              eventDetail.originalStartPattern!.endDate!;
        }
      }
      if (response.data['occurrence']['subscribers'] != null) {
        members = [];
        response.data['occurrence']['subscribers'].forEach((v) {
          members.add(MemberModel.fromJson(v));
        });
      }

      isPrivate = response.data['occurrence']['isPublic'] != null
          ? !response.data['occurrence']['isPublic']
          : false;

      if (response.data['currentTeam'] != null) {
        currentTeam = Teams.fromJson(response.data['currentTeam']);
      }

      if (response.data['currentTeam']['members'] != null) {
        teamMembers = [];
        response.data['currentTeam']['members'].forEach((v) {
          _teamMembers.add(MemberModel.fromJson(v));
        });
      }

      String textStartDateToLocal =
          DateTime.parse(response.data['occurrence']['startDate'])
              .toLocal()
              .toString();

      startDateEditingController =
          TextEditingController(text: textStartDateToLocal);

      String textEndDateToLocal =
          DateTime.parse(response.data['occurrence']['endDate'])
              .toLocal()
              .toString();

      endDateEditingController =
          TextEditingController(text: textEndDateToLocal);

      return Future.value();
    } catch (e) {
      print(e);
      return Future.value();
    }
  }

  submit() {
    if (selectedRepeat.code == 1) {
      EasyDebounce.debounce(
          'submit-add-check-in', // <-- An ID for this particular debouncer
          Duration(milliseconds: 600), // <-- The debounce duration
          () => postEvent() // <-- The target method
          );
    } else {
      EasyDebounce.debounce(
          'submit-add-check-in', // <-- An ID for this particular debouncer
          Duration(milliseconds: 600), // <-- The debounce duration
          () => postOccurrence() // <-- The target method
          );
    }
  }

  submitEdit() {
    if (selectedRepeat.code == 1 && occurrenceId == null) {
      // for cummon event
      EasyDebounce.debounce(
          'submit-add-check-in', // <-- An ID for this particular debouncer
          Duration(milliseconds: 600), // <-- The debounce duration
          () => editEvent() // <-- The target method
          );
    } else if (selectedRepeat.code != 1 && occurrenceId == null) {
      editSingleToOccurrence();
    } else if (occurrenceId != null && selectedRepeat.code == 1) {
      print('update occurrence to single');

      Get.dialog(DefaultAlert(
          onSubmit: () {
            EasyDebounce.debounce(
                'submit-add-check-in', // <-- An ID for this particular debouncer
                Duration(milliseconds: 600), // <-- The debounce duration
                () => editSingleOccurrence() // <-- The target method
                );
          },
          onCancel: () {
            Get.back();
          },
          title:
              'are you sure you want to update this occurrence event to single event ?'));
    } else {
      print('masuk edit event occurrence');
      Get.dialog(ScheduleDialogConfirm(
        onNo: editSingleOccurrence,
        onYes: editAllOccurrence,
      ));
    }
  }

  String dateAdapter(String dateString) {
    if (dateString != '') {
      String result = DateFormat("yyyy-MM-dd'T'HH:mm:ss'Z'")
          .format(DateTime.parse(dateString).toUtc());
      return result;
    }

    return DateFormat("yyyy-MM-dd'T'HH:mm:ss'Z'")
        .format(DateTime.now().toUtc());
  }

  bool validatePostEvent() {
    if (title == '') {
      showAlert(message: 'Title must be filled', messageColor: Colors.red);
      return false;
    }

    if (startDate == '') {
      showAlert(message: 'Start date must be filled', messageColor: Colors.red);
      return false;
    }

    if (endDate == '') {
      showAlert(message: 'End date must be filled', messageColor: Colors.red);
      return false;
    }

    return true;
  }

  postEvent() async {
    if (!validatePostEvent()) {
      return;
    }
    try {
      loadingGetData = true;
      String scheduleId = Get.put(TeamDetailController()).scheduleId;

      dynamic body = {
        "content": notes,
        "endDate": dateAdapter(endDate),
        "isPublic": !isPrivate,
        "mentionedUsers": [],
        "startDate": dateAdapter(startDate),
        "subscribers": subcriberAdapter(members),
        "title": title
      };
      final response = await _scheduleService.createEvent(scheduleId, body);

      showAlert(
          message: response.data['message'] ?? 'Create New Event Successful');
      loadingGetData = false;
      Get.back(result: true);
    } catch (e) {
      print(e);
      loadingGetData = false;
      errorMessageMiddleware(e);
    }
  }

  postOccurrence() async {
    if (!validatePostEvent()) {
      return;
    }
    try {
      loadingGetData = true;
      String scheduleId = Get.put(TeamDetailController()).scheduleId;

      dynamic recurrence = repeatUntilTextEditingController.text == ''
          ? {
              "code": selectedRepeat.alias,
              "startDate": dateAdapter(startDate),
            }
          : {
              "code": selectedRepeat.alias,
              "endDate": repeatUntilTextEditingController.text,
              "startDate": dateAdapter(startDate),
            };

      dynamic body = {
        "content": notes,
        "endDate": dateAdapter(endDate),
        "isPublic": !isPrivate,
        "isRecurring": true,
        "mentionedUsers": [],
        "recurrence": recurrence,
        "startDate": dateAdapter(startDate),
        "subscribers": subcriberAdapter(members),
        "title": title
      };

      final response =
          await _scheduleService.createEventOccurrence(scheduleId, body);

      showAlert(
          message: response.data['message'] ?? 'Create New Event Successful');
      loadingGetData = false;
      Get.back(result: true);
    } catch (e) {
      print(e);
      loadingGetData = false;
      errorMessageMiddleware(e);
    }
  }

  editEvent() async {
    if (!validatePostEvent()) {
      return;
    }
    try {
      loadingGetData = true;

      dynamic body = {
        "content": notes,
        "endDate": dateAdapter(endDate),
        "isPublic": !isPrivate,
        "mentionedUsers": [],
        "startDate": dateAdapter(startDate),
        "subscribers": subcriberAdapter(members),
        "title": title
      };
      final response = await _scheduleService.updateEvent(eventId!, body);

      showAlert(
          message: response.data['message'] ?? 'Create New Event Successful');
      loadingGetData = false;
      Get.back(result: true);
    } catch (e) {
      print(e);
      loadingGetData = false;
      errorMessageMiddleware(e);
    }
  }

  editSingleToOccurrence() async {
    try {
      loadingGetData = true;
      dynamic recurrence = repeatUntilTextEditingController.text == ''
          ? {
              "code": selectedRepeat.alias,
              "startDate": dateAdapter(startDate),
            }
          : {
              "code": selectedRepeat.alias,
              "endDate": repeatUntilTextEditingController.text,
              "startDate": dateAdapter(startDate),
            };
      dynamic body = {
        "endDate": dateAdapter(endDate),
        "isNotified.dueOneDay": false,
        "isNotified.dueOneHour": false,
        "isPublic": !isPrivate,
        "isRecurring": true,
        "mentionedUsers": [],
        "recurrence": recurrence,
        "startDate": dateAdapter(startDate),
        "subscribers": subcriberAdapter(members),
        "title": title,
      };
      final response =
          await _scheduleService.updateSingleEventToOccurrence(eventId!, body);

      if (response.data['occurrence'] != null) {
        String newOccurrenceId = response.data['occurrence']['_id'];
        String newEventId = response.data['occurrence']['event'];
        Get.back();
        await Future.delayed(Duration(milliseconds: 150));

        Get.offAndToNamed(RouteName.occurenceDetailScreen(
            companyId, teamId, newEventId, newOccurrenceId));
      } else {
        showAlert(
            message: 'Error occurrence id not found', messageColor: Colors.red);
      }
      loadingGetData = false;
    } catch (e) {
      print(e);
      errorMessageMiddleware(e);
      loadingGetData = false;
    }
  }

  editSingleOccurrence() async {
    try {
      loadingGetData = true;

      dynamic body = {
        "content": notes,
        "endDate": dateAdapter(endDate),
        "isNotified.dueOneDay": false,
        "isNotified.dueOneHour": false,
        "isPublic": !isPrivate,
        "isRecurring": false,
        "mentionedUsers": [],
        "startDate": dateAdapter(startDate),
        "subscribers": subcriberAdapter(members),
        "title": title,
      };
      final response = await _scheduleService.updateSingleEventOccurrence(
          eventId!, occurrenceId!, body);

      if (response.data['event'] != null) {
        String newEventId = response.data['event']['_id'];
        Get.back();
        await Future.delayed(Duration(milliseconds: 100));
        Get.back();
        await Future.delayed(Duration(milliseconds: 100));
        Get.back(result: true);
        await Future.delayed(Duration(milliseconds: 100));
        Get.toNamed(
            RouteName.scheduleDetailScreen(companyId, teamId, newEventId));
      } else {
        showAlert(
            message: 'Error event id not found', messageColor: Colors.red);
      }
      loadingGetData = false;
    } catch (e) {
      print(e);
      loadingGetData = false;
      errorMessageMiddleware(e);
    }
  }

  editAllOccurrence() async {
    try {
      dynamic recurrence = repeatUntilTextEditingController.text == ''
          ? {
              "code": selectedRepeat.alias,
              "startDate": dateAdapter(startDate),
            }
          : {
              "code": selectedRepeat.alias,
              "endDate": repeatUntilTextEditingController.text,
              "startDate": dateAdapter(startDate),
            };

      dynamic body = {
        "content": notes,
        "endDate": dateAdapter(endDate),
        "isNotified.dueOneDay": false,
        "isNotified.dueOneHour": false,
        "isPublic": !isPrivate,
        "isRecurring": true,
        "mentionedUsers": [],
        "recurrence": recurrence,
        "startDate": dateAdapter(startDate),
        "subscribers": subcriberAdapter(members),
        "title": title
      };
      loadingGetData = true;
      final response =
          await _scheduleService.updateAllEventOccurrence(eventId!, body);
      if (response.data['occurrence'] != null) {
        String newOccurrenceId = response.data['occurrence']['_id'];
        String newEventId = response.data['occurrence']['event'];
        Get.back();
        await Future.delayed(Duration(milliseconds: 100));
        Get.back();
        await Future.delayed(Duration(milliseconds: 100));
        Get.back(result: true);
        await Future.delayed(Duration(milliseconds: 100));
        // back & navigate to new occurenceId
        Get.toNamed(RouteName.occurenceDetailScreen(
            companyId, teamId, newEventId, newOccurrenceId));
      } else {
        showAlert(
            message: 'Error occurrence id not found', messageColor: Colors.red);
      }
      loadingGetData = false;
    } catch (e) {
      print(e);
      loadingGetData = false;
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
          '${RouteName.teamDetailScreen(companyId)}/${currentTeam.sId}?destinationIndex=5');
    }
  }
}
