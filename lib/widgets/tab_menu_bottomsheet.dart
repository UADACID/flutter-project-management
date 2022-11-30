import 'package:badges/badges.dart';
import 'package:cicle_mobile_f3/controllers/auth_controller.dart';
import 'package:cicle_mobile_f3/controllers/company_controller.dart';
import 'package:cicle_mobile_f3/controllers/notification_counter_controller.dart';
import 'package:cicle_mobile_f3/controllers/private_chat_controller.dart';
import 'package:cicle_mobile_f3/controllers/profile_controller.dart';
import 'package:cicle_mobile_f3/controllers/search_controller.dart';
import 'package:cicle_mobile_f3/controllers/tab_main_controller.dart';
import 'package:cicle_mobile_f3/models/companies_model.dart';
import 'package:cicle_mobile_f3/utils/constant.dart';
import 'package:cicle_mobile_f3/utils/helpers.dart';
import 'package:cicle_mobile_f3/utils/my_flutter_app_icons.dart';
import 'package:cicle_mobile_f3/widgets/avatar_custom.dart';
import 'package:cicle_mobile_f3/widgets/default_alert.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'form_add_team.dart';

class TabMenuBottomSheet extends StatelessWidget {
  TabMenuBottomSheet({
    Key? key,
    required this.teamId,
    required this.companyId,
  }) : super(key: key);

