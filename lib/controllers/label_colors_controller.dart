import 'package:cicle_mobile_f3/models/label_model.dart';
import 'package:cicle_mobile_f3/service/board_service.dart';
import 'package:get/get.dart';

class LabelsController extends GetxController {
  BoardService _boardService = BoardService();

  var _isLoading = false.obs;
  bool get isLoading => _isLoading.value;

  var _colors = <ColorModel>[].obs;
  List<ColorModel> get colors => _colors;

  Future<List<ColorModel>> getColors() async {
    try {
      _isLoading.value = true;
      final response = await _boardService.getColors();
      if (response.data['colors'] != null) {
        response.data['colors'].forEach((v) {
          _colors.add(ColorModel.fromJson(v));
        });
      }
      _isLoading.value = false;
    } catch (e) {}
    _isLoading.value = false;
    return Future.value([]);
  }

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    getColors();
  }
}
