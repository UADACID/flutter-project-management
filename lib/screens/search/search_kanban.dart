import 'package:cicle_mobile_f3/models/board_list_item_model.dart';
import 'package:cicle_mobile_f3/models/card_model.dart';
import 'package:cicle_mobile_f3/models/comment_item_model.dart';
import 'package:cicle_mobile_f3/models/label_model.dart';
import 'package:cicle_mobile_f3/models/member_model.dart';
import 'package:cicle_mobile_f3/screens/core/board/card_due_date.dart';
import 'package:cicle_mobile_f3/screens/core/board/card_label.dart';
import 'package:cicle_mobile_f3/screens/search/search_screen.dart';
import 'package:cicle_mobile_f3/utils/helpers.dart';
import 'package:cicle_mobile_f3/widgets/horizontal_list_member.dart';
import 'package:cicle_mobile_f3/widgets/search_header_menu.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer_animation/shimmer_animation.dart';

class SearchKanban extends StatelessWidget {
  const SearchKanban({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 23),
            child: SearchHeaderMenu(
              title: 'Kanban Card',
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 23),
            child: Container(
              width: 220,
              child: Column(
                children: [
                  SearchCardItem(
                    card: CardModel(
                        name: 'Bikin UIUX page Check-Ins',
                        desc: 'loremipsum dolor sit amet',
                        // dueDate: DateTime.now().toString(),
                        isLocal: false,
                        labels: [
                          LabelModel(
                              sId: '1',
                              name: 'bug',
                              color: ColorModel(sId: 'sId', name: '#FFB6F3'),
                              createdAt: "",
                              updatedAt: ""),
                          LabelModel(
                              sId: '1',
                              name: 'android',
                              color: ColorModel(sId: 'sId', name: '#7299FF'),
                              createdAt: "",
                              updatedAt: ""),
                          LabelModel(
                              sId: '1',
                              name: 'ios',
                              color: ColorModel(sId: 'sId', name: '#47D3FF'),
                              createdAt: "",
                              updatedAt: "")
                        ],
                        attachments: [
                          Attachments(sId: 'sId', creator: MemberModel()),
                          Attachments(sId: 'sId', creator: MemberModel()),
                          Attachments(sId: 'sId', creator: MemberModel())
                        ],
                        comments: [
                          CommentItemModel(creator: Creator(), sId: ''),
                          CommentItemModel(creator: Creator(), sId: '')
                        ],
                        members: [
                          MemberModel(),
                          MemberModel(),
                          MemberModel(),
                          MemberModel()
                        ],
                        dueDate: DateTime.now().toString(),
                        archived: Archived(),
                        complete: Complete(),
                        creator: Creator(),
                        isNotified: IsNotified()),
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      'Div. Apps & Products > Boards',
                      maxLines: 2,
                      style: TextStyle(
                          fontSize: 10,
                          color: Color(0xffB5B5B5),
                          fontWeight: FontWeight.w500),
                    ),
                  )
                ],
              ),
            ),
          ),
          SizedBox(
            height: 25,
          ),
          ButtonShowAllRelatedItems(
            onPress: () {},
            title: 'cards',
          )
        ],
      ),
    );
  }
}

class SearchCardItem extends StatelessWidget {
  const SearchCardItem({
    Key? key,
    required this.card,
  }) : super(key: key);
  final CardModel card;

  @override
  Widget build(BuildContext context) {
    String description = removeHtmlTag(card.desc);
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.w),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10.w),
        child: Container(
          child: Stack(
            children: [
              GestureDetector(
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
                                      maxLines: 5,
                                      overflow: TextOverflow.ellipsis,
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
                          card.members.length > 0
                              ? Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 4.0),
                                  child: HorizontalListMember(
                                    height: 33.51,
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
      ),
    );
  }
}
