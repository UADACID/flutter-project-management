import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CheckInFormDayItem extends StatelessWidget {
  const CheckInFormDayItem({
    Key? key,
    this.isSelected = false,
    this.title = '',
    required this.onPress,
  }) : super(key: key);
  final bool isSelected;
  final String title;
  final GestureTapCallback onPress;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(right: 2.w, bottom: 4.w, left: 2.w),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(3.0),
        child: Material(
          color:
              isSelected ? Theme.of(context).primaryColor : Colors.transparent,
          child: InkWell(
            onTap: onPress,
            child: Container(
              height: 36.w,
              width: 65.w,
              decoration: BoxDecoration(
                  border: Border.all(
                      color: Theme.of(context).primaryColor, width: 1),
                  borderRadius: BorderRadius.circular(3)),
              child: Center(
                child: Text(
                  title,
                  style: TextStyle(fontSize: 11.sp),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
