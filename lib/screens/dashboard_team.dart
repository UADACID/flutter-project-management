import 'package:cicle_mobile_f3/controllers/board_controller.dart';
import 'package:cicle_mobile_f3/controllers/tab_main_controller.dart';
import 'package:cicle_mobile_f3/controllers/team_detail_controller.dart';
import 'package:cicle_mobile_f3/screens/notification/notification_screen.dart';
import 'package:cicle_mobile_f3/screens/search/search_screen.dart';

import 'package:cicle_mobile_f3/screens/team_detail.dart';
import 'package:cicle_mobile_f3/widgets/tab_main_widget.dart';
import 'package:cicle_mobile_f3/widgets/team_detail_drawer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'package:get/get.dart';

class DashboardTeamScreen extends StatelessWidget {
  TabMainController _tabMainController = Get.find();
  TeamDetailController _teamDetailController = Get.find();
  BoardController _boardController = Get.find();

  var scaffoldKey = GlobalKey<ScaffoldState>();

  Future<bool> _onWillPop() async {
    // handle back on board menu
    if (_tabMainController.selectedIndex == 0 &&
        _teamDetailController.selectedMenuIndex == 2) {
      if (_boardController.scaffoldKey.currentState!.isEndDrawerOpen &&
          _boardController.scaffoldKeyArchived.currentState!.isEndDrawerOpen) {
        _boardController.scaffoldKeyArchived.currentState!.openDrawer();
        return Future.value(false);
      }
      if (_boardController.scaffoldKey.currentState!.isEndDrawerOpen) {
        _boardController.scaffoldKey.currentState!.openDrawer();
        return Future.value(false);
      }
    }
    if (_teamDetailController.scaffoldKey.currentState!.isEndDrawerOpen) {
      Get.back();
      return Future.value(false);
    }
    if (_tabMainController.selectedIndex != 0) {
      _tabMainController.selectedIndex = 0;
      return Future.value(false);
    }

    if (_tabMainController.selectedIndex == 0) {
      if (_teamDetailController.selectedMenuIndex != 0) {
        _teamDetailController.selectedMenuIndex = 0;
        return Future.value(false);
      }
    }

    return Future.value(true);
  }

  showBottomTab(int selectedMenuIndex, bool endDrawerIsOpen) {
    if (_teamDetailController.selectedMenuIndex == 4) {
      // hide tab for menu group chat
      return SizedBox();
    }

    if (_teamDetailController.selectedMenuIndex == 2 &&
        _boardController.isEndDrawerOpen) {
      return SizedBox();
    }

    return TabMainWidget();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        key: _teamDetailController.scaffoldKey,
        body: Obx(() => IndexedStack(
              index: _tabMainController.selectedIndex,
              children: [
                TeamDetailScreen(),
                NotificationScreen(
                  parentScaffoldKey: scaffoldKey,
                ),
                SearchScreen(),
                SizedBox(),
              ],
            )),
        bottomNavigationBar: Obx(() => showBottomTab(
            _tabMainController.selectedIndex,
            _boardController.isEndDrawerOpen)),
        endDrawer: TeamDetailDrawer(),
      ),
    );
  }
}
