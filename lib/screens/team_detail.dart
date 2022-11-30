import 'package:cicle_mobile_f3/controllers/team_detail_controller.dart';
import 'package:cicle_mobile_f3/models/member_model.dart';

import 'package:cicle_mobile_f3/screens/core/blast/blast_screen.dart';
import 'package:cicle_mobile_f3/screens/core/board/board_screen.dart';

import 'package:cicle_mobile_f3/screens/core/check_in/check_in_screen.dart';
import 'package:cicle_mobile_f3/screens/core/doc_and_file/doc_files_screen.dart';

import 'package:cicle_mobile_f3/screens/core/overview/overview_screen.dart';
import 'package:cicle_mobile_f3/screens/core/schedule/schedule_screen.dart';
import 'package:cicle_mobile_f3/utils/my_flutter_app_icons.dart';

import 'package:cicle_mobile_f3/widgets/horizontal_list_user.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lazy_load_indexed_stack/lazy_load_indexed_stack.dart';

class TeamDetailScreen extends GetView<TeamDetailController> {
  TeamDetailScreen({Key? key}) : super(key: key);

  String? teamId = Get.parameters['teamId'];
  // TeamDetailController _teamDetailController = Get.find();

  List<Widget> _menuOptions = <Widget>[
    OverviewScreen(),
    BlastScreen(),
    BoardScreen(),
    DocFilesScreen(),
    SizedBox(),
    ScheduleScreen(),
    CheckInScreen()
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // body: Obx(() => Container(
      //     child: _menuOptions.elementAt(controller.selectedMenuIndex))),
      body: Obx(() => LazyLoadIndexedStack(
            index: controller.selectedMenuIndex,
            children: _menuOptions,
          )),
    );
  }
}

class ActionsAppBarTeamDetail extends StatelessWidget {
  ActionsAppBarTeamDetail({Key? key, this.showSetting = true})
      : super(key: key);
  final bool showSetting;
  TeamDetailController controller = Get.put(TeamDetailController());

