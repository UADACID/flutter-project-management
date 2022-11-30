import 'package:cicle_mobile_f3/controllers/my_task_kanban_more_controller.dart';

import 'package:get/get.dart';

class MyTaskkanbanMoreBinding implements Bindings {
  @override
  void dependencies() {
    Get.put(
      MyTaskKanbanMoreController(),
    );
  }
}
