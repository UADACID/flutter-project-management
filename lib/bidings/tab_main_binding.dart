import 'package:cicle_mobile_f3/controllers/comment_controller.dart';
import 'package:cicle_mobile_f3/controllers/comment_item_controller.dart';
import 'package:cicle_mobile_f3/controllers/company_controller.dart';
import 'package:cicle_mobile_f3/controllers/notification_list_controller.dart';
import 'package:cicle_mobile_f3/controllers/private_chat_controller.dart';
import 'package:cicle_mobile_f3/controllers/tab_main_controller.dart';
import 'package:cicle_mobile_f3/controllers/top_tab_bar_controller.dart';
import 'package:get/get.dart';

class TabMainBinding implements Bindings {
  @override
  void dependencies() {
    Get.put(
      TabMainController(),
    );
    Get.put(TopTabBarController());
    Get.put(CompanyController());
    Get.put(PrivateChatController());
    Get.create(() => CommentController());
    Get.create(() => CommentItemController());
    Get.create(() => NotificationListController());
  }
}
