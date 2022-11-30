import 'package:cached_network_image/cached_network_image.dart';
import 'package:cicle_mobile_f3/models/member_model.dart';
import 'package:cicle_mobile_f3/utils/helpers.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:random_color/random_color.dart';

class BottomSheetAddSubscriber extends StatefulWidget {
  BottomSheetAddSubscriber(
      {Key? key,
      required this.listAllProjectMembers,
      required this.listSelectedMembers,
      required this.onDone})
      : super(key: key);

  final List<MemberModel> listAllProjectMembers;
  final List<MemberModel> listSelectedMembers;
  final Function onDone;

  @override
  _BottomSheetAddSubscriberState createState() =>
      _BottomSheetAddSubscriberState();
}

class _BottomSheetAddSubscriberState extends State<BottomSheetAddSubscriber> {
  RandomColor _randomColor = RandomColor();
  List<MemberModel> _listSelectedMembers = [];
  bool _initialSelectAll = false;
  String _keyWords = '';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    for (var i = 0; i < widget.listSelectedMembers.length; i++) {
      _listSelectedMembers.add(widget.listSelectedMembers[i]);
    }
  }

  onDone() async {
    widget.onDone(_listSelectedMembers);
    if (MediaQuery.of(context).viewInsets.bottom != 0.0) {
      FocusScope.of(context).unfocus();
      await Future.delayed(Duration(milliseconds: 600));
    }

    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    List<MemberModel> _listFilterAllMember = widget.listAllProjectMembers
        .where((element) =>
            element.fullName.toLowerCase().contains(_keyWords.toLowerCase()))
        .toList();
    _listFilterAllMember.sort((a, b) => a.fullName.compareTo(b.fullName));
    return Container(
      height: 450,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
        color: Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Column(
                children: [
                  SizedBox(
                    height: 24,
                  ),
                  Align(
                      alignment: Alignment.topCenter,
                      child: Text(
                        'Who do you wanna be notified?',
                        style:
                            TextStyle(fontSize: 12, color: Color(0xff979797)),
                      )),
                  SizedBox(
                    height: 24,
                  ),
                ],
              ),
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  child: InkWell(
                    onTap: onDone,
                    child: Align(
                      alignment: Alignment.topRight,
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Text('done',
                            style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Color(0xff708FC7))),
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
                border: Border.symmetric(
                    horizontal: BorderSide(
                        color: Colors.grey.withOpacity(0.2), width: 1))),
            child: Padding(
              padding: const EdgeInsets.only(left: 30.0, bottom: 10, top: 10),
              child: Text(
                'Company Members',
                style: TextStyle(fontSize: 12, color: Color(0xff708FC7)),
              ),
            ),
          ),
          Container(
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 25),
              child: TextField(
                style: TextStyle(fontSize: 11),
                onChanged: (value) {
                  setState(() {
                    _keyWords = value;
                  });
                },
                decoration: InputDecoration(
                  isDense: true,
                  hintText: "Search Name",
                  hintStyle: TextStyle(color: Color(0xffB5B5B5), fontSize: 12),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: new BorderRadius.circular(20.0),
                    borderSide: BorderSide(color: Colors.grey.withOpacity(0.2)),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: const BorderRadius.all(
                      const Radius.circular(20.0),
                    ),
                  ),
                ),
              )),
          Container(
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.only(
                left: 30.0,
                right: 15,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Select All',
                      style:
                          TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                  StatefulBuilder(builder: (ctx, setLocalState) {
                    return Checkbox(
                      value: _initialSelectAll,
                      onChanged: (value) {
                        setLocalState(() => _initialSelectAll = value!);
                        if (value == true) {
                          setState(() {
                            for (var i = 0;
                                i < _listFilterAllMember.length;
                                i++) {
                              _listSelectedMembers.add(_listFilterAllMember[i]);
                            }
                          });
                        } else {
                          setState(() {
                            _listSelectedMembers.clear();
                          });
                        }
                      },
                      fillColor:
                          MaterialStateProperty.all<Color>(Color(0xff708FC7)),
                    );
                  })
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
                itemCount: _listFilterAllMember.length,
                itemBuilder: (ctx, index) {
                  Color _color = _randomColor.randomColor(
                      colorBrightness: ColorBrightness.light);
                  MemberModel member = _listFilterAllMember[index];
                  int isMemberIncludeOnMembers = _listSelectedMembers
                      .where((element) => element.sId == member.sId)
                      .length;
                  return Container(
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.only(
                        left: 30.0,
                        right: 15,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              member.photoUrl != ''
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(25),
                                      child: CachedNetworkImage(
                                        height: 25,
                                        width: 25,
                                        fit: BoxFit.cover,
                                        imageUrl:
                                            getPhotoUrl(url: member.photoUrl),
                                        placeholder: (context, url) =>
                                            CircularProgressIndicator(),
                                        errorWidget: (context, url, error) =>
                                            Center(child: Icon(Icons.error)),
                                      ),
                                    )
                                  : Container(
                                      height: 25,
                                      width: 25,
                                      decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: _color),
                                      child: Center(
                                        child: Text(
                                          getInitials(member.fullName),
                                          style: TextStyle(
                                              color: Colors.white, fontSize: 9),
                                        ),
                                      ),
                                    ),
                              SizedBox(
                                width: 12,
                              ),
                              Text(member.fullName,
                                  style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600)),
                            ],
                          ),
                          Checkbox(
                              value: isMemberIncludeOnMembers > 0,
                              fillColor: MaterialStateProperty.all<Color>(
                                  Color(0xff708FC7)),
                              onChanged: (value) {
                                setState(() {
                                  if (isMemberIncludeOnMembers == 0) {
                                    _listSelectedMembers.add(member);
                                  } else {
                                    _listSelectedMembers.removeWhere(
                                        (element) => element.sId == member.sId);
                                  }
                                });
                              })
                        ],
                      ),
                    ),
                  );
                }),
          )
        ],
      ),
    );
  }
}
