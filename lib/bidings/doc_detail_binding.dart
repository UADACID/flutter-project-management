import 'package:cicle_mobile_f3/controllers/doc_detail_controller.dart';
import 'package:get/get.dart';

class DocDetailBinding implements Bindings {
  @override
  void dependencies() {
    Get.create(() => DocDetailController());
  }
}
