import 'package:cached_network_image/cached_network_image.dart';
import 'package:cicle_mobile_f3/models/member_model.dart';
import 'package:cicle_mobile_f3/utils/helpers.dart';
import 'package:flutter/material.dart';
import 'package:random_color/random_color.dart';

class HorizontalListAvatar extends StatelessWidget {
  const HorizontalListAvatar({
    Key? key,
    required this.members,
    required this.height,
  }) : super(key: key);

  final List<MemberModel> members;
  final double height;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemCount: members.length,
        scrollDirection: Axis.horizontal,
        itemBuilder: (ctx, index) {
          RandomColor _randomColor = RandomColor();
          Color _color =
              _randomColor.randomColor(colorBrightness: ColorBrightness.light);
          MemberModel member = members[index];
          return Container(
            margin: EdgeInsets.only(right: 4),
            child: member.photoUrl != ''
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(height),
                    child: Container(
                      height: height,
                      width: height,
                      child: CachedNetworkImage(
                        height: height,
                        width: height,
                        fit: BoxFit.cover,
                        imageUrl: getPhotoUrl(url: member.photoUrl),
                        placeholder: (context, url) =>
                            CircularProgressIndicator(),
                        errorWidget: (context, url, error) =>
                            Center(child: Icon(Icons.error)),
                      ),
                    ),
                  )
                : Container(
                    height: height,
                    width: height,
                    margin: EdgeInsets.only(right: 4),
                    decoration:
                        BoxDecoration(shape: BoxShape.circle, color: _color),
                    child: Center(
                      child: Text(
                        getInitials(member.fullName),
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ),
                  ),
          );
        });
  }
}
