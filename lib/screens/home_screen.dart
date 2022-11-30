import 'dart:math';

import 'package:cicle_mobile_f3/controllers/company_controller.dart';
import 'package:cicle_mobile_f3/controllers/home_controller.dart';
import 'package:cicle_mobile_f3/controllers/notification_controller.dart';
import 'package:cicle_mobile_f3/controllers/search_controller.dart';
import 'package:cicle_mobile_f3/models/companies_model.dart';

import 'package:cicle_mobile_f3/utils/constant.dart';
import 'package:cicle_mobile_f3/utils/helpers.dart';

import 'package:cicle_mobile_f3/widgets/animation_fade_and_slide.dart';
import 'package:cicle_mobile_f3/widgets/bottom_sheet_invite_user.dart';

import 'package:cicle_mobile_f3/widgets/error_something_wrong.dart';
import 'package:cicle_mobile_f3/widgets/expired_overflow.dart';
import 'package:cicle_mobile_f3/widgets/form_add_team.dart';
import 'package:cicle_mobile_f3/widgets/horizontal_list_avatar_with_more.dart';

import 'package:cicle_mobile_f3/widgets/logo_complete.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'package:scroll_to_index/scroll_to_index.dart';

import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:simple_animations/simple_animations.dart';
import 'package:supercharged/supercharged.dart';

