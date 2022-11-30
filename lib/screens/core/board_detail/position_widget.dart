import 'package:cicle_mobile_f3/controllers/board_detail_controller.dart';
import 'package:cicle_mobile_f3/utils/constant.dart';
import 'package:cicle_mobile_f3/utils/helpers.dart';
import 'package:cicle_mobile_f3/widgets/default_alert.dart';
import 'package:cicle_mobile_f3/widgets/move_card_dialog.dart';
import 'package:cicle_mobile_f3/widgets/shimmer_custom.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Position_Widget extends StatelessWidget {
  Position_Widget({
    Key? key,
    required BoardDetailController boardDetailController,
  })  : _boardDetailController = boardDetailController,
        super(key: key);

  final BoardDetailController _boardDetailController;
  String companyId = Get.parameters['companyId'] ?? '';

  onMoveCardPosition() {
    print('on move');
    if (_boardDetailController.listItem.archived.status) {
      return showAlert(message: 'The archived card cannot be moved');
    }

    Get.dialog(MoveCardDialog(
      cardId: _boardDetailController.cardId,
      boardId: _boardDetailController.boardId,
      listId: _boardDetailController.listItem.sId,
      onMove: (sourceListId, destinationListId) async {
        try {
          _boardDetailController.isLoading = true;
          await _boardDetailController.moveCard(
              _boardDetailController.cardId,
              sourceListId,
              destinationListId,
              _boardDetailController.boardId,
              0);

          _boardDetailController.init();
        } catch (e) {
          errorMessageMiddleware(e);
        }
      },
    ));
  }

  onNavigateTeamDetail() {
    String alertTitle =
        "are you sure to navigate to the ${_boardDetailController.teamName} overview page?";
    Get.dialog(DefaultAlert(
        onSubmit: () async {
          Get.back();
          Get.reset();
          await Future.delayed(Duration(milliseconds: 300));
          Get.offAllNamed(RouteName.dashboardScreen(companyId));
          await Future.delayed(Duration(milliseconds: 300));
          Get.toNamed(
              '${RouteName.teamDetailScreen(companyId)}/${_boardDetailController.teamId}?destinationIndex=0');
        },
        onCancel: () => Get.back(),
        title: alertTitle));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 23.0, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Obx(() {
            if (_boardDetailController.isLoading) {
              return ShimmerCustom(
                height: 15,
                borderRadius: 0,
                width: 220,
              );
            }
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  Text('in list '),
                  InkWell(
                    onTap: onMoveCardPosition,
                    child: Text('${_boardDetailController.listItem.name}',
                        style: TextStyle(
                            fontWeight: FontWeight.w600,
                            decoration: TextDecoration.underline,
                            color: Color(0xff708FC7))),
                  ),
                  Text(' at '),
                  InkWell(
                    onTap: onNavigateTeamDetail,
                    child: Text('${_boardDetailController.teamName}',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                            color: Color(0xff708FC7))),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
