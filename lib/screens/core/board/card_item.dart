import 'package:cicle_mobile_f3/controllers/board_controller.dart';
import 'package:cicle_mobile_f3/controllers/team_detail_controller.dart';
import 'package:cicle_mobile_f3/models/board_list_item_model.dart';
import 'package:cicle_mobile_f3/models/card_model.dart';

import 'package:cicle_mobile_f3/utils/constant.dart';
import 'package:cicle_mobile_f3/utils/helpers.dart';
import 'package:cicle_mobile_f3/widgets/default_alert.dart';
import 'package:cicle_mobile_f3/widgets/horizontal_list_member.dart';
import 'package:cicle_mobile_f3/widgets/move_card_dialog.dart';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'package:share_plus/share_plus.dart';
import 'package:shimmer_animation/shimmer_animation.dart';

import 'card_due_date.dart';
import 'card_label.dart';

class CardItem extends StatelessWidget {
  CardItem({
    Key? key,
    required this.card,
    required this.list,
    this.customSizeAvatarMember = 33.51,
    this.customMarginMember = const EdgeInsets.only(right: 7),
    this.customFontSizeMember = 14,
    this.hideMoreButton = false,
  }) : super(key: key);

  final double customSizeAvatarMember;
  final EdgeInsetsGeometry customMarginMember;
  final double customFontSizeMember;
  final BoardListItemModel list;
  final CardModel card;
  final bool hideMoreButton;
  BoardController _boardController = Get.find();
  TeamDetailController _teamDetailController = Get.find();

  @override
  Widget build(BuildContext context) {
    String description = removeHtmlTag(card.desc);
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.w),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10.w),
        child: Stack(
          children: [
            GestureDetector(
              onTap: card.isProgressToArchived
                  ? () {
                      showAlert(
                          message: 'the archive process is still in progress');
                    }
                  : null,
              child: Shimmer(
                duration: Duration(seconds: 2),
                enabled: card.isProgressToArchived ? true : false,
                child: Container(
                  color: card.isProgressToArchived
                      ? Colors.grey.withOpacity(0.3)
                      : Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 15.w,
                        ),
                        Wrap(
                          children: card.labels
                              .asMap()
                              .map((key, value) => MapEntry(
                                  key,
                                  CardLabel(
                                    label: value,
                                  )))
                              .values
                              .toList(),
                        ),
                        card.name.trim() == ""
                            ? Container()
                            : Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 4.0),
                                child: Text(card.name,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    )),
                              ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Row(
                            children: [
                              CardDueDate(
                                card: card,
                                list: list,
                              ),
                              description.length > 0
                                  ? Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 4.0),
                                      child: Icon(
                                        Icons.description_outlined,
                                        size: 20,
                                        color: Color(0xffB5B5B5),
                                      ),
                                    )
                                  : Container(),
                              card.comments.length > 0
                                  ? Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 4.0),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.chat_bubble_outline_rounded,
                                            size: 20,
                                            color: Color(0xffB5B5B5),
                                          ),
                                          SizedBox(
                                            width: 2.5,
                                          ),
                                          Text(
                                            card.comments.length.toString(),
                                            style: TextStyle(
                                                fontSize: 12,
                                                color: Color(0xffB5B5B5)),
                                          )
                                        ],
                                      ),
                                    )
                                  : Container(),
                              card.attachments.length > 0
                                  ? Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 4.0),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.attach_file_sharp,
                                            size: 20,
                                            color: Color(0xffB5B5B5),
                                          ),
                                          Text(
                                            card.attachments.length.toString(),
                                            style: TextStyle(
                                                fontSize: 12,
                                                color: Color(0xffB5B5B5)),
                                          )
                                        ],
                                      ),
                                    )
                                  : Container(),
                            ],
                          ),
                        ),
                        card.members.length > 0
                            ? Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 4.0),
                                child: HorizontalListMember(
                                  height: customSizeAvatarMember,
                                  marginItem: customMarginMember,
                                  fontSize: customFontSizeMember,
                                  members: card.members,
                                ),
                              )
                            : Container(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            card.isPublic == false
                ? Padding(
                    padding: const EdgeInsets.all(6.0),
                    child: Icon(
                      Icons.lock_rounded,
                      size: 16,
                    ),
                  )
                : SizedBox(),
            hideMoreButton ? SizedBox() : _buildMoreButton(),
            card.isLocal
                ? Shimmer(
                    duration: Duration(seconds: 1),
                    child: GestureDetector(
                      onTap: () {
                        showAlert(
                            message: 'waiting for card creation to finish');
                      },
                      child: Container(
                        width: 500,
                        height: 120,
                        color: Colors.black.withOpacity(0.1),
                        child: Center(),
                      ),
                    ),
                  )
                : Container(),
          ],
        ),
      ),
    );
  }

  Align _buildMoreButton() {
    String _boardId = _teamDetailController.boardId;

    onShareLink() {
      String _companyId = Get.parameters['companyId'] ?? '';
      String _teamId = Get.parameters['teamId'] ?? '';
      String _fullPath =
          '${Env.WEB_URL}/companies/$_companyId/teams/$_teamId/cards/${card.sId}';

      Share.share(_fullPath);
    }

    onMoveCard() {
      Get.dialog(MoveCardDialog(
        boardId: _boardId,
        cardId: card.sId,
        listId: list.sId,
        onMove: (sourceListId, destinationListId) async {
          try {
            _boardController.overlay = true;
            List<BoardListItemModel> result = await _boardController.moveCard(
                card.sId, sourceListId, destinationListId, _boardId, 0);
            _boardController.overlay = false;
            // if (result.length > 0) {
            //   _boardController.boardList = result;

            //   await Future.delayed(Duration(milliseconds: 300));
            //   int indexListDestination = _boardController.boardList
            //       .indexWhere((element) => element.sId == destinationListId);

            //   _boardController.boardViewController.animateTo(
            //       indexListDestination,
            //       duration: Duration(milliseconds: 600),
            //       curve: Curves.ease);
            //   _boardController.overlay = false;
            // }
          } catch (e) {
            errorMessageMiddleware(e);
            _boardController.overlay = false;
          }
        },
      ));
    }

    onArchive() {
      Get.dialog(DefaultAlert(
          onSubmit: () async {
            Get.back();
            List<BoardListItemModel> result =
                await _boardController.archiveCard(cardId: card.sId);

            if (result.length > 0) {
              _boardController.boardList = result;
            }
          },
          onCancel: () {
            Get.back();
          },
          textSubmit: 'Archive',
          title: 'Archived card?'));
    }

    onSetupCardPrivate() {
      _boardController.updatePrivateCard(card.sId, card.isPublic);
    }

    return Align(
      alignment: Alignment.topRight,
      child: Container(
        child: RotatedBox(
          quarterTurns: 2,
          child: Container(
            constraints: BoxConstraints(maxHeight: 30),
            child: PopupMenuButton(
              offset: Offset(14, -20),
              icon: Icon(
                Icons.more_horiz,
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
                    !card.isPublic
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
                  case 4:
                    return onArchive();
                  case 5:
                    return onSetupCardPrivate();
                  default:
                    return;
                }
              },
            ),
          ),
        ),
      ),
    );
  }
}
