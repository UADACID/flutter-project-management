import 'package:cicle_mobile_f3/models/cheer_item_model.dart';
import 'package:cicle_mobile_f3/utils/helpers.dart';
import 'package:cicle_mobile_f3/widgets/avatar_custom.dart';
import 'package:faker/faker.dart';
import 'package:flutter/material.dart';

class CheerItem extends StatelessWidget {
  CheerItem({
    Key? key,
    required this.item,
    this.bgColor = const Color(0xffFAFAFA),
    this.borderColor = const Color(0xffFAFAFA),
    this.height = 28,
    this.fontSize = 12,
  }) : super(key: key);
  final CheerItemModel item;
  final Color bgColor;
  final Color borderColor;
  final double height;
  final double fontSize;

  final faker = Faker(provider: FakerDataProvider());

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(right: 5, bottom: 5),
      padding: EdgeInsets.all(2),
      decoration: BoxDecoration(
          border: Border.all(color: borderColor, width: 1),
          color: bgColor,
          borderRadius: BorderRadius.circular(28)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AvatarCustom(
            height: height,
            child: Image.network(
              getPhotoUrl(url: item.creator.photoUrl),
              height: height,
              width: height,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 13, right: 8),
            child: Text(item.content,
                style: TextStyle(
                    fontSize: fontSize,
                    fontWeight: FontWeight.normal,
                    color: Color(0xff393E46))),
          ),
        ],
      ),
    );
  }
}
