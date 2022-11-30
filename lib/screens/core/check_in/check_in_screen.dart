import 'package:cicle_mobile_f3/controllers/check_in_controller.dart';
import 'package:cicle_mobile_f3/controllers/search_controller.dart';
import 'package:cicle_mobile_f3/controllers/team_detail_controller.dart';
import 'package:cicle_mobile_f3/models/check_in_model.dart';
import 'package:cicle_mobile_f3/models/member_model.dart';

import 'package:cicle_mobile_f3/utils/constant.dart';

import 'package:cicle_mobile_f3/widgets/horizontal_list_member.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../team_detail.dart';

class CheckInScreen extends StatelessWidget {
  TeamDetailController _teamDetailController = Get.find();

  String? teamId = Get.parameters['teamId'];
  String companyId = Get.parameters['companyId'] ?? '';

  RefreshController refreshController =
      RefreshController(initialRefresh: false);

  void onRefresh(CheckInController controller) async {
    await controller.getQuestions();
    refreshController.refreshCompleted();
  }

  void onLoadMore(CheckInController controller) async {
    print('load more');
    await controller.getMoreQuestions();
    print('load more done');

    refreshController.loadComplete();
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
          ActionsAppBarTeamDetail(
            showSetting: false,
          )
        ],
      ),
      body: GetX<CheckInController>(
          init: CheckInController(),
          initState: (state) {
            state.controller!.init();
          },
          builder: (_checkInController) {
            if (_checkInController.isLoading &&
                _checkInController.questions.length == 0) {
              return _buildLoading();
            }
            if (!_checkInController.isLoading &&
                _checkInController.questions.length == 0) {
              return _buildEmpty(_checkInController);
            }
            return _buildHasData(_checkInController);
          }),
      floatingActionButton: FloatingActionButton(
        heroTag: 'check-in',
        onPressed: () {
          String checkInId = Get.put(TeamDetailController()).checkInId;
          Get.toNamed(
              RouteName.checkInForm(companyId, teamId!, checkInId, 'create'));
        },
        child: Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }

  Center _buildLoading() {
    return Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildHasData(CheckInController _checkInController) {
    return SmartRefresher(
      enablePullUp: true,
      header: WaterDropMaterialHeader(),
      controller: refreshController,
      onRefresh: () => onRefresh(_checkInController),
      onLoading: () => onLoadMore(_checkInController),
      footer: CustomFooter(
        builder: (BuildContext context, LoadStatus? mode) {
          Widget body;
          if (mode == LoadStatus.idle) {
            body = SizedBox();
          } else if (mode == LoadStatus.loading) {
            body = CircularProgressIndicator();
          } else if (mode == LoadStatus.failed) {
            body = Text("Load Failed!Click retry!");
          } else if (mode == LoadStatus.canLoading) {
            body = Text("release to load more");
          } else {
            body = Text("No more Data");
          }
          return Container(
            height: 55.0,
            child: Center(child: body),
          );
        },
      ),
      child: ListView.builder(
          padding: EdgeInsets.only(top: 4),
          itemCount: _checkInController.questions.length,
          itemBuilder: (ctx, index) {
            CheckInModel item = _checkInController.questions[index];
            return CheckInItem(
              item: item,
            );
          }),
    );
  }

  SmartRefresher _buildEmpty(CheckInController _checkInController) {
    var column = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: 89,
        ),
        Image.asset(
          'assets/images/check_in.png',
          height: 145.w,
          width: 247.w,
          fit: BoxFit.contain,
        ),
        Container(
            margin: EdgeInsets.symmetric(horizontal: 34, vertical: 20),
            padding: EdgeInsets.symmetric(horizontal: 50.w),
            width: 306.w,
            child: Column(
              children: [
                Text(
                  'Remove unnecessary meetings',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 11.sp, color: Color(0xffB5B5B5)),
                ),
                Text(
                  'by sending routine questions for your team',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 11.sp, color: Color(0xffB5B5B5)),
                ),
              ],
            ))
      ],
    );
    return SmartRefresher(
      header: WaterDropMaterialHeader(),
      controller: refreshController,
      onRefresh: () => onRefresh(_checkInController),
      child: ListView.builder(
          padding: EdgeInsets.only(top: 4),
          itemCount: 1,
          itemBuilder: (ctx, index) {
            return column;
          }),
    );
  }
}

