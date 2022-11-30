import 'package:cicle_mobile_f3/widgets/button_default.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ErrorSomethingWrong extends StatelessWidget {
  const ErrorSomethingWrong(
      {Key? key, required this.refresh, this.message, this.isLoading = false})
      : super(key: key);
  final Function refresh;
  final String? message;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Column(
      children: [
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset('assets/images/sad.svg',
                  semanticsLabel: 'logo', height: 82.w, width: 82.w),
              SizedBox(
                height: 45.w,
              ),
              Container(
                width: 160.w,
                child: Text(
                  message ?? 'error something went wrong',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14.sp, color: Color(0xff7a7a7a)),
                ),
              ),
            ],
          ),
        ),
        ButtonDefault(
          onPress: isLoading ? () {} : refresh,
          child: Text(
            'Try Again',
            style: TextStyle(
                fontSize: 13.w,
                color: Colors.white,
                fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(
          height: 56.w,
        )
      ],
    ));
  }
}
