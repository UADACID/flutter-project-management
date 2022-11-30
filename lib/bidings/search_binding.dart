import 'package:cicle_mobile_f3/controllers/search_controller.dart';
import 'package:get/get.dart';

class SearchBinding implements Bindings {
  @override
  void dependencies() {
    Get.put(
      SearchController(),
    );
  }
}
