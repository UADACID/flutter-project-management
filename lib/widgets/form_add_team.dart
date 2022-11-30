import 'package:cicle_mobile_f3/utils/helpers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'animation_fade_and_slide.dart';

class FormAddTeam extends StatelessWidget {
  FormAddTeam({
    Key? key,
    required this.type,
    this.onSave,
  }) : super(key: key);
  final String type;
  final Function(String name, String description)? onSave;
  TextEditingController _textEditingControllerName = TextEditingController();
  TextEditingController _textEditingControllerDescription =
      TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20),
      child: Center(
          child: Material(
        color: Colors.transparent,
        child: AnimationFadeAndSlide(
          delay: Duration(milliseconds: 50),
          duration: Duration(milliseconds: 100),
          child: Container(
              margin: MediaQuery.of(context).viewInsets,
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10.w)),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 20.0),
                        child: Text(
                          'Create $type',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      IconButton(
                          onPressed: () {
                            Get.back();
                          },
                          icon: Icon(Icons.close))
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Divider(),
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: _buildFieldName(),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: _buildFieldDescription(),
                  ),
                  SizedBox(
                    height: 40,
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
                                      RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.h),
                              ))),
                          onPressed: () {
                            String textName = _textEditingControllerName.text;
                            String desc =
                                _textEditingControllerDescription.text;

                            if (textName != '' && desc != '') {
                              FocusScope.of(context).unfocus();
                              onSave!(textName, desc);
                            } else {
                              showAlert(
                                  message:
                                      'Name and description fields must be filled');
                            }
                          },
                          child: Container(
                              padding: EdgeInsets.symmetric(
                                  vertical: 0.w, horizontal: 30),
                              child: Text(
                                'Create',
                                style: TextStyle(
                                    fontSize: 12.w,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white),
                              ))),
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                ],
              )),
        ),
      )),
    );
  }

  Column _buildFieldName() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$type Name',
          style: TextStyle(fontSize: 12.w),
        ),
        SizedBox(
          height: 10,
        ),
        TextField(
          maxLines: 1,
          style: TextStyle(fontSize: 12.w),
          controller: _textEditingControllerName,
          decoration: InputDecoration(
            isDense: true,
            fillColor: Colors.white,
            filled: true,
            contentPadding: EdgeInsets.only(
                left: 19.w, right: 19.w, top: 19.w, bottom: 19.w),
            hintText: "type name...",
            hintStyle: TextStyle(color: Color(0xffB5B5B5), fontSize: 12.w),
            enabledBorder: OutlineInputBorder(
              borderRadius: new BorderRadius.circular(10.0),
              borderSide: BorderSide(color: Colors.black.withOpacity(0.1)),
            ),
            border: OutlineInputBorder(
              borderRadius: const BorderRadius.all(
                const Radius.circular(10.0),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Column _buildFieldDescription() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$type Description',
          style: TextStyle(fontSize: 12.w),
        ),
        SizedBox(
          height: 10,
        ),
        TextField(
          maxLines: 4,
          style: TextStyle(fontSize: 12.w),
          controller: _textEditingControllerDescription,
          decoration: InputDecoration(
            isDense: true,
            fillColor: Colors.white,
            filled: true,
            contentPadding:
                EdgeInsets.only(left: 19, right: 19, top: 19.w, bottom: 19.w),
            hintText: "type description...",
            hintStyle: TextStyle(color: Color(0xffB5B5B5), fontSize: 12.w),
            enabledBorder: OutlineInputBorder(
              borderRadius: new BorderRadius.circular(10.0),
              borderSide: BorderSide(color: Colors.black.withOpacity(0.1)),
            ),
            border: OutlineInputBorder(
              borderRadius: const BorderRadius.all(
                const Radius.circular(10.0),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
