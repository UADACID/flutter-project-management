import 'package:cicle_mobile_f3/controllers/company_controller.dart';

import 'package:cicle_mobile_f3/models/notif_as_cheers_model.dart';
import 'package:cicle_mobile_f3/service/notification_service.dart';
import 'package:cicle_mobile_f3/utils/constant.dart';
// ignore: implementation_imports
import 'package:darq/src/extensions/distinct.dart';
import 'package:get/get.dart';

class CheersSumaryController extends GetxController {
  NotificationService _notificationService = NotificationService();
  CompanyController _companyController = Get.put(CompanyController());

  String _nextLink = '';

  var _isLoading = false.obs;
  bool get isLoading => _isLoading.value;
  set isLoading(bool value) {
    _isLoading.value = value;
  }

  var _errorMessage = ''.obs;
  String get errorMessage => _errorMessage.value;
  set errorMessage(String value) {
    _errorMessage.value = value;
  }

  var _list = <NotifAsCheersModel>[].obs;
  List<NotifAsCheersModel> get list => _list;
  set list(List<NotifAsCheersModel> value) {
    _list.value = [...value];
  }

  Future<List<NotifAsCheersModel>> getData(String url) async {
    try {
      errorMessage = '';
      final response = await _notificationService.getNotifAsCheer(url);

      List<NotifAsCheersModel> _tempList = [];
      if (response.data['data'] != null) {
        response.data['data'].forEach((jsonItem) {
          NotifAsCheersModel item = NotifAsCheersModel.fromJson(jsonItem);
          _tempList.add(item);
        });
      }

      if (response.data['links'] != null &&
          response.data['links']['next'] != null) {
        _nextLink = response.data['links']['next'];
      }
      return Future.value(_tempList);
    } catch (e) {
      print(e);
      errorMessage = 'error to get cheers from server';
      return Future.value([]);
    }
  }

  Future<void> refresh() async {
    String _initialUrl =
        "${Env.BASE_URL}/api/v1/cheers?limit=5&page=1&sortBy=updatedAt&orderBy=desc&companyId=${_companyController.selectedCompanyId}";

    isLoading = true;
    List<NotifAsCheersModel> getList = await getData(_initialUrl);
    isLoading = false;
    list = getList;
    return Future.value(true);
  }

  Future<void> getMore() async {
    List<NotifAsCheersModel> getList = await getData(_nextLink);
    if (getList.isNotEmpty) {
      list = [...list, ...getList].distinct((d) => d.sId).toList();
    }

    return Future.value(true);
  }

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    refresh();
  }
}
