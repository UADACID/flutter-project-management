import 'package:cicle_mobile_f3/models/member_model.dart';

import 'package:cicle_mobile_f3/utils/helpers.dart';
import 'package:cicle_mobile_f3/widgets/avatar_custom.dart';
import 'package:flutter/material.dart';

class HorizontalListUser extends StatelessWidget {
  HorizontalListUser({
    Key? key,
    this.max = 5,
    this.members = const [],
    this.width = 15,
    this.margin = const EdgeInsets.only(right: 7),
    this.textStylePlus,
    this.textStyle,
  }) : super(key: key);
  final int max;
  final double width;
  final List<MemberModel> members;
  final EdgeInsetsGeometry? margin;
  final TextStyle? textStylePlus;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    bool _isReachLimit = members.length > max ? true : false;
    int _originalLength = members.length;

    if (_isReachLimit) {
      members.length = max;
    }

    int _hidden = _originalLength - members.length;

    if (members.length == 0) {
      return Container(
        height: width,
        width: width,
        color: Colors.transparent,
      );
    }

    return Container(
      height: width,
      child: Row(
        children: [
          ListView.builder(
              scrollDirection: Axis.horizontal,
              shrinkWrap: true,
              itemCount: members.length,
              itemBuilder: (ctx, index) {
                MemberModel memberModel = members[index];
                return Container(
                    margin: margin,
                    child: Stack(
                      children: [
                        AvatarCustom(
                            height: width,
                            child: Text(
                              getInitials(memberModel.fullName),
                              style:
                                  TextStyle(fontSize: 11, color: Colors.white)
                                      .merge(textStyle),
                            )),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(width),
                          child: Image.network(
                            getPhotoUrl(url: memberModel.photoUrl),
                            height: width,
                            width: width,
                            fit: BoxFit.cover,
                          ),
                        )
                      ],
                    ));
              }),
          _isReachLimit
              ? Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      height: width,
                      width: width,
                      decoration: BoxDecoration(
                          border: Border.all(width: 1, color: Colors.grey),
                          color: Colors.white,
                          shape: BoxShape.circle),
                    ),
                    Text(
                      '+$_hidden',
                      style: TextStyle(
                              fontSize: _hidden.toString().length < 2 ? 8 : 5,
                              color: Colors.grey)
                          .merge(textStylePlus),
                    )
                  ],
                )
              : SizedBox()
        ],
      ),
    );
  }
}
