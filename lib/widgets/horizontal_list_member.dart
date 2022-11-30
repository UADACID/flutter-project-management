import 'package:cached_network_image/cached_network_image.dart';
import 'package:cicle_mobile_f3/models/member_model.dart';
import 'package:cicle_mobile_f3/utils/helpers.dart';
import 'package:flutter/material.dart';
import 'package:random_color/random_color.dart';

class HorizontalListMember extends StatelessWidget {
  HorizontalListMember({
    Key? key,
    this.members = const [],
    this.height = 33.51,
    this.marginItem = const EdgeInsets.only(right: 7),
    this.fontSize = 14,
  }) : super(key: key);

  final double height;
  final List<MemberModel> members;
  final EdgeInsetsGeometry marginItem;
  final double fontSize;
  RandomColor _randomColor = RandomColor();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: members.length,
          itemBuilder: (ctx, index) {
            MemberModel member = members[index];
            Color _color = _randomColor.randomColor(
                colorBrightness: ColorBrightness.light);
            return Container(
              margin: marginItem,
              height: height,
              width: height,
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.3),
                shape: BoxShape.circle,
                border: Border.all(
                    color: Colors.black.withOpacity(0.05), width: 0.5),
              ),
              child: member.photoUrl != ''
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(height),
                      child: CachedNetworkImage(
                        fit: BoxFit.cover,
                        imageUrl: getPhotoUrl(url: member.photoUrl),
                        placeholder: (context, url) =>
                            CircularProgressIndicator(),
                        errorWidget: (context, url, error) =>
                            Center(child: Icon(Icons.error)),
                      ),
                    )
                  : Container(
                      decoration:
                          BoxDecoration(shape: BoxShape.circle, color: _color),
                      child: Center(
                        child: Text(
                          getInitials(member.fullName),
                          style: TextStyle(
                              color: Colors.white, fontSize: fontSize),
                        ),
                      ),
                    ),
            );
          }),
    );
  }
}
