import 'package:cicle_mobile_f3/utils/client.dart';
import 'package:cicle_mobile_f3/utils/helpers.dart';
import 'package:dio/dio.dart';
import 'package:get/route_manager.dart';

class CommentService {
  Dio client = Client.init();
  String dynamicCompanyId = '';

  Future<Response> _getCompanyId(String moduleName, String moduleId) async {
    try {
      List<String> removeQueryParamsFromModuleId = moduleId.split('?');
      String finalModuleId = removeQueryParamsFromModuleId[0];

      Response response =
          await client.get('/v2/$moduleName/$finalModuleId/company');
      if (response.data['companyId'] != null) {
        dynamicCompanyId = response.data['companyId'];
        client.options.queryParameters
            .addAll({'companyId': response.data['companyId']});
      }

      return response;
    } catch (e) {
      print(e);

      return Future.error(e);
    }
  }

  Future<Response> getComments(String baseUrl, dynamic params) async {
    try {
      List<String> spliteUri = Get.currentRoute.split('/');

      String moduleName = spliteUri.length > 5 ? spliteUri[5] : '';
      String moduleId = spliteUri.length > 6 ? spliteUri[6] : '';

      if (moduleName != '' && moduleId != '') {
        if (moduleName == 'occurrences') {
          dynamicCompanyId = Get.parameters['companyId'] ?? '';
          client.options.queryParameters
              .addAll({'companyId': dynamicCompanyId});
        } else {
          await _getCompanyId(moduleNameAdapter(moduleName), moduleId);
        }
      }

      Response response = await client.get(baseUrl, queryParameters: params);
      return response;
    } catch (e) {
      return Future.error(e);
    }
  }

  Future<Response> createComment(String baseUrl, dynamic body) async {
    return client.post('$baseUrl', data: body);
  }

  Future<Response> editComment(
      String baseUrl, String commentId, dynamic body) async {
    return client.patch('$baseUrl/$commentId', data: body);
  }

  Future<Response> archiveComment(String baseUrl, String commentId) async {
    return client.delete('$baseUrl/$commentId');
  }

  Future<Response> addCheerComment(
      String baseUrl, String commentId, dynamic body) async {
    return client.post('$baseUrl/$commentId/cheers', data: body);
  }

  Future<Response> deleteCheersComment(
      String baseUrl, String commentId, String cheersId) async {
    return client.delete('$baseUrl/$commentId/cheers/$cheersId');
  }

  Future<Response> getComment(String commentId, String teamId) async {
    try {
      List<String> spliteUri = Get.currentRoute.split('/');

      String moduleName = spliteUri.length > 5 ? spliteUri[5] : '';
      String moduleId = spliteUri.length > 6 ? spliteUri[6] : '';
      if (moduleName != '' && moduleId != '') {
        if (moduleName == 'occurrences') {
          dynamicCompanyId = Get.parameters['companyId'] ?? '';
          client.options.queryParameters
              .addAll({'companyId': dynamicCompanyId});
        } else {
          await _getCompanyId(moduleNameAdapter(moduleName), moduleId);
        }
      }
      Response response =
          await client.get('/v2/comments/$commentId?teamId=$teamId');
      return response;
    } catch (e) {
      return Future.error(e);
    }
  }

  Future<Response> getCommentV1(String baseUrl) async {
    return client.get(baseUrl);
  }

  Future<Response> getDiscussion(String commentId, dynamic params) async {
    return client.get('/v2/comments/$commentId/discussions',
        queryParameters: params);
  }

  Future<Response> getTeamMembers(String teamId) async {
    return client.get('/v2/teams/$teamId/members');
  }

  Future<Response> getParentData(String url) async {
    return client.get(url);
  }
}
