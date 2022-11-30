import 'package:cicle_mobile_f3/utils/client.dart';
import 'package:dio/dio.dart';

class BlastService {
  Dio client = Client.init();

  String dynamicCompanyId = '';

  Future<Response> _getCompanyId(String moduleName, String moduleId) async {
    try {
      Response response = await client.get('/v2/$moduleName/$moduleId/company');
      if (response.data['companyId'] != null) {
        dynamicCompanyId = response.data['companyId'];

        client.options.queryParameters
            .addAll({'companyId': response.data['companyId']});
      }
      return Future.value(response);
    } catch (e) {
      return Future.error(e);
    }
  }

  Future<Response> getPosts(String blastId) async {
    try {
      await _getCompanyId('blasts', blastId);
      final Response response =
          await client.get('/v2/blasts/$blastId?limit=10');
      return response;
    } catch (e) {
      return Future.error(e);
    }
  }

  Future<Response> getMorePosts(String blastId, dynamic params) async {
    return client.get('/v2/blasts/$blastId', queryParameters: params);
  }

  Future<Response> archivePost(String postId) async {
    return client.patch('/api/v1/posts/$postId/archived');
  }

  Future<Response> getPost(String postId) async {
    await _getCompanyId('posts', postId);
    return client.get('/api/v1/posts/$postId');
  }

  Future<Response> createPost(String blastId, dynamic body) async {
    try {
      await _getCompanyId('blasts', blastId);
      final Response response =
          await client.post('/api/v1/blasts/$blastId/posts', data: body);
      return response;
    } catch (e) {
      return Future.error(e);
    }
  }

  Future<Response> updatePost(String postId, dynamic body) async {
    return client.patch('/api/v1/posts/$postId', data: body);
  }

  Future<Response> toggleMembers(String postId, dynamic body) async {
    return client.post('/v2/posts/$postId/members', data: body);
  }

  Future<Response> updateCompleteStatus(String postId, dynamic body) async {
    return client.patch('/api/v1/posts/$postId/complete', data: body);
  }
}
