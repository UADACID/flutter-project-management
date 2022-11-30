import 'package:cicle_mobile_f3/controllers/check_in_controller.dart';
import 'package:cicle_mobile_f3/controllers/doc_files_controller.dart';
import 'package:cicle_mobile_f3/controllers/menu_controller.dart';
import 'package:cicle_mobile_f3/controllers/schedule_controller.dart';
import 'package:cicle_mobile_f3/controllers/team_detail_controller.dart';
import 'package:get/get.dart';

class TeamDetailBinding implements Bindings {
  @override
  void dependencies() {
    Get.put(
      TeamDetailController(),
    );
    // Get.put(
    //   CheckInController(),
    // );
    // Get.put(ScheduleController());
    // Get.put(
    //   DocFilesController(),
    // );
    Get.put(
      MenuController(),
    );
  }
}
