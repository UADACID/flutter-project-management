import 'dart:io';
import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cicle_mobile_f3/controllers/intro_controller.dart';
import 'package:cicle_mobile_f3/utils/constant.dart';
import 'package:cicle_mobile_f3/widgets/animation_fade_and_slide.dart';

import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'dart:math' as math;

class IntroScreen extends StatelessWidget {
  IntroScreen({Key? key}) : super(key: key);

  IntroController _introController = Get.put(IntroController());

  @override
  Widget build(BuildContext context) {
    double _height = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Container(
        padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
        child: AnimationFadeAndSlide(
          child: _buildContainer(_height, context),
          delay: 500.milliseconds,
          duration: 400.milliseconds,
        ),
      ),
    );
  }

  Container _buildContainer(double _height, BuildContext context) {
    return Container(
      child: Stack(
        children: [
          Obx(() => CarouselSlider(
                carouselController: _introController.buttonCarouselController,
                options: CarouselOptions(
                    scrollPhysics: _introController.indexIntro == 0
                        ? NeverScrollableScrollPhysics()
                        : BouncingScrollPhysics(), // disable swipe / scroll for first page
                    autoPlay: _introController.indexIntro == 0 ||
                            _introController.indexIntro == 5
                        ? false
                        : true,
                    height: double.infinity,
                    enableInfiniteScroll: false,
                    viewportFraction: 1,
                    onPageChanged: (index, reason) {
                      _introController.selectedMenuIndex = index.toDouble();
                    }),
                items: [
                  IntroPage1(height: _height),
                  IntroPage2(),
                  IntroPage3(),
                  IntroPage4(),
                  IntroPage5(),
                  IntroPage6(),
                ],
              )),
          Obx(() => AnimatedPositioned(
                duration: Duration(milliseconds: 200),
                bottom: _introController.indexIntro == 0 ||
                        _introController.indexIntro == 5
                    ? 158
                    : 65,
                child: Container(
                  width: 375.w,
                  child: Obx(() => DotsIndicator(
                        dotsCount: 6,
                        position: _introController.indexIntro,
                        decorator: DotsDecorator(
                          color: Colors.grey, // Inactive color
                          activeColor: Theme.of(context).primaryColor,
                        ),
                      )),
                ),
              )),
          Obx(() => _introController.indexIntro == 5.0
              ? SizedBox()
              : Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(8.0),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(10),
                      onTap: () {
                        _introController.buttonCarouselController.jumpToPage(5);
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(
                            left: 20.0, right: 20, top: 10, bottom: 10),
                        child: Text(
                          'Skip',
                          style: TextStyle(color: Color(0xff1F3762)),
                        ),
                      ),
                    ),
                  ),
                ))
        ],
      ),
    );
  }
}

