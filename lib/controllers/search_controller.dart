import 'package:cicle_mobile_f3/models/companies_model.dart';
import 'package:cicle_mobile_f3/screens/search/searc_filter.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class SearchController extends GetxController {
  String showFilter = Get.parameters['showFilter'] ?? '0';

  TextEditingController searchTextInputController = TextEditingController();

  final box = GetStorage();

  var _keyWords = [''].obs;
  List<String> get keyWords => _keyWords;
  set keyWords(List<String> value) {
    _keyWords.value = [...value];
  }

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

  bool get filterIsActive =>
      listSelectedHq.isNotEmpty ||
      listSelectedTeam.isNotEmpty ||
      listSelectedProject.isNotEmpty;

  int get filterCounter =>
      listSelectedHq.length +
      listSelectedTeam.length +
      listSelectedProject.length;

  // RECENLY VIEWED

  var _listRecenlyViewed = <RecentlyViewed>[].obs;
  List<RecentlyViewed> get listRecenlyViewed => _listRecenlyViewed;
  set listRecenlyViewed(List<RecentlyViewed> value) {
    _listRecenlyViewed.value = value;
  }

  insertListRecenlyViewed(RecentlyViewed value) async {
    _listRecenlyViewed.removeWhere((element) => element.uniqId == value.uniqId);

    _listRecenlyViewed.insert(0, value);

    var json = _listRecenlyViewed.toJson();
    box.write('recentlyViewed', json);
  }

  _setRecentlyViewedFromStorage() async {
    await Future.delayed(Duration(milliseconds: 300));
    var jsonList = box.read('recentlyViewed');
    if (jsonList != null) {
      jsonList.forEach((o) {
        _listRecenlyViewed.add(RecentlyViewed.fromJson(o));
      });
    }
  }

  var showAllHq = false.obs;
  var showAllTeam = false.obs;
  var showAllProject = false.obs;

  var _teams = <Teams>[].obs;
  List<Teams> get teams => _teams;

  set teams(List<Teams> value) {
    _teams.value = [...value];
  }

  // END RECENLY VIEWED

  // DATA FOR SEARCH

  var showAllSearchTeam = false.obs;
  var showAllSearchBoard = false.obs;
  var showAllSearchBlast = false.obs;
  var showAllSearchSchedule = false.obs;
  var showAllSearchCheckIn = false.obs;
  var showAllSearchGroupChat = false.obs;
  var showAllSearchDocsAndFiles = false.obs;

  // END DATA FOR SEARCH

  onSubmitSearch(String? value) {
    List<String> c = value != null ? value.split(' ') : [];

    List<String> d = c.where((element) => element.isEmpty == false).toList();

    keyWords = d;
  }

  removeFilterHq(String id) {
    _listSelectedHq.remove(id);
  }

  removeFilterTeam(String id) {
    _listSelectedTeam.remove(id);
  }

  removeFilterProject(String id) {
    _listSelectedProject.remove(id);
  }

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    init();
    // ever(_listSelectedHq, (value) {});
  }

  init() async {
    if (showFilter == '1') {
      await Future.delayed(Duration(milliseconds: 300));
      Get.bottomSheet(SearchFilter(), isScrollControlled: true);
    }

    _setRecentlyViewedFromStorage();
  }
}

class RecentlyViewed {
  late String uniqId;
  late String title;
  late String subtitle;

  late String teamName;

  late String moduleName;
  late String companyId;
  late String path;

  RecentlyViewed(
      {required this.companyId,
      required this.uniqId,
      required this.title,
      required this.subtitle,
      required this.teamName,
      required this.moduleName,
      required this.path});

  RecentlyViewed.fromJson(json) {
    if (json is RecentlyViewed) {
      this.uniqId = json.uniqId;
      this.companyId = json.companyId;
      this.title = json.title;
      this.teamName = json.teamName;
      this.moduleName = json.moduleName;
      this.path = json.path;
      this.subtitle = json.subtitle;
    } else {
      this.uniqId = json['uniqId'] ?? '';
      this.companyId = json?['companyId'] ?? '';
      this.title = json?['title'] ?? '';
      this.teamName = json?['teamName'] ?? '';
      this.moduleName = json?['moduleName'] ?? '';
      this.path = json?['path'] ?? '';
      this.subtitle = json?['subtitle'] ?? '';
    }
  }

  Map toJson() {
    return {
      'uniqId': this.uniqId,
      'title': this.title,
      'teamName': this.teamName,
      'moduleName': this.moduleName,
      'path': this.path,
      'companyId': this.companyId,
      'subtitle': this.subtitle
    };
  }
}
