import 'package:cicle_mobile_f3/controllers/my_task_controller.dart';
import 'package:cicle_mobile_f3/controllers/tab_my_task_controller.dart';
import 'package:cicle_mobile_f3/screens/my_task/my_task_blast.dart';
import 'package:cicle_mobile_f3/screens/my_task/my_task_blast_done.dart';
import 'package:cicle_mobile_f3/screens/my_task/my_task_check_in.dart';
import 'package:cicle_mobile_f3/screens/my_task/my_task_check_in_done.dart';
import 'package:cicle_mobile_f3/screens/my_task/my_task_kanban.dart';
import 'package:cicle_mobile_f3/screens/my_task/my_task_filter.dart';
import 'package:cicle_mobile_f3/screens/my_task/my_task_kanban_done.dart';
import 'package:cicle_mobile_f3/screens/my_task/my_task_schedule.dart';
import 'package:cicle_mobile_f3/screens/my_task/my_task_schedule_done.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:get/get.dart';

class MyTaskScreen extends StatelessWidget {
  MyTaskScreen({Key? key}) : super(key: key);

  TabMyTaskController _tabMyTaskController = Get.find();
  MyTaskController _myTaskController = Get.find();

  bool _hasFilter() {
    if (_myTaskController.listHqSelected.isNotEmpty ||
        _myTaskController.listProjectSelected.isNotEmpty ||
        _myTaskController.listTeamSelected.isNotEmpty) {
      return true;
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        titleSpacing: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('My Task'),
            Obx(() => Text(
                  _myTaskController.showCompleteTask
                      ? 'Done tasks'
                      : 'All task',
                  style: TextStyle(
                      fontSize: 12,
                      color: Color(0xff708FC7),
                      fontWeight: FontWeight.w600),
                )),
          ],
        ),
        actions: [
          IconButton(
              onPressed: () {
                Get.dialog(MyTaskFilter());
              },
              icon: Obx(() => Icon(
                    Icons.filter_alt_outlined,
                    color: _hasFilter() ? Color(0xffF0B418) : Color(0xffB5B5B5),
                  )))
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildTabItems(),
          Expanded(
            child: Obx(() => IndexedStack(
                  index: _myTaskController.showCompleteTask ? 1 : 0,
                  children: [
                    IndexedStack(
                      index: _tabMyTaskController.activeTabIndex,
                      children: [
                        MyTaskKanban(),
                        MyTaskBlast(),
                        MyTaskCheckIn(),
                        MyTaskSchedule()
                      ],
                    ),
                    IndexedStack(
                      index: _tabMyTaskController.activeTabIndex,
                      children: [
                        MyTaskKanbanDone(),
                        MyTaskBlastDone(),
                        MyTaskCheckInDone(),
                        MyTaskScheduleDone()
                      ],
                    )
                  ],
                )),
          ),
        ],
      ),
      floatingActionButton: Obx(() => FloatingActionButton(
            onPressed: () {
              _myTaskController.showCompleteTask =
                  !_myTaskController.showCompleteTask;
            },
            child: Icon(
              _myTaskController.showCompleteTask
                  ? Icons.summarize_outlined
                  : Icons.assignment_turned_in_outlined,
              color: Colors.white,
            ),
          )),
    );
  }

  Container _buildTabItems() => Container(
        color: Colors.white,
        padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 6.w),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _builtTabItem('Kanban', 0),
            _builtTabItem('Blast', 1),
            _builtTabItem('Check-in', 2),
            _builtTabItem('Schedule', 3),
          ],
        ),
      );

  InkWell _builtTabItem(String title, int index) => InkWell(
      onTap: () => _tabMyTaskController.activeTabIndex = index,
      child: Obx(() => Container(
          decoration: BoxDecoration(
              color: _tabMyTaskController.activeTabIndex == index
                  ? Color(0xffFFEEC3)
                  : Colors.white,
              border: Border.all(
                  width: 2.w,
                  color: _tabMyTaskController.activeTabIndex == index
                      ? Color(0xffFFEEC3)
                      : Color(0xffECECEC)),
              borderRadius: BorderRadius.circular(25.w)),
          padding: EdgeInsets.symmetric(horizontal: 17.w, vertical: 6.w),
          child: Text(
            title,
            style: TextStyle(
                fontSize: 12.w,
                fontWeight: _tabMyTaskController.activeTabIndex == index
                    ? FontWeight.bold
                    : FontWeight.normal,
                color: _tabMyTaskController.activeTabIndex == index
                    ? Color(0xffF0B418)
                    : Color(0xffD6D6D6)),
          ))));
}
