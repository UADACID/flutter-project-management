import 'package:cicle_mobile_f3/models/label_model.dart';
import 'package:cicle_mobile_f3/models/member_model.dart';

import 'package:get/get.dart';

class BoardFilterController extends GetxController {
  // NAME
  var _name = ''.obs;
  String get name => _name.value;
  set name(String value) {
    _name.value = value;
  }

  // LABELS
  var _selectedLabels = <LabelModel>[].obs;
  List<LabelModel> get selectedLabels => _selectedLabels;
  set selectedLabels(List<LabelModel> value) {
    _selectedLabels.value = [...value];
  }

  addSelectedLabel(LabelModel label) {
    _selectedLabels.add(label);
  }

  removeLabel(LabelModel value) {
    int getIndex =
        _selectedLabels.indexWhere((element) => element.sId == value.sId);
    if (getIndex >= 0) {
      _selectedLabels.removeAt(getIndex);
    }
  }

  // MEMBERS
  var _selectedMembers = <MemberModel>[].obs;

  List<MemberModel> get selectedMembers => _selectedMembers;
  set selectedMembers(List<MemberModel> value) {
    _selectedMembers.value = [...value];
  }

  addSelectedMember(MemberModel member) {
    _selectedMembers.add(member);
  }

  removeMember(MemberModel value) {
    int getIndex =
        _selectedMembers.indexWhere((element) => element.sId == value.sId);
    _selectedMembers.removeAt(getIndex);
  }

  // Due
  var _isDueToday = false.obs;
  bool get isDueToday => _isDueToday.value;
  set isDueToday(bool value) {
    _isDueToday.value = value;
  }

  var _isDueSoon = false.obs;
  bool get isDueSoon => _isDueSoon.value;
  set isDueSoon(bool value) {
    _isDueSoon.value = value;
  }

  var _isOverDue = false.obs;
  bool get isOverDue => _isOverDue.value;
  set isOverDue(bool value) {
    _isOverDue.value = value;
  }

  // RESET ALL
  reset() {
    name = '';
    _selectedLabels.clear();
    _selectedMembers.clear();
    _isDueToday.value = false;
    _isDueSoon.value = false;
    _isOverDue.value = false;
  }
}
