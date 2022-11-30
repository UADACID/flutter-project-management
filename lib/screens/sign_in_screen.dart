import 'dart:io';

import 'package:cicle_mobile_f3/controllers/auth_controller.dart';

import 'package:cicle_mobile_f3/utils/helpers.dart';
import 'package:cicle_mobile_f3/widgets/animation_fade_and_slide.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:simple_animations/simple_animations.dart';
import 'package:supercharged/supercharged.dart';

class SignInScreen extends StatelessWidget {
  SignInScreen({Key? key}) : super(key: key);
  final box = GetStorage();
  String? signInFrom = Get.parameters['sign-in-from'];
  String? redirect = Get.parameters['redirect'];

  AuthController _authController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _buildForm(),
    );
  }

  Container _buildForm() {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            height: 110.h,
          ),
          AnimationFadeAndSlide(
            delay: 300.milliseconds,
            duration: 250.milliseconds,
            child: signInFrom == null
                ? _buildTitle()
                : _buildTitleSignInFromLink(),
          ),
          SizedBox(
            height: 17.h,
          ),
          AnimationFadeAndSlide(
            delay: 500.milliseconds,
            duration: 250.milliseconds,
            child: signInFrom == null
                ? _buildSubtitle()
                : _buildSubtitleSignInFromLink(),
          ),
          SizedBox(
            height: signInFrom == null ? 86.w : 45.w,
          ),
          AnimationFadeAndSlide(
            delay: 700.milliseconds,
            duration: 150.milliseconds,
            child: _buildButtonGoogle(),
          ),
          SizedBox(
            height: 17.w,
          ),
          AnimationFadeAndSlide(
            delay: 800.milliseconds,
            duration: 150.milliseconds,
            child: _buildSparator(),
          ),
          SizedBox(
            height: 17.w,
          ),
          AnimationFadeAndSlide(
            delay: 900.milliseconds,
            duration: 150.milliseconds,
            child: _buildAppleButton(),
          ),
          Obx(() => Padding(
                padding: const EdgeInsets.only(top: 78.0),
                child: AnimationFadeAndSlide(
                  delay: 1200.milliseconds,
                  duration: 150.milliseconds,
                  child: Text(
                      'v${_authController.packageInfo.value.version}_${_authController.packageInfo.value.buildNumber}',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.withOpacity(0.5),
                      )),
                ),
              ))
        ],
      ),
    );
  }

  Widget _buildAppleButton() {
    return Obx(() => Padding(
          padding: EdgeInsets.symmetric(horizontal: 30.w),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20.w),
            child: Shimmer(
              duration: Duration(milliseconds: 1500),
              color: Colors.grey,
              enabled: _authController.isLoading,
              child: ButtonSignIn(
                onPress: _authController.isLoading == true
                    ? () => showAlert(message: 'Sign-in process is in progress')
                    : () async {
                        if (Platform.isAndroid) {
                          _authController.checkPrivacyPolice(
                              () => _authController.testSignInApple());
                          // _authController.testSignInApple();
                        } else {
                          _authController.checkPrivacyPolice(
                              () => _authController.signInApple());
                          // _authController.signInApple();
                        }
                      },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/apple_logo-min.png',
                      height: 20.w,
                      color: Colors.black,
                    ),
                    SizedBox(
                      width: 20.w,
                    ),
                    Text('Sign in with Apple',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: Color(0xff081B4B),
                        )),
                  ],
                ),
              ),
            ),
          ),
        ));
  }

  Stack _buildSparator() {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          margin: EdgeInsets.symmetric(horizontal: 48.w),
          height: 1.w,
          color: Color(0xffB5B5B5),
        ),
        Container(
          color: Colors.white,
          width: 50.w,
          height: 54.w,
          child: Center(
              child: Text('or',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.normal,
                    color: Color(0xff7A7A7A),
                  ))),
        )
      ],
    );
  }

  Widget _buildButtonGoogle() {
    return Obx(() => Padding(
          padding: EdgeInsets.symmetric(horizontal: 30.w),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20.w),
            child: Shimmer(
              duration: Duration(milliseconds: 1500),
              color: Colors.grey,
              enabled: _authController.isLoading,
              child: ButtonSignIn(
                onPress: _authController.isLoading == true
                    ? () => showAlert(message: 'Sign-in process is in progress')
                    : () async {
                        _authController.checkPrivacyPolice(
                            () => _authController.signInGoogle());
                        // _authController.signInGoogle();
                      },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/google_logo-min.png',
                      height: 20.w,
                    ),
                    SizedBox(
                      width: 20.w,
                    ),
                    Text('Sign in with Google Account',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: Color(0xff081B4B),
                        )),
                  ],
                ),
              ),
            ),
          ),
        ));
  }

  Align _buildSubtitle() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(left: 38.w),
        child: Text('Login to your account',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: Color(0xff7A7A7A),
            )),
      ),
    );
  }

  Align _buildSubtitleSignInFromLink() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        width: 285.w,
        margin: EdgeInsets.only(left: 38.w),
        child: Text(
            'You’re almost there!\nPlease login first before we sent you to your company',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: Color(0xff7A7A7A),
            )),
      ),
    );
  }

  Align _buildTitle() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
          margin: EdgeInsets.only(left: 38.w),
          width: 196.w,
          child: Text(
            'Welcome Aboard!',
            style: TextStyle(
                fontSize: 36.sp,
                fontWeight: FontWeight.bold,
                color: Color(0xff0C2044)),
          )),
    );
  }

  Align _buildTitleSignInFromLink() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
          margin: EdgeInsets.only(left: 38.w),
          width: 196.w,
          child: Text(
            'Just a bit more!',
            style: TextStyle(
                fontSize: 36.sp,
                fontWeight: FontWeight.bold,
                color: Color(0xff0C2044)),
          )),
    );
  }
}

class ButtonSignIn extends StatelessWidget {
  const ButtonSignIn({
    Key? key,
    required this.child,
    required this.onPress,
  }) : super(key: key);

  final Widget child;
  final Function onPress;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: ElevatedButton(
          style: ButtonStyle(
              padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                  EdgeInsets.symmetric(vertical: 10.w)),
              overlayColor: MaterialStateProperty.all<Color>(
                  Theme.of(context).primaryColor.withOpacity(0.5)),
              backgroundColor: MaterialStateProperty.all<Color>(Colors.white),
              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50.w),
                      side: BorderSide(color: Color(0xff081B4B), width: 1.w)))),
          onPressed: () {
            onPress();
          },
          child: Container(width: double.infinity, child: child)),
    );
  }
}
