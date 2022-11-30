import 'package:cicle_mobile_f3/controllers/my_task_blast_more_controller.dart';

import 'package:get/get.dart';

class MyTaskBlastMoreBinding implements Bindings {
  @override
  void dependencies() {
    Get.put(
      MyTaskBlastMoreController(),
    );
  }
}
