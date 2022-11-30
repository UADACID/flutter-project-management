import 'package:badges/badges.dart';
import 'package:cicle_mobile_f3/models/post_item_model.dart';
import 'package:cicle_mobile_f3/utils/helpers.dart';
import 'package:cicle_mobile_f3/widgets/avatar_custom.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class BlastFullFill extends StatelessWidget {
  const BlastFullFill({Key? key, this.list = const []}) : super(key: key);
  final List<PostItemModel> list;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: double.infinity,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Color(0xfff4f4f4),
          border: Border.all(color: Color(0xffF0F1F7))),
      child: SingleChildScrollView(
        physics: NeverScrollableScrollPhysics(),
        child: Column(
          children: [
            ...list
                .asMap()
                .map((key, value) {
                  PostItemModel item = value;
                  return MapEntry(key, _buildItem(item));
                })
                .values
                .toList(),
          ],
        ),
      ),
    );
  }

  Container _buildItem(PostItemModel item) {
    String title = item.title == '' ? 'untitled' : item.title;
    String createdBy =
        item.creator.fullName == '' ? 'creator name' : item.creator.fullName;
    // String description = removeHtmlTag(item.content).trim();
    String photoUrl = item.creator.photoUrl;
    int commentLength = item.commentsAsString.length;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        color: Colors.white,
      ),
      margin: EdgeInsets.only(left: 2.w, right: 2.w, bottom: 0, top: 5.w),
      padding: EdgeInsets.all(8),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 1.0),
                child: AvatarCustom(
                    height: 16,
                    child: Image.network(
                      getPhotoUrl(url: photoUrl),
                      height: 16,
                      width: 16,
                      fit: BoxFit.cover,
                    )),
              ),
              SizedBox(
                width: 5,
              ),
              item.isPublic == false
                  ? Padding(
                      padding: const EdgeInsets.only(right: 2.0, top: 2.5),
                      child: Icon(
                        Icons.lock_rounded,
                        size: 9,
                      ),
                    )
                  : SizedBox(),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style:
                            TextStyle(fontSize: 9.w, color: Color(0xff393E46))),
                    Text(createdBy,
                        style:
                            TextStyle(fontSize: 7.w, color: Color(0xff708FC7))),
                  ],
                ),
              )
            ],
          ),
          SizedBox(
            height: 3,
          ),
          // description == ''
          //     ? Row(
          //         children: [
          //           Expanded(
          //               child: Text(removeHtmlTag(description),
          //                   overflow: TextOverflow.ellipsis,
          //                   maxLines: 2,
          //                   style: TextStyle(
          //                       fontSize: 9.w, color: Color(0xff6F7782)))),
          //           SizedBox(
          //             width: 15,
          //           ),
          //           commentLength > 0
          //               ? ClipRRect(
          //                   borderRadius: BorderRadius.circular(8.0),
          //                   child: Badge(
          //                     padding: EdgeInsets.symmetric(
          //                         vertical: 2, horizontal: 5),
          //                     shape: BadgeShape.square,
          //                     badgeContent: Text(
          //                       commentLength.toString(),
          //                       style:
          //                           TextStyle(fontSize: 9, color: Colors.white),
          //                     ),
          //                   ),
          //                 )
          //               : Container()
          //         ],
          //       )
          //     : SizedBox()
        ],
      ),
    );
  }
}
