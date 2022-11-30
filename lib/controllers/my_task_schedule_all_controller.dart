import 'dart:collection';
import 'package:cicle_mobile_f3/controllers/schedule_controller.dart';
import 'package:cicle_mobile_f3/models/comment_item_model.dart';
import 'package:cicle_mobile_f3/models/event_item_model.dart';
import 'package:cicle_mobile_f3/models/member_model.dart';
import 'package:cicle_mobile_f3/service/my_task_service.dart';
import 'package:cicle_mobile_f3/utils/constant.dart';
import 'package:cicle_mobile_f3/utils/socket/socket_my_task_all.dart';
import 'package:cicle_mobile_f3/widgets/webview_cummon.dart';
import 'package:easy_debounce/easy_debounce.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:supercharged_dart/supercharged_dart.dart';
import 'package:table_calendar/table_calendar.dart';

import 'my_task_controller.dart';

class MyTaskScheduleAllController extends GetxController {
  final box = GetStorage();

  MyTaskService _myTaskService = MyTaskService();
  MyTaskController _myTaskController = Get.put(MyTaskController());
  SocketMyTaskAll _socketMyTaskAll = SocketMyTaskAll();

  late ScrollController controller;

  late PageController calendarPageController;

  ExpandableController expandableController =
      ExpandableController(initialExpanded: false);

  var _logedInUserId = ''.obs;
  String get logedInUserId => _logedInUserId.value;

  var _isLoading = false.obs;
  bool get isLoading => _isLoading.value;
  set isLoading(bool value) {
    _isLoading.value = value;
  }

  var _kToday = DateTime.now().obs;
  DateTime get kToday => _kToday.value;
  set kToday(DateTime value) {
    _kToday.value = value;
  }

  var _kFirstDay = DateTime.now().obs;
  DateTime get kFirstDay => _kFirstDay.value;
  set kFirstDay(DateTime value) {
    _kFirstDay.value = value;
  }

  var _kLastDay = DateTime.now().obs;
  DateTime get kLastDay => _kLastDay.value;
  set kLastDay(DateTime value) {
    _kLastDay.value = value;
  }

  var _selectedDay = DateTime.now().obs;
  DateTime get selectedDay => _selectedDay.value;
  set selectedDay(DateTime value) {
    _selectedDay.value = value;
  }

  var _focusedDay = DateTime.now().obs;
  DateTime get focusedDay => _focusedDay.value;
  set focusedDay(DateTime value) {
    _focusedDay.value = value;
  }

  var _isCalendarExpand = true.obs;
  bool get isCalendarExpand => _isCalendarExpand.value;
  set isCalendarExpand(bool value) {
    _isCalendarExpand.value = value;
  }

  var _calendarFormat = CalendarFormat.month.obs;
  CalendarFormat get calendarFormat => _calendarFormat.value;
  set calendarFormat(CalendarFormat value) {
    _calendarFormat.value = value;
  }

  var _kEvents = <DateTime, List<EventItemModel>>{}.obs;
  Map<DateTime, List<EventItemModel>> get kEvents => _kEvents;
  set kEvents(Map<DateTime, List<EventItemModel>> value) {
    _kEvents.value = value;
  }

  var _events = <EventItemModel>[].obs;
  List<EventItemModel> get events => _events;
  set events(List<EventItemModel> value) {
    _events.value = value;
  }

  var _setPublic = false.obs;
  bool get setPublic => _setPublic.value;
  set setPublic(bool value) {
    _setPublic.value = value;
  }

  var _scheduleGoogleCalendar = ScheduleGoogleCalendar().obs;
  ScheduleGoogleCalendar get scheduleGoogleCalendar =>
      _scheduleGoogleCalendar.value;
  set scheduleGoogleCalendar(ScheduleGoogleCalendar value) {
    _scheduleGoogleCalendar.value = value;
  }

  Future<List<EventItemModel>> getEvents(
      String fromDate, String untilDate) async {
    Map<String, dynamic> params = {
      "fromDate": dateAdapter(fromDate),
      "untilDate": "${untilDate}T24:00:00.000Z",
      "filters[complete.status]": false,
      'filters[team]': [
        ..._myTaskController.listHqSelected,
        ..._myTaskController.listProjectSelected,
        ..._myTaskController.listTeamSelected
      ]
    };

    final response = await _myTaskService.getScheduleList(params);
    events = [];
    response.data['tasks'].forEach((v) {
      if (v['service'] != null) {
        EventItemModel obj = EventItemModel.fromJson(v['service']);
        obj.teamName = v['team']['name'];
        CommentItemModel? lastComment = v['lastComment'] != null
            ? CommentItemModel.fromJson(v['lastComment'])
            : null;
        obj.lastComment = lastComment;
        _events.add(obj);
      }
    });

    return _events;
  }

  String dateAdapter(String dateString) {
    if (dateString != '') {
      String result = DateTime.parse(dateString).toIso8601String();
      return result;
    }

    return DateFormat("yyyy-MM-dd'T'HH:mm:ss'Z'")
        .format(DateTime.now().toUtc());
  }

