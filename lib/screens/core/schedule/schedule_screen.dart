import 'package:cicle_mobile_f3/controllers/schedule_controller.dart';
import 'package:cicle_mobile_f3/controllers/team_detail_controller.dart';
import 'package:cicle_mobile_f3/models/event_item_model.dart';

import 'package:cicle_mobile_f3/screens/team_detail.dart';
import 'package:cicle_mobile_f3/utils/constant.dart';
import 'package:cicle_mobile_f3/utils/my_flutter_app_icons.dart';
import 'package:expandable/expandable.dart';
import 'package:flash/flash.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'package:table_calendar/table_calendar.dart';

import 'event_item.dart';

class ScheduleScreen extends StatelessWidget {
  ScheduleScreen({Key? key}) : super(key: key);

  TeamDetailController _teamDetailController = Get.find();
  String teamId = Get.parameters['teamId']!;
  String companyId = Get.parameters['companyId'] ?? '';

  RefreshController refreshController =
      RefreshController(initialRefresh: false);

  Future<bool> onRefresh(ScheduleController scheduleController) async {
    try {
      DateTime selectedDateMonth = scheduleController.focusedDay;
      DateTime firstDataOfTheMonth =
          DateTime.utc(selectedDateMonth.year, selectedDateMonth.month, 1);

      DateTime lastDateOfThisMonth = DateTime.utc(
        selectedDateMonth.year,
        selectedDateMonth.month + 1,
      ).subtract(Duration(days: 1));
      await scheduleController.actionGetEvent(
          firstDataOfTheMonth, lastDateOfThisMonth);
      refreshController.refreshCompleted();
      return Future.value(true);
    } catch (e) {
      return Future.value(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetX<ScheduleController>(
        init: ScheduleController(),
        initState: (state) {
          state.controller!.init();
        },
        builder: (scheduleController) {
          return Scaffold(
            appBar: AppBar(
              titleSpacing: 0,
              title: Obx(() => Text(
                    _teamDetailController.teamName,
                    style: TextStyle(fontSize: 16),
                  )),
              elevation: 0.0,
              actions: [
                SizedBox(
                  width: 10,
                ),
                ActionsAppBarTeamDetail(
                  showSetting: false,
                )
              ],
            ),
            body: Stack(
              children: [
                Column(
                  children: [
                    ExpandablePanel(
                      controller: scheduleController.expandableController,
                      collapsed: _buildCalendar(scheduleController),
                      expanded: Container(),
                    ),
                    _buildCollapseHeader(scheduleController),
                    Expanded(
                      child: scheduleController.events.isEmpty
                          ? _buildListEmpty(scheduleController)
                          : _buildHasData(
                              scheduleController.events, scheduleController),
                    ),
                  ],
                ),
                scheduleController.isLoading
                    ? Container(
                        color: Colors.white.withOpacity(0.25),
                        height: double.infinity,
                        width: double.infinity,
                        child: Center(child: CircularProgressIndicator()),
                      )
                    : SizedBox()
              ],
            ),
            floatingActionButton: scheduleController.isLoading
                ? SizedBox()
                : FloatingActionButton(
                    onPressed: () async {
                      var result = await Get.toNamed(
                          RouteName.scheduleFormScreen(
                              teamId: teamId, companyId: companyId));
                      if (result == true) {
                        try {
                          scheduleController.isLoading = true;
                          await onRefresh(scheduleController);
                          scheduleController.isLoading = false;
                        } catch (e) {
                          scheduleController.isLoading = false;
                        }
                      }
                    },
                    child: Icon(
                      Icons.add,
                      color: Colors.white,
                    ),
                  ),
          );
        });
  }

  SmartRefresher _buildHasData(
      List<EventItemModel> value, ScheduleController scheduleController) {
    return SmartRefresher(
      physics: BouncingScrollPhysics(),
      header: WaterDropMaterialHeader(),
      controller: refreshController,
      onRefresh: () => onRefresh(scheduleController),
      child: Obx(() {
        List<EventItemModel> filterByMoreThanSelectedDay = value
            .where((element) =>
                DateTime.parse(element.startDate!)
                    .toLocal()
                    .isAfter(scheduleController.selectedDay) ||
                DateTime.parse(element.startDate!)
                    .toLocal()
                    .isAtSameMomentAs(scheduleController.selectedDay))
            .toList();

        return ListView.builder(
          controller: scheduleController.controller,
          itemCount: filterByMoreThanSelectedDay.length,
          itemBuilder: (context, index) {
            return EventItem(
              item: filterByMoreThanSelectedDay[index],
              index: index,
              list: filterByMoreThanSelectedDay,
              refreshList: () => onRefresh(scheduleController),
            );
          },
        );
      }),
    );
  }

  SmartRefresher _buildListEmpty(ScheduleController scheduleController) {
    return SmartRefresher(
      physics: BouncingScrollPhysics(),
      header: WaterDropMaterialHeader(),
      controller: refreshController,
      onRefresh: () => onRefresh(scheduleController),
      child: ListView(
        children: [
          SizedBox(
            height: 50,
          ),
          Container(
            height: 90,
            width: 90,
            child: Image.asset('assets/images/schedule.png'),
          ),
          Center(
              child: Text(
            'There is no events in this date range',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ))
        ],
      ),
    );
  }

  Container _buildCalendar(ScheduleController scheduleController) {
    final headerText = DateFormat.yMMM().format(scheduleController.focusedDay);
    return Container(
      color: Colors.white,
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.symmetric(vertical: 10),
      child: Column(
        children: [
          Container(
            margin: EdgeInsets.only(bottom: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                bottom: BorderSide(
                  color: Color(0xffFAFAFA),
                  width: 3.0,
                ),
                top: BorderSide(
                  color: Color(0xffFAFAFA),
                  width: 3.0,
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                    onPressed: () {
                      scheduleController.calendarPageController.previousPage(
                        duration: Duration(milliseconds: 300),
                        curve: Curves.easeOut,
                      );
                    },
                    icon: Icon(
                      Icons.chevron_left,
                      size: 28,
                      color: Theme.of(Get.context!).primaryColor,
                    )),
                Text(
                  headerText,
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
                IconButton(
                    onPressed: () {
                      scheduleController.calendarPageController.nextPage(
                        duration: Duration(milliseconds: 300),
                        curve: Curves.easeOut,
                      );
                    },
                    icon: Icon(
                      Icons.chevron_right,
                      size: 28,
                      color: Theme.of(Get.context!).primaryColor,
                    ))
              ],
            ),
          ),
          _buildButtonAddToPublicCalendar(scheduleController),
          Container(
            height: 2,
            color: Color(0xffE5E5E5).withOpacity(0.25),
          ),
          SizedBox(
            height: 15,
          ),
          TableCalendar(
            onCalendarCreated: (PageController calendarController) async {
              scheduleController.calendarPageController = calendarController;
            },
            firstDay: DateTime.utc(scheduleController.kToday.year - 15,
                scheduleController.kToday.month, scheduleController.kToday.day),
            lastDay: scheduleController.kLastDay,
            focusedDay: scheduleController.focusedDay,
            headerVisible: false,
            selectedDayPredicate: (day) {
              return isSameDay(scheduleController.selectedDay, day);
            },
            onDaySelected: (selectedDay, focusedDay) {
              print('focusedDayAsParams $selectedDay');
              if (!isSameDay(scheduleController.selectedDay, selectedDay)) {
                scheduleController.selectedDay = selectedDay;
                scheduleController.focusedDay = focusedDay;
              }
            },
            calendarFormat: scheduleController.calendarFormat,
            onFormatChanged: (format) {
              scheduleController.calendarFormat = format;
            },
            onPageChanged: scheduleController.onPageChange,
            eventLoader: (day) {
              return scheduleController.getEventsForDay(day);
            },
            calendarBuilders:
                CalendarBuilders(markerBuilder: (ctx, dateTime, events) {
              return events.length > 0
                  ? Padding(
                      padding: const EdgeInsets.all(6.0),
                      child: Align(
                        alignment: Alignment.topRight,
                        child: Container(
                          height: events.length.toString().length > 1 ? 18 : 15,
                          width: events.length.toString().length > 1 ? 18 : 15,
                          decoration: BoxDecoration(
                              color: Colors.red, shape: BoxShape.circle),
                          child: Center(
                              child: Text(
                            events.length.toString(),
                            style: TextStyle(
                                fontSize: events.length.toString().length > 2
                                    ? 8
                                    : 11,
                                color: Colors.white),
                          )),
                        ),
                      ),
                    )
                  : SizedBox();
            }),
          ),
        ],
      ),
    );
  }

  setAsPublicCalAction(ScheduleController controller) {
    Get.dialog(DialogSetPublicCalendar(
      onSubmit: () async {
        bool isSuccess = await controller.submitPublicCalendar();
        if (isSuccess) {
          showModalUrl(controller);
        }
      },
    ));
  }

  pickCalendar(ScheduleController controller) {
    Get.bottomSheet(BottomSheetPickCalendar(
      onPressAddToAppleCal: () async {
        Get.back();
        await Future.delayed(Duration(milliseconds: 250));
        setAsPublicCalAction(controller);
      },
      onPressAddToGoogleCal: () async {
        Get.back();
        await Future.delayed(Duration(milliseconds: 250));
        setAsPublicCalAction(controller);
      },
    ));
  }

  showModalUrl(ScheduleController controller) {
    Get.dialog(DialogCalendarModalUrl(
        controller: controller,
        fullUrl: controller.scheduleGoogleCalendar.calendarIcsLink ??
            'error get path url'));
  }

  GestureDetector _buildButtonAddToPublicCalendar(
      ScheduleController controller) {
    return GestureDetector(
      onTap: () {
        if (controller.setPublic) {
          showModalUrl(controller);
        } else {
          pickCalendar(controller);
        }
      },
      child: Container(
        margin: EdgeInsets.only(left: 0, bottom: 6),
        padding: EdgeInsets.symmetric(horizontal: 10),
        height: 26,
        decoration: BoxDecoration(boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 1,
            offset: Offset(1, 1),
          ),
        ], color: Color(0xffFDC532), borderRadius: BorderRadius.circular(5)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.add, color: Color(0xff385282)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                'Add this schedule to my calendars (Google or Apple)',
                style: TextStyle(
                  color: Color(0xff385282),
                  fontSize: 9,
                  decoration: TextDecoration.underline,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildCollapseHeader(ScheduleController scheduleController) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(width: 1.0, color: Color(0xffD6D6D6)),
        ),
      ),
      padding: EdgeInsets.only(left: 29, right: 22, top: 7, bottom: 7),
      child: Row(
        children: [
          Expanded(
              child: Text(
            'Upcoming Events',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          )),
          InkWell(
            onTap: () async {
              scheduleController.isLoading = true;
              await onRefresh(scheduleController);
              scheduleController.isLoading = false;
            },
            child: Container(
                decoration:
                    BoxDecoration(borderRadius: BorderRadius.circular(10.sp)),
                padding: EdgeInsets.all(6.75),
                child: Icon(
                  Icons.refresh_sharp,
                  color: Colors.grey,
                  size: 20,
                )),
          ),
          SizedBox(
            width: 10,
          ),
          GestureDetector(
            onTap: () async {
              scheduleController.toggleCalendar();
            },
            child: Container(
                decoration: BoxDecoration(
                    color: !scheduleController.isCalendarExpand
                        ? Colors.white
                        : Color(0xffFFD974),
                    borderRadius: BorderRadius.circular(10.sp)),
                padding: EdgeInsets.all(6.75),
                child: Icon(
                  MyFlutterApp.mdi_calendar_outline,
                  color: !scheduleController.isCalendarExpand
                      ? Colors.grey
                      : Colors.white,
                  size: 20,
                )),
          )
        ],
      ),
    );
  }
}

class DialogSetPublicCalendar extends StatelessWidget {
  const DialogSetPublicCalendar({
    Key? key,
    required this.onSubmit,
  }) : super(key: key);

