import 'package:cicle_mobile_f3/controllers/group_chat_controller.dart';
import 'package:get/get.dart';

class GroupChatBinding implements Bindings {
  @override
  void dependencies() {
    Get.create(() => GroupChatController());
  }
}
