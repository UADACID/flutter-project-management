import 'package:cached_network_image/cached_network_image.dart';
import 'package:cicle_mobile_f3/models/member_model.dart';
import 'package:cicle_mobile_f3/utils/helpers.dart';
import 'package:cicle_mobile_f3/widgets/avatar_custom.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:random_color/random_color.dart';
import 'package:simple_animations/simple_animations.dart';
import 'package:supercharged/supercharged.dart';

class HorizontalListAvatarWithMore extends StatelessWidget {
  HorizontalListAvatarWithMore({
    Key? key,
    this.members = const [],
    this.onPressAdd,
    this.numberDisplayed = 0,
    this.heightItem = 25,
    this.showButtonAdd = true,
    this.counterTextStyle,
  }) : super(key: key);

  final List<MemberModel> members;
  final Function? onPressAdd;
  final int numberDisplayed;
  final double heightItem;
  final bool showButtonAdd;
  final TextStyle? counterTextStyle;

  RandomColor _randomColor = RandomColor();

  @override
  Widget build(BuildContext context) {
    List<MemberModel> _tempList = [];
    for (var i = 0; i < members.length; i++) {
      if (i < numberDisplayed) {
        _tempList.add(members[i]);
      }
    }

    int selisish = (members.length - numberDisplayed);
    String _moreCounterText = selisish.toString();

    bool _showMore = selisish > 0 && selisish != 0;
    return Container(
      child: Row(
        children: [
          showButtonAdd
              ? Row(
                  children: [
                    SizedBox(
                      width: 14.w,
                    ),
                    GestureDetector(
                      onTap: () => onPressAdd!(),
                      child: Container(
                        height: heightItem,
                        width: heightItem,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xff708FC7),
                        ),
                        child: Icon(
                          Icons.add,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 4.w,
                    ),
                  ],
                )
              : SizedBox(
                  width: 14,
                ),
          Expanded(
              child: SingleChildScrollView(
            physics: ClampingScrollPhysics(),
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                ...List.generate(
                  _tempList.length,
                  (index) => _buildItem(index),
                ),
                _showMore ? _buildMore(_moreCounterText) : SizedBox(),
              ],
            ),
          ))
        ],
      ),
    );
  }

  Widget _buildMore(String _moreCounterText) {
    int index = numberDisplayed - 1;
    int firstDelay = 0;
    int eachDelay = firstDelay + (index * 250);
    return PlayAnimation<double>(
        tween: (17.5).tweenTo(0.0), // define tween
        delay: Duration(milliseconds: eachDelay), // define duration
        duration: Duration(milliseconds: index * 50),
        builder: (context, child, value) {
          return Transform.translate(
            offset: Offset(value, 0),
            child: Container(
              margin: EdgeInsets.only(right: 15),
              height: heightItem,
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  border: Border.all(color: Color(0xffD6D6D6))),
              width: heightItem,
              child: Center(
                  child: Text(
                '+$_moreCounterText',
                style: TextStyle(fontSize: 10.5).merge(counterTextStyle),
              )),
            ),
          );
        });
  }

  PlayAnimation _buildItem(int index) {
    Color color =
        _randomColor.randomColor(colorBrightness: ColorBrightness.light);
    int firstDelay = 0;
    int eachDelay = firstDelay + (index * 150);
    return PlayAnimation<double>(
        tween: (17.5).tweenTo(0.0), // define tween
        delay: Duration(milliseconds: eachDelay), // define duration
        duration: Duration(milliseconds: index * 50),
        builder: (context, child, value) {
          return Transform.translate(
            offset: Offset(value, 0),
            child: Container(
              margin: EdgeInsets.only(right: 4.w),
              child: PlayAnimation<double>(
                  tween: (0.0).tweenTo(1.0), // define tween
                  delay: Duration(milliseconds: eachDelay), // define duration
                  duration: Duration(milliseconds: index * 80),
                  builder: (context, child, opacityValue) {
                    return Opacity(
                      opacity: opacityValue,
                      child: Stack(
                        children: [
                          members[index].photoUrl == null ||
                                  members[index].photoUrl == ''
                              ? AvatarCustom(
                                  color: color,
                                  child: Text(
                                    getInitials(members[index].fullName),
                                    style: TextStyle(
                                        fontSize: 11, color: Colors.white),
                                  ),
                                  height: heightItem,
                                )
                              : ClipRRect(
                                  borderRadius:
                                      BorderRadius.circular(heightItem),
                                  child: CachedNetworkImage(
                                    height: heightItem,
                                    width: heightItem,
                                    fit: BoxFit.cover,
                                    imageUrl: getPhotoUrl(
                                        url: members[index].photoUrl),
                                    placeholder: (context, url) =>
                                        // CircularProgressIndicator(),
                                        Container(
                                      color: color,
                                    ),
                                    errorWidget: (context, url, error) =>
                                        Center(
                                            child: Icon(
                                                Icons.account_circle_sharp)),
                                  ),
                                )
                        ],
                      ),
                    );
                  }),
            ),
          );
        });
  }
}
