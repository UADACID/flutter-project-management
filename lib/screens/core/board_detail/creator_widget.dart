import 'package:cicle_mobile_f3/controllers/board_detail_controller.dart';
import 'package:cicle_mobile_f3/utils/helpers.dart';
import 'package:cicle_mobile_f3/widgets/avatar_custom.dart';
import 'package:cicle_mobile_f3/widgets/shimmer_custom.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;

class CreatorWidget extends StatelessWidget {
  const CreatorWidget({
    Key? key,
    required BoardDetailController boardDetailController,
  })  : _boardDetailController = boardDetailController,
        super(key: key);

  final BoardDetailController _boardDetailController;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 23.0, vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Obx(() {
            if (_boardDetailController.isLoading) {
              return ShimmerCustom(
                height: 15,
                borderRadius: 0,
                width: 150,
              );
            }
            String dateCummon = DateFormat.yMEd().format(
                DateTime.parse(_boardDetailController.cardDetail.createdAt)
                    .toLocal());

            String dateTimeAgo = timeago.format(
                DateTime.parse(_boardDetailController.cardDetail.createdAt)
                    .toLocal());

            bool isCreatedAtMoreThan3dayAgo = calculateDifference(
                        DateTime.parse(
                                _boardDetailController.cardDetail.createdAt)
                            .toLocal()) <=
                    -3
                ? true
                : false;
            return Row(
              children: [
                AvatarCustom(
                    height: 24,
                    child: Image.network(
                      getPhotoUrl(
                          url: _boardDetailController
                              .cardDetail.creator.photoUrl),
                      fit: BoxFit.cover,
                      height: 24,
                      width: 24,
                    )),
                SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: Text(
                    _boardDetailController.cardDetail.creator.fullName,
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 3),
                  decoration: BoxDecoration(
                      color: Color(0xffC1D6FD),
                      borderRadius: BorderRadius.circular(3)),
                  child: Text(
                    isCreatedAtMoreThan3dayAgo ? dateCummon : dateTimeAgo,
                    style: TextStyle(fontSize: 12),
                  ),
                )
              ],
            );
          })
        ],
      ),
    );
  }
}
