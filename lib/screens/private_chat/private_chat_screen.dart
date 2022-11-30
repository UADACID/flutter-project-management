import 'package:cicle_mobile_f3/controllers/private_chat_controller.dart';
import 'package:cicle_mobile_f3/models/member_model.dart';

import 'package:cicle_mobile_f3/utils/my_flutter_app_icons.dart';
import 'package:cicle_mobile_f3/widgets/animation_fade_and_slide.dart';

import 'package:faker/faker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:simple_animations/simple_animations.dart';
import 'package:supercharged/supercharged.dart';

import 'chat_item.dart';
import 'form_create_chat.dart';

class PrivateChatScreen extends StatelessWidget {
  PrivateChatController _privateChatController = Get.find();

  final fakerFa = Faker(provider: FakerDataProvider());

  void onAdd() {
    Get.dialog(FormCreateNewChat());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Inbox'),
      ),
      body: Column(
        children: [
          Obx(() {
            if (_privateChatController.isLoading &&
                _privateChatController.listRecentMessage.length == 0) {
              return Expanded(
                  child: Center(child: CircularProgressIndicator()));
            }
            if (!_privateChatController.isLoading &&
                _privateChatController.listRecentMessage.length == 0) {
              return _buildEmpty();
            }
            return _buildHasData();
          })
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          onAdd();
        },
        child: Icon(
          MyFlutterApp.add_comment_black_24dp_1,
          color: Colors.white,
        ),
      ),
    );
  }

  Expanded _buildEmpty(
      {String message = 'There is no recent chat,\nstart chatting!'}) {
    return Expanded(
      child: Container(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              PlayAnimation<double>(
                tween: (0.0).tweenTo(1.0),
                delay: 150.milliseconds,
                duration: 250.milliseconds,
                curve: Curves.fastOutSlowIn,
                builder: (context, child, value) {
                  return Transform.scale(
                    scale: value,
                    child: SvgPicture.asset(
                      'assets/images/Group_chat_empty.svg',
                      semanticsLabel: 'Acme Logo',
                      height: 122.w,
                      width: 156.w,
                      fit: BoxFit.contain,
                    ),
                  );
                },
              ),
              SizedBox(
                height: 42.w,
              ),
              AnimationFadeAndSlide(
                delay: 250.milliseconds,
                duration: 250.milliseconds,
                child: Align(
                  alignment: Alignment.center,
                  child: Text(
                    'Chats',
                    style: TextStyle(
                        fontSize: 24.w,
                        color: Color(0xffb5b5b5),
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              SizedBox(
                height: 0.w,
              ),
              AnimationFadeAndSlide(
                delay: 350.milliseconds,
                duration: 250.milliseconds,
                child: Align(
                  alignment: Alignment.center,
                  child: Text(
                    message,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 12.w,
                        color: Color(0xffb5b5b5),
                        fontWeight: FontWeight.normal),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Expanded _buildHasData() {
    return Expanded(
      child: Column(
        children: [
          _buildSearchInput(),
          Container(
            height: 1,
            color: Colors.grey.withOpacity(0.1),
          ),
          Expanded(child: _buildList())
        ],
      ),
    );
  }

  Obx _buildList() {
    return Obx(() {
      String _searchKey = _privateChatController.searchKey;
      List<DummyChatItemModel> _filterBySearch =
          _privateChatController.listRecentMessage.where((element) {
        List<MemberModel> membersFilterByNotLogedInUserId = element.members
            .where((e) => e.sId != _privateChatController.logedInUserId)
            .toList();

        if (membersFilterByNotLogedInUserId.isNotEmpty) {
          return membersFilterByNotLogedInUserId[0]
              .fullName
              .toLowerCase()
              .contains(_searchKey.toLowerCase());
        }
        return false;
      }).toList();

      if (_filterBySearch.length == 0) {
        return Column(
          children: [
            _buildEmpty(
                message: 'There is no recent chat\nfrom $_searchKey...'),
          ],
        );
      }
      return ListView.builder(
          padding: EdgeInsets.only(top: 5.w),
          itemCount: _filterBySearch.length,
          itemBuilder: (ctx, index) {
            DummyChatItemModel item = _filterBySearch[index];
            if (item.lastMessage.sId == "") {
              // handle empty message or first created chat
              return SizedBox();
            }
            return ChatItem(item: item);
          });
    });
  }

  Container _buildSearchInput() {
    return Container(
        color: Colors.white,
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10.w),
        child: TextField(
          controller: _privateChatController.textEditingControllerSearch,
          style: TextStyle(fontSize: 12.w),
          onChanged: (value) {
            _privateChatController.searchKey = value;
          },
          decoration: InputDecoration(
              isDense: true,
              fillColor: Colors.white,
              filled: true,
              contentPadding: EdgeInsets.fromLTRB(15, 15, 10, 15),
              hintText: "Search Name",
              hintStyle: TextStyle(color: Color(0xffB5B5B5), fontSize: 11),
              enabledBorder: OutlineInputBorder(
                borderRadius: new BorderRadius.circular(10.w),
                borderSide: BorderSide(color: Colors.grey.withOpacity(0.2)),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(10.w),
                ),
              ),
              prefixIconConstraints:
                  BoxConstraints(maxHeight: 20, minWidth: 40),
              suffixIconConstraints:
                  BoxConstraints(maxHeight: 20, minWidth: 40),
              prefixIcon: Icon(
                Icons.search,
                color: Color(0xffFDC532),
              ),
              suffixIcon: Obx(() => _privateChatController.searchKey == ''
                  ? Icon(
                      Icons.close,
                      color: Colors.transparent,
                    )
                  : GestureDetector(
                      onTap: () {
                        _privateChatController.searchKey = '';
                        _privateChatController
                            .textEditingControllerSearch.text = '';
                      },
                      child: Icon(Icons.close)))),
        ));
  }
}
