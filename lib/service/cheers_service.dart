import 'package:cicle_mobile_f3/utils/client.dart';
import 'package:dio/dio.dart';

class CheersService {
  Dio client = Client.init();

  String dynamicCompanyId = '';

  Future<Response> addCheerByModule(String url, dynamic body) async {
    if (dynamicCompanyId != '') {
      client.options.queryParameters.addAll({'companyId': dynamicCompanyId});
    }
    return client.post(url, data: body);
  }

  Future<Response> deleteCheerByModule(String url) async {
    if (dynamicCompanyId != '') {
      client.options.queryParameters.addAll({'companyId': dynamicCompanyId});
    }
    return client.delete(url);
  }
}
