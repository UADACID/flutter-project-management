import 'package:cicle_mobile_f3/models/cheer_item_model.dart';
import 'package:cicle_mobile_f3/models/comment_item_model.dart';
import 'package:get/get.dart';

class CommentItemController extends GetxController {
  // CONTENT
  var _content = ''.obs;
  String get content => _content.value;

  // DISCUSSIONS
  var _discussions = <Discussions>[].obs;
  List<Discussions> get discussions => _discussions;

  // CHEERS
  var _cheers = <CheerItemModel>[].obs;
  List<CheerItemModel> get cheers => _cheers;
  addCheers(CheerItemModel item) {
    _cheers.add(item);
  }

  // INIT
  setDefaultValue(CommentItemModel commentItem) {
    _content.value = commentItem.content;
    _discussions.value = [...commentItem.discussions];
    _cheers.value = [...commentItem.cheers];
  }
}
