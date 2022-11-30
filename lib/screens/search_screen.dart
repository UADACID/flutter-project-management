import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen(
      {Key? key, required GlobalKey<ScaffoldState> parentScaffoldKey})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: Get.width,
          ),
          SvgPicture.asset(
            'assets/images/search_placeholder.svg',
            semanticsLabel: 'Acme Logo',
            width: 200.w,
          ),
          SizedBox(
            height: 15,
          ),
          Text(
            'feature is under development\nwill be available soon',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