import '../widgets/home_not_yet_select_company.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({Key? key, required this.parentScaffoldKey}) : super(key: key);
  final GlobalKey<ScaffoldState> parentScaffoldKey;

  CompanyController _companyController = Get.find();
  HomeController _homeController = Get.put(HomeController());
  RefreshController refreshController =
      RefreshController(initialRefresh: false);

  void onRefresh() async {
    await _companyController.init();
    refreshController.refreshCompleted();
  }

  void onPressAdd() {
    Get.bottomSheet(BottomSheetInviteUser());
  }

  void onAddTeam() {
    Get.bottomSheet(BottomSheetAddTeam(), barrierColor: Colors.transparent);
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (!_companyController.isLoading &&
          _companyController.companies.isNotEmpty &&
          _companyController.selectedCompanyId == '') {
        return HomeNotYetSelectCompany(
          companyController: _companyController,
          refresh: onRefresh,
        );
      }
      if (_companyController.isLoading &&
          _companyController.companies.length == 0) {
        return Container(
          child: Scaffold(
            body: Center(child: CircularProgressIndicator()),
          ),
        );
      }

      if (!_companyController.isLoading &&
          _companyController.errorGetData != '') {
        return Center(
            child: ErrorSomethingWrong(
          refresh: onRefresh,
          message: _companyController.errorGetData,
        ));
      }

      if (!_companyController.isLoading &&
          _companyController.companies.length == 0) {
        return _buildEmpty();
      }
      return Container(
          child: _companyController.curentCompanyIsExpired == true
              ? _buildExpired()
              : _buildHasData());
    });
  }

  // Widget _buildNotSelectedCompany() => Scaffold(
  //     appBar: _buildAppBar(hideMembers: true, title: 'Cicle'),
  //     body: Column(
  //       mainAxisAlignment: MainAxisAlignment.center,
  //       // crossAxisAlignment: CrossAxisAlignment.stretch,
  //       children: [
  //         AnimationFadeAndSlide(
  //           duration: Duration(milliseconds: 300),
  //           delay: Duration(milliseconds: 300),
  //           child: Container(
  //             height: 150.w,
  //             child: SvgPicture.asset(
  //               'assets/images/colaboration.svg',
  //               semanticsLabel: 'logo',
  //             ),
  //           ),
  //         ),
  //         SizedBox(
  //           height: 20,
  //         ),
  //         AnimationFadeAndSlide(
  //           duration: Duration(milliseconds: 300),
  //           delay: Duration(milliseconds: 300),
  //           child:
  //               Text('Please choose a company that is \non your company list',
  //                   textAlign: TextAlign.center,
  //                   style: TextStyle(
  //                     fontSize: 12.w,
  //                     fontWeight: FontWeight.w500,
  //                   )),
  //         ),
  //         SizedBox(
  //           height: 20,
  //         ),
  //         PlayAnimation<double>(
  //             tween: (0.0).tweenTo(1.0),
  //             delay: 600.milliseconds,
  //             duration: 300.milliseconds,
  //             curve: Curves.fastOutSlowIn,
  //             builder: (context, child, value) {
  //               return Transform.scale(
  //                 scale: value,
  //                 child: Shimmer(
  //                   enabled: _companyController.isLoading ? true : false,
  //                   duration: Duration(milliseconds: 1500),
  //                   colorOpacity: 0.5,
  //                   child: Container(
  //                     width: 200,
  //                     child: OutlinedButton(
  //                         onPressed: () async {
  //                           await Future.delayed(Duration(milliseconds: 300));
  //                           _companyController.scaffoldKey.currentState
  //                               ?.openEndDrawer();
  //                         },
  //                         style: ButtonStyle(
  //                             shape: MaterialStateProperty.all<
  //                                     RoundedRectangleBorder>(
  //                                 RoundedRectangleBorder(
  //                           borderRadius: BorderRadius.circular(20.w),
  //                         ))),
  //                         child: Text(
  //                           'show company list',
  //                           // style: TextStyle(color: Colors.white),
  //                         )),
  //                   ),
  //                 ),
  //               );
  //             }),
  //         PlayAnimation<double>(
  //             tween: (0.0).tweenTo(1.0),
  //             delay: 900.milliseconds,
  //             duration: 300.milliseconds,
  //             curve: Curves.fastOutSlowIn,
  //             builder: (context, child, value) {
  //               return Transform.scale(
  //                 scale: value,
  //                 child: Shimmer(
  //                   enabled: _companyController.isLoading ? true : false,
  //                   duration: Duration(milliseconds: 1500),
  //                   colorOpacity: 0.5,
  //                   child: Container(
  //                     width: 200,
  //                     child: ElevatedButton(
  //                         onPressed: () {
  //                           Get.dialog(FormAddTeam(
  //                             type: 'Company',
  //                             onSave: (name, description) async {
  //                               _companyController.createCompany(
  //                                   name: name, desc: description);
  //                             },
  //                           ));
  //                         },
  //                         style: ButtonStyle(
  //                             shape: MaterialStateProperty.all<
  //                                     RoundedRectangleBorder>(
  //                                 RoundedRectangleBorder(
  //                           borderRadius: BorderRadius.circular(20.w),
  //                         ))),
  //                         child: Text(
  //                           'Create New Company',
  //                           style: TextStyle(color: Colors.white),
  //                         )),
  //                   ),
  //                 ),
  //               );
  //             })
  //       ],
  //     ));

  Widget _buildExpired() => Scaffold(
      appBar: _buildAppBar(hideMembers: true),
      body: InkWell(onDoubleTap: onRefresh, child: ExpiredOverFlow()));

  Widget _buildEmpty() {
    return Container(
      child: Scaffold(
        appBar: _buildAppBar(hideMembers: true, title: 'Cicle'),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimationFadeAndSlide(
              duration: Duration(milliseconds: 300),
              delay: Duration(milliseconds: 100),
              child: Container(
                height: 150.w,
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
              child: Text(
                  'Please create a new company to\nstart using Cicle. Or simply you can ask\nyour colleagues for link invitation to their\ncompany',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12.w,
                    fontWeight: FontWeight.w500,
                  )),
            ),
            SizedBox(
              height: 20,
            ),
            PlayAnimation<double>(
                tween: (0.0).tweenTo(1.0),
                delay: 300.milliseconds,
                duration: 400.milliseconds,
                curve: Curves.fastOutSlowIn,
                builder: (context, child, value) {
                  return Transform.scale(
                    scale: value,
                    child: Shimmer(
                      enabled: _companyController.isLoading ? true : false,
                      duration: Duration(milliseconds: 1500),
                      colorOpacity: 0.5,
                      child: ElevatedButton(
                          onPressed: () {
                            Get.dialog(FormAddTeam(
                              type: 'Company',
                              onSave: (name, description) async {
                                _companyController.createCompany(
                                    name: name, desc: description);
                              },
                            ));
                          },
                          style: ButtonStyle(
                              shape: MaterialStateProperty.all<
                                      RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.w),
                          ))),
                          child: Text(
                            'Create New Company',
                            style: TextStyle(color: Colors.white),
                          )),
                    ),
                  );
                })
          ],
        ),
      ),
    );
  }

  Scaffold _buildHasData() {
    return Scaffold(
      appBar: _buildAppBar(),
      body: NotificationListener<ScrollNotification>(
        onNotification: (scrollNotification) {
          if (scrollNotification is ScrollStartNotification) {
            _homeController.onStartScroll(scrollNotification.metrics);
          } else if (scrollNotification is ScrollUpdateNotification) {
            _homeController.onUpdateScroll(scrollNotification.metrics);
          } else if (scrollNotification is ScrollEndNotification) {
            _homeController.onEndScroll(scrollNotification.metrics);
          }
          return true;
        },
        child: SmartRefresher(
          physics: BouncingScrollPhysics(),
          header: WaterDropMaterialHeader(),
          controller: refreshController,
          onRefresh: onRefresh,
          child: ListView(
            controller: _homeController.autoScrollController,
            children: [
              AutoScrollTag(
                controller: _homeController.autoScrollController,
                index: 0,
                key: ValueKey(0),
                child: Obx(() {
                  List<Teams> teams = _companyController.teams
                      .where((element) =>
                          element.type == 'hq' &&
                          element.archived.status == false)
                      .toList();
                  return TeamCategoryItem(
                    type: 'HQ',
                    titleHeader: 'Headquarter',
                    emptyMessage:
                        'Start adding new HQ\nby clicking the yellow button!',
                    icon: Icon(
                      Icons.maps_home_work_outlined,
                      color: Color(0xffB5B5B5),
                    ),
                    list: teams.length == 0 ? [] : teams,
                  );
                }),
              ),
              AutoScrollTag(
                controller: _homeController.autoScrollController,
                index: 1,
                key: ValueKey(1),
                child: Obx(
                  () {
                    List<Teams> teams = _companyController.teams
                        .where((element) =>
                            element.type == 'team' &&
                            element.archived.status == false)
                        .toList();
                    return TeamCategoryItem(
                      type: 'Team',
                      titleHeader: 'Team',
                      emptyMessage:
                          'Start adding new Team\nby clicking the yellow button!',
                      icon: Icon(
                        Icons.groups_outlined,
                        color: Color(0xffB5B5B5),
                      ),
                      list: teams.length == 0 ? [] : teams,
                    );
                  },
                ),
              ),
              AutoScrollTag(
                controller: _homeController.autoScrollController,
                index: 2,
                key: ValueKey(2),
                child: Obx(() {
                  List<Teams> teams = _companyController.teams
                      .where((element) =>
                          element.type == 'project' &&
                          element.archived.status == false)
                      .toList();
                  return TeamCategoryItem(
                    type: 'Project',
                    titleHeader: 'Project',
                    emptyMessage:
                        'Start adding new Project\nby clicking the yellow button!',
                    icon: Icon(
                      Icons.assignment_outlined,
                      color: Color(0xffB5B5B5),
                    ),
                    list: teams.length == 0 ? [] : teams,
                  );
                }),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: _companyController.isLoading
          ? Container()
          : FloatingActionButton(
              onPressed: onAddTeam,
              child: Icon(
                Icons.add,
                color: Colors.white,
              ),
            ),
    );
  }

  AppBar _buildAppBar(
      {bool hideMembers = false, String? title, Widget? leading}) {
    return AppBar(
      title: title == null
          ? Obx(() {
              int _counterNotificationAllCompaniesWithOutSelectedCompany = 0;
              String _selectedCompanyId = _companyController.selectedCompanyId;
              List<NotifCompanyCounterItem>
                  filterlistCompanyCounterWithOutSelectedCompanyId =
                  _companyController.listCompanyCounter
                      .where((o) => o.companyId != _selectedCompanyId)
                      .toList();
              if (filterlistCompanyCounterWithOutSelectedCompanyId.isNotEmpty) {
                _counterNotificationAllCompaniesWithOutSelectedCompany =
                    filterlistCompanyCounterWithOutSelectedCompanyId
                        .map(
                            (item) => item.unreadChat + item.unreadNotification)
                        .reduce((a, b) => a + b);
              }

              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(_companyController.currentCompany.name),
                  IconButtonCompanies(
                    parentScaffoldKey: parentScaffoldKey,
                    counterNotificationAllCompaniesWithOutSelectedCompany:
                        _counterNotificationAllCompaniesWithOutSelectedCompany,
                  )
                ],
              );
            })
          : LogoComplete(
              size: 20.w,
              mainAxisAlignment: MainAxisAlignment.start,
            ),
      elevation: 0,
      automaticallyImplyLeading: false,
      bottom: hideMembers
          ? PreferredSize(
              preferredSize: Size.fromHeight(0),
              child: SizedBox(),
            )
          : PreferredSize(
              preferredSize: Size.fromHeight(50),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 0.0, right: 13),
                child: Container(
                  color: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 13),
                  child: Obx(() {
                    double fullWidth = Get.width;
                    double fullWidthContainerList = fullWidth - 70;
                    double _numberDisplay = fullWidthContainerList / 30.w;
                    int rounded = _numberDisplay.floor();
                    return HorizontalListAvatarWithMore(
                      numberDisplayed: rounded,
                      heightItem: 25.w,
                      onPressAdd: onPressAdd,
                      members: _companyController.companyMembers.length == 0
                          ? []
                          : _companyController.companyMembers,
                    );
                  }),
                ),
              ),
            ),
    );
  }
}

