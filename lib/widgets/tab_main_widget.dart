import 'package:badges/badges.dart';
import 'package:cicle_mobile_f3/controllers/company_controller.dart';
import 'package:cicle_mobile_f3/controllers/notification_counter_controller.dart';
import 'package:cicle_mobile_f3/controllers/profile_controller.dart';
import 'package:cicle_mobile_f3/controllers/tab_main_controller.dart';
import 'package:cicle_mobile_f3/controllers/team_detail_controller.dart';
import 'package:cicle_mobile_f3/utils/constant.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TabMainWidget extends StatelessWidget {
  TabMainController _tabMainController = Get.find();
  NotificationCounterController _notificationCounterController =
      Get.put(NotificationCounterController());

  CompanyController _companyController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Obx(() => _tabMainController.isTabHide.value
        ? SizedBox()
        : BottomNavigationBar(
            items: <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                  icon: Icon(Icons.home_filled),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Obx(() {
                    if (_notificationCounterController.counterUnreadNonChat ==
                        0) {
                      return Icon(Icons.notifications_none);
                    }
                    return Badge(
                      animationType: BadgeAnimationType.scale,
                      animationDuration: Duration(milliseconds: 300),
                      badgeColor: Theme.of(context).primaryColor,
                      position: BadgePosition(top: -10, end: -10),
                      badgeContent: Text(
                        _notificationCounterController.counterUnreadNonChat
                            .toString(),
                        style: TextStyle(color: Colors.white, fontSize: 9),
                      ),
                      child: Icon(Icons.notifications_none),
                    );
                  }),
                  label: 'Notification',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.search),
                  label: 'Search',
                ),
                // BottomNavigationBarItem(
                //   // icon: Icon(
                //   //   Icons.maps_home_work_outlined,
                //   // ),
                //   icon: Obx(() {
                //     if (_companyController.totalCounter == 0) {
                //       return Icon(Icons.maps_home_work_outlined);
                //     }
                //     return Badge(
                //       animationType: BadgeAnimationType.scale,
                //       animationDuration: Duration(milliseconds: 300),
                //       badgeColor: Theme.of(context).primaryColor,
                //       position: BadgePosition(top: -10, end: -10),
                //       badgeContent: Text(
                //         _companyController.totalCounter.toString(),
                //         style: TextStyle(color: Colors.white, fontSize: 9),
                //       ),
                //       child: Icon(
                //         Icons.maps_home_work_outlined,
                //       ),
                //     );
                //   }),
                //   label: 'Companies',
                // ),
                BottomNavigationBarItem(
                  icon: Obx(() {
                    if (_notificationCounterController.counterUnreadChat == 0) {
                      return Icon(Icons.menu);
                    }
                    return Badge(
                      animationType: BadgeAnimationType.scale,
                      animationDuration: Duration(milliseconds: 300),
                      badgeColor: Theme.of(context).primaryColor,
                      position: BadgePosition(top: -10, end: -10),
                      badgeContent: Text(
                        _notificationCounterController.counterUnreadChat
                            .toString(),
                        style: TextStyle(color: Colors.white, fontSize: 9),
                      ),
                      child: Icon(Icons.menu),
                    );
                  }),
                  label: 'Menu',
                ),
              ],
            type: BottomNavigationBarType.fixed,
            currentIndex: _tabMainController.selectedIndex,
            selectedItemColor: Color(0xff1F3762),
            unselectedItemColor: Colors.grey,
            onTap: (index) async {
              if (index == 3) {
                // handle open bottom sheet for every tab

                _tabMainController.showMenuBottomSheet();
                await Future.delayed(const Duration(milliseconds: 600));
                ProfileController _profileController =
                    Get.put(ProfileController());
                _profileController.setInitialValue(true);
              }
              // else if (index == 3) {
              //   // handle open bottom sheet for every tab
              //   _tabMainController.showCompaniesBottomSheet();
              //   // ProfileController _profileController =
              //   //     Get.put(ProfileController());
              //   // _profileController.setInitialValue(true);
              // }
              else {
                if (Get.currentRoute.contains('team-detail') &&
                    _tabMainController.selectedIndex == 0 &&
                    index == 0) {
                  TeamDetailController _teamDetailController = Get.find();
                  if (_teamDetailController.selectedMenuIndex == 0) {
                    // handle click if team detail on overview section
                    Get.back();
                  } else {
                    _teamDetailController.selectedMenuIndex = 0;
                  }
                } else {
                  _tabMainController.selectedIndex = index;
                }
              }
            }));
  }
}