  Future<List<EventItemModel>> actionGetEvent(from, until) async {
    try {
      String untilDate = DateFormat('yyyy-MM-dd').format(until.toUtc());
      String fromDate = from.toString();

      List<EventItemModel> _list = await getEvents(fromDate, untilDate);

      var groupingByDate = _list
          .where((element) => element.archived!.status == false)
          .groupBy<DateTime, EventItemModel>(
        (item) {
          DateTime date = DateTime.parse(item.startDate!).toLocal();
          DateTime finalDate = DateTime(date.year, date.month, date.day);
          return finalDate;
        },
        valueTransform: (item) => item,
      );

      LinkedHashMap<DateTime, List<EventItemModel>> _mapEventList =
          LinkedHashMap<DateTime, List<EventItemModel>>(
        equals: isSameDay,
        hashCode: getHashCode,
      )..addAll(groupingByDate);

      events = _getEventsForRange(from, until, _mapEventList);

      kEvents = _mapEventList;

      await Future.delayed(Duration(milliseconds: 600));

      return Future.value(events);
    } catch (e) {
      isLoading = false;
      print(e);
      return Future.value([]);
    }
  }

  toggleCalendar() async {
    expandableController.toggle();
    await Future.delayed(Duration(milliseconds: 150));
    _isCalendarExpand.toggle();
  }

  onPageChange(focusedDayAsParams) {
    // handle when calendar page change more than one at same time
    EasyDebounce.debounce(
        'my-debouncer', // <-- An ID for this particular debouncer
        Duration(milliseconds: 500), // <-- The debounce duration
        () async {
      print('onPageChanged $focusedDayAsParams');
      focusedDay = focusedDayAsParams;
      isLoading = true;
      DateTime _date = focusedDayAsParams;
      DateTime firstDataOfTheMonth = DateTime.utc(_date.year, _date.month, 1);

      DateTime lastDateOfThisMonth = DateTime.utc(
        _date.year,
        _date.month + 1,
      ).subtract(Duration(days: 1));
      await actionGetEvent(firstDataOfTheMonth, lastDateOfThisMonth);
      // check apakah bulan dan tahun yang di pilih adalah bulan & tahun skrng ?
      int currentYear = DateTime.now().year;
      int currentMonth = DateTime.now().month;
      int activeYearCalendar = _date.year;
      int activeMonthCalendar = _date.month;
      bool isDateFromCalendarCurrentMonthAndYear =
          currentYear == activeYearCalendar &&
              currentMonth == activeMonthCalendar;
      if (isDateFromCalendarCurrentMonthAndYear) {
        selectedDay = DateTime(currentYear, currentMonth, DateTime.now().day);
        // selectedDay = firstDataOfTheMonth;
      } else {
        selectedDay = firstDataOfTheMonth;
      }
      isLoading = false;
    });
  }

  List<EventItemModel> getEventsForDay(DateTime day,
      [LinkedHashMap<DateTime, List<EventItemModel>>? events]) {
    if (events != null && events.length > 0) {
      return events[day] ?? [];
    }
    return _kEvents[day] ?? [];
  }

  List<EventItemModel> _getEventsForRange(DateTime start, DateTime end,
      [LinkedHashMap<DateTime, List<EventItemModel>>? events]) {
    final days = daysInRange(start, end);
    return _getEventsForDays(days, events);
  }

  List<EventItemModel> _getEventsForDays(Iterable<DateTime> days,
      [LinkedHashMap<DateTime, List<EventItemModel>>? events]) {
    if (events!.isEmpty) {
      return [];
    }
    return [
      for (final d in days) ...getEventsForDay(d, events),
    ];
  }

  handleClickGCal() {
    String url =
        "https://support.google.com/calendar/answer/37100?co=GENIE.Platform%3DDesktop&hl=en";
    Get.to(WebViewCummon(url: url));
  }

  handleClickICal() {
    String url =
        "https://discussions.apple.com/thread/6034963#:~:text=to%20a%20calendar.-,Go%20to%20Settings%20%3E%20Mail%2C%20Contacts%2C%20Calendars%2C%20then%20tap,ics%20file%20to%20subscribe%20to";

    Get.to(WebViewCummon(url: url));
  }

  listAdapter(List<EventItemModel> list) {
    var groupingByDate = list
        .where((element) => element.archived!.status == false)
        .groupBy<DateTime, EventItemModel>(
      (item) {
        DateTime date = DateTime.parse(item.startDate!).toLocal();

        DateTime finalDate = DateTime(date.year, date.month, date.day);

        return finalDate;
      },
      valueTransform: (item) => item,
    );

    LinkedHashMap<DateTime, List<EventItemModel>> _mapEventList =
        LinkedHashMap<DateTime, List<EventItemModel>>(
      equals: isSameDay,
      hashCode: getHashCode,
    )..addAll(groupingByDate);

    DateTime _date = focusedDay;
    DateTime firstDataOfTheMonth = DateTime.utc(_date.year, _date.month, 1);

    DateTime lastDateOfThisMonth = DateTime.utc(
      _date.year,
      _date.month + 1,
    ).subtract(Duration(days: 1));

    events = _getEventsForRange(
        firstDataOfTheMonth, lastDateOfThisMonth, _mapEventList);
    kEvents = _mapEventList;
  }

