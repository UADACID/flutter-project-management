import 'package:cicle_mobile_f3/controllers/form_create_chat_controller.dart';
import 'package:cicle_mobile_f3/controllers/private_chat_controller.dart';
import 'package:cicle_mobile_f3/controllers/search_controller.dart';
import 'package:cicle_mobile_f3/models/member_model.dart';
import 'package:cicle_mobile_f3/utils/constant.dart';
import 'package:cicle_mobile_f3/utils/helpers.dart';
import 'package:cicle_mobile_f3/widgets/avatar_custom.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:get/get.dart';
import 'package:simple_animations/simple_animations.dart';

class FormCreateNewChat extends StatelessWidget {
  FormCreateNewChat({
    Key? key,
  }) : super(key: key);

  PrivateChatController _privateChatController =
      Get.put(PrivateChatController());

  String companyId = Get.parameters['companyId'] ?? '';

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Get.back();
      },
      child: GetX(
          init: FormCreateChatController(),
          builder: (FormCreateChatController state) {
            return Scaffold(
                backgroundColor: Colors.transparent,
                body: Center(
                  child: Container(
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15.w)),
                    margin: EdgeInsets.symmetric(horizontal: 20.w),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          height: 15,
                        ),
                        Align(
                            alignment: Alignment.centerLeft,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 15.0),
                              child: Text(
                                'Company Members',
                                style: TextStyle(
                                    fontSize: 14.w,
                                    fontWeight: FontWeight.w600),
                              ),
                            )),
                        SizedBox(
                          height: 15,
                        ),
                        _buildSearchInput(state),
                        SizedBox(
                          height: 10,
                        ),
                        Container(
                          height: 1,
                          color: Colors.grey.withOpacity(0.1),
                        ),
                        _buildList(state),
                        SizedBox(
                          height: 20.w,
                        )
                      ],
                    ),
                  ),
                ),
                floatingActionButton: FloatingActionButton(
                  onPressed: () {
                    Get.back();
                  },
                  child: Icon(
                    Icons.close,
                    color: Colors.white,
                  ),
                ));
          }),
    );
  }

  Container _buildList(FormCreateChatController state) {
    List<MemberModel> _filterBySearchKey = state.companyMembers
        .where((element) => element.fullName
            .toLowerCase()
            .contains(state.searchKey.toLowerCase()))
        .toList();
    if (_filterBySearchKey.length == 0) {
      return Container(
        height: 300.w,
        child: Center(
            child: Text(
          'member not found',
          style: TextStyle(fontSize: 11.w, color: Colors.grey.withOpacity(0.5)),
        )),
      );
    }
    return Container(
      height: 300.w,
      color: Color(0xffFAFAFA),
      child: ListView.builder(
          itemCount: _filterBySearchKey.length,
          padding: EdgeInsets.only(top: 10),
          itemBuilder: (ctx, index) {
            String name = _filterBySearchKey[index].fullName;
            MemberModel member = _filterBySearchKey[index];
            return _buildItem(member);
          }),
    );
  }

  Widget _buildItem(MemberModel member) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 2.5),
      decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 0.5,
              offset: Offset(0, 0), // changes position of shadow
            ),
          ],
          borderRadius: BorderRadius.circular(10.w)),
      child: ListTile(
        onTap: () async {
          String? teamId = Get.parameters['teamId'];

          Get.back();
          await Future.delayed(Duration(milliseconds: 300));
          try {
            String chatId =
                await _privateChatController.createNewChat(member.sId);

            // handle for history viewed
            String path =
                '${RouteName.privateChatDetailScreen(companyId, chatId)}?teamId=$teamId';
            Get.put(SearchController()).insertListRecenlyViewed(RecentlyViewed(
                moduleName: 'private-chat-detail',
                companyId: companyId,
                path: path,
                teamName: ' ',
                title: member.fullName,
                subtitle: 'Home  >  Menu  >  Inbox  >  ${member.fullName}',
                uniqId: chatId));
            Get.toNamed(path);
          } catch (e) {
            print(e);
            errorMessageMiddleware(e);
          }
        },
        leading: AvatarCustom(
            height: 29.w,
            child: Image.network(
              getPhotoUrl(url: member.photoUrl),
              height: 29.w,
              width: 29.w,
              fit: BoxFit.cover,
            )),
        title: Text(
          member.fullName,
          style: TextStyle(fontSize: 12.w),
        ),
      ),
    );
  }

  Container _buildSearchInput(FormCreateChatController state) {
    return Container(
        padding: EdgeInsets.symmetric(horizontal: 10),
        child: TextField(
          controller: state.textEditingControllerSearchKey,
          style: TextStyle(fontSize: 11.w),
          onChanged: (value) {
            state.searchKey = value;
          },
          decoration: InputDecoration(
              isDense: true,
              contentPadding: EdgeInsets.fromLTRB(15, 15, 10, 15),
              hintText: "Search Name",
              hintStyle: TextStyle(color: Color(0xffB5B5B5), fontSize: 11),
              enabledBorder: OutlineInputBorder(
                borderRadius: new BorderRadius.circular(10.0),
                borderSide: BorderSide(color: Colors.grey.withOpacity(0.2)),
              ),
              border: OutlineInputBorder(
                borderRadius: const BorderRadius.all(
                  const Radius.circular(10.0),
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
              suffixIcon: state.searchKey == ''
                  ? Icon(
                      Icons.close,
                      color: Colors.transparent,
                    )
                  : GestureDetector(
                      onTap: () {
                        state.searchKey = '';
                        state.textEditingControllerSearchKey.text = '';
                      },
                      child: Icon(Icons.close))),
        ));
  }
}
