import 'package:cicle_mobile_f3/controllers/company_controller.dart';
import 'package:cicle_mobile_f3/controllers/menu_controller.dart';

import 'package:cicle_mobile_f3/controllers/team_detail_controller.dart';
import 'package:cicle_mobile_f3/models/member_model.dart';
import 'package:cicle_mobile_f3/models/message_item_model.dart';
import 'package:cicle_mobile_f3/screens/core/overview/schedule_full_fill.dart';

import 'package:cicle_mobile_f3/utils/helpers.dart';
import 'package:cicle_mobile_f3/widgets/animation_fade_and_slide.dart';
import 'package:cicle_mobile_f3/widgets/avatar_custom.dart';

import 'package:cicle_mobile_f3/widgets/error_something_wrong.dart';
import 'package:cicle_mobile_f3/widgets/horizontal_list_avatar_with_more.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'package:supercharged/supercharged.dart';

import '../../team_detail.dart';
import 'blast_full_fill.dart';
import 'board_full_fill.dart';
import 'check_in_full_fill.dart';
import 'doc_file_full_fill.dart';
import 'group_chat_full_fill.dart';
import 'menu_item_overview.dart';

class OverviewScreen extends StatelessWidget {
  OverviewScreen({Key? key}) : super(key: key);

  CompanyController _companyController = Get.find();

  TeamDetailController _teamDetailController = Get.find();

  MenuController _menuController = Get.find();
  String? teamId = Get.parameters['teamId'];
  String groupChatId = '66';

  RefreshController refreshController =
      RefreshController(initialRefresh: false);

  void onRefresh() async {
    await _teamDetailController.getTeam();
    refreshController.refreshCompleted();
  }

