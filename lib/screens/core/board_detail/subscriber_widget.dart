import 'package:cicle_mobile_f3/controllers/board_detail_controller.dart';
import 'package:cicle_mobile_f3/models/member_model.dart';
import 'package:cicle_mobile_f3/screens/core/board_detail/board_detail_screen.dart';
import 'package:cicle_mobile_f3/widgets/bottom_sheet_add_subscriber.dart';
import 'package:cicle_mobile_f3/widgets/horizontal_list_avatar.dart';
import 'package:cicle_mobile_f3/widgets/shimmer_custom.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SubscriberWidget extends StatelessWidget {
  SubscriberWidget({Key? key, required this.boardDetailController})
      : super(key: key);

  final BoardDetailController boardDetailController;

  onPressAdd() {
    Get.bottomSheet(
        BottomSheetAddSubscriber(
          listAllProjectMembers: boardDetailController.teamMembers,
          listSelectedMembers: boardDetailController.members,
          onDone: (List<MemberModel> listSelected) {
            boardDetailController.addMembers(listSelected);
          },
        ),
        isDismissible: false,
        isScrollControlled: true);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 23.0, vertical: 11),
        child: Container(
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Subscribers',
                style: label,
              ),
              SizedBox(
                height: 10,
              ),
              Row(
                children: [
                  Obx(() => boardDetailController.isLoading ||
                          boardDetailController.loadingGetTeamMembers.value
                      ? ShimmerCustom(
                          height: 33.51,
                          width: 33.51,
                          borderRadius: 33.51,
                        )
                      : boardDetailController.loadingToggleMember.value
                          ? Container(
                              height: 33.51,
                              width: 33.51,
                              padding: EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.5),
                                      blurRadius: 1,
                                      offset: Offset(1, 1),
                                    ),
                                  ],
                                  color: Color(0xff708FC7),
                                  shape: BoxShape.circle),
                              child: Center(
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                ),
                              ))
                          : GestureDetector(
                              onTap: onPressAdd,
                              child: Container(
                                  height: 33.51,
                                  width: 33.51,
                                  decoration: BoxDecoration(
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.5),
                                          blurRadius: 1,
                                          offset: Offset(1, 1),
                                        ),
                                      ],
                                      color: Color(0xff708FC7),
                                      shape: BoxShape.circle),
                                  child: Center(
                                    child: Icon(
                                      Icons.add,
                                      color: Colors.white,
                                    ),
                                  )),
                            )),
                  SizedBox(
                    width: 4,
                  ),
                  Expanded(
                    child: Container(
                      height: 33.51,
                      child: Obx(() {
                        if (boardDetailController.isLoading ||
                            boardDetailController.loadingGetTeamMembers.value) {
                          return SizedBox();
                        }
                        List<MemberModel> members =
                            boardDetailController.members;
                        members
                            .sort((a, b) => a.fullName.compareTo(b.fullName));
                        return HorizontalListAvatar(
                          height: 33.51,
                          members: boardDetailController.members.length == 0
                              ? []
                              : members,
                        );
                      }),
                    ),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
