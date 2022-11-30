import 'package:cicle_mobile_f3/controllers/my_task_blast_done_controller.dart';
import 'package:cicle_mobile_f3/controllers/my_task_check_in_done_controller.dart';
import 'package:cicle_mobile_f3/controllers/my_task_kanban_all_controller.dart';
import 'package:cicle_mobile_f3/controllers/my_task_kanban_done_controller.dart';
import 'package:get/get.dart';

import 'my_task_blast_all_controller.dart';
import 'my_task_check_in_all_controller.dart';
import 'my_task_controller.dart';

class TabMyTaskController extends GetxController {
  MyTaskController _myTaskController = Get.put(MyTaskController());

  // check-in
  MyTaskCheckInAllController _myTaskCheckInAllController =
      Get.put(MyTaskCheckInAllController());
  MyTaskCheckInDoneController _myTaskCheckInDoneController =
      Get.put(MyTaskCheckInDoneController());

  // blast
  MyTaskBlastDoneController _myTaskBlastDoneController =
      Get.put(MyTaskBlastDoneController());
  MyTaskBlastAllController _myTaskBlastAllController =
      Get.put(MyTaskBlastAllController());

  // kanban
  MyTaskKanbanDoneController _myTaskKanbanDoneController =
      Get.put(MyTaskKanbanDoneController());
  MyTaskKanbanAllController _myTaskKanbanAllController =
      Get.put(MyTaskKanbanAllController());

  var _activeTabIndex = 0.obs;
  int get activeTabIndex => _activeTabIndex.value;
  set activeTabIndex(int value) {
    _activeTabIndex.value = value;
  }

  onChangeTabIndex(int index) {
    bool isShowCompleteTask = _myTaskController.showCompleteTask;
    actionForGetDataByTabAndStatus(index, isShowCompleteTask);
  }

  onChangeShowComplete(bool value) {
    actionForGetDataByTabAndStatus(activeTabIndex, value);
  }

  actionForGetDataByTabAndStatus(int tabIndex, bool taskStatus) {
    if (!taskStatus) {
      print('action all task');
      switch (tabIndex) {
        case 0:
          _myTaskKanbanAllController.init();
          break;
        case 1:
          _myTaskBlastAllController.init();
          break;
        case 2:
          _myTaskCheckInAllController.init();
          break;
        case 3:
          break;
        default:
      }
    } else {
      print('action done task');
      switch (tabIndex) {
        case 0:
          _myTaskKanbanDoneController.init();
          break;
        case 1:
          _myTaskBlastDoneController.init();
          break;
        case 2:
          _myTaskCheckInDoneController.init();
          break;
        case 3:
          break;
        default:
      }
    }
  }

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    _myTaskKanbanAllController.init();
    ever(_activeTabIndex, onChangeTabIndex);
    ever(_myTaskController.showComplete, onChangeShowComplete);
  }
}
