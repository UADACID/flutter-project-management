import 'package:cicle_mobile_f3/controllers/board_detail_controller.dart';
import 'package:get/get.dart';

class BoardDetailBinding implements Bindings {
  @override
  void dependencies() {
    Get.create(() => BoardDetailController());
  }
}
