import 'package:cicle_mobile_f3/controllers/event_detail_controller.dart';
import 'package:cicle_mobile_f3/controllers/event_occurence_controller.dart';
import 'package:get/get.dart';

class ScheduleDetailBinding implements Bindings {
  @override
  void dependencies() {
    Get.create(() => EventDetailController());
    Get.create(() => EventOccurenceDetailController());
  }
}
