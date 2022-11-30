import 'package:cicle_mobile_f3/models/board_list_item_model.dart';
import 'package:cicle_mobile_f3/models/card_model.dart';
import 'package:cicle_mobile_f3/screens/core/board/card_due_date.dart';
import 'package:cicle_mobile_f3/screens/core/board/card_label.dart';
import 'package:cicle_mobile_f3/utils/helpers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer_animation/shimmer_animation.dart';

import 'horizontal_list_member.dart';

class CardItemCustom extends StatelessWidget {
  const CardItemCustom({
    Key? key,
    required this.card,
    this.customHeightMemberAvatar = 33.0,
  }) : super(key: key);
  final CardModel card;
  final double customHeightMemberAvatar;

  @override
  Widget build(BuildContext context) {
    String description = removeHtmlTag(card.desc);
    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.w),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10.w),
        child: Container(
          child: Stack(
            children: [
              GestureDetector(
                // onTap: card.isProgressToArchived
                //     ? () {
                //         showAlert(
                //             message: 'the archive process is still in progress');
                //       }
                //     : null,
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
                          // SizedBox(
                          //   height: 15.w,
                          // ),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
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
                          ),
                          card.name.trim() == ""
                              ? Container()
                              : Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 4.0),
                                  child: Text(card.name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      )),
                                ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: [
                                  CardDueDate(
                                    card: card,
                                    list: BoardListItemModel(
                                        archived: Archived(),
                                        complete: Complete()),
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
                                                Icons
                                                    .chat_bubble_outline_rounded,
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
                                                card.attachments.length
                                                    .toString(),
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
                          ),
                          card.members.length > 0
                              ? Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 4.0),
                                  child: HorizontalListMember(
                                    height: customHeightMemberAvatar,
                                    marginItem: const EdgeInsets.only(right: 7),
                                    fontSize: 14,
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
              // _buildMoreButton(),
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
                          child: Center(
                              // child: CircularProgressIndicator()
                              ),
                        ),
                      ),
                    )
                  : Container(),
            ],
          ),
        ),
      ),
    );
  }
}
