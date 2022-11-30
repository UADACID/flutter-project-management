import 'package:flutter/material.dart';

class AfterView extends StatefulWidget {
  const AfterView({Key? key, this.child}) : super(key: key);
  final Widget? child;
  @override
  _AfterViewState createState() => _AfterViewState();
}

class _AfterViewState extends State<AfterView> {
  bool show = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    init();
  }

  void init() async {
    await Future.delayed(Duration(seconds: 2));
    setState(() {
      show = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return show ? widget.child ?? Container() : Container(
      height: 10,
      width: 10,
    );
  }
}
