import 'package:get/get.dart';

class TopTabBarController extends GetxController {
  var _selectedIndex = 0.obs;

  int get selectedIndex => _selectedIndex.value;
  set selectedIndex(int value) {
    _selectedIndex.value = value;
  }
}

class TabFilterModel {
  final String title;
  final String? value;

  TabFilterModel({required this.title, this.value});
}
