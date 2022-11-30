import 'package:cicle_mobile_f3/controllers/board_detail_controller.dart';
import 'package:cicle_mobile_f3/utils/my_flutter_app_icons.dart';
import 'package:cicle_mobile_f3/widgets/shimmer_custom.dart';
import 'package:flutter/material.dart';
import 'package:get/get_state_manager/get_state_manager.dart';

class TitleWidget extends StatelessWidget {
  const TitleWidget({Key? key, required this.boardDetailController})
      : super(key: key);

  final BoardDetailController boardDetailController;

  @override
  Widget build(BuildContext context) {
    if (boardDetailController.isLoading) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(left: 22, right: 22),
            child: ShimmerCustom(
              height: 16,
              width: double.infinity,
            ),
          ),
          SizedBox(
            height: 8,
          ),
          Padding(
            padding: EdgeInsets.only(left: 22, right: 22),
            child: ShimmerCustom(
              height: 16,
              width: 300,
            ),
          ),
          SizedBox(
            height: 15,
          ),
        ],
      );
    }
    return Container(
      color: Colors.white,
      width: double.infinity,
      padding: EdgeInsets.only(left: 22, right: 22, bottom: 15, top: 15),
      child: Obx(() {
        if (boardDetailController.showForm) {
          return Row(
            children: [
              Expanded(
                child: TextField(
                  controller: boardDetailController.textEditingControllerTitle,
                  autofocus: true,
                  minLines: 1,
                  maxLines: 8,
                  decoration: InputDecoration(
                    hintText: 'Type Card title here...',
                    hintStyle: TextStyle(
                        fontSize: 18,
                        color: Color(0xff7A7A7A).withOpacity(0.5)),
                    contentPadding: EdgeInsets.fromLTRB(0, 5, 6, 5),
                  ),
                ),
              ),
              IconButton(
                  onPressed: () {
                    if (boardDetailController.textEditingControllerTitle.text ==
                        '') {
                      return;
                    }
                    FocusScope.of(context).unfocus();

                    boardDetailController.updateTitle(
                        boardDetailController.textEditingControllerTitle.text);
                  },
                  icon: Icon(
                    Icons.check,
                    color: Theme.of(context).primaryColor,
                  ))
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                boardDetailController.title,
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xff393e46)),
              ),
            ),
            GestureDetector(
              onTap: () {
                boardDetailController.showForm = true;
              },
              child: Padding(
                padding: const EdgeInsets.only(left: 10, top: 2, bottom: 2),
                child: Icon(
                  MyFlutterApp.edit,
                  size: 18,
                  color: Color(0xff7A7A7A),
                ),
              ),
            )
          ],
        );
      }),
    );
  }
}