class IconButtonCompanies extends StatelessWidget {
  const IconButtonCompanies({
    Key? key,
    required this.parentScaffoldKey,
    required this.counterNotificationAllCompaniesWithOutSelectedCompany,
  }) : super(key: key);

  final GlobalKey<ScaffoldState> parentScaffoldKey;
  final int counterNotificationAllCompaniesWithOutSelectedCompany;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        parentScaffoldKey.currentState!.openEndDrawer();
      },
      child: Stack(
        children: [
          Container(
            margin: EdgeInsets.all(5),
            height: 35,
            width: 35,
            decoration: BoxDecoration(
                border: Border.all(color: Color(0xffD6D6D6)),
                borderRadius: BorderRadius.circular(5)),
            child: Icon(
              Icons.maps_home_work_outlined,
              color: Color(0xff7A7A7A),
            ),
          ),
          counterNotificationAllCompaniesWithOutSelectedCompany > 0
              ? Positioned(
                  top: 2,
                  right: 2,
                  child: Container(
                    height: 10,
                    width: 10,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle, color: Color(0xffFDC532)),
                  ),
                )
              : SizedBox()
        ],
      ),
    );
  }
}

class BottomSheetAddTeam extends StatelessWidget {
  BottomSheetAddTeam({
    Key? key,
  }) : super(key: key);
  HomeController _homeController = Get.put(HomeController());
  CompanyController _companyController = Get.find();

