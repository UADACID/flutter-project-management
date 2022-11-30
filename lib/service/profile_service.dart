import 'package:cicle_mobile_f3/utils/client.dart';
import 'package:dio/dio.dart';

class ProfileService {
  Dio client = Client.init();

  Future<Response> getUser(String userId) async {
    return client.get('/api/v1/users/$userId');
    // return client.get('http://httpstat.us/500');
  }

  Future<Response> updateUser(String userId, dynamic body) async {
    return client.patch('/api/v1/users/$userId', data: body);
    // return client.get('http://httpstat.us/500');
  }

  Future<Response> uploadAvatar(String userId, dynamic body) async {
    String path = '/api/v1/users/$userId/photo';

    FormData formData = FormData.fromMap({
      "file": await MultipartFile.fromFile(body['uri'], filename: body['name']),
    });
    return client.post(path, data: formData);
    // return client.get('http://httpstat.us/500');
  }
}
