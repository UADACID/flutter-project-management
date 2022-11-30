import 'package:cicle_mobile_f3/controllers/invite_people_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class BottomSheetInviteUser extends StatelessWidget {
  const BottomSheetInviteUser({
    Key? key,
  }) : super(key: key);

  onClose() {
    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    return GetX<InvitePeopleController>(
        init: InvitePeopleController(),
        builder: (state) {
          return Container(
            height: 260,
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
            child: Column(
              children: [
                SizedBox(
                  height: 5.w,
                ),
                Padding(
                  padding: EdgeInsets.only(left: 20.w),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Invite People',
                        style: TextStyle(
                            fontSize: 12.w, fontWeight: FontWeight.bold),
                      ),
                      IconButton(onPressed: onClose, icon: Icon(Icons.close))
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: Divider(),
                ),
                Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 20.w, vertical: 15.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Email Address',
                        style: TextStyle(
                            fontSize: 11.w, fontWeight: FontWeight.w600),
                      ),
                      SizedBox(
                        height: 10.w,
                      ),
                      TextField(
                        maxLines: 1,
                        style: TextStyle(fontSize: 12.w),
                        controller: state.emailEditingController,
                        decoration: InputDecoration(
                          isDense: true,
                          fillColor: Colors.white,
                          filled: true,
                          contentPadding: EdgeInsets.only(
                              left: 10, right: 10, top: 19.w, bottom: 19.w),
                          hintText: "type email address...",
                          hintStyle: TextStyle(
                              color: Color(0xffB5B5B5), fontSize: 12.w),
                          errorText: state.errorMessage == ''
                              ? null
                              : state.errorMessage,
                          enabledBorder: OutlineInputBorder(
                            borderRadius: new BorderRadius.circular(10.0),
                            borderSide: BorderSide(
                                color: Colors.black.withOpacity(0.1)),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: const BorderRadius.all(
                              const Radius.circular(10.0),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: Align(
                    alignment: Alignment.bottomRight,
                    child: ElevatedButton(
                        style: ButtonStyle(
                            padding:
                                MaterialStateProperty.all<EdgeInsetsGeometry>(
                                    EdgeInsets.zero),
                            shape: MaterialStateProperty.all<
                                RoundedRectangleBorder>(RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.h),
                            ))),
                        onPressed: () {
                          FocusScope.of(context).unfocus();
                          state.sendInvitation();
                        },
                        child: Container(
                            padding: EdgeInsets.symmetric(
                                vertical: 0.w, horizontal: 30),
                            child: Text(
                              'Send',
                              style: TextStyle(
                                  fontSize: 12.w,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white),
                            ))),
                  ),
                )
              ],
            ),
          );
        });
  }
}