  void onPressAdd(titleHeader, code) {
    Get.dialog(FormAddTeam(
      type: titleHeader,
      onSave: (name, description) async {
        if (code == 0) {
          await _companyController.createTeam(
              name: name, desc: description, type: 'hq');
          await Future.delayed(Duration(milliseconds: 300));
          return _homeController.autoScrollController
              .scrollToIndex(0, preferPosition: AutoScrollPosition.end);
        }

        if (code == 1) {
          // TEAM
          await _companyController.createTeam(
              name: name, desc: description, type: 'team');
          await Future.delayed(Duration(milliseconds: 300));
          return _homeController.autoScrollController
              .scrollToIndex(1, preferPosition: AutoScrollPosition.end);
        }

        if (code == 2) {
          // PROJECT
          await _companyController.createTeam(
              name: name, desc: description, type: 'project');
          await Future.delayed(Duration(milliseconds: 300));
          return _homeController.autoScrollController
              .scrollToIndex(2, preferPosition: AutoScrollPosition.end);
        }
      },
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 165,
      decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 5,
              blurRadius: 7,
              offset: Offset(0, 3), // changes position of shadow
            ),
          ],
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20.w), topRight: Radius.circular(20.w))),
      child: Column(
        children: [
          SizedBox(
            height: 10,
          ),
          _buildItem('Add new HQ', Icons.maps_home_work_outlined,
              () => onPressAdd('New HQ', 0)),
          _buildItem('Add new team', Icons.groups_outlined,
              () => onPressAdd('New Team', 1)),
          _buildItem('Add new project', Icons.assignment_outlined,
              () => onPressAdd('New Project', 2)),
        ],
      ),
    );
  }

  Widget _buildItem(String title, IconData icon, Function onPress) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 25),
      child: Column(
        children: [
          SizedBox(
            height: 50,
            child: ListTile(
              onTap: () => onPress(),
              contentPadding: EdgeInsets.zero,
              leading: Icon(
                icon,
                color: Color(0xff708FC7),
              ),
              title: Text(
                title,
                style: TextStyle(fontSize: 12.w, color: Color(0xff708FC7)),
              ),
            ),
          ),
          SizedBox(height: 1, child: Divider())
        ],
      ),
    );
  }
}

