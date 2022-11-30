import 'package:cicle_mobile_f3/models/edit_menu_model.dart';
import 'package:get/get.dart';

class MenuController extends GetxController {
  var _listMenu = <MenuModel>[
    MenuModel(isActive: true, title: 'Group Chat'),
    MenuModel(isActive: true, title: 'Blast'),
    MenuModel(isActive: true, title: 'Schedule'),
    MenuModel(isActive: true, title: 'Board'),
    MenuModel(isActive: true, title: 'Check-in'),
    MenuModel(isActive: true, title: 'Docs & Files'),
  ].obs;

  List<MenuModel> get listMenu => _listMenu;

  List<MenuModel> get filterListMenu {
    List<MenuModel> tempList =
        _listMenu.where((item) => item.isActive == true).toList();
    return tempList;
  }

  setListMenu(List<MenuModel> list) {
    _listMenu.value = [...list];
  }
}
