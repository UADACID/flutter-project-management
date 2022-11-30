import 'package:cicle_mobile_f3/controllers/private_chat_detail_controller.dart';
import 'package:get/get.dart';

class PrivateChatDetailBinding implements Bindings {
  @override
  void dependencies() {
    Get.create(() => PrivateChatDetailController());
  }
}
