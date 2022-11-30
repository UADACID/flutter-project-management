import 'package:cicle_mobile_f3/controllers/board_archived_controller.dart';
import 'package:cicle_mobile_f3/controllers/board_filter_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'filter_board.dart';

class FilterArchived extends StatelessWidget {
  FilterArchived({
    Key? key,
    required this.boardArchiveController,
  }) : super(key: key);

  final BoardArchivedController boardArchiveController;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: GetX<BoardFilterController>(
          init: BoardFilterController(),
          initState: (state) {
            state.controller!.selectedLabels = [
              ...boardArchiveController.selectedLabels
            ];
            state.controller!.selectedMembers = [
              ...boardArchiveController.selectedMembers
            ];
            state.controller!.isDueToday = boardArchiveController.isDueToday;
            state.controller!.isDueSoon = boardArchiveController.isDueSoon;
            state.controller!.isOverDue = boardArchiveController.isOverDue;
          },
          builder: (controller) {
            return Column(
              children: [
                Text(
                  controller.selectedLabels.length.toString(),
                  style: TextStyle(fontSize: 0),
                ),
                CardFilter(
                  hideFilterName: true,
                  leading: Container(
                    child: Row(
                      children: [
                        IconButton(
                            onPressed: () {
                              Get.back();
                            },
                            icon: Icon(Icons.arrow_back)),
                        Text(
                          'Filter Archive',
                          style: TextStyle(
                              fontSize: 14.sp, fontWeight: FontWeight.w600),
                        )
                      ],
                    ),
                  ),
                  onApply: (_, selectedLabels, selectedMembers, isDueSoon,
                      isDueToday, isOverDue) {
                    boardArchiveController.selectedLabels = selectedLabels;
                    boardArchiveController.selectedMembers = selectedMembers;
                    boardArchiveController.isDueSoon = isDueSoon;
                    boardArchiveController.isDueToday = isDueToday;
                    boardArchiveController.isOverDue = isOverDue;
                    Get.back();
                  },
                  controller: controller,
                ),
              ],
            );
          }),
    );
  }
}