  final Function onSubmit;

  @override
  Widget build(BuildContext context) {
    return Material(
        color: Colors.transparent,
        child: Center(
            child: Container(
          padding: EdgeInsets.symmetric(horizontal: 29),
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(30)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 25,
              ),
              Text(
                'Set as Public Calendar',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 20,
              ),
              Text(
                'Before subscribing, we need to set\nthis schedule as a public calendar\nand anybody in the internet with the\nlink could see it. Do you want to\nproceed?',
                textAlign: TextAlign.center,
              ),
              SizedBox(
                height: 15,
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  InkWell(
                    onTap: () {
                      Get.back();
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Text('Cancel'),
                    ),
                  ),
                  SizedBox(
                    width: 60,
                  ),
                  InkWell(
                    onTap: () => onSubmit(),
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Text('Proceed',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xff001AFF))),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 20,
              )
            ],
          ),
        )));
  }
}

class BottomSheetPickCalendar extends StatelessWidget {
  const BottomSheetPickCalendar({
    Key? key,
    required this.onPressAddToGoogleCal,
    required this.onPressAddToAppleCal,
  }) : super(key: key);

  final Function onPressAddToGoogleCal;
  final Function onPressAddToAppleCal;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 130,
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16), topRight: Radius.circular(16))),
      padding: EdgeInsets.symmetric(horizontal: 23),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 20,
          ),
          InkWell(
            onTap: () => onPressAddToGoogleCal(),
            child: Container(
              width: double.infinity,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Google Calendar',
                  style: TextStyle(color: Color(0xff708FC7)),
                ),
              ),
            ),
          ),
          Divider(),
          InkWell(
            onTap: () => onPressAddToAppleCal(),
            child: Container(
              width: double.infinity,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Apple Calendar',
                  style: TextStyle(color: Color(0xff708FC7)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DialogCalendarModalUrl extends StatelessWidget {
  const DialogCalendarModalUrl({
    Key? key,
    required this.fullUrl,
    required this.controller,
  }) : super(key: key);

  final String fullUrl;
  final ScheduleController controller;

  onTapCopy() {
    Clipboard.setData(ClipboardData(text: fullUrl)).then((value) {
      showFlash(
        context: Get.context!,
        duration: Duration(seconds: 4),
        builder: (context, controller) {
          return Flash(
            borderRadius: BorderRadius.horizontal(right: Radius.circular(10)),
            margin: EdgeInsets.all(20),
            controller: controller,
            behavior: FlashBehavior.floating,
            boxShadows: kElevationToShadow[4],
            position: FlashPosition.top,
            horizontalDismissDirection: HorizontalDismissDirection.horizontal,
            child: FlashBar(
              padding: EdgeInsets.zero,
              content: Row(
                children: [
                  Container(
                    height: 52,
                    width: 6,
                    color: Theme.of(context).primaryColor,
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Expanded(
                      child: Align(
                          alignment: Alignment.center,
                          child: Text(
                            'The URL has been copied to the clipboard',
                            style: TextStyle(fontSize: 12, color: Colors.black),
                          ))),
                  IconButton(
                      onPressed: () {
                        controller.dismiss();
                      },
                      icon: Icon(Icons.close))
                ],
              ),
            ),
          );
        },
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Center(
        child: Container(
          width: 325,
          height: 525,
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(5)),
          child: Stack(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    SizedBox(
                      height: 52,
                    ),
                    Text(
                      'Subscribe to all events\nin this project via this link:',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Color(0xff262727),
                          fontSize: 16,
                          fontWeight: FontWeight.w600),
                    ),
                    SizedBox(
                      height: 26,
                    ),
                    Container(
                      height: 118,
                      width: 118,
                      child: Image.asset('assets/images/schedule.png'),
                    ),
                    SizedBox(
                      height: 26,
                    ),
                    Container(
                      decoration: BoxDecoration(
                          border: Border.all(
                              color: Color(0xffFDC532).withOpacity(0.25),
                              width: 3),
                          borderRadius: BorderRadius.circular(7)),
                      child: Container(
                        decoration: BoxDecoration(
                            border: Border.all(color: Color(0xffFDC532)),
                            borderRadius: BorderRadius.circular(5)),
                        child: Row(
                          children: [
                            Expanded(
                              child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: Text(fullUrl),
                                  )),
                            ),
                            InkWell(
                              onTap: onTapCopy,
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 4.0),
                                child: Icon(
                                  Icons.copy,
                                  color: Color(0xffB5B5B5),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 32,
                    ),
                    Text(
                      'See how to add this link to:',
                      style: TextStyle(color: Color(0xff7A7A7A), fontSize: 11),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                            onPressed: controller.handleClickGCal,
                            child: Text('Google Calendar',
                                style: TextStyle(
                                    color: Color(0xff1F3762), fontSize: 11)))),
                    SizedBox(
                      height: 6,
                    ),
                    SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                            onPressed: controller.handleClickICal,
                            child: Text('Apple Calendar',
                                style: TextStyle(
                                    color: Color(0xff1F3762), fontSize: 11))))
                  ],
                ),
              ),
              Align(
                alignment: Alignment.topRight,
                child: IconButton(
                    onPressed: () {
                      Get.back();
                    },
                    icon: Icon(
                      Icons.close,
                      color: Color(0xffB5B5B5),
                    )),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
