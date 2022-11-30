import 'package:cicle_mobile_f3/utils/client.dart';
import 'package:dio/dio.dart';

class TeamDetailService {
  Dio client = Client.init();

  String dynamicCompanyId = '';

  Future<Response> _getCompanyId(String moduleName, String moduleId) async {
    try {
      Response response = await client.get('/v2/$moduleName/$moduleId/company');
      // Response response = await client.get('http://httpstat.us/500');
      if (response.data['companyId'] != null) {
        dynamicCompanyId = response.data['companyId'];

        client.options.queryParameters
            .addAll({'companyId': response.data['companyId']});
      }
      return response;
    } catch (e) {
      return Future.error(e);
    }
  }

  Future<Response> getTeam(String teamId, CancelToken cancelToken) async {
    try {
      await _getCompanyId('teams', teamId);
      Response response = await client.get('/api/v1/teams/$teamId',
          queryParameters: {"withOccurrences": 1}, cancelToken: cancelToken);
      // Response response = await client.get('http://httpstat.us/500');
      return response;
    } catch (e) {
      return Future.error(e);
      //  Error(e);
    }
  }

  Future<Response> updateTeam(String teamId, dynamic data) async {
    return client.patch('/api/v1/teams/$teamId', data: data);
    // return client.get('http://httpstat.us/500');
  }

  Future<Response> addMembers(String teamId, dynamic data) async {
    return client.post('/v2/teams/$teamId/members', data: data);
    // return client.get('http://httpstat.us/500');
  }
}
