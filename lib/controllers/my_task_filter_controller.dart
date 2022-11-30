import 'package:cicle_mobile_f3/controllers/company_controller.dart';
import 'package:cicle_mobile_f3/controllers/my_task_controller.dart';
import 'package:cicle_mobile_f3/models/companies_model.dart';
import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MyTaskFilterController extends GetxController {
  CompanyController _companyController = Get.find();
  MyTaskController _myTaskController = Get.find();

  TextEditingController nameTextEditingController = TextEditingController();
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

  var listHq = <Teams>[].obs;

  var listTeam = <Teams>[].obs;

  var listProject = <Teams>[].obs;

  var limitDisplayHq = 0.obs;
  var limitDisplayTeam = 0.obs;
  var limitDisplayProject = 0.obs;

  onPressHqItem(String item) {
    if (listHqSelected.contains(item)) {
      _listHqSelected.remove(item);
    } else {
      _listHqSelected.add(item);
    }
  }

  var _listTeamSelected = <String>[].obs;
  List<String> get listTeamSelected => _listTeamSelected;
  set listTeamSelected(List<String> value) {
    _listTeamSelected.value = value;
  }

  onPressTeamItem(String item) {
    if (listTeamSelected.contains(item)) {
      _listTeamSelected.remove(item);
    } else {
      _listTeamSelected.add(item);
    }
  }

  var _listProjectSelected = <String>[].obs;
  List<String> get listProjectSelected => _listProjectSelected;
  set listProjectSelected(List<String> value) {
    _listProjectSelected.value = value;
  }

  onPressProjectItem(String item) {
    if (listProjectSelected.contains(item)) {
      _listProjectSelected.remove(item);
    } else {
      _listProjectSelected.add(item);
    }
  }

  reset() {
    nameTextEditingController.text = "";
    searchKey = '';
    listHqSelected = [];
    listTeamSelected = [];
    listProjectSelected = [];
  }

  init() {
    // set default value
    searchKey = _myTaskController.searchKey;
    listHqSelected = [..._myTaskController.listHqSelected];
    listTeamSelected = [..._myTaskController.listTeamSelected];
    listProjectSelected = [..._myTaskController.listProjectSelected];

    if (_myTaskController.searchKey != "") {
      nameTextEditingController.text = _myTaskController.searchKey;
      actionOnTypeSearch(_myTaskController.searchKey);
    } else {
      listHq.value = _companyController.teams
          .where((element) => element.type == 'hq')
          .toList();
      if (listHq.length > 2) {
        limitDisplayHq.value = 2;
      } else {
        limitDisplayHq.value = listHq.length;
      }
      listTeam.value = _companyController.teams
          .where((element) => element.type == 'team')
          .toList();
      if (listTeam.length > 2) {
        limitDisplayTeam.value = 2;
      } else {
        limitDisplayTeam.value = listTeam.length;
      }
      listProject.value = _companyController.teams
          .where((element) => element.type == 'project')
          .toList();
      if (listProject.length > 2) {
        limitDisplayProject.value = 2;
      } else {
        limitDisplayProject.value = listProject.length;
      }
    }
  }

  onTypeSearchKey(String value) {
    EasyDebounce.debounce(
        'submit-add-check-in', // <-- An ID for this particular debouncer
        Duration(milliseconds: 600), // <-- The debounce duration
        () {
      print('value $value');
      actionOnTypeSearch(value);
    } // <-- The target method
        );
  }

  actionOnTypeSearch(String key) {
    // for search HQ
    listHq.value = _companyController.teams
        .where((element) =>
            element.type == 'hq' &&
            element.name.toLowerCase().contains(key.toLowerCase()))
        .toList();
    if (listHq.length > 2) {
      limitDisplayHq.value = 2;
    } else {
      limitDisplayHq.value = listHq.length;
    }
    //for search team
    listTeam.value = _companyController.teams
        .where((element) =>
            element.type == 'team' &&
            element.name.toLowerCase().contains(key.toLowerCase()))
        .toList();
    if (listTeam.length > 2) {
      limitDisplayTeam.value = 2;
    } else {
      limitDisplayTeam.value = listTeam.length;
    }
    // for search project
    listProject.value = _companyController.teams
        .where((element) =>
            element.type == 'project' &&
            element.name.toLowerCase().contains(key.toLowerCase()))
        .toList();
    if (listProject.length > 2) {
      limitDisplayProject.value = 2;
    } else {
      limitDisplayProject.value = listProject.length;
    }
  }

  onSubmit() {
    _myTaskController.searchKey = searchKey;
    _myTaskController.listHqSelected = [...listHqSelected];
    _myTaskController.listTeamSelected = [...listTeamSelected];
    _myTaskController.listProjectSelected = [...listProjectSelected];
    _myTaskController.listAllIdSelected.value = [
      ...listHqSelected,
      ...listTeamSelected,
      ...listProjectSelected
    ];
    Get.back();
  }

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    init();
    ever(_searchKey, onTypeSearchKey);
  }
}
