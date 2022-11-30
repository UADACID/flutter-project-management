import 'package:cicle_mobile_f3/controllers/search_controller.dart';
import 'package:cicle_mobile_f3/controllers/tab_main_controller.dart';
import 'package:cicle_mobile_f3/models/companies_model.dart';
import 'package:cicle_mobile_f3/utils/constant.dart';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:substring_highlight/substring_highlight.dart';

import 'searc_filter.dart';
import 'search_blast.dart';
import 'search_comments.dart';
import 'search_docs.dart';
import 'search_hq.dart';
import 'search_kanban.dart';
import 'search_members.dart';
import 'search_projects.dart';
import 'search_teams.dart';

class SearchResultScreen extends StatelessWidget {
  SearchResultScreen({Key? key}) : super(key: key);

  SearchController _searchController = Get.find();

  onPressFilter() {
    Get.bottomSheet(SearchFilter(), isScrollControlled: true);
  }

  List<Teams> _getListByCategory(String categoryTitle) {
    List<Teams> list = _searchController.teams.where((element) {
      String title = categoryTitle == 'Teams'
          ? element.name
          : '$categoryTitle: ${element.name}';

      return _searchController.keyWords.every(
          (element) => title.toLowerCase().contains(element.toLowerCase()));
    }).toList();
    return list;
  }

