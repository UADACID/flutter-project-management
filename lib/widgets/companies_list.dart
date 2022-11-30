import 'package:badges/badges.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cicle_mobile_f3/controllers/company_controller.dart';
import 'package:cicle_mobile_f3/controllers/tab_main_controller.dart';
import 'package:cicle_mobile_f3/models/companies_model.dart';
import 'package:cicle_mobile_f3/utils/helpers.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'form_add_team.dart';

class CompaniesList extends StatelessWidget {
  CompaniesList({
    Key? key,
  }) : super(key: key);

  CompanyController _companyController = Get.find();
  TabMainController _tabMainController = Get.find();

  @override
  Widget build(BuildContext context) {
    double statusBarHeight = MediaQuery.of(context).padding.top;
    return Container(
      width: Get.width < 600 ? Get.width - 75 : 550,
      decoration: BoxDecoration(
        color: Colors.white,
      ),
      child: Column(
        children: [
          SizedBox(
            height: statusBarHeight,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Obx(() => Padding(
                    padding: const EdgeInsets.only(left: 25),
                    child: Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              width: 0.0, color: Colors.grey.withOpacity(0.0))),
                      height: 56,
                      child: CachedNetworkImage(
                        imageUrl: getPhotoUrl(
                            url: _companyController.currentCompany.logo ?? ''),
                        fit: BoxFit.contain,
                      ),
                    ),
                  )),
              InkWell(
                onTap: () {
                  showAlert(message: 'Company Setting is under development');
                },
                child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                    child: Icon(
                      Icons.settings_outlined,
                      color: Color(0xffB5B5B5),
                    )),
              )
            ],
          ),
          SizedBox(
            height: 10,
          ),
          Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 25.0),
                child: Obx(() => Text(
                      _companyController.currentCompany.name,
                      style: TextStyle(fontWeight: FontWeight.w600),
                    )),
              )),
          SizedBox(
            height: 10,
          ),
          Divider(),
          SizedBox(
            height: 10,
          ),
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () {
                    _companyController.listCompaniesCollapse =
                        !_companyController.listCompaniesCollapse;
                  },
                  child: Row(
                    children: [
                      SizedBox(
                        width: 25,
                      ),
                      Obx(
                        () => Icon(
                          _companyController.listCompaniesCollapse
                              ? Icons.keyboard_arrow_down_outlined
                              : Icons.keyboard_arrow_up_outlined,
                          color: _companyController.listCompaniesCollapse
                              ? Theme.of(context).primaryColor
                              : Color(0xff1F3762),
                        ),
                      ),
                      SizedBox(
                        width: 19,
                      ),
                      Expanded(
                          child: Text(
                        'Companies',
                        style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Color(0xff1F3762),
                            fontSize: 16),
                      ))
                    ],
                  ),
                ),
              ),
              InkWell(
                onTap: () async {
                  // if (_companyController.curentCompanyIsExpired) {
                  //   return showAlert(
                  //       message:
                  //           'Company is not active.\nPlease contact our Customer Service');
                  // }
                  Get.dialog(FormAddTeam(
                    type: 'Company',
                    onSave: (name, description) async {
                      _companyController.createCompany(
                          name: name, desc: description);
                    },
                  ));
                },
                child: Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(3),
                      border: Border.all(color: Color(0xffDEEAFF))),
                  margin: EdgeInsets.only(right: 20),
                  padding: const EdgeInsets.all(8.0),
                  child: Icon(
                    Icons.add,
                    color: Color(0xff1F3762),
                  ),
                ),
              ),
            ],
          ),
          // SizedBox(
          //   height: 20,
          // ),
          Obx(() => _companyController.listCompaniesCollapse
              ? _buildListCompanies()
              : SizedBox()),
          Divider(),
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
        List<Companies> _list = _companyController.companies;
        return ListView.builder(
            padding: EdgeInsets.only(top: 10),
            itemCount: _list.length,
            itemBuilder: (_, index) {
              Companies item = _list[index];
              Companies _currentCompany = _companyController.currentCompany;
              int _counter = 0;
              List<NotifCompanyCounterItem> filterCounterById =
                  _companyController.listCompanyCounter
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
                        _companyController.setCompanyId(item.sId);
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
                        _companyController.setCompanyId(item.sId);
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
