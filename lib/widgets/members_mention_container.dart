import 'package:cicle_mobile_f3/models/member_model.dart';
import 'package:cicle_mobile_f3/utils/helpers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'avatar_custom.dart';

class ListMemberForMention extends StatelessWidget {
  const ListMemberForMention({
    Key? key,
    this.list = const [],
    required this.onSelect,
    required this.onMentionAll,
    this.showMentionAll = true,
  }) : super(key: key);

  final List<MemberModel> list;
  final Function(MemberModel member) onSelect;
  final Function(List<MemberModel> members) onMentionAll;
  final bool showMentionAll;

  _onMentionAll() {
    onMentionAll(list);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxHeight: 175.w, minHeight: 0),
      color: Colors.white,
      child: list.length == 0
          ? Container(
              width: double.infinity,
              padding: EdgeInsets.all(10),
              child: Center(
                  child: Text(
                "members not found,\ncan't mention user",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12.w, color: Colors.grey),
              )))
          : Container(
              child: Column(
                children: [
                  showMentionAll
                      ? Align(
                          alignment: Alignment.topRight,
                          child: InkWell(
                            onTap: _onMentionAll,
                            child: Container(
                              color: Colors.white,
                              padding: const EdgeInsets.all(8.0),
                              child: Text('mention all',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xffFDC532))),
                            ),
                          ),
                        )
                      : SizedBox(),
                  Expanded(
                    child: ListView.builder(
                        itemCount: list.length,
                        itemBuilder: (ctx, index) {
                          MemberModel member = list[index];
                          return GestureDetector(
                            onTap: () {
                              onSelect(member);
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 7.5),
                              color: Colors.white,
                              margin: EdgeInsets.all(0.5),
                              child: Row(
                                children: [
                                  AvatarCustom(
                                      height: 24,
                                      child: Image.network(
                                        getPhotoUrl(url: member.photoUrl),
                                        height: 24,
                                        width: 24,
                                        fit: BoxFit.cover,
                                      )),
                                  SizedBox(
                                    width: 40.w,
                                  ),
                                  Text(
                                    member.fullName,
                                    style: TextStyle(fontSize: 11.w),
                                  )
                                ],
                              ),
                            ),
                          );
                        }),
                  ),
                ],
              ),
            ),
    );
  }
}
