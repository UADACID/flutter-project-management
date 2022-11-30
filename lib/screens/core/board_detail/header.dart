import 'package:cicle_mobile_f3/controllers/board_detail_controller.dart';
import 'package:cicle_mobile_f3/models/board_list_item_model.dart';
import 'package:cicle_mobile_f3/utils/constant.dart';
import 'package:cicle_mobile_f3/utils/helpers.dart';
import 'package:cicle_mobile_f3/widgets/default_alert.dart';
import 'package:cicle_mobile_f3/widgets/move_card_dialog.dart';
import 'package:cicle_mobile_f3/widgets/shimmer_custom.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';

class Header extends StatelessWidget {
  Header({
    Key? key,
    required this.boardDetailController,
  }) : super(key: key);

  final BoardDetailController boardDetailController;
  String companyId = Get.parameters['companyId'] ?? '';

  @override
  Widget build(BuildContext context) {
    double statusBarHeight = MediaQuery.of(context).padding.top;
    return Obx(() {
      if (boardDetailController.isLoading) {
        return Align(
          alignment: Alignment.centerLeft,
          child: Container(
            margin: EdgeInsets.only(top: statusBarHeight),
            padding: EdgeInsets.symmetric(vertical: 7),
            decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  bottom: BorderSide(width: 1.0, color: Color(0xffFAFAFA)),
                )),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 5,
                ),
                IconButton(
                    onPressed: () {
                      Get.back();
                    },
                    icon: Icon(Icons.arrow_back)),
                Expanded(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                    width: 250.w,
                    decoration: BoxDecoration(
                        border: Border.all(color: Color(0xffD6D6D6), width: 1),
                        borderRadius: BorderRadius.circular(5)),
                    child: ShimmerCustom(
                      height: 20,
                    ),
                  ),
                ),
                SizedBox(
                  width: 35,
                ),
              ],
            ),
          ),
        );
      }
      return Container(
          margin: EdgeInsets.only(top: statusBarHeight),
          padding: EdgeInsets.symmetric(vertical: 7),
          decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                bottom: BorderSide(width: 1.0, color: Color(0xffFAFAFA)),
              )),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: 5,
              ),
              IconButton(
                  onPressed: () {
                    Get.back();
                  },
                  icon: Icon(Icons.arrow_back)),
              !boardDetailController.isPrivate
                  ? SizedBox()
                  : Padding(
                      padding: const EdgeInsets.only(right: 10.0, top: 0),
                      child: Icon(
                        Icons.lock_rounded,
                        size: 20,
                      ),
                    ),
              Expanded(
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Obx(() => Text(
                        boardDetailController.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontSize: 12, fontWeight: FontWeight.bold),
                      )),
                  SizedBox(
                    height: 3,
                  ),
                  InkWell(
                    onTap: () async {
                      Get.reset();
                      await Future.delayed(Duration(milliseconds: 300));
                      Get.offAllNamed(RouteName.dashboardScreen(companyId));
                      await Future.delayed(Duration(milliseconds: 300));
                      Get.toNamed(
                          '${RouteName.teamDetailScreen(companyId)}/${boardDetailController.teamId}?destinationIndex=2');
                    },
                    child: Text(
                      '[Boards] ${boardDetailController.teamName}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Color(0xff708FC7)),
                    ),
                  )
                ],
              )),
              Obx(() => _buildMoreButton(
                  boardDetailController.cardDetail.archived.status))
            ],
          ));
    });
  }

  Container _buildMoreButton(bool archiveStatus) {
    onShareLink() {
      String _companyId = Get.parameters['companyId'] ?? '';
      String _teamId = Get.parameters['teamId'] ?? '';
      String _fullPath =
          '${Env.WEB_URL}/companies/$_companyId/teams/$_teamId/cards/${boardDetailController.cardId}';

      Share.share(_fullPath);
    }

    onMoveCard() {
      print('on move');
      if (archiveStatus) {
        return showAlert(message: 'The archived card cannot be moved');
      }
      try {
        Get.dialog(MoveCardDialog(
          cardId: boardDetailController.cardId,
          boardId: boardDetailController.boardId,
          listId: boardDetailController.listItem.sId,
          onMove: (sourceListId, destinationListId) async {
            boardDetailController.isLoading = true;
            await boardDetailController.moveCard(
                boardDetailController.cardId,
                sourceListId,
                destinationListId,
                boardDetailController.boardId,
                0);
            boardDetailController.init();
          },
        ));
      } catch (e) {
        print(e);
        errorMessageMiddleware(e);
      }
    }

    onCopyCard() {
      showAlert(message: 'feature is under development');
    }

    onArchive() {
      if (archiveStatus) {
        return showAlert(message: 'This card is already archived');
      }
      Get.dialog(DefaultAlert(
          onSubmit: () async {
            Get.back();
            List<BoardListItemModel> _list = await boardDetailController
                .archiveCard(cardId: boardDetailController.cardId);
          },
          onCancel: () {
            Get.back();
          },
          textSubmit: 'Archive',
          title: 'Archived card?'));
    }

    onSetupCardPrivate() {
      boardDetailController.updatePrivateCard(
          boardDetailController.cardId, !boardDetailController.isPrivate);
    }

    return Container(
      child: PopupMenuButton(
        offset: Offset(-20, 55),
        icon: Icon(
          Icons.more_vert_outlined,
          color: Color(0xffB5B5B5),
        ),
        padding: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5),
        ),
        itemBuilder: (context) => [
          PopupMenuItem(
            height: 35,
            child: Text(
              "Share card link",
              style: TextStyle(fontSize: 14, color: Color(0xff979797)),
            ),
            value: 1,
          ),
          PopupMenuItem(
            height: 35,
            child: Text(
              "Move card",
              style: TextStyle(fontSize: 14, color: Color(0xff979797)),
            ),
            value: 2,
          ),
          PopupMenuItem(
            height: 35,
            child: Text(
              "Copy card",
              style: TextStyle(fontSize: 14, color: Color(0xff979797)),
            ),
            value: 3,
          ),
          PopupMenuItem(
            height: 35,
            child: Text(
              "Archive card",
              style: TextStyle(fontSize: 14, color: Color(0xff979797)),
            ),
            value: 4,
          ),
          PopupMenuItem(
            height: 35,
            child: Text(
              boardDetailController.isPrivate
                  ? "Set card to public"
                  : "Set card to private",
              style: TextStyle(fontSize: 14, color: Color(0xff979797)),
            ),
            value: 5,
          ),
        ],
        onSelected: (int value) {
          switch (value) {
            case 1:
              return onShareLink();
            case 2:
              return onMoveCard();
            case 3:
              return onCopyCard();
            case 4:
              return onArchive();
            case 5:
              return onSetupCardPrivate();
            default:
              return;
          }
        },
      ),
    );
  }
}
