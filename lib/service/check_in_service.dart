import 'package:cicle_mobile_f3/utils/client.dart';
import 'package:dio/dio.dart';

class CheckInService {
  Dio client = Client.init();

  Future<Response> _getCompanyId(String moduleName, String moduleId) async {
    try {
      Response response = await client.get('/v2/$moduleName/$moduleId/company');
      if (response.data['companyId'] != null) {
        client.options.queryParameters
            .addAll({'companyId': response.data['companyId']});
      }
      return Future.value(response);
    } catch (e) {
      return Future.error(e);
    }
  }

  Future<Response> getQuestions(String checkInId) async {
    try {
      await _getCompanyId('check-ins', checkInId);
      Response response = await client.get('/v2/check-ins/$checkInId?limit=10');
      return response;
    } catch (e) {
      return Future.error(e);
    }
  }

  Future<Response> getMoreQuestions(String checkInId, dynamic params) async {
    return client.get('/v2/check-ins/$checkInId', queryParameters: params);
  }

  Future<Response> getQuestion(String questionId) async {
    try {
      await _getCompanyId('questions', questionId);
      Response response = await client.get('/api/v1/questions/$questionId');
      return response;
    } catch (e) {
      return Future.error(e);
    }
  }

  Future<Response> archiveQuestion(String questionId) async {
    return client.patch('/api/v1/questions/$questionId/archived');
  }

  Future<Response> createQuestion(String checkInId, dynamic body) async {
    try {
      await _getCompanyId('check-ins', checkInId);
      Response response = await client
          .post('/api/v1/check-ins/$checkInId/questions', data: body);
      return response;
    } catch (e) {
      return Future.error(e);
    }
  }

  Future<Response> updateQuestion(String checkInId, dynamic body) async {
    return client.patch('/api/v1/questions/$checkInId', data: body);
  }
}