class TeamCategoryItem extends StatelessWidget {
  TeamCategoryItem({
    Key? key,
    required this.titleHeader,
    required this.icon,
    this.list = const [],
    required this.emptyMessage,
    required this.type,
  }) : super(key: key);
  final String titleHeader;
  final Icon icon;
  final List<Teams> list;
  final String emptyMessage;
  final String type;

  void onPressAdd() {
    Get.dialog(FormAddTeam(
      type: titleHeader,
      onSave: (name, description) {
        Get.back();
      },
    ));
  }

  @override
  Widget build(BuildContext context) {
    double fullWidth = MediaQuery.of(context).size.width;
    bool _isPhone = fullWidth < 600;
    bool _isSmallTablet = fullWidth > 600 && fullWidth < 720;
    return Column(
      children: [
        HeaderTitleListTeam(
          title: titleHeader,
          icon: icon,
        ),
        list.length > 0
            ? _hasData(_isPhone, _isSmallTablet)
            : _buildEmpty(_isPhone, _isSmallTablet),
      ],
    );
  }

  GridView _buildEmpty(bool _isPhone, bool _isSmallTablet) => GridView.count(
        shrinkWrap: true,
        primary: false,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 2 / 1,
        crossAxisCount: _isPhone
            ? 1
            : _isSmallTablet
                ? 1
                : 1,
        children: <Widget>[
          Center(
              child: Text(
            emptyMessage,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12.w, color: Color(0xff7A7A7A)),
          ))
        ],
      );

  GestureDetector _buildButtonAdd() {
    return GestureDetector(
      onTap: onPressAdd,
      child: Container(
        decoration: BoxDecoration(
            color: Color(0xffECECEC),
            borderRadius: BorderRadius.circular(20.w)),
        child: DottedBorder(
            color: Colors.grey,
            borderType: BorderType.RRect,
            radius: Radius.circular(20.w),
            dashPattern: [5],
            child: Stack(
              children: [
                Align(
                  alignment: Alignment.topCenter,
                  child: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Text(
                      'Create new $type',
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey),
                    ),
                  ),
                ),
                Center(
                    child: Icon(
                  Icons.add,
                  size: 80,
                  color: Colors.grey,
                )),
              ],
            )),
      ),
    );
  }

  GridView _hasData(bool _isPhone, bool _isSmallTablet) {
    final _random = new Random();
    List<String> _listColors = List.from(cardHomeColorsList);
    _listColors.shuffle(_random);
    return GridView.count(
      shrinkWrap: true,
      primary: false,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      crossAxisCount: _isPhone
          ? 2
          : _isSmallTablet
              ? 3
              : 4,
      children: <Widget>[
        ...list
            .asMap()
            .map((key, value) {
              Color _color = HexColor(_listColors[key % _listColors.length]);
              return MapEntry(
                  key,
                  TeamItem(
                    team: value,
                    color: _color,
                  ));
            })
            .values
            .toList(),
      ],
    );
  }
}