  onPressAdd() {
    Get.dialog(
        AnimationFadeAndSlide(
            child: DialogAddSubscriber(
              title: _teamDetailController.teamName,
              listAllMembers: _companyController.companyMembers,
              listSelectedMembers: _teamDetailController.teamMembers,
              onCLose: (List<MemberModel> listSelected) {
                _teamDetailController.addMembers(listSelected);
                Get.back();
              },
            ),
            duration: 50.milliseconds,
            delay: 50.milliseconds),
        barrierDismissible: false,
        name: 'dialog-team-add-subscriber');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Obx(() => Text(
              _teamDetailController.teamName,
              style: TextStyle(fontSize: 16),
            )),
        elevation: 0.0,
        actions: [
          SizedBox(
            width: 10,
          ),
          Obx(() => _teamDetailController.isLoading &&
                  _teamDetailController.errorMessage == ''
              ? SizedBox()
              : ActionsAppBarTeamDetail())
        ],
      ),
      body: Container(
          child: Column(
        children: [
          Container(
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
                members: _teamDetailController.teamMembers.length == 0
                    ? []
                    : _teamDetailController.teamMembers,
              );
            }),
          ),
          Container(
            height: 1,
            width: double.infinity,
            color: Color(0xffFAFAFA),
          ),
          Expanded(
            child: Obx(() {
              if (_teamDetailController.isLoading) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }
              if (_teamDetailController.errorMessage != '' &&
                  !_teamDetailController.isLoading) {
                return ErrorSomethingWrong(
                  refresh: () async {
                    _teamDetailController.init();
                  },
                  message: _teamDetailController.errorMessage,
                );
              }
              return _buildHasData();
            }),
          ),
        ],
      )),
    );
  }

  Obx _buildHasData() {
    return Obx(() => GestureDetector(
          onTap: () {
            _teamDetailController.fullFillOverview =
                !_teamDetailController.fullFillOverview;
          },
          child: SmartRefresher(
            physics: BouncingScrollPhysics(),
            header: WaterDropMaterialHeader(),
            controller: refreshController,
            onRefresh: onRefresh,
            child: GridView.count(
              primary: false,
              padding: const EdgeInsets.all(20),
              crossAxisSpacing: 10,
              mainAxisSpacing: 4,
              crossAxisCount: 2,
              childAspectRatio: 156 / 207,
              children: <Widget>[
                ..._menuController.filterListMenu
                    .asMap()
                    .map((key, value) {
                      Widget child = SizedBox();
                      switch (value.title) {
                        case "Group Chat":
                          child = _buildGroupChat();
                          break;

                        case "Blast":
                          child = _buildBlast();
                          break;

                        case "Schedule":
                          child = _buildSchedule();
                          break;

                        case "Board":
                          child = _buildBoard();
                          break;

                        case "Check-in":
                          child = _buildCheckIn();
                          break;

                        case "Docs & Files":
                          child = _buildDocsAndFile();
                          break;
                        default:
                          child = Container();
                      }
                      return MapEntry(key, child);
                    })
                    .values
                    .toList(),
              ],
            ),
          ),
        ));
  }

  GestureDetector _buildDocsAndFile() {
    return GestureDetector(
      onTap: () {
        _teamDetailController.selectedMenuIndex = 3;
      },
      child: Obx(() => MenuItemOverview(
            label: 'Docs & Files',
            child: Center(
              child: !_teamDetailController.isLoading &&
                      _teamDetailController.listOverviewDocFile.length > 0
                  ? DocFileFullFill(
                      list: _teamDetailController.listOverviewDocFile)
                  : Container(
                      height: 90,
                      width: 90,
                      child: Image.asset('assets/images/doc_and_file.png'),
                    ),
            ),
          )),
    );
  }

  GestureDetector _buildCheckIn() {
    return GestureDetector(
      onTap: () {
        _teamDetailController.selectedMenuIndex = 6;
      },
      child: Obx(() => MenuItemOverview(
            label: 'Check-Ins',
            child: Center(
              child: !_teamDetailController.isLoading &&
                      _teamDetailController.listOverviewCheckIns.length > 0
                  ? CheckInFullFill(
                      list: _teamDetailController.listOverviewCheckIns,
                    )
                  : Container(
                      height: 110,
                      width: 110,
                      child: Image.asset(
                        'assets/images/check_in.png',
                        fit: BoxFit.cover,
                      ),
                    ),
            ),
          )),
    );
  }

  GestureDetector _buildBoard() {
    return GestureDetector(
      onTap: () {
        _teamDetailController.selectedMenuIndex = 2;
      },
      child: Obx(() => MenuItemOverview(
            label: 'Board',
            child: Center(
              child: !_teamDetailController.isLoading &&
                      _teamDetailController.listOverviewBoards.length > 0
                  ? BoardFullFill(
                      list: _teamDetailController.listOverviewBoards,
                      boardList: _teamDetailController.boardList)
                  : Container(
                      height: 80,
                      width: 80,
                      child: Image.asset('assets/images/board.png'),
                    ),
            ),
          )),
    );
  }

  GestureDetector _buildSchedule() {
    return GestureDetector(
      onTap: () {
        _teamDetailController.selectedMenuIndex = 5;
      },
      child: Obx(() => MenuItemOverview(
            label: 'Schedule',
            child: Center(
              child: !_teamDetailController.isLoading &&
                      _teamDetailController.listMapEvents.length > 0
                  ? ScheduleFullFill(list: _teamDetailController.listMapEvents)
                  : Container(
                      height: 90,
                      width: 90,
                      child: Image.asset('assets/images/schedule.png'),
                    ),
            ),
          )),
    );
  }

  GestureDetector _buildBlast() {
    return GestureDetector(
      onTap: () {
        _teamDetailController.selectedMenuIndex = 1;
      },
      child: Obx(() => MenuItemOverview(
            label: 'Blast',
            child: Center(
              child: !_teamDetailController.isLoading &&
                      _teamDetailController.listOverviewBlast.length > 0
                  ? BlastFullFill(
                      list: _teamDetailController.listOverviewBlast,
                    )
                  : Container(
                      height: 110,
                      width: 110,
                      child: Image.asset('assets/images/blast.png'),
                    ),
            ),
          )),
    );
  }

  GestureDetector _buildGroupChat() {
    return GestureDetector(
      onTap: () {
        _teamDetailController.selectedMenuIndex = 4;
      },
      child: Obx(() {
        List<MessageItemModel> list =
            _teamDetailController.listOverviewGroupChat;
        list.sort((a, b) =>
            DateTime.parse(a.createdAt).compareTo(DateTime.parse(b.createdAt)));
        return MenuItemOverview(
          label: 'Group Chat',
          child: Center(
            child: !_teamDetailController.isLoading && list.length > 0
                ? IgnorePointer(child: GroupChatFullFill(list: list))
                : Container(
                    height: 100,
                    width: 100,
                    child: Image.asset('assets/images/group_chat.png'),
                  ),
          ),
        );
      }),
    );
  }
}

class DialogAddSubscriber extends StatefulWidget {
  const DialogAddSubscriber({
    Key? key,
    this.listAllMembers = const [],
    this.listSelectedMembers = const [],
    this.onCLose,
    required this.title,
  }) : super(key: key);

  final List<MemberModel> listAllMembers;
  final List<MemberModel> listSelectedMembers;
  final Function? onCLose;
  final String? title;

  @override
  _DialogAddSubscriberState createState() => _DialogAddSubscriberState();
}

class _DialogAddSubscriberState extends State<DialogAddSubscriber> {
  List<MemberModel> _list = [];
  List<MemberModel> _selectedList = [];
  String _keyWords = '';

  @override
  void initState() {
    super.initState();
    setState(() {
      _list = [...widget.listAllMembers];
      _selectedList = [...widget.listSelectedMembers];
    });
  }

