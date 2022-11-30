import 'package:cicle_mobile_f3/controllers/folder_detail_controller.dart';
import 'package:get/get.dart';

class FolderDetailBinding implements Bindings {
  @override
  void dependencies() {
    Get.create(() => FolderDetailController());
  }
}