class TeamItem extends StatelessWidget {
  TeamItem({
    Key? key,
    required this.team,
    required this.color,
    this.customTitle,
    this.disableOnPress = false,
  }) : super(key: key);
  final Teams team;
  final Color color;
  CompanyController _companyController = Get.find();
  final Widget? customTitle;
  final bool disableOnPress;
  String companyId = Get.parameters['companyId'] ?? '';
  NotificationController _notificationController = Get.find();

  SearchController _searchController = Get.put(SearchController());

  _insertViewed(String path) {
    _searchController.insertListRecenlyViewed(RecentlyViewed(
        moduleName: 'team-detail',
        companyId: companyId,
        path: path,
        teamName: team.name,
        title: team.name,
        subtitle: 'Home  >  ${team.name}  >  Overview',
        uniqId: team.sId));
  }

  @override
  Widget build(BuildContext context) {
    Color? _color = _companyController.isLoading ? Colors.grey[350] : color;

    return Shimmer(
      enabled: _companyController.isLoading ? true : false,
      // enabled: true,
      duration: Duration(milliseconds: 1500),
      colorOpacity: 0.5,
      child: ElevatedButton(
        onPressed: disableOnPress == true
            ? null
            : () async {
                String path =
                    '${RouteName.teamDetailScreen(companyId)}/${team.sId}';
                Get.toNamed(path);
                await Future.delayed(Duration(milliseconds: 300));

                _notificationController.handleSelectTeamFromHome(team.sId);
                // handle for history viewed
                _insertViewed(path);
              },
        style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all<Color>(_color!),
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
            ))),
        child: Container(
          child: Align(
            alignment: Alignment.center,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: 13,
                ),
                customTitle != null
                    ? customTitle!
                    : Text(
                        team.name,
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                SizedBox(
                  height: 9,
                ),
                Text(
                  team.desc,
                  style: TextStyle(color: Colors.white, fontSize: 11),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(
                  height: 13,
                ),
                _companyController.isLoading
                    ? Container(
                        height: 15.w,
                      )
                    : HorizontalListAvatarWithMore(
                        showButtonAdd: false,
                        numberDisplayed: 5,
                        heightItem: 15.w,
                        counterTextStyle:
                            TextStyle(fontSize: 6.w, color: Colors.grey),
                        // onPressAdd: onPressAdd,
                        members: team.members,
                      )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class HeaderTitleListTeam extends StatelessWidget {
  const HeaderTitleListTeam({
    Key? key,
    required this.title,
    required this.icon,
  }) : super(key: key);
  final String title;
  final Icon icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 10),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              icon,
              SizedBox(
                width: 4,
              ),
              Text(
                '$title',
                style: TextStyle(
                    fontWeight: FontWeight.w600, color: Color(0xffB5B5B5)),
              )
            ],
          ),
          Divider(
            color: Color(0xffC4C4C4),
          )
        ],
      ),
    );
  }
}
