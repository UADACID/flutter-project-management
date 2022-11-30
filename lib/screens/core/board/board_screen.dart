import 'package:boardview/board_item.dart';
import 'package:boardview/board_list.dart';
import 'package:boardview/boardview.dart';
import 'package:cicle_mobile_f3/controllers/board_controller.dart';
import 'package:cicle_mobile_f3/controllers/search_controller.dart';

import 'package:cicle_mobile_f3/controllers/team_detail_controller.dart';
import 'package:cicle_mobile_f3/models/board_list_item_model.dart';
import 'package:cicle_mobile_f3/models/card_model.dart';
import 'package:cicle_mobile_f3/utils/constant.dart';

import 'package:cicle_mobile_f3/utils/my_flutter_app_icons.dart';
import 'package:cicle_mobile_f3/widgets/keyboard_visibility_builder.dart';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../team_detail.dart';
import 'card_item.dart';
import 'endrawer_board.dart';
import 'filter_board.dart';
import 'footer_list.dart';
import 'form_add_board_list.dart';
import 'list_header.dart';

class BoardScreen extends StatelessWidget {
  TeamDetailController _teamDetailController = Get.find();
  String companyId = Get.parameters['companyId'] ?? '';

  showFromAddList(controller) {
    Get.dialog(FormAddBoardList(
      onSubmit: (String name) async {
        controller.addNewList(name: name);
      },
    ));
  }

  RefreshController refreshController =
      RefreshController(initialRefresh: false);

  void _onRefresh(BoardController controller) async {
    await controller.getBoard();
    refreshController.refreshCompleted();
  }

  @override
  Widget build(BuildContext context) {
    return GetX<BoardController>(
        init: BoardController(),
        initState: (state) {
          state.controller!.getBoard();
        },
        builder: (_boardController) {
          List<BoardList> _lists = [];
          List<BoardListItemModel> filterByNotArchived = _boardController
              .boardList
              .where((element) => element.archived.status == false)
              .toList();
          for (int i = 0; i < filterByNotArchived.length; i++) {
            _lists.add(
                _createBoardList(filterByNotArchived[i], _boardController)
                    as BoardList);
          }

          if (filterByNotArchived.length == 0 &&
              _boardController.loading == true) {
            return Scaffold(
                appBar: AppBar(
                  titleSpacing: 0,
                  title: Obx(() => Text(
                        _teamDetailController.teamName,
                        style: TextStyle(fontSize: 16),
                      )),
                  elevation: 0.0,
                  actions: [
                    ActionsAppBarTeamDetail(
                      showSetting: false,
                    )
                  ],
                ),
                body: Center(child: CircularProgressIndicator()));
          }
          return Stack(
            children: [
              Scaffold(
                key: _boardController.scaffoldKey,
                appBar: AppBar(
                  title: Obx(() => Text(
                        _teamDetailController.teamName,
                        style: TextStyle(fontSize: 16),
                      )),
                  elevation: 0.0,
                  actions: [
                    FilterBoard(),
                    GestureDetector(
                      onTap: () {
                        _boardController.scaffoldKey.currentState!
                            .openEndDrawer();
                      },
                      child: Container(
                        margin: EdgeInsets.only(right: 15),
                        child: Padding(
                          padding: const EdgeInsets.all(7.5),
                          child: Icon(
                            MyFlutterApp.archive,
                            size: 16,
                            color: Color(0xffB5B5B5),
                          ),
                        ),
                      ),
                    ),
                    ActionsAppBarTeamDetail(
                      showSetting: false,
                    )
                  ],
                ),
                endDrawer: EndDrawerBoard(boardController: _boardController),
                onEndDrawerChanged: (value) {
                  _boardController.isEndDrawerOpen = value;
                },
                body: SmartRefresher(
                  physics: BouncingScrollPhysics(),
                  header: WaterDropMaterialHeader(),
                  controller: refreshController,
                  onRefresh: () {
                    _onRefresh(_boardController);
                  },
                  child: BoardView(
                    lists: _lists,
                    boardViewController: _boardController.boardViewController,
                  ),
                ),
                floatingActionButton: KeyboardVisibilityBuilder(
                  builder: (context, child, isKeyboardVisible) {
                    if (isKeyboardVisible) {
                      return SizedBox();
                    } else {
                      return FloatingActionButton(
                        onPressed: () {
                          showFromAddList(_boardController);
                        },
                        child: Icon(
                          Icons.add,
                          color: Colors.white,
                        ),
                      );
                    }
                  },
                  child: SizedBox(),
                ),
              ),
              _boardController.overlay
                  ? _buildBoardOverlay(_boardController)
                  : SizedBox()
            ],
          );
        });
  }

