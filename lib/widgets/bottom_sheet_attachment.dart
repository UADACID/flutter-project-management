import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class BottomSheetAttachment extends StatelessWidget {
  const BottomSheetAttachment({
    Key? key,
    required this.onPressDoc,
    required this.onPressCamera,
    required this.onPressgallery,
  }) : super(key: key);
  final Function onPressDoc;
  final Function onPressCamera;
  final Function onPressgallery;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 150.w,
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20.w), topRight: Radius.circular(20.w))),
      child: Column(
        children: [
          _buildItem(
              'Document & Video', Icons.description_outlined, onPressDoc),
          _buildItem(
              'Image from Camera', Icons.camera_alt_outlined, onPressCamera),
          _buildItem(
              'Image from Gallery', Icons.image_outlined, onPressgallery),
        ],
      ),
    );
  }

  Widget _buildItem(String title, IconData icon, Function onPress) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 25),
      child: Column(
        children: [
          SizedBox(
            height: 50,
            child: ListTile(
              onTap: () => onPress(),
              contentPadding: EdgeInsets.zero,
              leading: Icon(
                icon,
                color: Color(0xff708FC7),
              ),
              title: Text(
                title,
                style: TextStyle(fontSize: 12.w, color: Color(0xff708FC7)),
              ),
            ),
          ),
          SizedBox(height: 1, child: Divider())
        ],
      ),
    );
  }
}
