import 'package:cicle_mobile_f3/controllers/comment_detail_controller.dart';
import 'package:get/get.dart';

class CommentDetailBinding implements Bindings {
  @override
  void dependencies() {
    Get.create(() => CommentDetailController());
  }
}
