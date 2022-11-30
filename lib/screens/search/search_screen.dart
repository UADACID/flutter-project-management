import 'package:cicle_mobile_f3/controllers/company_controller.dart';
import 'package:cicle_mobile_f3/controllers/notification_controller.dart';
import 'package:cicle_mobile_f3/controllers/private_chat_controller.dart';
import 'package:cicle_mobile_f3/controllers/search_controller.dart';
import 'package:cicle_mobile_f3/controllers/tab_main_controller.dart';
import 'package:cicle_mobile_f3/models/companies_model.dart';
import 'package:cicle_mobile_f3/utils/constant.dart';
import 'package:cicle_mobile_f3/utils/my_flutter_app_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

// import 'searc_filter.dart';

class SearchScreen extends StatelessWidget {
  SearchScreen({Key? key}) : super(key: key);

  SearchController _searchController = Get.put(SearchController());
  // CompanyController _companyController = Get.put(CompanyController());

  String currentCompanyId = Get.parameters['companyId'] ?? '';

  // onPressFilter() {
  //   // Get.bottomSheet(SearchFilter(), isScrollControlled: true);
  //   String companyId = Get.parameters['companyId'] ?? '';
  //   String teamId = Get.parameters['teamId'] ?? '';
  //   Get.toNamed(
  //       '${RouteName.searchResultScreen(companyId, teamId)}?showFilter=1');
  // }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: SafeArea(
        child: Scaffold(
          body: Column(
            children: [
              // Container(
              //   color: Colors.white,
              //   padding: EdgeInsets.only(bottom: 10, top: 5),
              //   child: _buildHeaderInput(),
              // ),
              Container(
                width: double.infinity,
                height: 1,
                color: Color(0xffFAFAFA),
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      SizedBox(
                        height: 12,
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'Jump to',
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Color(0xff7A7A7A)),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      _buildListRecenlyViewed(),
                      _buildListHq(
                          'Headquarter',
                          'hq',
                          Icon(
                            Icons.maps_home_work_outlined,
                            color: Color(0xffB5B5B5),
                          ),
                          _searchController.showAllHq),
                      _buildListHq(
                          'Teams',
                          'team',
                          Icon(
                            Icons.groups_outlined,
                            color: Color(0xffB5B5B5),
                          ),
                          _searchController.showAllTeam),
                      _buildListHq(
                          'Projects',
                          'project',
                          Icon(
                            Icons.assignment_outlined,
                            color: Color(0xffB5B5B5),
                          ),
                          _searchController.showAllProject)
                    ],
                  ),
                ),
              ),
              Container(
                // color: Theme.of(context).primaryColor.withOpacity(0.5),
                // color: Colors.white,
                padding: EdgeInsets.only(bottom: 16, top: 14),
                child: _buildHeaderInput(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Container _buildListHq(
      String title, String type, Icon icon, RxBool isShowAll) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Obx(() {
        List<Teams> teamAsHQ = _searchController.teams
            .where((o) => o.type == type && o.archived.status == false)
            .toList();
        int limit = isShowAll.value ? teamAsHQ.length : 2;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            teamAsHQ.length > 0
                ? Padding(
                    padding:
                        const EdgeInsets.only(bottom: 12, left: 8, top: 16),
                    child: Text(title,
                        style: TextStyle(color: Colors.black.withOpacity(0.5))),
                  )
                : SizedBox(),
            ...teamAsHQ
                .asMap()
                .map((key, value) => MapEntry(
                    key,
                    InkWell(
                      onTap: () async {
                        NotificationController _notificationController =
                            Get.find();
                        String companyId = Get.parameters['companyId'] ?? '';
                        // Get.put(TabMainController()).selectedIndex = 0;
                        String path =
                            '${RouteName.teamDetailScreen(companyId)}/${value.sId}?destinationIndex=0';

                        _searchController
                            .insertListRecenlyViewed(RecentlyViewed(
                                // icon: Icons.maps_home_work_outlined,
                                moduleName: 'team-detail',
                                companyId: companyId,
                                path: path,
                                teamName: value.name,
                                title: value.name,
                                subtitle: 'Home  >  ${value.name}  >  Overview',
                                uniqId: value.sId));

                        _notificationController
                            .handleSelectTeamFromHome(value.sId);
                        // Get.reset();
                        // await Future.delayed(Duration(milliseconds: 300));
                        // Get.offAllNamed(
                        //     RouteName.dashboardScreen(currentCompanyId));
                        // await Future.delayed(Duration(milliseconds: 300));
                        // Get.toNamed(path);

                        Get.back();
                        await Future.delayed(Duration(milliseconds: 300));
                        Get.back();
                        Get.put(TabMainController()).selectedIndex = 0;
                        await Future.delayed(Duration(milliseconds: 300));
                        Get.back();
                        await Future.delayed(Duration(milliseconds: 300));
                        Get.toNamed(path);
                      },
                      child: Card(
                          elevation: 0.5,
                          child: Container(
                              width: double.infinity,
                              margin: EdgeInsets.only(bottom: 3, top: 3),
                              padding: EdgeInsets.symmetric(
                                  vertical: 11, horizontal: 17),
                              child: Row(
                                children: [
                                  icon,
                                  SizedBox(
                                    width: 16,
                                  ),
                                  Text(value.name),
                                ],
                              ))),
                    )))
                .values
                .toList()
                .take(limit),
            teamAsHQ.length > 2
                ? Align(
                    alignment: Alignment.bottomRight,
                    child: OutlinedButton(
                        onPressed: () {
                          isShowAll.toggle();
                        },
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                            color: Colors.transparent,
                          ),
                        ),
                        child: isShowAll.value
                            ? Text('show less')
                            : Text('... show ${teamAsHQ.length - 2} more')),
                  )
                : SizedBox()
          ],
        );
      }),
    );
  }

  String _getTitle(RecentlyViewed item) {
    if (item.moduleName == 'group-chat' ||
        item.moduleName == 'blast' ||
        item.moduleName == 'schedule' ||
        item.moduleName == 'board' ||
        item.moduleName == 'check-ins' ||
        item.moduleName == 'docsAndFile') {
      return '${item.title} - ${item.teamName}';
    } else {
      return item.title;
    }
  }

  String _buildSubtitle(String subtitle) {
    String replaceDoubleSpace = subtitle.replaceAll('  >  ', ' > ');

    return replaceDoubleSpace;
  }

  Widget _buildListRecenlyViewed() {
    return Obx(() => Column(
          children: [
            _searchController.listRecenlyViewed
                    .where((element) => element.companyId == currentCompanyId)
                    .toList()
                    .isEmpty
                ? SizedBox()
                : Padding(
                    padding:
                        const EdgeInsets.only(left: 24.0, bottom: 6, top: 3),
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: Text('Recently Viewed',
                          style:
                              TextStyle(color: Colors.black.withOpacity(0.5))),
                    ),
                  ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Column(
                children: [
                  ..._searchController.listRecenlyViewed
                      .take(5)
                      .where((element) => element.companyId == currentCompanyId)
                      .toList()
                      .asMap()
                      .map((key, value) => MapEntry(
                          key,
                          InkWell(
                            onTap: () async {
                              try {
                                if (value.moduleName == 'group-chat' ||
                                    value.moduleName == 'team-detail' ||
                                    value.moduleName == 'blast' ||
                                    value.moduleName == 'schedule' ||
                                    value.moduleName == 'board' ||
                                    value.moduleName == 'check-ins' ||
                                    value.moduleName == 'docsAndFile') {
                                  // _searchController.insertListRecenlyViewed(
                                  //     RecentlyViewed(
                                  //         moduleName: value.moduleName,
                                  //         companyId: currentCompanyId,
                                  //         path: value.path,
                                  //         teamName: value.teamName,
                                  //         title: value.title,
                                  //         subtitle: value.subtitle,
                                  //         uniqId: value.uniqId));

                                  // Get.reset();
                                  // await Future.delayed(
                                  //     Duration(milliseconds: 300));
                                  // Get.offAllNamed(RouteName.dashboardScreen(
                                  //     currentCompanyId));
                                  // await Future.delayed(
                                  //     Duration(milliseconds: 300));
                                  // Get.toNamed(value.path);
                                  Get.put(TabMainController()).selectedIndex =
                                      0;
                                  Get.back();
                                  // await Future.delayed(
                                  //     Duration(milliseconds: 300));
                                  Get.back();
                                  // await Future.delayed(
                                  //     Duration(milliseconds: 300));
                                  Get.back();
                                  await Future.delayed(
                                      Duration(milliseconds: 300));

                                  await Future.delayed(
                                      Duration(milliseconds: 300));
                                  Get.toNamed(value.path);
                                } else if (value.moduleName == 'inbox') {
                                  // print('mlebu kene');
                                  PrivateChatController _privateChatController =
                                      Get.put(PrivateChatController());
                                  _privateChatController.searchKey = '';
                                  _privateChatController
                                      .textEditingControllerSearch.text = '';
                                  String companyId =
                                      Get.parameters['companyId'] ?? '';
                                  _privateChatController.listenData(companyId);
                                  // print('value.path ${value.path}');
                                  Get.toNamed(value.path);
                                } else {
                                  Get.toNamed(value.path);
                                  // _searchController.insertListRecenlyViewed(
                                  //     RecentlyViewed(
                                  //         moduleName: value.moduleName,
                                  //         companyId: value.companyId,
                                  //         path: value.path,
                                  //         teamName: value.teamName,
                                  //         title: value.title,
                                  //         subtitle: value.subtitle,
                                  //         uniqId: value.uniqId));
                                }
                              } catch (e) {
                                print(e);
                              }
                            },
                            child: Container(
                              margin: EdgeInsets.only(),
                              padding: EdgeInsets.symmetric(
                                  vertical: 5, horizontal: 17),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      _buildIcon(value.moduleName),
                                      SizedBox(
                                        width: 12,
                                      ),
                                      Expanded(
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            // Text(value.subtitle,
                                            //     style: TextStyle(
                                            //         fontWeight:
                                            //             FontWeight.w500)),
                                            // Text(' - '),
                                            Expanded(
                                              child: Text(
                                                // value.title + " " + value.teamName,
                                                _getTitle(value),
                                                style: TextStyle(
                                                    color: Colors.black
                                                        .withOpacity(0.6),
                                                    fontWeight:
                                                        FontWeight.w600),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  // Text(value.path),
                                  value.teamName == ''
                                      ? SizedBox()
                                      : Text(
                                          _buildSubtitle(value.subtitle),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                              color: Colors.grey, fontSize: 10),
                                        )
                                ],
                              ),
                            ),
                          )))
                      .values
                      .toList()
                ],
              ),
            ),
            _searchController.listRecenlyViewed
                    .where((element) => element.companyId == currentCompanyId)
                    .toList()
                    .isEmpty
                ? SizedBox()
                : Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Divider(),
                  ),
          ],
        ));
  }

  Icon _buildIcon(String moduleName) {
    var icon = Icon(Icons.history, color: Colors.black.withOpacity(0.6));

    switch (moduleName) {
      case 'team-detail':
        return Icon(Icons.group_outlined, color: Colors.black.withOpacity(0.6));
      case 'group-chat':
        return Icon(Icons.forum_outlined, color: Colors.black.withOpacity(0.6));
      case 'blast':
        return Icon(Icons.chat_outlined, color: Colors.black.withOpacity(0.6));
      case 'post':
        return Icon(Icons.campaign_outlined,
            color: Colors.black.withOpacity(0.6));
      case 'schedule':
        return Icon(Icons.calendar_today_outlined,
            color: Colors.black.withOpacity(0.6));
      case 'event':
        return Icon(Icons.event, color: Colors.black.withOpacity(0.6));
      case 'occurrence':
        return Icon(Icons.date_range_outlined,
            color: Colors.black.withOpacity(0.6));

      case 'board':
        return Icon(Icons.dashboard_outlined,
            color: Colors.black.withOpacity(0.6));
      case 'card':
        return Icon(Icons.text_snippet_outlined,
            color: Colors.black.withOpacity(0.6));
      case 'check-ins':
        return Icon(Icons.business_center_outlined,
            color: Colors.black.withOpacity(0.6));
      case 'question':
        return Icon(Icons.help_outline, color: Colors.black.withOpacity(0.6));
      case 'docsAndFile':
      case 'folder':
        return Icon(Icons.snippet_folder_outlined,
            color: Colors.black.withOpacity(0.6));
      case 'doc':
        return Icon(Icons.article_outlined,
            color: Colors.black.withOpacity(0.6));
      case 'file':
        return Icon(Icons.attach_file_outlined,
            color: Colors.black.withOpacity(0.6));

      case 'private-chat-detail':
        return Icon(Icons.chat_bubble_outline,
            color: Colors.black.withOpacity(0.6));
      case 'profile':
      case 'other-profile':
        return Icon(Icons.account_circle_outlined,
            color: Colors.black.withOpacity(0.6));

      case 'Cheers':
        return Icon(Icons.celebration_outlined,
            color: Colors.black.withOpacity(0.6));
      case 'comment-detail':
        return Icon(Icons.comment_outlined,
            color: Colors.black.withOpacity(0.6));
      case 'inbox':
        return Icon(MyFlutterApp.icon_chat,
            color: Colors.black.withOpacity(0.6));
      default:
        return icon;
    }
  }

  Row _buildHeaderInput() {
    return Row(
      children: [
        SizedBox(
          width: 16,
        ),
        Expanded(
          child: InkWell(
            onTap: () {
              String companyId = Get.parameters['companyId'] ?? '';
              String teamId = Get.parameters['teamId'] ?? '';
              Get.toNamed(
                  '${RouteName.searchResultScreen(companyId, teamId)}&needAutoFocus=1');
            },
            child: IgnorePointer(
              child: TextField(
                onSubmitted: (String value) {
                  String companyId = Get.parameters['companyId'] ?? '';
                  String teamId = Get.parameters['teamId'] ?? '';
                  Get.toNamed(
                      '${RouteName.searchResultScreen(companyId, teamId)}');
                },
                decoration: InputDecoration(
                  isDense: true,
                  fillColor: Colors.white,
                  filled: true,
                  contentPadding: EdgeInsets.fromLTRB(15, 5.w, 5.w, 15),
                  // contentPadding: EdgeInsets.only(left: 15),
                  // hintText: "Search people / document / folder / blast... etc",
                  hintText: 'jumping to another team or menu',
                  hintStyle:
                      TextStyle(color: Color(0xffB5B5B5), fontSize: 12.w),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: new BorderRadius.circular(10.w),
                    borderSide: BorderSide(color: Colors.grey.withOpacity(0.2)),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(10.w),
                    ),
                  ),
                  prefixIconConstraints: BoxConstraints(
                      // maxHeight: 90,
                      maxHeight: 20,
                      minWidth: 40),
                  prefixIcon: Icon(
                    Icons.search,
                    color: Color(0xffFDC532),
                  ),
                ),
              ),
            ),
          ),
        ),
        // SizedBox(
        //   width: 10,
        // ),
        // InkWell(
        //     onTap: onPressFilter,
        //     child: Icon(
        //       Icons.filter_alt_outlined,
        //       color: Color(0xffFDC532),
        //     )),
        SizedBox(
          width: 16,
        ),
      ],
    );
  }
}

class ButtonShowAllRelatedItems extends StatelessWidget {
  const ButtonShowAllRelatedItems(
      {Key? key, required this.onPress, required this.title})
      : super(key: key);
  final Function onPress;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: InkWell(
        splashColor: Colors.white.withOpacity(0.1),
        highlightColor: Colors.grey.withOpacity(0.1),
        onTap: () => onPress(),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 50, vertical: 3),
          child: Text(
            'Show all related $title',
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xffFDC532)),
          ),
        ),
      ),
    );
  }
}
