import 'package:cicle_mobile_f3/controllers/blast_detail_controller.dart';
import 'package:get/get.dart';

class BlastDetailBinding implements Bindings {
  @override
  void dependencies() {
    Get.create(() => BlastDetailController());
  }
}
