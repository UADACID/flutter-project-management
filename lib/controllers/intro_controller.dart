import 'package:carousel_slider/carousel_controller.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class IntroController extends GetxController {

  final box = GetStorage();

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    init();
  }

  void init() {
    bool checkShowIntro = box.read('show_intro');
    _showIntro.value = !checkShowIntro;
  }

  var _indexIntro = 0.0.obs;

  CarouselController buttonCarouselController = CarouselController();

  double get indexIntro => _indexIntro.value;

  set selectedMenuIndex(double index) {
    _indexIntro.value = index;
  }

  // show introduction
  var _showIntro = false.obs;

  bool get showIntro => _showIntro.value;

  set showIntro(bool value) {
    _showIntro.value = value;
    box.write('show_intro', !value);
  }
}
