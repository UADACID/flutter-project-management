import 'package:cicle_mobile_f3/controllers/company_controller.dart';
import 'package:cicle_mobile_f3/controllers/tab_main_controller.dart';
import 'package:cicle_mobile_f3/screens/home_screen.dart';
import 'package:cicle_mobile_f3/screens/notification/notification_screen.dart';
import 'package:cicle_mobile_f3/screens/search/search_screen.dart';

import 'package:cicle_mobile_f3/widgets/companies_list.dart';

import 'package:cicle_mobile_f3/widgets/tab_main_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class DashboardScreen extends StatelessWidget {
  TabMainController _tabMainController = Get.find();

  final box = GetStorage();
  CompanyController _companyController = Get.put(CompanyController());

  Future<bool> _onWillPop() async {
    if (_tabMainController.selectedIndex != 0) {
      _tabMainController.selectedIndex = 0;
      return Future.value(false);
    }
    return Future.value(true);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Obx(() {
        if (_companyController.curentCompanyIsExpired) {
          return Scaffold(
            key: _companyController.scaffoldKey,
            endDrawer: CompaniesList(),
            body: HomeScreen(
              parentScaffoldKey: _companyController.scaffoldKey,
            ),
            bottomNavigationBar: TabMainWidget(),
          );
        }
        return Scaffold(
          key: _companyController.scaffoldKey,
          endDrawer: CompaniesList(),
          body: Obx(() => IndexedStack(
                index: _tabMainController.selectedIndex,
                children: [
                  HomeScreen(
                    parentScaffoldKey: _companyController.scaffoldKey,
                  ),
                  NotificationScreen(
                    parentScaffoldKey: _companyController.scaffoldKey,
                  ),
                  SearchScreen(),
                  SizedBox(),
                ],
              )),
          bottomNavigationBar: Obx(() => _companyController.isLoading &&
                  _companyController.companies.length == 0
              ? Container(
                  child: Text(''),
                )
              : TabMainWidget()),
        );
      }),
    );
  }
}
