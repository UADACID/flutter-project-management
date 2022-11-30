import 'package:cicle_mobile_f3/utils/client.dart';
import 'package:dio/dio.dart';
import 'package:get/route_manager.dart';

class MyTaskService {
  Dio client = Client.init();

  Future<Response> getList(Map<String, dynamic> params) async {
    String companyId = Get.parameters['companyId'] ?? '';
    params.addAll({'companyId': companyId});
    return client.get('/v2/tasks', queryParameters: params);
  }

  Future<Response> getDueList(Map<String, dynamic> params) async {
    String companyId = Get.parameters['companyId'] ?? '';
    params.addAll({'companyId': companyId});
    return client.get('/v2/tasks/due', queryParameters: params);
  }

  Future<Response> getScheduleList(Map<String, dynamic> params) async {
    String companyId = Get.parameters['companyId'] ?? '';
    params.addAll({'companyId': companyId});
    return client.get('/v2/tasks/schedules', queryParameters: params);
  }
}
