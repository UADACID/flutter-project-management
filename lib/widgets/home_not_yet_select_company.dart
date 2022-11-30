import 'package:badges/badges.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:simple_animations/simple_animations.dart';
import 'package:supercharged/supercharged.dart';

import '../controllers/company_controller.dart';
import '../controllers/tab_main_controller.dart';
import '../models/companies_model.dart';
import 'animation_fade_and_slide.dart';
import 'form_add_team.dart';
import 'logo_complete.dart';

class HomeNotYetSelectCompany extends StatelessWidget {
  HomeNotYetSelectCompany({
    Key? key,
    required this.companyController,
    required this.refresh,
  }) : super(key: key);

  final Function refresh;
  final CompanyController companyController;
  TabMainController _tabMainController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: LogoComplete(
          size: 20,
          mainAxisAlignment: MainAxisAlignment.start,
        ),
        actions: [
          InkWell(
            onTap: () {
              refresh();
            },
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(
                Icons.refresh_rounded,
                color: Theme.of(context).primaryColor,
              ),
            ),
          )
        ],
      ),
      body: Column(
        children: [
          SizedBox(
            height: 20,
          ),
          AnimationFadeAndSlide(
            duration: Duration(milliseconds: 300),
            delay: Duration(milliseconds: 300),
            child: Container(
              height: 150,
              child: SvgPicture.asset(
                'assets/images/colaboration.svg',
                semanticsLabel: 'logo',
              ),
            ),
          ),
          SizedBox(
            height: 20,
          ),
          AnimationFadeAndSlide(
            duration: Duration(milliseconds: 300),
            delay: Duration(milliseconds: 300),
            child:
                Text('Please choose a company that is \non your company list',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    )),
          ),
          SizedBox(
            height: 20,
          ),
          _buildListCompanies(),
          PlayAnimation<double>(
              tween: (0.0).tweenTo(1.0),
              delay: 900.milliseconds,
              duration: 300.milliseconds,
              curve: Curves.fastOutSlowIn,
              builder: (context, child, value) {
                return Transform.scale(
                  scale: value,
                  child: Shimmer(
                    enabled: companyController.isLoading ? true : false,
                    duration: Duration(milliseconds: 1500),
                    colorOpacity: 0.5,
                    child: Container(
                      width: 200,
                      child: ElevatedButton(
                          onPressed: () {
                            Get.dialog(FormAddTeam(
                              type: 'Company',
                              onSave: (name, description) async {
                                companyController.createCompany(
                                    name: name, desc: description);
                              },
                            ));
                          },
                          style: ButtonStyle(
                              shape: MaterialStateProperty.all<
                                      RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ))),
                          child: Text(
                            'Create New Company',
                            style: TextStyle(color: Colors.white),
                          )),
                    ),
                  ),
                );
              }),
          SizedBox(
            height: 20,
          ),
        ],
      ),
    );
  }

  Expanded _buildListCompanies() {
    return Expanded(
        child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: Obx(() {
        List<Companies> _list = companyController.companies;
        return ListView.builder(
            padding: EdgeInsets.only(top: 10),
            itemCount: _list.length,
            itemBuilder: (_, index) {
              Companies item = _list[index];
              Companies _currentCompany = companyController.currentCompany;
              int _counter = 0;
              List<NotifCompanyCounterItem> filterCounterById =
                  companyController.listCompanyCounter
                      .where((element) => element.companyId == item.sId)
                      .toList();
              if (filterCounterById.isNotEmpty) {
                _counter = filterCounterById[0].unreadNotification +
                    filterCounterById[0].unreadChat;
              }
              if (_currentCompany.sId == item.sId) {
                return Container(
                  margin: EdgeInsets.symmetric(vertical: 7.5),
                  child: Material(
                    child: InkWell(
                      onTap: () {
                        Get.back();
                      },
                      child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 30, vertical: 10),
                          decoration: BoxDecoration(
                              color: Color(0xffF0F1F7),
                              borderRadius: BorderRadius.circular(5)),
                          child: Row(
                            children: [
                              Text(
                                item.name,
                                style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xff1F3762),
                                    fontSize: 16),
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              // _counter == 0
                              //     ? SizedBox()
                              //     : Badge(
                              //         animationType: BadgeAnimationType.scale,
                              //         animationDuration:
                              //             Duration(milliseconds: 300),
                              //         badgeColor:
                              //             Theme.of(Get.context!).primaryColor,
                              //         position:
                              //             BadgePosition(top: -10, end: -10),
                              //         badgeContent: Text(
                              //           _counter.toString(),
                              //           style: TextStyle(
                              //               color: Colors.white, fontSize: 9),
                              //         ),
                              //       )
                            ],
                          )),
                    ),
                  ),
                );
              }
              return Container(
                margin: EdgeInsets.symmetric(vertical: 7.5),
                child: Material(
                  color: Colors.white,
                  child: InkWell(
                    onTap: () async {
                      await Future.delayed(Duration(milliseconds: 300));
                      String _currentRouteName = Get.currentRoute;

                      if (_currentRouteName.contains('dashboard')) {
                        Get.back();
                        await Future.delayed(Duration(milliseconds: 300));
                        companyController.setCompanyId(item.sId);
                        await Future.delayed(Duration(milliseconds: 300));
                        _tabMainController.selectedIndex = 0;
                        Get.dialog(
                            Container(
                              child: Center(child: CircularProgressIndicator()),
                            ),
                            name: 'check_subscription_dialog',
                            barrierColor: Colors.black.withOpacity(0.5));
                      } else {
                        Get.back();
                        await Future.delayed(Duration(milliseconds: 300));
                        Get.back();
                        companyController.setCompanyId(item.sId);
                        await Future.delayed(Duration(milliseconds: 300));
                        _tabMainController.selectedIndex = 0;
                        Get.dialog(
                            Container(
                              child: Center(child: CircularProgressIndicator()),
                            ),
                            name: 'check_subscription_dialog',
                            barrierColor: Colors.black.withOpacity(0.5));
                      }
                    },
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                      decoration: BoxDecoration(
                          border:
                              Border.all(width: 1, color: Color(0xffF0F1F7)),
                          borderRadius: BorderRadius.circular(5)),
                      // child: Text(
                      //   item.name,
                      //   style: TextStyle(
                      //       fontWeight: FontWeight.w600,
                      //       color: Color(0xff1F3762),
                      //       fontSize: 16),
                      // )
                      child: Row(
                        children: [
                          Text(
                            item.name,
                            style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Color(0xff1F3762),
                                fontSize: 16),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          _counter == 0
                              ? SizedBox()
                              : Badge(
                                  animationType: BadgeAnimationType.scale,
                                  animationDuration:
                                      Duration(milliseconds: 300),
                                  badgeColor:
                                      Theme.of(Get.context!).primaryColor,
                                  position: BadgePosition(top: -10, end: -10),
                                  badgeContent: Text(
                                    _counter.toString(),
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 9),
                                  ),
                                )
                        ],
                      ),
                    ),
                  ),
                ),
              );
            });
      }),
    ));
  }
}
