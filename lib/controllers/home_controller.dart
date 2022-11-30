import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

class HomeController extends GetxController {
  AutoScrollController autoScrollController = AutoScrollController();

  // AnimationController animationControllerFab;
  var _hideFAB = false.obs;
  bool get hideFAB => _hideFAB.value;

  onStartScroll(ScrollMetrics metrics) {
    _hideFAB.value = true;
  }

  onUpdateScroll(ScrollMetrics metrics) {}

  onEndScroll(ScrollMetrics metrics) {
    _hideFAB.value = false;
  }
}
