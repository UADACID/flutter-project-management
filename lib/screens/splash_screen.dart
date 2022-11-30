import 'package:cicle_mobile_f3/controllers/splash_controller.dart';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

class SplashScreen extends GetWidget<SplashController> {
  @override
  Widget build(BuildContext context) {
    final String logo = 'assets/images/logo_svg.svg';
    return Scaffold(
      body: Center(
        child: Hero(
          tag: 'firs_logo',
          child: Container(
            height: 98,
            width: 98,
            child: SvgPicture.asset(logo, semanticsLabel: 'Acme Logo'),
          ),
        ),
      ),
    );
  }
}

class SplashEndScreen extends StatelessWidget {
  const SplashEndScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String logo = 'assets/images/logo_svg.svg';
    final String textLogo = 'assets/images/cicle.svg';
    return Scaffold(
      body: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Hero(
              tag: 'firs_logo',
              child: Container(
                height: 49,
                width: 49,
                child: SvgPicture.asset(logo, semanticsLabel: 'logo'),
              ),
            ),
            SizedBox(
              width: 10,
            ),
            Container(
              height: 44,
              width: 117,
              margin: EdgeInsets.only(bottom: 5),
              child: SvgPicture.asset(textLogo, semanticsLabel: 'text-logo'),
            )
          ],
        ),
      ),
    );
  }
}