class IntroPage5 extends StatelessWidget {
  const IntroPage5({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Stack(
        children: [
          Positioned(
              left: -136.5,
              top: -136.5,
              child: Container(
                height: 273,
                width: 273,
                decoration: BoxDecoration(
                    shape: BoxShape.circle, color: Color(0xffDEEAFF)),
              )),
          Container(
              child: Image.asset(
            'assets/images/Intro_page5.png',
            width: double.infinity,
            height: double.infinity,
            fit: BoxFit.contain,
          )),
          Container(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    margin: EdgeInsets.only(left: 20, right: 30),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          margin: EdgeInsets.only(bottom: 15, left: 10),
                          width: 152,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Schedule',
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                    fontSize: 24,
                                    color: Color(0xff1F3762),
                                    fontWeight: FontWeight.bold),
                              ),
                              Text('a centralized calendar for your team',
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    color: Color(0xff1F3762),
                                  ))
                            ],
                          ),
                        ),
                        Container(
                            child: Image.asset(
                          'assets/images/schedule.png',
                          height: 174,
                          width: 174,
                        )),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 56,
                  ),
                  Container(
                    margin: EdgeInsets.only(left: 20, right: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          child: Image.asset(
                            'assets/images/doc_and_file.png',
                            height: 156.w,
                            width: 156.w,
                            fit: BoxFit.fitWidth,
                          ),
                        ),
                        Flexible(
                          child: Container(
                            margin: EdgeInsets.only(top: 0, right: 5),
                            width: 158,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  'Docs & Files',
                                  style: TextStyle(
                                      fontSize: 24,
                                      color: Color(0xff1F3762),
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  'storing and managing all your docs & files in one place',
                                  style: TextStyle(color: Color(0xff1F3762)),
                                  textAlign: TextAlign.right,
                                )
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 36,
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class IntroPage4 extends StatelessWidget {
  const IntroPage4({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Stack(
        children: [
          Positioned(
              right: -136.5,
              top: -136.5,
              child: Container(
                height: 273,
                width: 273,
                decoration: BoxDecoration(
                    shape: BoxShape.circle, color: Color(0xffDEEAFF)),
              )),
          Positioned(
              left: -160,
              bottom: 145,
              child: Transform.rotate(
                angle: -math.pi / 6.63,
                child: SvgPicture.asset(
                  'assets/images/union-new.svg',
                  width: 190,
                  semanticsLabel: 'logo',
                  color: Color(0xffDEEAFF),
                ),
              )),
          Container(
              child: Image.asset(
            'assets/images/Intro_page4.png',
            width: double.infinity,
            height: double.infinity,
            fit: BoxFit.contain,
          )),
          Container(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    margin: EdgeInsets.only(left: 20, right: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Container(
                            margin: EdgeInsets.only(bottom: 0, left: 10),
                            width: 198.w,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Group Chat',
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                      fontSize: 24,
                                      color: Color(0xff1F3762),
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(
                                    'a place for chatting with all your team members',
                                    textAlign: TextAlign.left,
                                    style: TextStyle(
                                      color: Color(0xff1F3762),
                                    ))
                              ],
                            ),
                          ),
                        ),
                        Container(
                            child: Image.asset(
                          'assets/images/group_chat.png',
                          height: 173.w,
                          width: 173.w,
                        )),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 45,
                  ),
                  Container(
                    margin: EdgeInsets.only(left: 20, right: 25),
                    child: Stack(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              child: Image.asset(
                                'assets/images/check_in.png',
                                height: 216.w,
                                width: 216.w,
                                fit: BoxFit.fitWidth,
                              ),
                            ),
                          ],
                        ),
                        Positioned(
                          bottom: 42,
                          right: 0,
                          child: Container(
                            width: 174.w,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  'Check-Ins',
                                  style: TextStyle(
                                      fontSize: 24,
                                      color: Color(0xff1F3762),
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  'Remove unnecessary meetings by sending routine questions for your team',
                                  style: TextStyle(color: Color(0xff1F3762)),
                                  textAlign: TextAlign.right,
                                )
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 70,
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class IntroPage3 extends StatelessWidget {
  const IntroPage3({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Stack(
        children: [
          Positioned(
              right: -30,
              bottom: 145,
              child: Transform.rotate(
                angle: -math.pi / 6.63,
                child: SvgPicture.asset(
                  'assets/images/union-new.svg',
                  width: 190,
                  semanticsLabel: 'logo',
                  color: Color(0xffDEEAFF),
                ),
              )),
          Container(
              child: Image.asset(
            'assets/images/Intro_page3.png',
            width: double.infinity,
            height: double.infinity,
            fit: BoxFit.contain,
          )),
          Container(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    margin: EdgeInsets.only(left: 20, right: 40),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          margin: EdgeInsets.only(bottom: 15, left: 10),
                          width: 161,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Kanban Board',
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                    fontSize: 24,
                                    color: Color(0xff1F3762),
                                    fontWeight: FontWeight.bold),
                              ),
                              Text(
                                  'Get more things done by tracking work progress',
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    color: Color(0xff1F3762),
                                  ))
                            ],
                          ),
                        ),
                        Transform.rotate(
                          angle: -math.pi / -10.23,
                          child: Container(
                              child: Image.asset(
                            'assets/images/board.png',
                            height: 147.73,
                            width: 147.73,
                          )),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 65,
                  ),
                  Container(
                    margin: EdgeInsets.only(left: 20, right: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Transform.rotate(
                          angle: -math.pi / 9.45,
                          child: Container(
                            child: Image.asset(
                              'assets/images/blast.png',
                              height: 170.w,
                              width: 170.w,
                              fit: BoxFit.fitWidth,
                            ),
                          ),
                        ),
                        Flexible(
                          child: Container(
                            margin: EdgeInsets.only(top: 30, right: 5),
                            width: 151.w,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  'Blast',
                                  style: TextStyle(
                                      fontSize: 24,
                                      color: Color(0xff1F3762),
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  'keep team informed, also to decide something without meeting',
                                  style: TextStyle(color: Color(0xff1F3762)),
                                  textAlign: TextAlign.right,
                                )
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 76,
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class IntroPage6 extends StatelessWidget {
  IntroPage6({
    Key? key,
  }) : super(key: key);

  IntroController _introController = Get.put(IntroController());

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      child: Stack(
        children: [
          Positioned(
              right: -90.5,
              bottom: -90.5,
              child: Container(
                height: 273,
                width: 273,
                decoration: BoxDecoration(
                    shape: BoxShape.circle, color: Color(0xffDEEAFF)),
              )),
          Container(
              child: Image.asset(
            'assets/images/Intro_page6.png',
            width: double.infinity,
            height: double.infinity,
            fit: BoxFit.contain,
          )),
          Container(
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 140,
                  child: Text(
                    'Ready to be organised?',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Image.asset('assets/images/intro_logo6.png'),
                SizedBox(
                  height: 130,
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: double.infinity,
              margin: EdgeInsets.only(bottom: 110),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Don’t show me this introduction anymore',
                    style: TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                  SizedBox(
                    width: 7,
                  ),
                  Obx(() => Checkbox(
                        fillColor: MaterialStateProperty.all<Color>(
                            Theme.of(context).primaryColor),
                        value: _introController.showIntro,
                        onChanged: (bool? value) {
                          _introController.showIntro = value!;
                        },
                      ))
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 37.0, vertical: 40),
              child: ElevatedButton(
                onPressed: () async {
                  if (Platform.isIOS) {
                    final status = await AppTrackingTransparency
                        .requestTrackingAuthorization();
                    print(status);
                    if (status == TrackingStatus.authorized ||
                        status == TrackingStatus.notSupported) {
                      Get.offNamed(RouteName.signInScreen);
                    } else {
                      Get.offNamed(RouteName.signInScreen);
                    }
                  } else {
                    Get.offNamed(RouteName.signInScreen);
                  }
                },
                style: ButtonStyle(
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50.0),
                ))),
                child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: 305, maxHeight: 45),
                    child: Container(
                        width: double.infinity,
                        child: Center(child: Text('Go to Sign In')))),
              ),
            ),
          )
        ],
      ),
    );
  }
}

class IntroPage2 extends StatelessWidget {
  const IntroPage2({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double _fullWidth = ScreenUtil().screenWidth;
    return Container(
      width: double.infinity,
      child: Stack(
        children: [
          Positioned(
              left: 0,
              top: 8,
              child: SvgPicture.asset('assets/images/intro_part_1.svg',
                  width: _fullWidth / 2, semanticsLabel: 'logo')),
          Container(
              child: Image.asset(
            'assets/images/Intro_page2.png',
            width: double.infinity,
            height: double.infinity,
            fit: BoxFit.contain,
          )),
          Container(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 284,
                  child: Text(
                    'Cicle is here to help leaders like you who feels overwhelmed when managing teams remotely',
                    style: TextStyle(fontSize: 18),
                    textAlign: TextAlign.center,
                  ),
                ),
                Image.asset('assets/images/intro_logo2.png'),
                SizedBox(
                  height: 20,
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 54.w),
                  child: Text(
                    'To be stress free and make your team more productive',
                    style: TextStyle(fontSize: 18),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class IntroPage1 extends StatelessWidget {
  IntroPage1({
    Key? key,
    required double height,
  })  : _height = height,
        super(key: key);

  IntroController _introController = Get.put(IntroController());

  final double _height;

  @override
  Widget build(BuildContext context) {
    double _fullWidth = ScreenUtil().screenWidth;
    return Container(
      width: double.infinity,
      child: Stack(
        children: [
          Positioned(
              right: 0,
              top: 8,
              child: SvgPicture.asset('assets/images/intro_part_2.svg',
                  width: _fullWidth / 2, semanticsLabel: 'logo')),
          Container(
              child: Image.asset(
            'assets/images/Intro_page1.png',
            width: double.infinity,
            height: double.infinity,
            fit: BoxFit.contain,
          )),
          Container(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('assets/images/intro_logo1.png'),
                SizedBox(
                  height: 20,
                ),
                Center(
                    child: Text(
                  'Sick of miscoordination?',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                )),
                SizedBox(
                  height: (_height / 7),
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 37.0, vertical: 40),
              child: ElevatedButton(
                onPressed: () {
                  _introController.buttonCarouselController.nextPage(
                      duration: Duration(milliseconds: 300),
                      curve: Curves.linear);
                },
                style: ButtonStyle(
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50.0),
                ))),
                child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: 305, maxHeight: 45),
                    child: Container(
                        width: double.infinity,
                        child: Center(child: Text('Yes!')))),
              ),
            ),
          )
        ],
      ),
    );
  }
}
