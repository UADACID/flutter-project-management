import 'package:cicle_mobile_f3/controllers/board_archived_controller.dart';
import 'package:cicle_mobile_f3/controllers/board_controller.dart';
import 'package:cicle_mobile_f3/controllers/team_detail_controller.dart';
import 'package:cicle_mobile_f3/models/board_list_item_model.dart';
import 'package:cicle_mobile_f3/models/card_model.dart';
import 'package:cicle_mobile_f3/utils/constant.dart';
import 'package:cicle_mobile_f3/utils/my_flutter_app_icons.dart';
import 'package:cicle_mobile_f3/widgets/default_alert.dart';
import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'card_item.dart';
import 'filter_archived.dart';

class EndDrawerBoard extends StatelessWidget {
  EndDrawerBoard({
    Key? key,
    required this.boardController,
  }) : super(key: key);

  final BoardController boardController;

  @override
  Widget build(BuildContext context) {
    return GetX<BoardArchivedController>(
        init: BoardArchivedController(),
        builder: (_boardArchiveController) {
          isFilterActive() {
            bool isDueSoonActive =
                _boardArchiveController.isDueSoon ? true : false;
            bool isDueTodayActive =
                _boardArchiveController.isDueToday ? true : false;
            bool isOverDueActive =
                _boardArchiveController.isOverDue ? true : false;
            bool isAnyMemberFilterSelected =
                _boardArchiveController.selectedMembers.length > 0
                    ? true
                    : false;
            bool isAnyLabelFilterSelected =
                _boardArchiveController.selectedLabels.length > 0
                    ? true
                    : false;

            if (isDueSoonActive ||
                isDueTodayActive ||
                isOverDueActive ||
                isAnyMemberFilterSelected ||
                isAnyLabelFilterSelected) {
              return true;
            }

            return false;
          }

          double statusBarHeight = MediaQuery.of(context).padding.top;
          return Container(
            width: 320.w,
            color: Colors.white,
            child: Scaffold(
              key: boardController.scaffoldKeyArchived,
              endDrawer: FilterArchived(
                  boardArchiveController: _boardArchiveController),
              body: Padding(
                padding: const EdgeInsets.only(left: 15, right: 15),
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(top: statusBarHeight + 10.w),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'Archived Items',
                            style: TextStyle(fontSize: 14.sp),
                          ),
                          GestureDetector(
                              onTap: () {
                                Get.back();
                              },
                              child: Container(
                                padding: const EdgeInsets.all(10.0),
                                child: Icon(
                                  Icons.close,
                                  color: Color(0xffB5B5B5),
                                ),
                              ))
                        ],
                      ),
                    ),
                    SizedBox(height: 1, child: Divider()),
                    SizedBox(
                      height: 15.w,
                    ),
                    Row(
                      children: [
                        Expanded(
                            child: _boardArchiveController.mode ==
                                    viewType.CARDS
                                ? _buildSearchInputCard(_boardArchiveController)
                                : _buildSearchInputList(
                                    _boardArchiveController)),
                        _boardArchiveController.mode == viewType.CARDS
                            ? GestureDetector(
                                onTap: () {
                                  boardController
                                      .scaffoldKeyArchived.currentState!
                                      .openEndDrawer();
                                },
                                child: Container(
                                    decoration: BoxDecoration(
                                        color: isFilterActive()
                                            ? Theme.of(context).primaryColor
                                            : Colors.transparent,
                                        border: Border.all(
                                            width: 1.w,
                                            color: isFilterActive()
                                                ? Colors.transparent
                                                : Color(0xffd6d6d6)),
                                        borderRadius:
                                            BorderRadius.circular(10.w)),
                                    padding: EdgeInsets.all(4.w),
                                    margin: EdgeInsets.only(left: 10.w),
                                    child: Icon(
                                      Icons.filter_alt_outlined,
                                      color: isFilterActive()
                                          ? Colors.white
                                          : Color(0xffB5B5B5),
                                    )),
                              )
                            : SizedBox(),
                        GestureDetector(
                          onTap: () {
                            if (_boardArchiveController.mode ==
                                viewType.CARDS) {
                              _boardArchiveController.mode = viewType.LISTS;
                            } else {
                              _boardArchiveController.mode = viewType.CARDS;
                            }
                          },
                          child: Container(
                              decoration: BoxDecoration(
                                  color: _boardArchiveController.mode ==
                                          viewType.LISTS
                                      ? Theme.of(context).primaryColor
                                      : Colors.transparent,
                                  border: Border.all(
                                      width: 1.w,
                                      color: _boardArchiveController.mode ==
                                              viewType.LISTS
                                          ? Colors.transparent
                                          : Color(0xffd6d6d6)),
                                  borderRadius: BorderRadius.circular(10.w)),
                              padding: EdgeInsets.all(4.w),
                              margin: EdgeInsets.only(left: 10.w),
                              child: Icon(
                                MyFlutterApp.mdi_format_list_bulleted,
                                color: _boardArchiveController.mode ==
                                        viewType.LISTS
                                    ? Colors.white
                                    : Color(0xffB5B5B5),
                              )),
                        ),
                      ],
                    ),
                    Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.only(
                              top: 2, bottom: 2, left: 7.5),
                          child: Text(
                            _boardArchiveController.mode == viewType.LISTS
                                ? 'Search by name'
                                : 'Search cards by name',
                            style: TextStyle(
                                fontSize: 8.sp, color: Color(0xff7a7a7a)),
                          ),
                        )),
                    _boardArchiveController.mode == viewType.LISTS
                        ? _buildBoardList(_boardArchiveController)
                        : _buildCardList(_boardArchiveController)
                  ],
                ),
              ),
            ),
          );
        });
  }

  Expanded _buildBoardList(BoardArchivedController _boardArchiveController) {
    return Expanded(
      child: _boardArchiveController.boardList.length == 0 &&
              _boardArchiveController.isLoading
          ? _buildLoading()
          : _buildHasDataBoardList(_boardArchiveController),
    );
  }

  Center _buildLoading() {
    return Center(
      child: CircularProgressIndicator(),
    );
  }

  ListView _buildHasDataBoardList(
      BoardArchivedController _boardArchiveController) {
    List<BoardListItemModel> filterBySearchKey = _boardArchiveController
        .boardList
        .where((element) =>
            element.name.toLowerCase().contains(
                _boardArchiveController.searchKeyList.toLowerCase()) &&
            element.archived.status == true)
        .toList();
    if (filterBySearchKey.length == 0) {
      return ListView(
        children: [
          Container(
            height: 250,
            width: double.infinity,
            child: Center(
                child: Text(
              'Archived list is not found',
              style: TextStyle(
                  fontSize: 14.w, color: Colors.grey.withOpacity(0.5)),
            )),
          )
        ],
      );
    }

    filterBySearchKey.sort((a, b) =>
        DateTime.parse(b.updatedAt).compareTo(DateTime.parse(a.updatedAt)));
    return ListView.builder(
        padding: EdgeInsets.only(top: 12.w),
        itemCount: filterBySearchKey.length,
        itemBuilder: (ctx, index) {
          BoardListItemModel item = filterBySearchKey[index];

          int cardsCounter = item.cards.length;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Card(
                child: Container(
                  margin: EdgeInsets.only(bottom: 3.5.w, top: 3.5),
                  padding: EdgeInsets.all(8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Container(
                          child: Text(
                            'List: ${item.name}',
                            style: TextStyle(
                                fontSize: 14.sp, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 15.w, vertical: 5.w),
                        decoration: BoxDecoration(
                            color: Color(0xffD6D6D6),
                            borderRadius: BorderRadius.circular(5.w)),
                        child: Text('$cardsCounter cards'),
                      ),
                      SizedBox(
                        height: 10.w,
                      ),
                    ],
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  Get.dialog(DefaultAlert(
                      onSubmit: () {
                        EasyDebounce.debounce(
                            'submit-add-check-in', Duration(milliseconds: 300),
                            () async {
                          await _boardArchiveController.unArchiveList(item.sId);
                          Get.back();
                        });
                      },
                      onCancel: () {
                        Get.back();
                      },
                      title: 'Restore "${item.name}" list?'));
                },
                child: Padding(
                  padding: EdgeInsets.all(5.w),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.undo_outlined,
                          size: 16, color: Color(0xff708FC7)),
                      SizedBox(
                        width: 6.w,
                      ),
                      Text(
                        'Restore',
                        style: TextStyle(
                            fontSize: 12.sp, color: Color(0xff708FC7)),
                      ),
                      SizedBox(
                        width: 10.w,
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: 10.w,
              )
            ],
          );
        });
  }

  Expanded _buildCardList(BoardArchivedController _boardArchiveController) {
    return Expanded(
      child: _boardArchiveController.cards.length == 0 &&
              _boardArchiveController.isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : _buildHasData(_boardArchiveController),
    );
  }

  TextField _buildSearchInputCard(
      BoardArchivedController _boardArchiveController) {
    return TextField(
      controller: _boardArchiveController.textEditingControllerSearch,
      style: TextStyle(fontSize: 11.w),
      onChanged: (value) {
        _boardArchiveController.searchKey = value;
      },
      decoration: InputDecoration(
        isDense: true,
        contentPadding: EdgeInsets.fromLTRB(15, 10, 10, 10),
        hintText: "Search cards...",
        hintStyle: TextStyle(color: Color(0xffB5B5B5), fontSize: 11),
        enabledBorder: OutlineInputBorder(
          borderRadius: new BorderRadius.circular(5.0),
          borderSide: BorderSide(color: Colors.grey.withOpacity(0.2)),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(5.w),
          ),
        ),
        suffixIcon: _boardArchiveController.searchKey == ''
            ? Icon(Icons.search)
            : InkWell(
                onTap: () {
                  _boardArchiveController.searchKey = '';
                  _boardArchiveController.textEditingControllerSearch.text = '';
                },
                child: Icon(Icons.close)),
        suffixIconConstraints: BoxConstraints(minWidth: 40),
      ),
    );
  }

  TextField _buildSearchInputList(
      BoardArchivedController _boardArchiveController) {
    return TextField(
      controller: _boardArchiveController.textEditingControllerSearchList,
      style: TextStyle(fontSize: 11.w),
      onChanged: (value) {
        _boardArchiveController.searchKeyList = value;
      },
      decoration: InputDecoration(
        isDense: true,
        contentPadding: EdgeInsets.fromLTRB(15, 10, 10, 10),
        hintText: "Search board list...",
        hintStyle: TextStyle(color: Color(0xffB5B5B5), fontSize: 11),
        enabledBorder: OutlineInputBorder(
          borderRadius: new BorderRadius.circular(5.0),
          borderSide: BorderSide(color: Colors.grey.withOpacity(0.2)),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(5.w),
          ),
        ),
        suffixIcon: _boardArchiveController.searchKeyList == ''
            ? Icon(Icons.search)
            : InkWell(
                onTap: () {
                  _boardArchiveController.searchKeyList = '';
                  _boardArchiveController.textEditingControllerSearchList.text =
                      '';
                },
                child: Icon(Icons.close)),
        suffixIconConstraints: BoxConstraints(minWidth: 40),
      ),
    );
  }

  isSuitableLabels(CardModel card, BoardArchivedController controller) {
    if (controller.selectedLabels.length == 0) {
      return true;
    }
    if (card.labels.length >= controller.selectedLabels.length) {
      var labelsId = [];
      card.labels.forEach((element) {
        labelsId.add(element.sId);
      });

      var filterlabelsId = [];
      controller.selectedLabels.forEach((element) {
        filterlabelsId.add(element.sId);
      });

      var _tempList = [];
      labelsId.forEach((label) {
        if (filterlabelsId.contains(label)) {
          _tempList.add(label);
        }
      });

      if (_tempList.length == filterlabelsId.length) {
        return true;
      }
      return false;
    }
    return false;
  }

  isSuitableMembers(CardModel card, BoardArchivedController controller) {
    if (controller.selectedMembers.length == 0) {
      return true;
    }
    if (card.members.length >= controller.selectedMembers.length) {
      var membersId = [];
      card.members.forEach((element) {
        membersId.add(element.sId);
      });

      var filtermembersId = [];
      controller.selectedMembers.forEach((element) {
        filtermembersId.add(element.sId);
      });

      var _tempList = [];
      membersId.forEach((label) {
        if (filtermembersId.contains(label)) {
          _tempList.add(label);
        }
      });

      if (_tempList.length == filtermembersId.length) {
        return true;
      }
      return false;
    }
    return false;
  }

  isSuitablePrivateAccess(CardModel card, BoardArchivedController controller) {
    if (card.isPublic) {
      return true;
    } else {
      var cardMembers = card.members;
      var listOfStringIdMembers = [];
      cardMembers.forEach((element) {
        listOfStringIdMembers.add(element.sId);
      });

      if (listOfStringIdMembers.contains(controller.logedInUserId)) {
        return true;
      }
      return false;
    }
  }

  isSuitableDueToday(CardModel card, BoardArchivedController controller) {
    bool filterIsDueToday = controller.isDueToday;
    if (!filterIsDueToday) {
      return true;
    }

    if (filterIsDueToday && card.dueDate == '') {
      return false;
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateToCheck = DateTime.parse(card.dueDate);
    final aDate =
        DateTime(dateToCheck.year, dateToCheck.month, dateToCheck.day);
    if (aDate == today) {
      return true;
    }
    return false;
  }

  isSuitableDueSoon(CardModel card, BoardArchivedController controller) {
    bool filterIsDueSoon = controller.isDueSoon;
    if (!filterIsDueSoon) {
      return true;
    }

    if (filterIsDueSoon && card.dueDate == '') {
      return false;
    }

    final now = DateTime.now();

    final dateToCheck = DateTime.parse(card.dueDate);
    final duration = dateToCheck.difference(now).inMinutes;

    if (duration > 0 && duration <= 60) {
      return true;
    }
    return false;
  }

  isSuitableOverDue(CardModel card, BoardArchivedController controller) {
    bool filterIsOverDue = controller.isOverDue;
    if (!filterIsOverDue) {
      return true;
    }

    if (filterIsOverDue && card.dueDate == '') {
      return false;
    }

    final now = DateTime.now();

    final dateToCheck = DateTime.parse(card.dueDate);
    final duration = dateToCheck.difference(now).inMinutes;

    print('duration $duration');
    if (duration < 0) {
      return true;
    }
    return false;
  }

  isSuitableFilter(CardModel card, BoardArchivedController controller) {
    var checkLabels = isSuitableLabels(card, controller);

    var checkMembers = isSuitableMembers(card, controller);

    var checkDueToday = isSuitableDueToday(card, controller);

    var checkDueSoon = isSuitableDueSoon(card, controller);

    var checkOverDue = isSuitableOverDue(card, controller);

    var checkForPrivateAccess = isSuitablePrivateAccess(card, controller);

    var checkArchived = card.archived.status == true;

    var result = checkLabels &&
        checkMembers &&
        checkDueToday &&
        checkDueSoon &&
        checkOverDue &&
        checkForPrivateAccess &&
        checkArchived;

    return result;
  }

  ListView _buildHasData(BoardArchivedController _boardArchiveController) {
    List<CardModel> filterBySearchKey = _boardArchiveController.cards
        .where((element) =>
            element.name
                .toLowerCase()
                .contains(_boardArchiveController.searchKey.toLowerCase()) &&
            isSuitableFilter(element, _boardArchiveController))
        .toList();
    if (filterBySearchKey.length == 0) {
      return ListView(
        children: [
          Container(
            height: 250,
            width: double.infinity,
            child: Center(
                child: Text(
              'Archived cards is not found',
              style: TextStyle(
                  fontSize: 14.w, color: Colors.grey.withOpacity(0.5)),
            )),
          )
        ],
      );
    }
    return ListView.builder(
        padding: EdgeInsets.only(top: 12.w),
        itemCount: filterBySearchKey.length,
        itemBuilder: (ctx, index) {
          CardModel item = filterBySearchKey[index];
          BoardListItemModel list =
              BoardListItemModel(archived: Archived(), complete: Complete());

          return Container(
            margin: EdgeInsets.only(bottom: 3.5.w, top: 3.5),
            child: Column(
              children: [
                InkWell(
                  onTap: () {
                    String teamId = Get.put(TeamDetailController()).teamId;
                    String companyId = Get.parameters['companyId'] ?? '';
                    Get.toNamed(RouteName.boardDetailScreen(
                        companyId, teamId, item.sId));
                  },
                  child: CardItem(
                    hideMoreButton: true,
                    card: item,
                    list: list,
                    customSizeAvatarMember: 24.w,
                    customFontSizeMember: 10.sp,
                    customMarginMember: EdgeInsets.only(right: 4),
                  ),
                ),
                SizedBox(
                  height: 8.w,
                ),
                GestureDetector(
                  onTap: () {
                    Get.dialog(DefaultAlert(
                        onSubmit: () {
                          EasyDebounce.debounce('submit-add-check-in',
                              Duration(milliseconds: 300), () async {
                            await _boardArchiveController
                                .unArchiveCard(item.sId);
                            Get.back();
                          });
                        },
                        onCancel: () {
                          Get.back();
                        },
                        title: 'Restore "${item.name}" card?'));
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Icon(Icons.undo_outlined,
                          size: 16, color: Color(0xff708FC7)),
                      SizedBox(
                        width: 6.w,
                      ),
                      Text(
                        'Restore',
                        style: TextStyle(
                            fontSize: 12.sp, color: Color(0xff708FC7)),
                      ),
                      SizedBox(
                        width: 6.w,
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 10.w,
                ),
              ],
            ),
          );
        });
  }
}
