import 'package:cicle_mobile_f3/controllers/search_controller.dart';
import 'package:get/get.dart';

class SearchFilterController extends GetxController {
  SearchController _searchController = Get.find();

  var _listSelectedHq = <String>[].obs;
  List<String> get listSelectedHq => _listSelectedHq;
  set listSelectedHq(List<String> value) {
    _listSelectedHq.value = value;
  }

  var _listSelectedTeam = <String>[].obs;
  List<String> get listSelectedTeam => _listSelectedTeam;
  set listSelectedTeam(List<String> value) {
    _listSelectedTeam.value = value;
  }

  var _listSelectedProject = <String>[].obs;
  List<String> get listSelectedProject => _listSelectedProject;
  set listSelectedProject(List<String> value) {
    _listSelectedProject.value = value;
  }

  onSelectHq(String id) {
    if (listSelectedHq.contains(id)) {
      _listSelectedHq.remove(id);
    } else {
      _listSelectedHq.add(id);
    }
  }

  onSelectTeam(String id) {
    if (listSelectedTeam.contains(id)) {
      _listSelectedTeam.remove(id);
    } else {
      _listSelectedTeam.add(id);
    }
  }

  onSelectProject(String id) {
    if (listSelectedProject.contains(id)) {
      _listSelectedProject.remove(id);
    } else {
      _listSelectedProject.add(id);
    }
  }

  reset() {
    _listSelectedHq.clear();
    _listSelectedTeam.clear();
    _listSelectedProject.clear();
  }

  submit() {
    _searchController.listSelectedHq = [...listSelectedHq];
    _searchController.listSelectedTeam = [...listSelectedTeam];
    _searchController.listSelectedProject = [...listSelectedProject];
    Get.back();
  }

  getPreviousData() {
    listSelectedHq = [..._searchController.listSelectedHq];
    listSelectedTeam = [..._searchController.listSelectedTeam];
    listSelectedProject = [..._searchController.listSelectedProject];
  }
}
