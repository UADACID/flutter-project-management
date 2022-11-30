import 'package:cicle_mobile_f3/controllers/blast_controller.dart';
import 'package:get/get.dart';

class BlastBinding implements Bindings {
  @override
  void dependencies() {
    Get.put(BlastController());
  }
}