  final String? teamId;
  final String companyId;
  PrivateChatController _privateChatController =
      Get.put(PrivateChatController());
  NotificationCounterController _notificationCounterController =
      Get.put(NotificationCounterController());
  CompanyController _companyController = Get.find();
  ProfileController _profileController = Get.put(ProfileController());
  AuthController _authController = Get.put(AuthController());
  TabMainController _tabMainController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Container(
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20), topRight: Radius.circular(20))),
        height: 380,
        child: Column(
          children: [
            // SizedBox(
            //   height: 25,
            // ),
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //   crossAxisAlignment: CrossAxisAlignment.start,
            //   children: [
            //     Obx(() => Padding(
            //           padding: const EdgeInsets.only(left: 25),
            //           child: Container(
            //               decoration: BoxDecoration(
            //                   borderRadius: BorderRadius.circular(10),
            //                   border: Border.all(
            //                       width: 0.0,
            //                       color: Colors.grey.withOpacity(0.0))),
            //               height: 56.w,
            //               child: Image.network(
            //                 getPhotoUrl(
            //                     url: _companyController.currentCompany.logo ??
            //                         ''),
            //                 fit: BoxFit.contain,
            //               )),
            //         )),
            //     InkWell(
            //       onTap: () {
            //         showAlert(message: 'Company Setting is under development');
            //       },
            //       child: Padding(
            //           padding: const EdgeInsets.symmetric(
            //               horizontal: 20, vertical: 5),
            //           child: Icon(
            //             Icons.settings_outlined,
            //             color: Color(0xffB5B5B5),
            //           )),
            //     )
            //   ],
            // ),
            // SizedBox(
            //   height: 10,
            // ),
            // Align(
            //     alignment: Alignment.centerLeft,
            //     child: Padding(
            //       padding: const EdgeInsets.only(left: 25.0),
            //       child: Obx(() => Text(
            //             _companyController.currentCompany.name,
            //             style: TextStyle(fontWeight: FontWeight.w600),
            //           )),
            //     )),
            SizedBox(
              height: 16,
            ),
            // Divider(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 8),
              child: Row(
                children: [
                  InkWell(
                    onTap: () async {
                      if (_companyController.curentCompanyIsExpired) {
                        return showAlert(
                            message:
                                'Company is not active.\nPlease contact our Customer Service');
                      }
                      Get.back();
                      await Future.delayed(Duration(milliseconds: 300));
                      String path =
                          '${RouteName.profileScreen(companyId)}?teamId=$teamId';
                      Get.toNamed(path);

                      // handle for history viewed
                      Get.put(SearchController()).insertListRecenlyViewed(
                          RecentlyViewed(
                              moduleName: 'profile',
                              companyId: companyId,
                              path: path,
                              teamName: ' ',
                              title: '${_profileController.name}',
                              subtitle:
                                  'Home  >  Menu  >  Profile  >  ${_profileController.name}',
                              uniqId: _profileController.logedInUserId));
                    },
                    child: Container(
                        constraints: BoxConstraints(maxWidth: 182.w),
                        height: 49,
                        padding: EdgeInsets.symmetric(horizontal: 15),
                        decoration: BoxDecoration(
                            color: Color(0xffF0F1F7),
                            borderRadius: BorderRadius.circular(5)),
                        child: Obx(() {
                          String _userName = _profileController.name;
                          return Row(
                            children: [
                              AvatarCustom(
                                  height: 32,
                                  child: Image.network(
                                    getPhotoUrl(
                                        url: _profileController.photoUrl),
                                    height: 32,
                                    width: 32,
                                    fit: BoxFit.cover,
                                  )),
                              SizedBox(
                                width: 10,
                              ),
                              Container(
                                width: 100.w,
                                child: Text(_userName,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                    style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xff1F3762))),
                              ),
                              SizedBox(
                                width: 10,
                              ),
                            ],
                          );
                        })),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Flexible(
                    child: InkWell(
                      onTap: () async {
                        if (_companyController.curentCompanyIsExpired) {
                          return showAlert(
                              message:
                                  'Company is not active.\nPlease contact our Customer Service');
                        }
                        Get.back();

                        await Future.delayed(Duration(milliseconds: 300));

                        _privateChatController.searchKey = '';
                        _privateChatController
                            .textEditingControllerSearch.text = '';
                        String companyId = Get.parameters['companyId'] ?? '';
                        _privateChatController.createRecentlyViewed();
                        _privateChatController.listenData(companyId);
                        Get.toNamed(
                            '${RouteName.privateChatScreen(companyId)}?teamId=$teamId');
                      },
                      child: Container(
                          height: 49,
                          padding: EdgeInsets.symmetric(horizontal: 15),
                          decoration: BoxDecoration(
                              color: Color(0xffF0F1F7),
                              borderRadius: BorderRadius.circular(5)),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 10,
                              ),
                              Obx(() {
                                String _count = _notificationCounterController
                                    .counterUnreadChat
                                    .toString();
                                if (_notificationCounterController
                                        .counterUnreadChat ==
                                    0) {
                                  return Icon(MyFlutterApp.icon_chat);
                                }
                                return Badge(
                                  animationType: BadgeAnimationType.scale,
                                  animationDuration:
                                      Duration(milliseconds: 300),
                                  badgeColor: Theme.of(context).primaryColor,
                                  position: BadgePosition(
                                      top: -5,
                                      end: _count.length > 1 ? -20 : -10),
                                  padding: EdgeInsets.symmetric(
                                      vertical: 1, horizontal: 5),
                                  shape: BadgeShape.square,
                                  borderRadius: BorderRadius.circular(20),
                                  badgeContent: Text(
                                    _notificationCounterController
                                        .counterUnreadChat
                                        .toString(),
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 9),
                                  ),
                                  child: Icon(MyFlutterApp.icon_chat),
                                );
                              }),
                              Obx(() => SizedBox(
                                    width: _notificationCounterController
                                                .counterUnreadChat ==
                                            0
                                        ? 16
                                        : 30,
                                  )),
                              Text(
                                'Inbox',
                                style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xff1F3762)),
                              ),
                              SizedBox(
                                width: 10,
                              ),
                            ],
                          )),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 5,
            ),
            Divider(),
            SizedBox(
              height: 5,
            ),
            Material(
              color: Colors.white,
              child: InkWell(
                onTap: () async {
                  // Get.back();
                  // await Future.delayed(Duration(milliseconds: 300));
                  // Get.toNamed(
                  //     '${RouteName.myTaskScreen(companyId)}?teamId=$teamId');
                  showAlert(message: 'feature is under further development');
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 25,
                      ),
                      Icon(
                        Icons.task_alt_outlined,
                        color: Color(0xff1F3762),
                      ),
                      SizedBox(
                        width: 19,
                      ),
                      Text('My Task',
                          style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Color(0xff1F3762),
                              fontSize: 16.sp))
                    ],
                  ),
                ),
              ),
            ),
            Material(
              color: Colors.white,
              child: InkWell(
                onTap: () async {
                  Get.back();
                  await Future.delayed(Duration(milliseconds: 300));
                  Get.toNamed(
                      '${RouteName.workloadScreen(companyId)}?teamId=$teamId');
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 25,
                      ),
                      Icon(
                        MyFlutterApp.icon_work_load,
                        color: Color(0xff1F3762),
                      ),
                      SizedBox(
                        width: 19,
                      ),
                      Text('Workload',
                          style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Color(0xff1F3762),
                              fontSize: 16.sp))
                    ],
                  ),
                ),
              ),
            ),
            Material(
              color: Colors.white,
              child: InkWell(
                onTap: () async {
                  Get.back();
                  await Future.delayed(Duration(milliseconds: 300));
                  Get.toNamed(
                      '${RouteName.staticReportScreen(companyId)}?teamId=$teamId');
                },
                child: Container(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 25,
                        ),
                        Icon(
                          MyFlutterApp.icon_statistic,
                          color: Color(0xff1F3762),
                        ),
                        SizedBox(
                          width: 19,
                        ),
                        Text('Statistic Report',
                            style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Color(0xff1F3762),
                                fontSize: 16.sp))
                      ],
                    ),
                  ),
                ),
              ),
            ),
            // Divider(),
            // Row(
            //   children: [
            //     Expanded(
            //       child: InkWell(
            //         onTap: () {
            //           _companyController.listCompaniesCollapse =
            //               !_companyController.listCompaniesCollapse;
            //         },
            //         child: Row(
            //           children: [
            //             SizedBox(
            //               width: 25,
            //             ),
            //             Obx(
            //               () => Icon(
            //                 _companyController.listCompaniesCollapse
            //                     ? Icons.keyboard_arrow_down_outlined
            //                     : Icons.keyboard_arrow_up_outlined,
            //                 color: _companyController.listCompaniesCollapse
            //                     ? Theme.of(context).primaryColor
            //                     : Color(0xff1F3762),
            //               ),
            //             ),
            //             SizedBox(
            //               width: 19,
            //             ),
            //             Expanded(
            //                 child: Text(
            //               'Companies',
            //               style: TextStyle(
            //                   fontWeight: FontWeight.w600,
            //                   color: Color(0xff1F3762),
            //                   fontSize: 16.sp),
            //             ))
            //           ],
            //         ),
            //       ),
            //     ),
            //     InkWell(
            //       onTap: () async {
            //         if (_companyController.curentCompanyIsExpired) {
            //           return showAlert(
            //               message:
            //                   'Company is not active.\nPlease contact our Customer Service');
            //         }
            //         Get.dialog(FormAddTeam(
            //           type: 'Company',
            //           onSave: (name, description) async {
            //             _companyController.createCompany(
            //                 name: name, desc: description);
            //           },
            //         ));
            //       },
            //       child: Container(
            //         decoration: BoxDecoration(
            //             borderRadius: BorderRadius.circular(3),
            //             border: Border.all(color: Color(0xffDEEAFF))),
            //         margin: EdgeInsets.only(right: 20),
            //         padding: const EdgeInsets.all(8.0),
            //         child: Icon(
            //           Icons.add,
            //           color: Color(0xff1F3762),
            //         ),
            //       ),
            //     ),
            //   ],
            // ),
            // SizedBox(
            //   height: 20,
            // ),
            // Obx(() => _companyController.listCompaniesCollapse
            //     ? _buildListCompanies()
            //     : SizedBox()),
            Divider(),
            SizedBox(
              height: 20,
            ),
            InkWell(
              onTap: () {
                Get.dialog(DefaultAlert(
                    onSubmit: () {
                      _authController.handleSignOut();
                    },
                    onCancel: () {
                      Get.back();
                    },
                    title: "Are you sure to logout ?"));
              },
              child: Row(
                children: [
                  SizedBox(
                    width: 25,
                  ),
                  Icon(
                    Icons.logout,
                    color: Color(0xffFF7171),
                  ),
                  SizedBox(
                    width: 19,
                  ),
                  Text(
                    'Logout',
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Color(0xffFF7171),
                        fontSize: 16.sp),
                  ),
                  Expanded(child: SizedBox()),
                  Text(
                    'v${_tabMainController.packageInfo.value.version}+${_tabMainController.packageInfo.value.buildNumber}',
                    style: TextStyle(color: Colors.grey.withOpacity(0.5)),
                  ),
                  SizedBox(
                    width: 25,
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 20,
            ),
          ],
        ),
      ),
    );
  }

  // Expanded _buildListCompanies() {
  //   return Expanded(
  //       child: Padding(
  //     padding: const EdgeInsets.symmetric(horizontal: 25),
  //     child: Obx(() {
  //       List<Companies> _list = _companyController.companies;
  //       return ListView.builder(
  //           itemCount: _list.length,
  //           itemBuilder: (_, index) {
  //             Companies item = _list[index];
  //             Companies _currentCompany = _companyController.currentCompany;
  //             if (_currentCompany.sId == item.sId) {
  //               return Container(
  //                 margin: EdgeInsets.symmetric(vertical: 7.5),
  //                 child: Material(
  //                   child: InkWell(
  //                     onTap: () {
  //                       Get.back();
  //                     },
  //                     child: Container(
  //                         padding: EdgeInsets.symmetric(
  //                             horizontal: 30, vertical: 10),
  //                         decoration: BoxDecoration(
  //                             color: Color(0xffF0F1F7),
  //                             borderRadius: BorderRadius.circular(5)),
  //                         child: Text(
  //                           item.name,
  //                           style: TextStyle(
  //                               fontWeight: FontWeight.w600,
  //                               color: Color(0xff1F3762),
  //                               fontSize: 16.sp),
  //                         )),
  //                   ),
  //                 ),
  //               );
  //             }
  //             return Container(
  //               margin: EdgeInsets.symmetric(vertical: 7.5),
  //               child: Material(
  //                 color: Colors.white,
  //                 child: InkWell(
  //                   onTap: () async {
  //                     await Future.delayed(Duration(milliseconds: 300));
  //                     String _currentRouteName = Get.currentRoute;

  //                     if (_currentRouteName.contains('dashboard')) {
  //                       Get.back();
  //                       await Future.delayed(Duration(milliseconds: 300));
  //                       _companyController.setCompanyId(item.sId);
  //                       await Future.delayed(Duration(milliseconds: 300));
  //                       _tabMainController.selectedIndex = 0;
  //                       Get.dialog(
  //                           Container(
  //                             child: Center(child: CircularProgressIndicator()),
  //                           ),
  //                           name: 'check_subscription_dialog',
  //                           barrierColor: Colors.black.withOpacity(0.5));
  //                     } else {
  //                       Get.back();
  //                       await Future.delayed(Duration(milliseconds: 300));
  //                       Get.back();
  //                       _companyController.setCompanyId(item.sId);
  //                       await Future.delayed(Duration(milliseconds: 300));
  //                       _tabMainController.selectedIndex = 0;
  //                       Get.dialog(
  //                           Container(
  //                             child: Center(child: CircularProgressIndicator()),
  //                           ),
  //                           name: 'check_subscription_dialog',
  //                           barrierColor: Colors.black.withOpacity(0.5));
  //                     }
  //                   },
  //                   child: Container(
  //                       padding:
  //                           EdgeInsets.symmetric(horizontal: 30, vertical: 10),
  //                       decoration: BoxDecoration(
  //                           border:
  //                               Border.all(width: 1, color: Color(0xffF0F1F7)),
  //                           borderRadius: BorderRadius.circular(5)),
  //                       child: Text(
  //                         item.name,
  //                         style: TextStyle(
  //                             fontWeight: FontWeight.w600,
  //                             color: Color(0xff1F3762),
  //                             fontSize: 16.sp),
  //                       )),
  //                 ),
  //               ),
  //             );
  //           });
  //     }),
  //   ));
  // }
}