  @override
  Widget build(BuildContext context) {
    String needAutoFocus = Get.parameters['needAutoFocus'] ?? '0';
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Container(
        color: Colors.white,
        child: SafeArea(
          child: Scaffold(
            backgroundColor: Colors.white,
            body: Column(
              children: [
                Container(
                  color: Colors.white,
                  padding: EdgeInsets.only(bottom: 10),
                  child: _buildSearchInput(needAutoFocus),
                ),
                Container(
                  width: double.infinity,
                  height: 1,
                  color: Color(0xffFAFAFA),
                ),
                SizedBox(
                  height: 2,
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Container(
                      padding: EdgeInsets.only(top: 16, left: 6, right: 6),
                      // color: Colors.white,
                      child: Obx(() {
                        List<Teams> _listTeam = _getListByCategory('Teams');

                        List<Teams> _listBoard =
                            _getListByCategory('Kanban Board');

                        List<Teams> _listBlast = _getListByCategory('Blast');

                        List<Teams> _listSchedule =
                            _getListByCategory('Schedule');

                        List<Teams> _listCheckIn =
                            _getListByCategory('Check In');

                        List<Teams> _listGroupChat =
                            _getListByCategory('Group Chat');

                        List<Teams> _listDocsAndFiles =
                            _getListByCategory('Docs & Files');

                        List<Teams> _allCombineList = [
                          ..._listTeam,
                          ..._listBoard,
                          ..._listBlast,
                          ..._listSchedule,
                          ..._listCheckIn,
                          ..._listGroupChat,
                          ..._listDocsAndFiles,
                        ];

                        if (_allCombineList.isEmpty) {
                          return Text('No result found',
                              style: TextStyle(fontWeight: FontWeight.bold));
                        }

                        return Column(
                          children: [
                            _searchController.keyWords.isNotEmpty
                                ? Padding(
                                    padding: const EdgeInsets.only(bottom: 8.0),
                                    child: Text(
                                      '${_allCombineList.length} results found',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                  )
                                : SizedBox(),
                            _buildList(
                                'Teams',
                                _searchController.showAllSearchTeam,
                                'team-detail'),
                            _buildList('Kanban Board',
                                _searchController.showAllSearchBoard, 'board'),
                            _buildList('Blast',
                                _searchController.showAllSearchBlast, 'blast'),
                            _buildList(
                                'Schedule',
                                _searchController.showAllSearchSchedule,
                                'schedule'),
                            _buildList(
                                'Check In',
                                _searchController.showAllSearchCheckIn,
                                'check-ins'),
                            _buildList(
                                'Group Chat',
                                _searchController.showAllSearchGroupChat,
                                'group-chat'),
                            _buildList(
                                'Docs & Files',
                                _searchController.showAllSearchDocsAndFiles,
                                'docsAndFile')
                          ],
                        );
                      }),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Icon _buildIcon(String moduleName, Teams team) {
    var icon = Icon(Icons.history, color: Colors.black.withOpacity(0.6));

    switch (moduleName) {
      case 'Teams':
        if (team.type == 'hq') {
          return Icon(Icons.maps_home_work_outlined,
              color: Colors.black.withOpacity(0.6));
        } else if (team.type == 'team') {
          return Icon(Icons.groups_outlined,
              color: Colors.black.withOpacity(0.6));
        }
        return Icon(Icons.assignment_outlined,
            color: Colors.black.withOpacity(0.6));
      case 'Group Chat':
        return Icon(Icons.forum_outlined, color: Colors.black.withOpacity(0.6));
      case 'Blast':
        return Icon(Icons.chat_outlined, color: Colors.black.withOpacity(0.6));

      case 'Schedule':
        return Icon(Icons.calendar_today_outlined,
            color: Colors.black.withOpacity(0.6));

      case 'Kanban Board':
        return Icon(Icons.dashboard_outlined,
            color: Colors.black.withOpacity(0.6));

      case 'Check In':
        return Icon(Icons.business_center_outlined,
            color: Colors.black.withOpacity(0.6));

      case 'Docs & Files':
        return Icon(Icons.snippet_folder_outlined,
            color: Colors.black.withOpacity(0.6));

      default:
        return icon;
    }
  }

  Obx _buildList(String categoryTitle, RxBool isShowAll, String moduleName) {
    return Obx(() {
      List<Teams> _list = _searchController.teams.where((element) {
        String title = categoryTitle == 'Teams'
            ? element.name
            : '$categoryTitle: ${element.name}';

        return _searchController.keyWords.every(
            (element) => title.toLowerCase().contains(element.toLowerCase()));
      }).toList();
      _list.sort((a, b) {
        String title =
            categoryTitle == 'Teams' ? a.name : '$categoryTitle: ${a.name}';

        String titleB =
            categoryTitle == 'Teams' ? b.name : '$categoryTitle: ${b.name}';

        String _titleHighLight = '';
        String _titleHighLightB = '';

        _searchController.keyWords.forEach((element) {
          var a = title.toLowerCase().contains(element.toLowerCase());
          if (a) {
            _titleHighLight += element;
          }

          var b = titleB.toLowerCase().contains(element.toLowerCase());

          if (b) {
            _titleHighLightB += element;
          }
        });

        return _titleHighLightB.length.compareTo(_titleHighLight.length);
      });
      int limit = isShowAll.value ? _list.length : 3;

      if (_list.isEmpty) {
        return SizedBox();
      }
      return Container(
        margin: EdgeInsets.only(bottom: 10),
        child: Column(
          children: [
            Align(
                alignment: Alignment.topLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: 16.0),
                  child: Text(categoryTitle,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black.withOpacity(1))),
                )),
            ..._list
                .asMap()
                .map((key, value) =>
                    MapEntry(key, _buildItem(categoryTitle, value, moduleName)))
                .values
                .toList()
                .take(limit),
            _list.length > 3
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
                            : Text('... show ${_list.length - 3} more')),
                  )
                : SizedBox()
          ],
        ),
      );
    });
  }

  String _getUniqId(Teams item, String moduleName) {
    switch (moduleName) {
      case 'blast':
        return item.sId + item.blast;

      case 'schedule':
        return item.sId + item.schedule;

      case 'board':
        return item.sId + item.boards[0];

      case 'check-ins':
        return item.sId + item.checkIn;

      case 'docsAndFile':
        return item.sId + item.bucket;

      case 'group-chat':
        return item.sId + item.groupChat;

      default:
        return item.sId;
    }
  }

  _redirect(Teams item, String moduleName) async {
    String companyId = Get.parameters['companyId'] ?? '';

    String path = '';

    switch (moduleName) {
      case 'blast':
        path =
            '${RouteName.teamDetailScreen(companyId)}/${item.sId}?destinationIndex=1';
        break;

      case 'schedule':
        path =
            '${RouteName.teamDetailScreen(companyId)}/${item.sId}?destinationIndex=5';
        break;

      case 'board':
        path =
            '${RouteName.teamDetailScreen(companyId)}/${item.sId}?destinationIndex=2';
        break;

      case 'check-ins':
        path =
            '${RouteName.teamDetailScreen(companyId)}/${item.sId}?destinationIndex=6';
        break;

      case 'docsAndFile':
        path =
            '${RouteName.teamDetailScreen(companyId)}/${item.sId}?destinationIndex=3';
        break;

      case 'group-chat':
        path =
            '${RouteName.teamDetailScreen(companyId)}/${item.sId}?destinationIndex=4';
        break;

      default:
        path =
            '${RouteName.teamDetailScreen(companyId)}/${item.sId}?destinationIndex=0';
        break;
    }

    print(path);

    // Get.reset();
    // await Future.delayed(Duration(milliseconds: 300));
    // Get.offAllNamed(RouteName.dashboardScreen(companyId));
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
  }

  InkWell _buildItem(String categoryTitle, Teams item, String moduleName) {
    String title =
        categoryTitle == 'Teams' ? item.name : '$categoryTitle: ${item.name}';
    String subtitle = categoryTitle == 'Teams'
        ? 'Home  >  ${item.name}'
        : 'Home  >  ${item.name}  >  $categoryTitle';

    return InkWell(
      onTap: () async {
        String companyId = Get.parameters['companyId'] ?? '';
        String uniqId = _getUniqId(item, moduleName);
        if (moduleName == 'team-detail') {
          _searchController.insertListRecenlyViewed(RecentlyViewed(
              moduleName: moduleName,
              companyId: companyId,
              path: "value.path",
              teamName: item.name,
              title: item.name,
              subtitle: subtitle,
              uniqId: uniqId));
        } else {
          _searchController.insertListRecenlyViewed(RecentlyViewed(
              moduleName: moduleName,
              companyId: companyId,
              path: "value.path",
              teamName: item.name,
              title: item.name,
              subtitle: subtitle,
              uniqId: uniqId));
        }

        _redirect(item, moduleName);
      },
      child: Container(
        margin: EdgeInsets.only(),
        padding: EdgeInsets.symmetric(vertical: 11, horizontal: 17),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _buildIcon(categoryTitle, item),
                SizedBox(
                  width: 12,
                ),
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: SubstringHighlight(
                          caseSensitive: false,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          terms: [..._searchController.keyWords],
                          text: title,
                          textAlign: TextAlign.left,
                          textStyle: TextStyle(
                              color: Colors.black.withOpacity(0.6),
                              fontWeight: FontWeight.w400),
                          textStyleHighlight: TextStyle(
                              color: Color(0xffFFBF42),
                              fontWeight: FontWeight.w400),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Text(
              subtitle,
              style: TextStyle(color: Colors.grey, fontSize: 11),
            )
          ],
        ),
      ),
    );
  }

  Row _buildSearchInput(String needAutoFocus) {
    return Row(
      children: [
        IconButton(
            onPressed: () {
              Get.back();
            },
            icon: Icon(Icons.arrow_back)),
        Expanded(
            child: Obx(() => TextField(
                  // onSubmitted: _searchController.onSubmitSearch,
                  onChanged: _searchController.onSubmitSearch,
                  controller: _searchController.searchTextInputController,
                  autofocus: needAutoFocus == '1' ? true : false,
                  decoration: InputDecoration(
                    isDense: true,
                    fillColor: Colors.white,
                    filled: true,
                    contentPadding: EdgeInsets.fromLTRB(15, 5.w, 5.w, 15),
                    hintText: 'jumping to another team or menu',
                    hintStyle:
                        TextStyle(color: Color(0xffB5B5B5), fontSize: 12.w),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: new BorderRadius.circular(10.w),
                      borderSide:
                          BorderSide(color: Colors.grey.withOpacity(0.2)),
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
                    suffixIconConstraints:
                        BoxConstraints(maxHeight: 20, minWidth: 40),
                    suffixIcon: _searchController.keyWords.length > 0
                        ? InkWell(
                            onTap: () {
                              _searchController.keyWords = [];
                              _searchController.searchTextInputController.text =
                                  "";
                            },
                            child: Icon(
                              Icons.close,
                              color: Color(0xffFDC532),
                            ),
                          )
                        : null,
                  ),
                ))),
        SizedBox(
          width: 23,
        ),
      ],
    );
  }

  Container _buildListFilterSelected() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 23),
            child: Obx(() => Row(
                  children: [
                    _searchController.filterCounter == 0
                        ? SizedBox()
                        : Text(
                            '${_searchController.filterCounter.toString()}  ',
                            style: TextStyle(
                                fontSize: 12, fontWeight: FontWeight.bold)),
                    Text('Filter',
                        style: TextStyle(
                            fontSize: 12, fontWeight: FontWeight.bold)),
                  ],
                )),
          ),
          Container(
            width: 1,
            height: 30,
            color: Color(0xffD6D6D6),
          ),
          Expanded(
              child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                ..._searchController.listSelectedHq
                    .asMap()
                    .map((key, value) => MapEntry(
                        key,
                        InkWell(
                          onTap: () {
                            _searchController.removeFilterHq(value);
                          },
                          child: Container(
                              margin: EdgeInsets.only(left: 7),
                              padding: EdgeInsets.symmetric(
                                  horizontal: 15, vertical: 7),
                              decoration: BoxDecoration(
                                  border: Border.all(color: Color(0xffFFD974)),
                                  borderRadius: BorderRadius.circular(10)),
                              child: Text(
                                value,
                                style: TextStyle(
                                    color: Color(0xffFDC532),
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold),
                              )),
                        )))
                    .values
                    .toList(),
                ..._searchController.listSelectedTeam
                    .asMap()
                    .map((key, value) => MapEntry(
                        key,
                        InkWell(
                          onTap: () {
                            _searchController.removeFilterTeam(value);
                          },
                          child: Container(
                              margin: EdgeInsets.only(left: 7),
                              padding: EdgeInsets.symmetric(
                                  horizontal: 15, vertical: 7),
                              decoration: BoxDecoration(
                                  border: Border.all(color: Color(0xffFFD974)),
                                  borderRadius: BorderRadius.circular(10)),
                              child: Text(
                                value,
                                style: TextStyle(
                                    color: Color(0xffFDC532),
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold),
                              )),
                        )))
                    .values
                    .toList(),
                ..._searchController.listSelectedProject
                    .asMap()
                    .map((key, value) => MapEntry(
                        key,
                        InkWell(
                          onTap: () {
                            _searchController.removeFilterProject(value);
                          },
                          child: Container(
                              margin: EdgeInsets.only(left: 7),
                              padding: EdgeInsets.symmetric(
                                  horizontal: 15, vertical: 7),
                              decoration: BoxDecoration(
                                  border: Border.all(color: Color(0xffFFD974)),
                                  borderRadius: BorderRadius.circular(10)),
                              child: Text(
                                value,
                                style: TextStyle(
                                    color: Color(0xffFDC532),
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold),
                              )),
                        )))
                    .values
                    .toList()
              ],
            ),
          ))
        ],
      ),
    );
  }
}
