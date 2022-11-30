import 'dart:collection';

import 'package:cicle_mobile_f3/controllers/team_detail_controller.dart';
import 'package:cicle_mobile_f3/models/event_item_model.dart';
import 'package:cicle_mobile_f3/models/member_model.dart';
import 'package:cicle_mobile_f3/service/schedule_service.dart';
import 'package:cicle_mobile_f3/utils/constant.dart';
import 'package:cicle_mobile_f3/utils/helpers.dart';
import 'package:cicle_mobile_f3/utils/socket/socket_schedule.dart';
import 'package:cicle_mobile_f3/widgets/webview_cummon.dart';
import 'package:easy_debounce/easy_debounce.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

import 'package:supercharged/supercharged.dart';
import 'package:table_calendar/table_calendar.dart';

int getHashCode(DateTime key) {
  return key.day * 1000000 + key.month * 10000 + key.year;
}

List<DateTime> daysInRange(DateTime first, DateTime last) {
  final dayCount = last.difference(first).inDays + 1;
  return List.generate(
    dayCount,
    (index) => DateTime.utc(first.year, first.month, first.day + index),
  );
}

class ScheduleController extends GetxController {
  final box = GetStorage();
  ScheduleService _scheduleService = ScheduleService();
  TeamDetailController _teamDetailController = Get.find();

  SocketSchedule _socketSchedule = SocketSchedule();

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
      String scheduleId, String fromDate, String untilDate) async {
    dynamic params = {
      "fromDate": dateAdapter(fromDate),
      "untilDate": "${untilDate}T24:00:00.000Z"
    };

    final response = await _scheduleService.getEvents(scheduleId, params);

    events = [];
    response.data['schedule']['events'].forEach((v) {
      _events.add(EventItemModel.fromJson(v));
    });

    if (response.data['schedule']['setPublic'] != null) {
      setPublic = response.data['schedule']['setPublic'];
    }
    if (response.data['schedule']['googleCalendar'] != null) {
      scheduleGoogleCalendar = ScheduleGoogleCalendar.fromJson(
          response.data['schedule']['googleCalendar']);
    }
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
      if (_teamDetailController.scheduleId == '') {
        await _teamDetailController.getTeam();
      }

      String untilDate = DateFormat('yyyy-MM-dd').format(until.toUtc());
      String fromDate = from.toString();

      List<EventItemModel> _list = await getEvents(
          _teamDetailController.scheduleId, fromDate, untilDate);

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
      // isLoading = false;
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
        selectedDay = DateTime.now();
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

  Future<bool> submitPublicCalendar() async {
    try {
      Get.back();
      isLoading = true;
      dynamic body = {};
      _teamDetailController.scheduleId;
      final response = await _scheduleService.publicCalendar(
          _teamDetailController.scheduleId, body);
      showAlert(message: response.data['message']);
      if (response.data['schedule']['setPublic'] != null) {
        setPublic = response.data['schedule']['setPublic'];
      }

      if (response.data['schedule']['googleCalendar'] != null) {
        scheduleGoogleCalendar = ScheduleGoogleCalendar.fromJson(
            response.data['schedule']['googleCalendar']);
      }
      isLoading = false;
      return Future.value(true);
    } catch (e) {
      isLoading = false;
      errorMessageMiddleware(e);
      return Future.value(false);
    }
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

  onSocketPostNew(data) {
    // print('new event');
  }

  onSocketPostUpdate(data) {
    EventItemModel _eventItem = EventItemModel.fromJson(data);

    List<EventItemModel> _tempList = List.from(_events);
    int index =
        _tempList.indexWhere((element) => element.sId == _eventItem.sId);

    if (index >= 0) {
      _tempList[index] = _eventItem;
      listAdapter(_tempList);
    } else {
      DateTime eventStartDate = DateTime.parse(_eventItem.startDate!).toLocal();
      var eventMonth = eventStartDate.month;
      var eventYear = eventStartDate.year;
      DateTime currentFocusDate = focusedDay;
      var currentFocusMonth = currentFocusDate.month;
      var currentFocusYear = currentFocusDate.year;

      if ('$eventMonth$eventYear' == '$currentFocusMonth$currentFocusYear') {
        // event ada di bulan yang sedang aktif
        _tempList.add(_eventItem);
        listAdapter(_tempList);
      }
    }
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
  }

  onSocketPostArchive(data) {
    List<EventItemModel> _tempList = List.from(_events);
    EventItemModel _eventItem = EventItemModel.fromJson(data);
    int index =
        _tempList.indexWhere((element) => element.sId == _eventItem.sId);
    if (index >= 0) {
      _tempList.removeAt(index);
      listAdapter(_tempList);
    }
  }

  onSocketOccurrenceNew(data) {
    List<EventItemModel> _tempList = List.from(_events);
    data.forEach((o) {
      EventItemModel _eventItem = EventItemModel.fromJson(data);
      DateTime eventStartDate = DateTime.parse(_eventItem.startDate!).toLocal();
      var eventMonth = eventStartDate.month;
      var eventYear = eventStartDate.year;
      DateTime currentFocusDate = focusedDay;
      var currentFocusMonth = currentFocusDate.month;
      var currentFocusYear = currentFocusDate.year;
      if ('$eventMonth$eventYear' == '$currentFocusMonth$currentFocusYear') {
        _tempList.add(_eventItem);
        listAdapter(_tempList);
      }
    });
  }

  onSocketOccurrenceUpdate(data) {
    try {
      List<EventItemModel> _tempList = List.from(_events);
      data.forEach((o) {
        EventItemModel _eventItem = EventItemModel.fromJson(o);
        int index =
            _tempList.indexWhere((element) => element.sId == _eventItem.sId);

        if (index >= 0) {
          _tempList[index] = _eventItem;
        }
      });

      listAdapter(_tempList);
    } catch (e) {
      print(e);
    }
  }

  onSocketOccurrenceArchive(data) {
    List<EventItemModel> _tempList = List.from(_events);
    data.forEach((o) {
      EventItemModel _eventItem = EventItemModel.fromJson(data);
      int index =
          _tempList.indexWhere((element) => element.sId == _eventItem.sId);

      if (index >= 0) {
        _tempList.removeAt(index);
      }
    });

    listAdapter(_tempList);
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

      String scheduleId = _teamDetailController.scheduleId;
      _socketSchedule.init(scheduleId, logedInUserId);
      _socketSchedule.listener(
          onSocketPostNew,
          onSocketPostUpdate,
          onSocketPostArchive,
          onSocketOccurrenceNew,
          onSocketOccurrenceUpdate,
          onSocketOccurrenceArchive);
    }
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
  }

  @override
  void onClose() {
    // TODO: implement onClose
    super.onClose();
    _socketSchedule.removeListenFromSocket();
  }
}
