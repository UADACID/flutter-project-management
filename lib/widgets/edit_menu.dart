import 'package:cicle_mobile_f3/controllers/menu_controller.dart';
import 'package:cicle_mobile_f3/models/edit_menu_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class EditMenu extends StatefulWidget {
  EditMenu({
    Key? key,
    required this.onSave,
  }) : super(key: key);

  final Function onSave;

  @override
  _EditMenuState createState() => _EditMenuState();
}

class _EditMenuState extends State<EditMenu> {
  MenuController _menuController = Get.find();

  List<MenuModel> _tempList = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setState(() {
      _tempList = [..._menuController.listMenu];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(right: 23.w, left: 30.w),
      child: Column(
        children: [
          SizedBox(
            height: 25.w,
          ),
          ..._tempList
              .asMap()
              .map((key, value) {
                MenuModel menu = value;
                return MapEntry(
                    key,
                    _buildItem(
                        title: menu.title,
                        value: menu.isActive,
                        onChange: (bool value) {
                          setState(() {
                            _tempList[key].isActive = value;
                          });
                        }));
              })
              .values
              .toList(),
          SizedBox(
            height: 45.w,
          ),
          _buildButtonSave()
        ],
      ),
    );
  }

  Align _buildButtonSave() {
    return Align(
      alignment: Alignment.bottomRight,
      child: ElevatedButton(
          style: ButtonStyle(
              padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                  EdgeInsets.zero),
              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.h),
              ))),
          onPressed: () {
            _menuController.setListMenu(_tempList);

            widget.onSave();
          },
          child: Container(
              padding: EdgeInsets.symmetric(vertical: 0.w, horizontal: 30),
              child: Text(
                'Save',
                style: TextStyle(
                    fontSize: 12.w,
                    fontWeight: FontWeight.w600,
                    color: Colors.white),
              ))),
    );
  }

  Container _buildItem(
      {String title = '', bool value = false, required Function onChange}) {
    return Container(
      height: 35.w,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
                fontSize: 14.w,
                fontWeight: FontWeight.bold,
                color: Theme.of(Get.context!).primaryColor),
          ),
          Switch(
            value: value,
            onChanged: (bool value) {
              onChange(value);
            },
            activeColor: Theme.of(Get.context!).primaryColor,
          )
        ],
      ),
    );
  }
}
