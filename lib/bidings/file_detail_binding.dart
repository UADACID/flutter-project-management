import 'package:cicle_mobile_f3/controllers/file_detail_controller.dart';
import 'package:get/get.dart';

class FileDetailBinding implements Bindings {
  @override
  void dependencies() {
    Get.create(() => FileDetailController());
  }
}
