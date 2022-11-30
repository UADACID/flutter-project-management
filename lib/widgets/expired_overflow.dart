import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../utils/client.dart';

class ExpiredOverFlow extends StatelessWidget {
  const ExpiredOverFlow({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 30.w),
      child: Center(
          child: Text(
        'Company is not active.\nPlease contact our Customer Service',
        textAlign: TextAlign.center,
        style: TextStyle(
            fontSize: 14.w,
            fontWeight: FontWeight.bold,
            color: Colors.grey.withOpacity(0.5)),
      )),
    );
  }
}