class CheckInItem extends StatelessWidget {
  CheckInItem({
    Key? key,
    required this.item,
    this.customFooter,
    this.customPaddingContainer = const EdgeInsets.symmetric(horizontal: 17.0),
    this.customCardMargin = const EdgeInsets.all(4),
  }) : super(key: key);

  String? teamId = Get.parameters['teamId'];
  String companyId = Get.parameters['companyId'] ?? '';
  final CheckInModel item;
  final Widget? customFooter;
  final EdgeInsets customPaddingContainer;
  final EdgeInsets customCardMargin;

  @override
  Widget build(BuildContext context) {
    List<MemberModel> members = item.subscribers;
    String days = '';
    for (var i = 0; i < item.schedule.days.length; i++) {
      days += ' ${item.schedule.days[i]},';
    }

    int utcHour = item.schedule.hour;
    int utcMinute = item.schedule.minute;

    DateTime today = DateTime.now().toUtc();
    DateTime baseDate =
        DateTime.utc(today.year, today.month, today.day, utcHour, utcMinute, 0)
            .toLocal();

    var minute = baseDate.minute;
    var hour = baseDate.hour;
    String amPm = hour >= 12 ? 'PM' : 'AM';
    hour = ((hour + 11) % 12 + 1);

    var prefixHour = hour >= 10 ? "" : "0";
    var prefixMinute = minute >= 10 ? "" : "0";

    var time = prefixHour +
        hour.toString() +
        ':' +
        prefixMinute +
        minute.toString() +
        ' ' +
        amPm;

    return Padding(
      padding: customPaddingContainer,
      child: InkWell(
        onTap: () {
          print('$teamId ${item.sId}');
          String path =
              RouteName.checkInDetailScreen(companyId, teamId!, item.sId);
          Get.put(SearchController()).insertListRecenlyViewed(RecentlyViewed(
              moduleName: 'question',
              companyId: companyId,
              path: path,
              teamName: Get.put(TeamDetailController()).teamName,
              title: item.title,
              subtitle:
                  'Home  >  ${Get.put(TeamDetailController()).teamName}  >  Check-in  >  ${item.title}',
              uniqId: item.sId));
          Get.toNamed(
              RouteName.checkInDetailScreen(companyId, teamId!, item.sId));
        },
        onLongPress: () {},
        child: Card(
          margin: customCardMargin,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(0, 8, 0, 5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 11),
                  child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 2.0),
                      decoration: BoxDecoration(
                          color: Color(0xffDEEAFF),
                          borderRadius: BorderRadius.circular(5)),
                      child: Padding(
                        padding: const EdgeInsets.all(6.0),
                        child: Text(
                            'Asking ${members.length} people every $days at $time',
                            style: TextStyle(
                                fontSize: 10, fontWeight: FontWeight.normal)),
                      )),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 11),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5.0),
                    child: Row(
                      children: [
                        item.isPublic
                            ? SizedBox()
                            : Padding(
                                padding: const EdgeInsets.only(right: 4.0),
                                child: Icon(
                                  Icons.lock_rounded,
                                  size: 14,
                                ),
                              ),
                        Flexible(
                          child: Text(
                            item.title,
                            style: TextStyle(
                                fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                members.length > 0
                    ? Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 11),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 5.0),
                          child: HorizontalListMember(
                            members: members,
                          ),
                        ),
                      )
                    : Container(),
                customFooter != null ? customFooter! : SizedBox()
              ],
            ),
          ),
        ),
      ),
    );
  }
}
