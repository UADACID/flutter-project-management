import 'package:cicle_mobile_f3/controllers/check_in_detail_controller.dart';
import 'package:get/get.dart';

class CheckInDetailBinding implements Bindings {
  @override
  void dependencies() {
    Get.create(() => CheckInDetailController());
  }
}
