import 'package:get/get.dart';

class MyTaskController extends GetxController {
  var _searchKey = ''.obs;
  String get searchKey => _searchKey.value;
  set searchKey(String value) {
    _searchKey.value = value;
  }

  var _listHqSelected = <String>[].obs;
  List<String> get listHqSelected => _listHqSelected;
  set listHqSelected(List<String> value) {
    _listHqSelected.value = value;
  }

  var _listTeamSelected = <String>[].obs;
  List<String> get listTeamSelected => _listTeamSelected;
  set listTeamSelected(List<String> value) {
    _listTeamSelected.value = value;
  }

  var _listProjectSelected = <String>[].obs;
  List<String> get listProjectSelected => _listProjectSelected;
  set listProjectSelected(List<String> value) {
    _listProjectSelected.value = value;
  }

  var listAllIdSelected = <String>[].obs;

  var _showCompleteTask = false.obs;
  bool get showCompleteTask => _showCompleteTask.value;
  set showCompleteTask(bool value) {
    _showCompleteTask.value = value;
  }

  bool hasFilter() {
    if (listHqSelected.isNotEmpty ||
        listProjectSelected.isNotEmpty ||
        listTeamSelected.isNotEmpty) {
      return true;
    }

    return false;
  }

  // helper for handle action on tab controller
  var showComplete = false.obs;

  onChangeShowComplete(bool value) {
    showComplete.value = value;
  }

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();

    ever(_showCompleteTask, onChangeShowComplete);
  }
}
