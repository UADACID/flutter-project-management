import 'dart:ffi';

import 'package:cicle_mobile_f3/utils/helpers.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:simple_animations/simple_animations.dart';
import 'package:supercharged/supercharged.dart';

import '../controllers/invitation_controller.dart';
import '../utils/client.dart';
import '../widgets/animation_fade_and_slide.dart';

class InvitationScreen extends StatelessWidget {
  InvitationConteroller _invitationConteroller =
      Get.put(InvitationConteroller());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Invitation'),
      ),
      body: Obx(() {
        if (_invitationConteroller.isLoading) {
          return Container(
            width: double.infinity,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(
                  height: 30,
                ),
                Text('Please wait...'),
                SizedBox(
                  height: 15,
                ),
                Text('checking your invitation link')
              ],
            ),
          );
        }

        return _buildRedirectScreen(_invitationConteroller.message);
      }),
    );
  }

  // BELUM DI PAKE SAMPAI BISA BUKA APLIKASI DARI LINK
  Widget _buildRedirectScreen(String message) {
    return WillPopScope(
      onWillPop: () => Future.value(false),
      child: Container(
        child: Stack(
          fit: StackFit.expand,
          alignment: Alignment.center,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  'assets/images/logo_svg.svg',
                  semanticsLabel: 'logo',
                  width: 72,
                ),
                SizedBox(
                  height: 30,
                ),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xff0C2044)),
                ),
                SizedBox(
                  height: 35,
                ),
                Text(
                  'You will be redirected in a moment...',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: Color(0xff7A7A7A)),
                ),
              ],
            ),
            Positioned(
              bottom: 48,
              child: _buildFooterLogo(),
            )
          ],
        ),
      ),
    );
  }

  Row _buildFooterLogo() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SvgPicture.asset(
          'assets/images/logo_svg.svg',
          semanticsLabel: 'logo',
          width: 16,
        ),
        SizedBox(
          width: 3,
        ),
        SvgPicture.asset(
          'assets/images/cicle.svg',
          semanticsLabel: 'logo',
          width: 38,
          color: Color(0xffFDC532),
        ),
      ],
    );
  }
}
