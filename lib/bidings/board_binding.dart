import 'package:cicle_mobile_f3/controllers/board_controller.dart';
import 'package:cicle_mobile_f3/controllers/board_filter_controller.dart';
import 'package:get/get.dart';

class BoardBinding implements Bindings {
  @override
  void dependencies() {
    Get.put(BoardController());
    Get.create(() => BoardFilterController());
  }
}