  EventItemModel? _filterItem(dynamic json) {
    if (json['task'] != null) {
      if (json['task']['serviceType'] != null &&
          json['task']['serviceType'] == 'Event') {
        // parsing to model
        EventItemModel event = EventItemModel.fromJson(json['task']['service']);
        CommentItemModel? lastComment = json['task']['lastComment'] != null
            ? CommentItemModel.fromJson(json['task']['lastComment'])
            : null;

        String teamName = json['task']['team']['name'];
        String teamId = json['task']['team']['_id'];

        event.lastComment = lastComment;
        event.teamId = teamId;
        event.teamName = teamName;
        List<String> _activeProjectFilter = [
          ..._myTaskController.listHqSelected,
          ..._myTaskController.listProjectSelected,
          ..._myTaskController.listTeamSelected
        ];

        // check is project filter active
        if (_activeProjectFilter.isEmpty) {
          return event;
        } else {
          // check is final iteam team id exist on filter
          List<String> checkItemTeamIdonFilter = _activeProjectFilter
              .where((element) => element == event.teamId)
              .toList();
          if (checkItemTeamIdonFilter.isNotEmpty) {
            return event;
          }
          return null;
        }
      }

      return null;
    }

    return null;
  }

  onSocketTaskAssigned(dynamic json) {
    EventItemModel? item = _filterItem(json);

    if (item != null) {
      int getIndexItem =
          events.indexWhere((element) => element.sId == item.sId);
      if (getIndexItem < 0) {
        // add event to list
        DateTime eventStartDate = DateTime.parse(item.startDate!).toLocal();
        var eventMonth = eventStartDate.month;
        var eventYear = eventStartDate.year;
        DateTime currentFocusDate = focusedDay;
        var currentFocusMonth = currentFocusDate.month;
        var currentFocusYear = currentFocusDate.year;
        List<EventItemModel> newList = [...events];
        if ('$eventMonth$eventYear' == '$currentFocusMonth$currentFocusYear') {
          // event ada di bulan yang sedang aktif
          newList.insert(0, item);
          listAdapter(newList);
        }
      }
    }
  }

  onSocketTaskRemoved(dynamic json) {
    EventItemModel? item = _filterItem(json);
    if (item != null) {
      List<EventItemModel> newList = [...events];
      newList.removeWhere((element) => element.sId == item.sId);
      listAdapter(newList);
    }
  }

  onSocketTaskUpdateStatus(dynamic json) {
    EventItemModel? item = _filterItem(json);
    if (item != null) {
      int getIndexItem =
          events.indexWhere((element) => element.sId == item.sId);
      if (getIndexItem >= 0) {
        bool completeStatus = json['task']?['complete']?['status'] ?? false;
        List<EventItemModel> newList = [...events];
        if (completeStatus == true) {
          newList.removeAt(getIndexItem);
        } else {
          newList[getIndexItem] = item;
        }

        listAdapter(newList);
      }
    }
  }

  init() async {
    if (events.isEmpty) {
      isLoading = true;

      DateTime firstDataOfTheMonth =
          DateTime.utc(DateTime.now().year, DateTime.now().month, 1);

      DateTime lastDateOfThisMonth = DateTime.utc(
        DateTime.now().year,
        DateTime.now().month + 1,
      ).subtract(Duration(days: 1));

      await actionGetEvent(firstDataOfTheMonth, lastDateOfThisMonth);
      isLoading = false;
      _socketMyTaskAll.init('schedule', logedInUserId);
      _socketMyTaskAll.listener(
          onSocketTaskAssigned: onSocketTaskAssigned,
          onSocketTaskRemoved: onSocketTaskRemoved,
          onSocketTaskUpdateStatus: onSocketTaskUpdateStatus);
    }
  }

  onChangeFilterSelected(List<String> value) async {
    DateTime firstDataOfTheMonth =
        DateTime.utc(focusedDay.year, focusedDay.month, 1);

    DateTime lastDateOfThisMonth = DateTime.utc(
      focusedDay.year,
      focusedDay.month + 1,
    ).subtract(Duration(days: 1));
    isLoading = true;
    await actionGetEvent(firstDataOfTheMonth, lastDateOfThisMonth);
    isLoading = false;
  }

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    final userString = box.read(KeyStorage.logedInUser);
    MemberModel logedInUser = MemberModel.fromJson(userString);
    _logedInUserId.value = logedInUser.sId;
    kFirstDay = DateTime(kToday.year, kToday.month - 3, kToday.day);
    kLastDay = DateTime.utc(kToday.year + 1, kToday.month, kToday.day);
    controller = AutoScrollController(
        viewportBoundaryGetter: () =>
            Rect.fromLTRB(0, 0, 0, MediaQuery.of(Get.context!).padding.bottom),
        axis: Axis.vertical);

    selectedDay = DateTime(
        DateTime.now().year, DateTime.now().month, DateTime.now().day, 0);

    ever(_myTaskController.listAllIdSelected, onChangeFilterSelected);
  }
}
