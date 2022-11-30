import 'package:cicle_mobile_f3/controllers/my_task_blast_all_controller.dart';
import 'package:cicle_mobile_f3/controllers/my_task_blast_done_controller.dart';
import 'package:cicle_mobile_f3/controllers/my_task_check_in_all_controller.dart';
import 'package:cicle_mobile_f3/controllers/my_task_check_in_done_controller.dart';
import 'package:cicle_mobile_f3/controllers/my_task_controller.dart';
import 'package:cicle_mobile_f3/controllers/my_task_kanban_all_controller.dart';
import 'package:cicle_mobile_f3/controllers/my_task_kanban_done_controller.dart';
import 'package:cicle_mobile_f3/controllers/tab_my_task_controller.dart';
import 'package:get/get.dart';

class MyTaskBinding implements Bindings {
  @override
  void dependencies() {
    Get.put(
      TabMyTaskController(),
    );
    Get.put(MyTaskController());
    Get.put(MyTaskCheckInAllController());
    Get.put(MyTaskCheckInDoneController());
    Get.put(MyTaskBlastDoneController());
    Get.put(MyTaskKanbanDoneController());
    Get.put(MyTaskBlastAllController());
    Get.put(MyTaskKanbanAllController());
  }
}