  onTapHeaderButton() {
    Get.bottomSheet(Container(
        height: 360,
        padding: EdgeInsets.symmetric(horizontal: 25),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20), topRight: Radius.circular(20))),
        child: Obx(
          () => ListView(
            physics: ClampingScrollPhysics(),
            children: <Widget>[
              SizedBox(
                height: 20,
              ),
              _buildListItem(
                  icon: Icon(
                    MyFlutterApp.overview_icon,
                    size: 18,
                    color: controller.selectedMenuIndex == 0
                        ? Colors.yellow[700]
                        : Color(0xffD6D6D6),
                  ),
                  text: Text(
                    'Overview',
                    style: TextStyle(
                      color: controller.selectedMenuIndex == 0
                          ? Colors.yellow[700]
                          : Color(0xffD6D6D6),
                    ),
                  ),
                  checkMark: controller.selectedMenuIndex == 0
                      ? Icon(
                          Icons.check,
                          color: Colors.yellow[700],
                        )
                      : SizedBox(),
                  onPress: () {
                    controller.selectedMenuIndex = 0;
                    Get.back();
                  }),
              Divider(
                color: Color(0xffF0F1F7),
              ),
              _buildListItem(
                  icon: Icon(Icons.campaign_outlined,
                      size: 24,
                      color: controller.selectedMenuIndex == 1
                          ? Colors.yellow[700]
                          : Color(0xffD6D6D6)),
                  text: Text(
                    'Blast',
                    style: TextStyle(
                      color: controller.selectedMenuIndex == 1
                          ? Colors.yellow[700]
                          : Color(0xffD6D6D6),
                    ),
                  ),
                  checkMark: controller.selectedMenuIndex == 1
                      ? Icon(
                          Icons.check,
                          color: Colors.yellow[700],
                        )
                      : SizedBox(),
                  onPress: () {
                    controller.selectedMenuIndex = 1;
                    Get.back();
                  }),
              Divider(
                color: Color(0xffF0F1F7),
              ),
              _buildListItem(
                  icon: Icon(MyFlutterApp.board_icon,
                      size: 18,
                      color: controller.selectedMenuIndex == 2
                          ? Colors.yellow[700]
                          : Color(0xffD6D6D6)),
                  text: Text(
                    'Board',
                    style: TextStyle(
                      color: controller.selectedMenuIndex == 2
                          ? Colors.yellow[700]
                          : Color(0xffD6D6D6),
                    ),
                  ),
                  checkMark: controller.selectedMenuIndex == 2
                      ? Icon(
                          Icons.check,
                          color: Colors.yellow[700],
                        )
                      : SizedBox(),
                  onPress: () {
                    controller.selectedMenuIndex = 2;
                    Get.back();
                  }),
              Divider(
                color: Color(0xffF0F1F7),
              ),
              _buildListItem(
                  icon: Icon(MyFlutterApp.doc_icon,
                      size: 18,
                      color: controller.selectedMenuIndex == 3
                          ? Colors.yellow[700]
                          : Color(0xffD6D6D6)),
                  text: Text(
                    'Doc & Files',
                    style: TextStyle(
                      color: controller.selectedMenuIndex == 3
                          ? Colors.yellow[700]
                          : Color(0xffD6D6D6),
                    ),
                  ),
                  checkMark: controller.selectedMenuIndex == 3
                      ? Icon(
                          Icons.check,
                          color: Colors.yellow[700],
                        )
                      : SizedBox(),
                  onPress: () {
                    controller.selectedMenuIndex = 3;
                    Get.back();
                  }),
              Divider(
                color: Color(0xffF0F1F7),
              ),
              _buildListItem(
                  icon: Icon(MyFlutterApp.group_chat_icon,
                      size: 18,
                      color: controller.selectedMenuIndex == 4
                          ? Colors.yellow[700]
                          : Color(0xffD6D6D6)),
                  text: Text(
                    'Group Chat',
                    style: TextStyle(
                        color: controller.selectedMenuIndex == 4
                            ? Colors.yellow[700]
                            : Color(0xffD6D6D6)),
                  ),
                  checkMark: controller.selectedMenuIndex == 4
                      ? Icon(
                          Icons.check,
                          color: Colors.yellow[700],
                        )
                      : SizedBox(),
                  onPress: () async {
                    Get.back();
                    await Future.delayed(Duration(milliseconds: 300));
                    controller.selectedMenuIndex = 4;
                  }),
              Divider(
                color: Color(0xffF0F1F7),
              ),
              _buildListItem(
                  icon: Icon(MyFlutterApp.schedule_icon,
                      size: 18,
                      color: controller.selectedMenuIndex == 5
                          ? Colors.yellow[700]
                          : Color(0xffD6D6D6)),
                  text: Text(
                    'Schedule',
                    style: TextStyle(
                        color: controller.selectedMenuIndex == 5
                            ? Colors.yellow[700]
                            : Color(0xffD6D6D6)),
                  ),
                  checkMark: controller.selectedMenuIndex == 5
                      ? Icon(
                          Icons.check,
                          color: Colors.yellow[700],
                        )
                      : SizedBox(),
                  onPress: () async {
                    controller.selectedMenuIndex = 5;
                    Get.back();
                  }),
              Divider(
                color: Color(0xffF0F1F7),
              ),
              _buildListItem(
                  icon: Icon(MyFlutterApp.check_in_icon,
                      size: 18,
                      color: controller.selectedMenuIndex == 6
                          ? Colors.yellow[700]
                          : Color(0xffD6D6D6)),
                  text: Text(
                    'Check-Ins',
                    style: TextStyle(
                        color: controller.selectedMenuIndex == 6
                            ? Colors.yellow[700]
                            : Color(0xffD6D6D6)),
                  ),
                  checkMark: controller.selectedMenuIndex == 6
                      ? Icon(
                          Icons.check,
                          color: Colors.yellow[700],
                        )
                      : SizedBox(),
                  onPress: () async {
                    controller.selectedMenuIndex = 6;
                    Get.back();
                  }),
              Divider(
                color: Color(0xffF0F1F7),
              ),
            ],
          ),
        )));
  }

  Container _buildListItem(
      {required onPress,
      required Icon icon,
      required Text text,
      required Widget checkMark}) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 5),
      child: InkWell(
        onTap: onPress,
        child: Row(
          children: [
            Container(width: 30, height: 30, child: icon),
            SizedBox(
              width: 16,
            ),
            Expanded(child: text),
            checkMark
          ],
        ),
      ),
    );
  }

  String getTitleButton(int index) {
    switch (index) {
      case 0:
        return 'Overview';
      case 1:
        return 'Blast';
      case 2:
        return 'Board';
      case 3:
        return 'Doc & Files';
      case 4:
        return 'Group Chat';
      case 5:
        return 'Schedule';
      default:
        return 'Check-Ins';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Center(
          child: Container(
            height: 29,
            child: OutlinedButton(
              style: ButtonStyle(
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ))),
              onPressed: onTapHeaderButton,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Obx(() => Text(
                        getTitleButton(controller.selectedMenuIndex),
                        style: TextStyle(fontSize: 11),
                      )),
                  SizedBox(
                    width: 7,
                  ),
                  Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 20,
                  )
                ],
              ),
            ),
          ),
        ),
        showSetting
            ? IconButton(
                onPressed: () {
                  controller.scaffoldKey.currentState!.openEndDrawer();
                },
                icon: Icon(
                  Icons.settings_outlined,
                  color: Colors.grey,
                ))
            : SizedBox(
                width: 20,
              )
      ],
    );
  }
}

class HorizontalListTeamDetail extends StatelessWidget {
  const HorizontalListTeamDetail({
    Key? key,
    this.onPressAdd,
    this.onPressSubmit,
    this.members = const [],
    this.max = 20,
  }) : super(key: key);

  final Function()? onPressAdd;
  final Function()? onPressSubmit;
  final List<MemberModel>? members;
  final int max;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 14.0, right: 13),
        child: Row(
          children: [
            GestureDetector(
              onTap: onPressAdd,
              child: Container(
                margin: EdgeInsets.only(right: 4, left: 20),
                height: 25.w,
                width: 25.w,
                decoration: BoxDecoration(
                    color: Color(0xff708FC7), shape: BoxShape.circle),
                child: Icon(
                  Icons.add,
                  size: 20,
                  color: Colors.white,
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: HorizontalListUser(
                  max: max,
                  margin: EdgeInsets.only(right: 4.w),
                  width: 25.w,
                  textStylePlus: TextStyle(fontSize: 11),
                  members: members!,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
