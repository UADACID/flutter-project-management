import 'package:cicle_mobile_f3/controllers/my_task_schedule_done_controller.dart';
import 'package:cicle_mobile_f3/models/event_item_model.dart';
import 'package:cicle_mobile_f3/screens/core/schedule/event_item.dart';
import 'package:cicle_mobile_f3/utils/helpers.dart';
import 'package:cicle_mobile_f3/utils/my_flutter_app_icons.dart';
import 'package:cicle_mobile_f3/widgets/avatar_custom.dart';
import 'package:cicle_mobile_f3/widgets/custom_sparator.dart';
import 'package:expandable/expandable.dart';

import 'package:flutter/material.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'package:table_calendar/table_calendar.dart';

class MyTaskScheduleDone extends StatelessWidget {
  MyTaskScheduleDone({Key? key}) : super(key: key);

  RefreshController refreshController =
      RefreshController(initialRefresh: false);

  Future<bool> onRefresh(
      MyTaskScheduleDoneController scheduleController) async {
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
    return GetX<MyTaskScheduleDoneController>(
        init: MyTaskScheduleDoneController(),
        initState: (state) {
          state.controller!.init();
        },
        builder: (scheduleController) {
          return Scaffold(
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
          );
        });
  }

  SmartRefresher _buildHasData(List<EventItemModel> value,
      MyTaskScheduleDoneController scheduleController) {
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
            return Column(
              children: [
                SizedBox(
                  height: 16,
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                      margin: EdgeInsets.only(right: 30),
                      padding:
                          EdgeInsets.symmetric(vertical: 3, horizontal: 13),
                      decoration: BoxDecoration(
                          color: Color(0xffA9C289),
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(12),
                              topRight: Radius.circular(12))),
                      child: Text(
                        filterByMoreThanSelectedDay[index].teamName,
                        style: TextStyle(
                            fontSize: 12,
                            color: Colors.white,
                            fontWeight: FontWeight.bold),
                      )),
                ),
                EventItem(
                  isDone: true,
                  customMargin: EdgeInsets.zero,
                  customFooter: filterByMoreThanSelectedDay[index]
                              .lastComment ==
                          null
                      ? SizedBox(
                          height: 15,
                        )
                      : Container(
                          padding: EdgeInsets.symmetric(vertical: 9),
                          child: Column(
                            children: [
                              CustomSparator(
                                color: Color(0xffD6D6D6),
                              ),
                              SizedBox(
                                height: 9,
                              ),
                              Padding(
                                padding: EdgeInsets.only(left: 11, right: 11),
                                child: Row(
                                  children: [
                                    AvatarCustom(
                                      child: Image.network(
                                        getPhotoUrl(
                                            url: filterByMoreThanSelectedDay[
                                                    index]
                                                .lastComment!
                                                .creator
                                                .photoUrl),
                                        height: 28,
                                        width: 28,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    SizedBox(
                                      width: 9,
                                    ),
                                    Text(
                                      filterByMoreThanSelectedDay[index]
                                          .lastComment!
                                          .creator
                                          .fullName,
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    SizedBox(
                                      width: 3,
                                    ),
                                    Flexible(
                                        child: Text(
                                      removeHtmlTag(
                                          filterByMoreThanSelectedDay[index]
                                              .lastComment!
                                              .content),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ))
                                  ],
                                ),
                              ),
                            ],
                          )),
                  item: filterByMoreThanSelectedDay[index],
                  index: index,
                  list: filterByMoreThanSelectedDay,
                  refreshList: () => onRefresh(scheduleController),
                ),
              ],
            );
          },
        );
      }),
    );
  }

  SmartRefresher _buildListEmpty(
      MyTaskScheduleDoneController scheduleController) {
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

  Container _buildCalendar(MyTaskScheduleDoneController scheduleController) {
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

  Widget _buildCollapseHeader(MyTaskScheduleDoneController scheduleController) {
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
