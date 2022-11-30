import 'package:flutter/material.dart';

class ErrorNoInternet extends StatelessWidget {
  const ErrorNoInternet({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(child: Center(child: Text('error no internet')));
  }
}