  Container _buildBoardOverlay(BoardController _boardController) {
    return Container(
      color: Colors.black.withOpacity(0.5),
      child: Column(
        children: [
          AppBar(
            title: Obx(() => Text(
                  _teamDetailController.teamName,
                  style: TextStyle(fontSize: 16),
                )),
            elevation: 0.0,
            actions: [
              FilterBoard(),
              GestureDetector(
                onTap: () {
                  _boardController.scaffoldKey.currentState!.openEndDrawer();
                },
                child: Container(
                  margin: EdgeInsets.only(right: 15),
                  child: Padding(
                    padding: const EdgeInsets.all(7.5),
                    child: Icon(
                      MyFlutterApp.archive,
                      size: 16,
                      color: Color(0xffB5B5B5),
                    ),
                  ),
                ),
              ),
              ActionsAppBarTeamDetail(
                showSetting: false,
              )
            ],
          ),
          Expanded(child: Center(child: CircularProgressIndicator())),
        ],
      ),
    );
  }

  isSuitableLabels(CardModel card, BoardController controller) {
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

  isSuitableMembers(CardModel card, BoardController controller) {
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

  isSuitablePrivateAccess(CardModel card, BoardController controller) {
    if (card.isPublic) {
      return true;
    } else {
      if (card.creator.sId == controller.logedInUserId) {
        return true;
      }
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

  isSuitableDueToday(CardModel card, BoardController controller) {
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

  isSuitableDueSoon(CardModel card, BoardController controller) {
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

    if (duration > 0 && duration <= 1440) {
      return true;
    }
    return false;
  }

  isSuitableOverDue(CardModel card, BoardController controller) {
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

  isSuitableTitle(CardModel card, BoardController controller) {
    String _filteredTitle = controller.filteredName;

    if (_filteredTitle == '') {
      return true;
    }

    if (card.name.toLowerCase().contains(_filteredTitle.toLowerCase())) {
      return true;
    }

    return false;
  }

  isSuitableFilter(CardModel card, BoardController controller) {
    var checkTitle = isSuitableTitle(card, controller);

    var checkLabels = isSuitableLabels(card, controller);

    var checkMembers = isSuitableMembers(card, controller);

    var checkDueToday = isSuitableDueToday(card, controller);

    var checkDueSoon = isSuitableDueSoon(card, controller);

    var checkOverDue = isSuitableOverDue(card, controller);

    var checkForPrivateAccess = isSuitablePrivateAccess(card, controller);

    var checkArchived = card.archived.status == false;

    var result = checkTitle &&
        checkLabels &&
        checkMembers &&
        checkDueToday &&
        checkDueSoon &&
        checkOverDue &&
        checkForPrivateAccess &&
        checkArchived;

    return result;
  }

  Widget buildBoardItem(CardModel itemObject, BoardController controller,
      BoardListItemModel list) {
    var suitableFilter = isSuitableFilter(itemObject, controller);
    bool draggable = isSuitablePrivateAccess(itemObject, controller);
    return BoardItem(
        draggable: draggable,
        onStartDragItem:
            (int? listIndex, int? itemIndex, BoardItemState? state) {},
        onDropItem: (int? listIndex, int? itemIndex, int? oldListIndex,
            int? oldItemIndex, BoardItemState? state) {
          controller.onDropCard(
              oldListIndex: oldListIndex!,
              oldItemIndex: oldItemIndex!,
              listIndex: listIndex!,
              itemIndex: itemIndex!);
        },
        onTapItem:
            (int? listIndex, int? itemIndex, BoardItemState? state) async {
          String path = RouteName.boardDetailScreen(
              companyId, _teamDetailController.teamId, itemObject.sId);
          Get.put(SearchController()).insertListRecenlyViewed(RecentlyViewed(
              moduleName: 'card',
              companyId: companyId,
              path: path,
              teamName: _teamDetailController.teamName,
              title: itemObject.name,
              subtitle:
                  'Home  >  ${Get.put(TeamDetailController()).teamName}  >  Board  >  ${itemObject.name}',
              uniqId: itemObject.sId));

          draggable
              ? Get.toNamed(RouteName.boardDetailScreen(
                  companyId, _teamDetailController.teamId, itemObject.sId))
              : print('unauthorized');
        },
        item: suitableFilter
            ? Container(
                margin: EdgeInsets.only(
                  left: 6.w,
                  right: 6.w,
                ),
                child: CardItem(
                  card: itemObject,
                  list: list,
                ),
              )
            : SizedBox());
  }

  Widget _createBoardList(BoardListItemModel list, controller) {
    List<BoardItem> items = [];
    List<CardModel> filterCardsByNotArchived = list.cards;
    for (int i = 0; i < filterCardsByNotArchived.length; i++) {
      items.insert(
          i,
          buildBoardItem(filterCardsByNotArchived[i], controller, list)
              as BoardItem);
    }

    return BoardList(
      onStartDragList: (int? listIndex) {},
      onTapList: (int? listIndex) async {},
      onDropList: (int? listIndex, int? oldListIndex) {
        controller.onDropListItem(
            listIndex: listIndex!, oldListIndex: oldListIndex!);
      },
      headerBackgroundColor: Colors.transparent,
      backgroundColor: Color(0xffF0F1F7),
      header: [
        ListHeader(
          listItem: list,
        )
      ],
      items: items,
      footer: Column(
        children: [
          FooterList(
            listItem: list,
          ),
        ],
      ),
    );
  }
}
