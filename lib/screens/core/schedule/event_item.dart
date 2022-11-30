import 'package:badges/badges.dart';
import 'package:cicle_mobile_f3/controllers/search_controller.dart';
import 'package:cicle_mobile_f3/controllers/team_detail_controller.dart';
import 'package:cicle_mobile_f3/models/event_item_model.dart';

import 'package:cicle_mobile_f3/utils/constant.dart';

import 'package:cicle_mobile_f3/widgets/horizontal_list_member.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class EventItem extends StatelessWidget {
  EventItem({
    Key? key,
    required this.item,
    required this.index,
    required this.list,
    required this.refreshList,
    this.customMargin = const EdgeInsets.only(bottom: 8, top: 8),
    this.customFooter,
    this.isDone = false,
  }) : super(key: key);

  final Function refreshList;

  final EventItemModel item;
  final int index;
  final List<EventItemModel> list;
  final EdgeInsets customMargin;
  final Widget? customFooter;
  final bool isDone;

  String? teamId = Get.parameters['teamId'];
  String companyId = Get.parameters['companyId'] ?? '';

  @override
  Widget build(BuildContext context) {
    String dayName =
        DateFormat('EEEE').format(DateTime.parse(item.startDate!).toLocal());
    String date =
        DateFormat.d().format(DateTime.parse(item.startDate!).toLocal());

    bool isSameFirstDay = checkIsSameFirstDay(list, index);

    bool isSameLastDay = checkIsSameLastDay(list, index);

    String title = item.title ?? '';
    int commentCounter = item.comments != null ? item.comments!.length : 0;

    String startDate =
        DateFormat('hh.mm').format(DateTime.parse(item.startDate!).toLocal());
    String endDate =
        DateFormat('hh.mm a').format(DateTime.parse(item.endDate!).toLocal());

    _buildTime() {
      print('item.status ${item.status}');
      if (item.status == 'sameDay') {
        return Text('$startDate - $endDate',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.normal));
      } else if (item.status == 'onStart') {
        return Text('$startDate onward',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.normal));
      } else if (item.status == 'onGoing') {
        return Text('-',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.normal));
      } else if (item.status == 'onEnd') {
        return Text('Until $endDate',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.normal));
      }

      return Text('$startDate - $endDate',
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.normal));
    }

    return GestureDetector(
      onTap: () async {
        var result;
        if (item.isRecurring!) {
          String path = RouteName.occurenceDetailScreen(
              companyId, teamId!, item.event!, item.sId!);
          Get.put(SearchController()).insertListRecenlyViewed(RecentlyViewed(
              moduleName: 'occurrence',
              companyId: companyId,
              path: path,
              teamName: Get.put(TeamDetailController()).teamName,
              title: title,
              subtitle:
                  'Home  >  ${Get.put(TeamDetailController()).teamName}  >  Schedule  >  ${item.title}',
              uniqId: item.sId!));
          result = await Get.toNamed(path);
        } else {
          String path =
              RouteName.scheduleDetailScreen(companyId, teamId!, item.sId!);
          Get.put(SearchController()).insertListRecenlyViewed(RecentlyViewed(
              moduleName: 'event',
              companyId: companyId,
              path: path,
              teamName: Get.put(TeamDetailController()).teamName,
              title: title,
              subtitle:
                  'Home  >  ${Get.put(TeamDetailController()).teamName}  >  Schedule  >  ${item.title}',
              uniqId: item.sId!));
          result = await Get.toNamed(path);
        }

        if (result == true) {
          refreshList();
        }
      },
      child: Container(
        margin: customMargin,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.only(left: 8, top: 8),
              width: 80,
              child: Center(
                  child: isSameFirstDay
                      ? Column(
                          children: [
                            Text(
                              date,
                              textAlign: TextAlign.end,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                            Text(
                              dayName.substring(0, 3),
                              textAlign: TextAlign.end,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                          ],
                        )
                      : Container()),
            ),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                    color: Color(0xffA9C289),
                    borderRadius: BorderRadius.circular(8)),
                child: Stack(
                  alignment: AlignmentDirectional.center,
                  children: [
                    Opacity(
                      opacity: isDone ? 0.5 : 1.0,
                      child: Container(
                        decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: Color(0xffDEEAFF)),
                            borderRadius: BorderRadius.circular(8.w)),
                        child: Padding(
                          padding: const EdgeInsets.all(0.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                height: 10,
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                child: Row(
                                  children: [
                                    item.isPublic == false
                                        ? Padding(
                                            padding: const EdgeInsets.only(
                                                right: 4.0),
                                            child: Icon(
                                              Icons.lock_rounded,
                                              size: 16,
                                            ),
                                          )
                                        : SizedBox(),
                                    Expanded(
                                      child: Text(
                                        title,
                                        maxLines: 1,
                                        style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                child: Row(
                                  children: [
                                    Expanded(child: _buildTime()),
                                    commentCounter > 0
                                        ? Badge(
                                            badgeContent:
                                                Text(commentCounter.toString(),
                                                    style: TextStyle(
                                                      fontSize: 11,
                                                      color: Colors.white,
                                                    )),
                                          )
                                        : SizedBox()
                                  ],
                                ),
                              ),
                              Container(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                child: item.subscribers!.isEmpty
                                    ? Padding(
                                        padding: const EdgeInsets.only(top: 10),
                                        child: Container(
                                          height: 33.52,
                                          child: Align(
                                              alignment: Alignment.centerLeft,
                                              child: Text(
                                                'no members for this event',
                                                style: TextStyle(
                                                    fontSize: 11,
                                                    color: Colors.grey),
                                              )),
                                        ),
                                      )
                                    : Padding(
                                        padding: const EdgeInsets.only(top: 10),
                                        child: HorizontalListMember(
                                          height: 33.51,
                                          marginItem: EdgeInsets.only(right: 4),
                                          members: item.subscribers!,
                                        ),
                                      ),
                              ),
                              customFooter != null
                                  ? customFooter!
                                  : SizedBox(
                                      height: 10,
                                    )
                            ],
                          ),
                        ),
                      ),
                    ),
                    isDone
                        ? Icon(
                            Icons.task_alt_rounded,
                            size: 60,
                            color: Colors.white,
                          )
                        : SizedBox()
                  ],
                ),
              ),
            ),
            SizedBox(
              width: 23,
            )
          ],
        ),
      ),
    );
  }
}

checkIsSameFirstDay(List<EventItemModel> list, index) {
  int _previousIndex = index - 1;
  bool _hasPreviousItem =
      _previousIndex >= 0 ? (list[index - 1] != null ? true : false) : false;
  bool result = _hasPreviousItem
      ? DateFormat('yyyy-MM-dd').format(
                  DateTime.parse(list[index - 1].startDate!).toLocal()) ==
              DateFormat('yyyy-MM-dd')
                  .format(DateTime.parse(list[index].startDate!).toLocal())
          ? false
          : true
      : true;
  return result;
}

checkIsSameLastDay(List<EventItemModel> list, index) {
  if (index + 1 >= list.length) {
    return true;
  }
  int _previousIndex = index + 1;
  bool _hasPreviousItem =
      _previousIndex >= 2 ? (list[index + 1] != null ? true : false) : false;
  bool result = _hasPreviousItem
      ? DateFormat('yyyy-MM-dd').format(
                  DateTime.parse(list[index + 1].startDate!).toLocal()) !=
              DateFormat('yyyy-MM-dd')
                  .format(DateTime.parse(list[index].startDate!).toLocal())
          ? true
          : false
      : false;
  return result;
}
