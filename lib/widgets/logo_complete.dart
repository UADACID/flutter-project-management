import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

class LogoComplete extends StatelessWidget {
  const LogoComplete({
    Key? key,
    this.mainAxisAlignment = MainAxisAlignment.center,
    required this.size,
  }) : super(key: key);

  final MainAxisAlignment mainAxisAlignment;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: mainAxisAlignment,
      children: [
        SvgPicture.asset(
          'assets/images/logo_svg.svg',
          semanticsLabel: 'Cicle Logo',
          height: size,
        ),
        SizedBox(
          width: 7.w,
        ),
        Container(
          margin: EdgeInsets.only(bottom: 5.w),
          child: SvgPicture.asset(
            'assets/images/cicle.svg',
            semanticsLabel: 'Text Logo',
            height: size,
          ),
        )
      ],
    );
  }
}