  @override
  Widget build(BuildContext context) {
    String title = widget.title ?? "Cilsy’s HQ Subscribers";
    String subtitle = 'Add / remove member';
    return WillPopScope(
      onWillPop: () async {
        widget.onCLose!(_selectedList);
        print('on close dialog add members');
        return Future.value(true);
      },
      child: Container(
        child: Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 16.w),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30.w),
                  color: Colors.white),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildCloseButton(),
                  Text(
                    title,
                    style:
                        TextStyle(fontSize: 14.w, fontWeight: FontWeight.w600),
                  ),
                  SizedBox(
                    height: 15.w,
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                        fontSize: 9.w,
                        fontWeight: FontWeight.normal,
                        color: Color(0xff7A7A7A)),
                  ),
                  SizedBox(
                    height: 14.w,
                  ),
                  _buildSearchInput(),
                  Container(
                    padding: EdgeInsets.only(left: 25.w, right: 20.w),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Select all',
                          style: TextStyle(
                              fontSize: 12.w, fontWeight: FontWeight.w600),
                        ),
                        Checkbox(
                            value: _list.length == _selectedList.length,
                            fillColor: MaterialStateProperty.all<Color>(
                                Color(0xff708FC7)),
                            onChanged: (bool? value) {
                              if (value!) {
                                setState(() {
                                  _selectedList = [..._list];
                                });
                              } else {
                                setState(() {
                                  _selectedList = [];
                                });
                              }
                            })
                      ],
                    ),
                  ),
                  _buildListMembers(context),
                  SizedBox(
                    height: 26.w,
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Container _buildListMembers(BuildContext context) {
    _list.sort((a, b) => a.fullName.compareTo(b.fullName));
    List<MemberModel> _listFilterAllMember = _list
        .where((element) =>
            element.fullName.toLowerCase().contains(_keyWords.toLowerCase()))
        .toList();
    if (_listFilterAllMember.length == 0) {
      return Container(
        child: Column(
          children: [
            SizedBox(
              height: 20,
            ),
            Text(
              'No Members',
              style: TextStyle(
                  fontSize: 11.w, color: Colors.grey.withOpacity(0.5)),
            ),
            SizedBox(
              height: 20,
            ),
          ],
        ),
      );
    }
    return Container(
      margin: EdgeInsets.only(
        left: 30.w,
        right: 20.w,
      ),
      height: 500.w,
      child: SingleChildScrollView(
        child: Column(
          children: [
            ...List.generate(
              _listFilterAllMember.length,
              (index) => _buildItem(
                index,
              ),
            ),
            Container(
              margin: MediaQuery.of(context).viewInsets,
            )
          ],
        ),
      ),
    );
  }

  Container _buildItem(int index) {
    List<MemberModel> _listFilterAllMember = _list
        .where((element) =>
            element.fullName.toLowerCase().contains(_keyWords.toLowerCase()))
        .toList();
    MemberModel _memberModel = _listFilterAllMember[index];

    int isMemberIncludeOnMembers = _selectedList
        .where((element) => element.sId == _memberModel.sId)
        .length;
    return Container(
      margin: EdgeInsets.only(bottom: 1),
      child: Row(
        children: [
          AvatarCustom(
            child: Image.network(
              getPhotoUrl(url: _memberModel.photoUrl),
              height: 25.w,
              width: 25.w,
              fit: BoxFit.cover,
            ),
            height: 25.w,
          ),
          SizedBox(
            width: 12.w,
          ),
          Expanded(
              child: Text(
            _memberModel.fullName,
            style: TextStyle(fontSize: 12.w),
          )),
          Checkbox(
              value: isMemberIncludeOnMembers > 0,
              fillColor: MaterialStateProperty.all<Color>(Color(0xff708FC7)),
              onChanged: (bool? value) {
                int selectedIndex = _selectedList
                    .indexWhere((element) => element.sId == _memberModel.sId);

                if (value!) {
                  setState(() {
                    _selectedList.add(_memberModel);
                  });
                } else {
                  setState(() {
                    _selectedList.removeAt(selectedIndex);
                  });
                }
              })
        ],
      ),
    );
  }

  Container _buildSearchInput() {
    return Container(
        padding: EdgeInsets.symmetric(horizontal: 25),
        child: TextField(
          style: TextStyle(fontSize: 11.w),
          onChanged: (value) {
            setState(() {
              _keyWords = value;
            });
          },
          decoration: InputDecoration(
              isDense: true,
              contentPadding: EdgeInsets.fromLTRB(15, 10, 10, 10),
              hintText: "Search Name",
              hintStyle: TextStyle(color: Color(0xffB5B5B5), fontSize: 11),
              enabledBorder: OutlineInputBorder(
                borderRadius: new BorderRadius.circular(20.0),
                borderSide: BorderSide(color: Colors.grey.withOpacity(0.2)),
              ),
              border: OutlineInputBorder(
                borderRadius: const BorderRadius.all(
                  const Radius.circular(20.0),
                ),
              ),
              prefixIconConstraints: BoxConstraints(minWidth: 40),
              prefixIcon: Icon(Icons.search)),
        ));
  }

  Align _buildCloseButton() {
    return Align(
      alignment: Alignment.topRight,
      child: Container(
        height: 40.w,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: IconButton(
              onPressed: () {
                widget.onCLose!(_selectedList);
              },
              icon: Icon(
                Icons.close,
                color: Color(0xff7A7A7A),
              )),
        ),
      ),
    );
  }
}
